// ============================================
// AI CHATBOT - OPENROUTER INTEGRATION
// ============================================
// deno-lint-ignore-file no-explicit-any

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const OPENROUTER_API_KEY = Deno.env.get('OPENROUTER_API_KEY') || ''
const SUPABASE_URL = Deno.env.get('SUPABASE_URL') || ''
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || ''

interface ChatRequest {
  conversation_id: string
  message: string
}

// Persona configurations
const PERSONAS = {
  wise_mentor: {
    name: 'Pak Arief',
    model: 'anthropic/claude-3.5-sonnet',
    system_prompt: `Anda adalah Pak Arief, seorang mentor keuangan yang bijaksana dan berpengalaman. 
Gaya komunikasi: formal, penuh empati, memberikan nasihat berdasarkan pengalaman.
Fokus: edukasi mendalam, pengelolaan risiko, perencanaan jangka panjang.
Bahasa: Indonesia formal tapi hangat.
Anda membantu user mencatat transaksi dan memberikan insight finansial.`
  },
  friendly_companion: {
    name: 'Dina',
    model: 'openai/gpt-4-turbo',
    system_prompt: `Anda adalah Dina, teman finansial yang friendly dan supportive.
Gaya komunikasi: casual, penuh semangat, menggunakan emoji sesekali.
Fokus: motivasi, habit building, goal tracking.
Bahasa: Indonesia casual, seperti teman sebaya.
Anda membantu user mencatat transaksi dengan cara yang menyenangkan.`
  },
  professional_advisor: {
    name: 'Sarah',
    model: 'google/gemini-pro-1.5',
    system_prompt: `Anda adalah Sarah, financial advisor profesional.
Gaya komunikasi: efisien, data-driven, to the point.
Fokus: analisis mendalam, rekomendasi investasi, optimasi portfolio.
Bahasa: Indonesia profesional.
Anda membantu user dengan analisis finansial yang detail.`
  }
}

// Transaction intent detection
function extractTransactionIntent(message: string): {
  intent: string | null
  data: any | null
} {
  const lowerMsg = message.toLowerCase()
  
  // Expense detection
  const expenseKeywords = ['beli', 'bayar', 'buat', 'keluar', 'habis', 'spend']
  const isExpense = expenseKeywords.some(kw => lowerMsg.includes(kw))
  
  // Income detection
  const incomeKeywords = ['terima', 'dapat', 'gaji', 'bonus', 'income']
  const isIncome = incomeKeywords.some(kw => lowerMsg.includes(kw))
  
  if (!isExpense && !isIncome) return { intent: null, data: null }
  
  // Extract amount (e.g., "50000", "50rb", "50k")
  const amountMatch = message.match(/(\d+\.?\d*)\s?(rb|ribu|k|juta|jt)?/i)
  if (!amountMatch) return { intent: null, data: null }
  
  let amount = parseFloat(amountMatch[1])
  const unit = amountMatch[2]?.toLowerCase()
  
  if (unit === 'rb' || unit === 'ribu' || unit === 'k') {
    amount *= 1000
  } else if (unit === 'juta' || unit === 'jt') {
    amount *= 1000000
  }
  
  return {
    intent: 'record_transaction',
    data: {
      type: isExpense ? 'expense' : 'income',
      amount: amount,
      description: message,
      // Category akan dipilih oleh user di Flutter
    }
  }
}

serve(async (req: Request) => {
  try {
    // CORS headers
    if (req.method === 'OPTIONS') {
      return new Response('ok', {
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'POST',
          'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
        }
      })
    }

    const { conversation_id, message }: ChatRequest = await req.json()

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

    // Get conversation context
    const { data: conversation, error: convError } = await supabase
      .from('chat_conversations')
      .select('user_id, persona, title')
      .eq('id', conversation_id)
      .single()

    if (convError) throw new Error('Conversation not found')

    // Get recent messages for context
    const { data: recentMessages } = await supabase
      .from('chat_messages')
      .select('role, content')
      .eq('conversation_id', conversation_id)
      .order('created_at', { ascending: false })
      .limit(10)

    const messageHistory = recentMessages?.reverse() || []

    // Get persona config
    const personaConfig = PERSONAS[conversation.persona as keyof typeof PERSONAS] || PERSONAS.wise_mentor

    // Detect transaction intent
    const { intent, data: extractedData } = extractTransactionIntent(message)

    // Build messages for OpenRouter
    const messages = [
      {
        role: 'system',
        content: personaConfig.system_prompt + '\n\nJika user menyebutkan transaksi (beli, bayar, terima, dll), bantu identifikasi jumlah dan jenis transaksi (income/expense).'
      },
      ...messageHistory.map(msg => ({
        role: msg.role,
        content: msg.content
      })),
      {
        role: 'user',
        content: message
      }
    ]

    // Call OpenRouter API
    const openRouterResponse = await fetch('https://openrouter.ai/api/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${OPENROUTER_API_KEY}`,
        'Content-Type': 'application/json',
        'HTTP-Referer': 'https://moneystocks.app',
        'X-Title': 'MoneyStocks AI Chatbot'
      },
      body: JSON.stringify({
        model: personaConfig.model,
        messages: messages,
        temperature: 0.7,
        max_tokens: 500,
      })
    })

    if (!openRouterResponse.ok) {
      throw new Error(`OpenRouter API error: ${openRouterResponse.statusText}`)
    }

    const aiResponse = await openRouterResponse.json()
    const aiMessage = aiResponse.choices[0].message.content

    // Save user message
    await supabase.from('chat_messages').insert({
      conversation_id,
      role: 'user',
      content: message,
      intent: intent,
      extracted_data: extractedData
    })

    // Save AI response
    await supabase.from('chat_messages').insert({
      conversation_id,
      role: 'assistant',
      content: aiMessage,
      persona: conversation.persona,
    })

    // Update conversation last activity
    await supabase
      .from('chat_conversations')
      .update({ updated_at: new Date().toISOString() })
      .eq('id', conversation_id)

    return new Response(
      JSON.stringify({
        message: aiMessage,
        persona: personaConfig.name,
        intent: intent,
        extracted_data: extractedData
      }),
      {
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*'
        }
      }
    )

  } catch (error: any) {
    console.error('Error:', error)
    return new Response(
      JSON.stringify({ 
        error: error?.message || 'Internal server error'
      }),
      {
        status: 500,
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*'
        }
      }
    )
  }
})
