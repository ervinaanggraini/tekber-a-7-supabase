// ============================================
// FETCH NEWS API FOR INVESTMENT COURSES
// ============================================
// deno-lint-ignore-file no-explicit-any

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const NEWS_API_KEY = Deno.env.get('NEWS_API_KEY') || ''
const SUPABASE_URL = Deno.env.get('SUPABASE_URL') || ''
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || ''

interface NewsRequest {
  course_id: string
}

serve(async (req: Request) => {
  try {
    // CORS headers
    if (req.method === 'OPTIONS') {
      return new Response('ok', {
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST',
          'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
        }
      })
    }

    const { course_id }: NewsRequest = await req.json()

    if (!course_id) {
      throw new Error('Missing course_id')
    }

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)

    // Get course configuration
    const { data: course, error: courseError } = await supabase
      .from('courses')
      .select('title, content')
      .eq('id', course_id)
      .single()

    if (courseError || !course) {
      throw new Error('Course not found')
    }

    const config = course.content as {
      api_source: string
      query: string
      language: string
      country?: string
      category?: string
      pageSize: number
    }

    // Build News API URL
    const params = new URLSearchParams({
      q: config.query,
      language: config.language,
      pageSize: config.pageSize.toString(),
      sortBy: 'publishedAt',
      apiKey: NEWS_API_KEY
    })

    if (config.country) params.append('country', config.country)
    if (config.category) params.append('category', config.category)

    const newsApiUrl = config.country 
      ? `https://newsapi.org/v2/top-headlines?${params.toString()}`
      : `https://newsapi.org/v2/everything?${params.toString()}`

    // Fetch news
    const newsResponse = await fetch(newsApiUrl)

    if (!newsResponse.ok) {
      throw new Error(`News API error: ${newsResponse.statusText}`)
    }

    const newsData = await newsResponse.json()

    if (newsData.status !== 'ok') {
      throw new Error(`News API error: ${newsData.message || 'Unknown error'}`)
    }

    // Format articles
    const articles = newsData.articles.map((article: any) => ({
      title: article.title,
      description: article.description,
      url: article.url,
      image_url: article.urlToImage,
      published_at: article.publishedAt,
      source: article.source.name,
      author: article.author,
    }))

    return new Response(
      JSON.stringify({
        success: true,
        course_title: course.title,
        total_articles: articles.length,
        articles: articles
      }),
      {
        headers: {
          'Content-Type': 'application/json',
          'Access-Control-Allow-Origin': '*'
        }
      }
    )

  } catch (error: any) {
    console.error('News API Error:', error)
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
