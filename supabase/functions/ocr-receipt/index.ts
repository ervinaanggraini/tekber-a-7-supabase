// ============================================
// OCR RECEIPT PROCESSING - OPENROUTER VISION
// ============================================
// deno-lint-ignore-file no-explicit-any

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const OPENROUTER_API_KEY = Deno.env.get('OPENROUTER_API_KEY') || ''
const SUPABASE_URL = Deno.env.get('SUPABASE_URL') || ''
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || ''

interface OCRRequest {
  image_url: string
  user_id: string
}

interface OCRResult {
  merchant_name: string | null
  total_amount: number
  items: Array<{
    name: string
    quantity: number
    price: number
  }>
  date: string | null
  confidence: number
  raw_text: string
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

    const { image_url, user_id }: OCRRequest = await req.json()

    if (!image_url || !user_id) {
      throw new Error('Missing required fields: image_url, user_id')
    }

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

    // Call OpenRouter Vision API
    const openRouterResponse = await fetch('https://openrouter.ai/api/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${OPENROUTER_API_KEY}`,
        'Content-Type': 'application/json',
        'HTTP-Referer': 'https://moneystocks.app',
        'X-Title': 'MoneyStocks OCR Receipt'
      },
      body: JSON.stringify({
        model: 'google/gemini-pro-vision',
        messages: [
          {
            role: 'user',
            content: [
              {
                type: 'text',
                text: `Analyze this receipt image and extract the following information in JSON format:
{
  "merchant_name": "nama toko/merchant",
  "total_amount": total_belanja_dalam_angka,
  "items": [
    {
      "name": "nama_item",
      "quantity": jumlah,
      "price": harga_satuan
    }
  ],
  "date": "tanggal_transaksi (YYYY-MM-DD jika ada)",
  "confidence": nilai_kepercayaan_0_sampai_1,
  "raw_text": "semua_text_yang_terbaca"
}

IMPORTANT: Return ONLY valid JSON, no other text.
If you cannot read certain fields, use null or empty array.
For Indonesian receipts, merchant_name and item names should be in Indonesian.`
              },
              {
                type: 'image_url',
                image_url: {
                  url: image_url
                }
              }
            ]
          }
        ],
        temperature: 0.1,
        max_tokens: 1000,
      })
    })

    if (!openRouterResponse.ok) {
      const errorText = await openRouterResponse.text()
      throw new Error(`OpenRouter API error: ${openRouterResponse.statusText} - ${errorText}`)
    }

    const aiResponse = await openRouterResponse.json()
    const aiMessage = aiResponse.choices[0].message.content

    // Parse JSON response
    let ocrResult: OCRResult
    try {
      // Try to extract JSON from response
      const jsonMatch = aiMessage.match(/\{[\s\S]*\}/)
      if (jsonMatch) {
        ocrResult = JSON.parse(jsonMatch[0])
      } else {
        throw new Error('No JSON found in response')
      }
    } catch (parseError) {
      console.error('Failed to parse AI response:', aiMessage)
      throw new Error('Failed to parse OCR result')
    }

    // Validate and ensure required fields
    if (!ocrResult.total_amount || ocrResult.total_amount <= 0) {
      throw new Error('Could not extract valid total amount from receipt')
    }

    // Get suggested category based on merchant name or items
    const suggestedCategory = await suggestCategory(supabase, ocrResult.merchant_name, ocrResult.items)

    // Store OCR result (optional: untuk tracking & analytics)
    const { data: ocrRecord } = await supabase.from('ocr_processing_logs').insert({
      user_id,
      image_url,
      merchant_name: ocrResult.merchant_name,
      total_amount: ocrResult.total_amount,
      items: ocrResult.items,
      confidence: ocrResult.confidence,
      raw_text: ocrResult.raw_text,
      suggested_category_id: suggestedCategory?.id,
    }).select().single()

    return new Response(
      JSON.stringify({
        success: true,
        data: {
          merchant_name: ocrResult.merchant_name,
          total_amount: ocrResult.total_amount,
          items: ocrResult.items,
          date: ocrResult.date,
          confidence: ocrResult.confidence,
          suggested_category: suggestedCategory,
          ocr_log_id: ocrRecord?.id
        }
      }),
      {
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*'
        }
      }
    )

  } catch (error: any) {
    console.error('OCR Error:', error)
    return new Response(
      JSON.stringify({
        success: false,
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

// Helper function to suggest category
async function suggestCategory(
  supabase: any,
  merchantName: string | null,
  items: Array<{ name: string }> = []
): Promise<{ id: string; name: string; icon: string; color: string } | null> {
  // Category keywords mapping
  const categoryKeywords: Record<string, string[]> = {
    'Makanan & Minuman': ['restoran', 'cafe', 'kopi', 'makan', 'food', 'burger', 'pizza', 'nasi', 'minuman', 'bakery'],
    'Transportasi': ['grab', 'gojek', 'taxi', 'bensin', 'pertamina', 'parkir', 'tol', 'transport'],
    'Belanja': ['indomaret', 'alfamart', 'supermarket', 'hypermart', 'mall', 'toko', 'superindo'],
    'Tagihan': ['listrik', 'air', 'pdam', 'telkom', 'internet', 'wifi', 'token', 'pln'],
    'Kesehatan': ['apotek', 'farmasi', 'kimia farma', 'guardian', 'rumah sakit', 'klinik', 'dokter'],
    'Pendidikan': ['buku', 'gramedia', 'sekolah', 'kursus', 'les', 'bimbel'],
  }

  const searchText = `${merchantName} ${items.map(i => i.name).join(' ')}`.toLowerCase()

  // Find matching category
  for (const [categoryName, keywords] of Object.entries(categoryKeywords)) {
    if (keywords.some(kw => searchText.includes(kw))) {
      const { data: category } = await supabase
        .from('categories')
        .select('id, name, icon, color')
        .eq('name', categoryName)
        .eq('type', 'expense')
        .eq('is_system', true)
        .single()

      if (category) return category
    }
  }

  // Default: return "Lainnya" category
  const { data: defaultCategory } = await supabase
    .from('categories')
    .select('id, name, icon, color')
    .eq('name', 'Lainnya')
    .eq('type', 'expense')
    .eq('is_system', true)
    .single()

  return defaultCategory || null
}
