// ============================================
// AI CHATBOT - OPENROUTER INTEGRATION (FREE TIER)
// ============================================
// deno-lint-ignore-file no-explicit-any

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const OPENROUTER_API_KEY = Deno.env.get('OPENROUTER_API_KEY') || ''
const SUPABASE_URL = Deno.env.get('SUPABASE_URL') || ''
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || ''

interface ChatRequest {
  conversationId?: string
  conversation_id?: string
  message: string
  imageUrl?: string
}

// ============================================
// KONFIGURASI PERSONA (MODEL GRATIS)
// ============================================
const PERSONAS = {
  finny: {
    name: 'Finny',
    title: 'The Angry Mom',
    // Menggunakan Qwen 2.5 7B untuk text, Google Gemini Flash untuk vision
    model: 'qwen/qwen-2.5-7b-instruct:free',
    visionModel: 'google/gemini-flash-1.5-8b', 
    system_prompt: `Anda adalah Finny, seorang 'Angry Mom' (Ibu yang galak dan tegas) dalam urusan keuangan.
    
    Karakteristik:
    - Galak, protektif, dan sangat cerewet soal pengeluaran tidak penting.
    - Jika user mencatat pengeluaran boros (jajan, hobi mahal), marahi mereka secara natural seperti ibu memarahi anaknya ("Uang itu dicari susah loh!", "Beli ginian lagi?! Hemat dikit napa!").
    - Jika user menabung atau berhemat, puji tapi dengan nada gengsi ("Nah gitu dong, baru anak ibu.").
    - Selalu ingatkan betapa pentingnya uang darurat.
    
    Gaya Bahasa: Indonesia sehari-hari, ekspresif, tegas, kadang menggunakan caps lock untuk penekanan.`
  },
  mona: {
    name: 'Mona',
    title: 'The Supportive Cheerleader',
    // Menggunakan Phi-3 Medium untuk text, Google Gemini Flash untuk vision
    model: 'microsoft/phi-3-medium-128k-instruct:free',
    visionModel: 'google/gemini-flash-1.5-8b',
    system_prompt: `Anda adalah Mona, teman yang sangat suportif dan ceria ('Cheerleader').
    
    Karakteristik:
    - Selalu positif, penuh semangat, dan mengapresiasi setiap langkah kecil user.
    - Gunakan banyak emoji (💖, ✨, 🎉, 💪).
    - Jika user boros, jangan dimarahi, tapi ajak kembali ke track dengan lembut ("Gapapa bestie, besok kita hemat ya! Semangat!").
    - Fokus pada motivasi dan membangun kebiasaan baik.
    
    Gaya Bahasa: Indonesia gaul/akrab, friendly, seperti teman curhat yang baik.`
  },
  vesto: {
    name: 'Vesto',
    title: 'The Wise Mentor',
    // Menggunakan Mistral 7B untuk text, Google Gemini Flash untuk vision
    model: 'mistralai/mistral-7b-instruct:free',
    visionModel: 'google/gemini-flash-1.5-8b',
    system_prompt: `Anda adalah Vesto, seorang mentor bijaksana dengan aura seperti penyihir tua yang berilmu tinggi.
    
    Karakteristik:
    - Tenang, strategis, dan berwawasan luas.
    - Fokus pada pertumbuhan aset jangka panjang, investasi, dan manajemen risiko.
    - Menjelaskan konsep keuangan dengan analogi yang cerdas dan mendalam.
    - Tidak emosional, melainkan objektif, solutif, dan menenangkan.
    
    Gaya Bahasa: Indonesia formal namun hangat, bijak, terstruktur (gunakan poin-poin jika perlu).
    
    PENTING: Anda HARUS merespons sapaan atau pertanyaan user dengan jawaban yang relevan dan singkat (maksimal 2-3 kalimat). JANGAN membuat asumsi atau bertanya balik tentang hal yang tidak disebutkan user.`
  }
}

// Transaction intent detection
function extractTransactionIntent(message: string): {
  intent: string | null
  data: any | null
} {
  const lowerMsg = message.toLowerCase()
  
  // Expense detection
  const expenseKeywords = ['beli', 'bayar', 'buat', 'keluar', 'habis', 'spend', 'jajan', 'makan']
  const isExpense = expenseKeywords.some(kw => lowerMsg.includes(kw))
  
  // Income detection
  const incomeKeywords = ['terima', 'dapat', 'gaji', 'bonus', 'income', 'cuan', 'masuk']
  const isIncome = incomeKeywords.some(kw => lowerMsg.includes(kw))
  
  if (!isExpense && !isIncome) return { intent: null, data: null }
  
  // Extract amount (e.g., "50000", "50rb", "50k", "1.5jt")
  const amountMatch = message.match(/(\d+[.,]?\d*)\s?(rb|ribu|k|juta|jt)?/i)
  if (!amountMatch) return { intent: null, data: null }
  
  let amount = parseFloat(amountMatch[1].replace(',', '.')) // Handle koma
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

    const { conversationId, conversation_id, message, imageUrl }: ChatRequest = await req.json()
    
    console.log('📥 Received request:', { conversationId, conversation_id, message, imageUrl })
    
    // Support both parameter names
    const conversationIdValue = conversationId || conversation_id
    
    if (!conversationIdValue) {
      throw new Error('Missing conversationId parameter')
    }

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

    // Get conversation context
    const { data: conversation, error: convError } = await supabase
      .from('chat_conversations')
      .select('user_id, persona, title')
      .eq('id', conversationIdValue)
      .single()

    if (convError) throw new Error('Conversation not found')

    // Get recent messages for context
    const { data: recentMessages } = await supabase
      .from('chat_messages')
      .select('role, content')
      .eq('conversation_id', conversationIdValue)
      .order('created_at', { ascending: false })
      .limit(10)

    const messageHistory = recentMessages?.reverse() || []

    // Get persona config (Fallback to Vesto if invalid)
    const personaKey = conversation.persona?.toLowerCase() as keyof typeof PERSONAS
    const personaConfig = PERSONAS[personaKey] || PERSONAS.vesto

    // Detect transaction intent
    const { intent, data: extractedData } = extractTransactionIntent(message)

    // Build messages for OpenRouter
    const messages = [
      {
        role: 'system',
        content: personaConfig.system_prompt + '\n\nINSTRUKSI PENTING: Berikan respons singkat dan natural (maksimal 2-3 kalimat) sesuai kepribadianmu. Jika user hanya menyapa (hi/halo/aloo), balas dengan sapaan ramah dan tanyakan bagaimana bisa membantu. Jika user menyebutkan transaksi (beli/bayar/terima uang), identifikasi jumlahnya dan berikan komentar singkat. Jika ada gambar, deskripsikan apa yang kamu lihat dengan gaya bahasamu.'
      },
      ...messageHistory.map((msg: any) => ({
        role: msg.role,
        content: msg.content
      })),
      {
        role: 'user',
        content: imageUrl 
          ? [
              { type: 'text', text: message || 'Apa yang kamu lihat di gambar ini?' },
              { type: 'image_url', image_url: { url: imageUrl } }
            ]
          : message
      }
    ]

    // Use vision model if image is provided
    const selectedModel = imageUrl ? personaConfig.visionModel : personaConfig.model

    // Call OpenRouter API with error handling
    let aiMessage: string
    
    try {
      const openRouterResponse = await fetch('https://openrouter.ai/api/v1/chat/completions', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${OPENROUTER_API_KEY}`,
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://moneystocks.app',
          'X-Title': 'MoneyStocks AI'
        },
        body: JSON.stringify({
          model: selectedModel,
          messages: messages,
          temperature: 0.7, 
          max_tokens: 400,
        })
      })

      if (!openRouterResponse.ok) {
        const errorData = await openRouterResponse.json().catch(() => ({}))
        console.error('OpenRouter error:', errorData)
        throw new Error(`API error: ${openRouterResponse.statusText}`)
      }

      const aiResponse = await openRouterResponse.json()
      aiMessage = aiResponse.choices[0].message.content
      
      // Clean up response - remove any XML tags, [INST] tags, or weird formatting
      aiMessage = aiMessage
        .replace(/<\/?s>/g, '') // Remove <s> tags
        .replace(/\[\/s\]/g, '') // Remove [/s]
        .replace(/\[s\]/g, '') // Remove [s]
        .replace(/\[\/INST\]/g, '') // Remove [/INST]
        .replace(/\[INST\]/g, '') // Remove [INST]
        .replace(/\[\/\]/g, '') // Remove [/]
        .replace(/\[\]/g, '') // Remove []
        .trim()
      
      // If response is too long or doesn't make sense, use fallback
      if (aiMessage.length > 500 || aiMessage.includes('aku ngebut') || aiMessage.includes('aku nk beli')) {
        throw new Error('Invalid AI response')
      }
      
    } catch (apiError: any) {
      console.error('OpenRouter API failed:', apiError)
      
      // Fallback response based on persona
      const fallbackResponses = {
        finny: `Aduh, sistem AI-nya lagi sibuk nih! Tapi gapapa, Ibu tetap bisa bantu. ${intent ? 'Transaksimu sudah dicatat ya!' : 'Ada yang bisa Ibu bantu tentang keuanganmu?'} 😤`,
        mona: `Halo bestie! Maaf ya AI-nya lagi overload 😅 Tapi tenang, aku tetap di sini buat kamu! ${intent ? 'Transaksinya udah kusimpan kok! 💖' : 'Cerita aja, aku dengerin! ✨'}`,
        vesto: `Sistem AI sedang mengalami kendala teknis. ${intent ? 'Namun, transaksi Anda telah tercatat dengan baik.' : 'Saya tetap siap membantu perencanaan finansial Anda.'} 🧙‍♂️`
      }
      
      aiMessage = fallbackResponses[personaKey] || fallbackResponses.vesto
    }

    // Save user message
    const userMessageData: any = {
      conversation_id: conversationIdValue,
      role: 'user',
      content: message,
    }
    if (intent) userMessageData.intent = intent
    if (extractedData) userMessageData.extracted_data = extractedData
    if (imageUrl) userMessageData.image_url = imageUrl
    
    console.log('💾 Saving user message:', userMessageData)
    
    await supabase.from('chat_messages').insert(userMessageData)

    // Save AI response
    const assistantMessageData: any = {
      conversation_id: conversationIdValue,
      role: 'assistant',
      content: aiMessage,
    }
    if (conversation.persona) assistantMessageData.persona = conversation.persona
    
    await supabase.from('chat_messages').insert(assistantMessageData)

    // Update conversation last activity
    await supabase
      .from('chat_conversations')
      .update({ last_message_at: new Date().toISOString() })
      .eq('id', conversationIdValue)

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