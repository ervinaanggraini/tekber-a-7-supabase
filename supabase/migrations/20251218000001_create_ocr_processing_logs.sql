-- Create table for OCR processing logs
CREATE TABLE public.ocr_processing_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.user_profiles(id) ON DELETE CASCADE,
  image_url TEXT,
  merchant_name TEXT,
  total_amount DECIMAL(15,2),
  items JSONB,
  date DATE,
  confidence NUMERIC,
  raw_text TEXT,
  suggested_category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
