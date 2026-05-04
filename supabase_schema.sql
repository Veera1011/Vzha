-- VZHA Supabase Schema

-- Profiles Table (Linked to auth.users)
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Function to automatically create a profile when a user signs up
CREATE OR REPLACE FUNCTION public.handle_new_user() 
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email)
  VALUES (new.id, new.email);
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to call the function after a user is created
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- News Feed Table (For caching/storing news if needed)
CREATE TABLE news_feed (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  url TEXT NOT NULL,
  source TEXT NOT NULL,
  published_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Packages Table (For caching package info if needed)
CREATE TABLE packages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  current_version TEXT,
  latest_version TEXT,
  ecosystem TEXT NOT NULL, -- npm, pub, pip
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Alerts Table (For caching vulnerabilities if needed)
CREATE TABLE alerts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  severity TEXT NOT NULL, -- low, medium, high
  description TEXT,
  source_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Saved Items Table
CREATE TABLE saved_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  item_type TEXT NOT NULL, -- 'news', 'package', 'alert'
  item_id TEXT NOT NULL, -- The original ID or name from the external API
  item_data JSONB, -- Store minimal data (title, url, etc.) for easy display
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Set Row Level Security (RLS) on saved_items
ALTER TABLE saved_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can only view their own saved items"
ON saved_items FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own saved items"
ON saved_items FOR INSERT
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own saved items"
ON saved_items FOR DELETE
USING (auth.uid() = user_id);

-- Enable RLS on other tables (Public read access for cached data)
ALTER TABLE news_feed ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read news_feed" ON news_feed FOR SELECT USING (true);

ALTER TABLE packages ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read packages" ON packages FOR SELECT USING (true);

ALTER TABLE alerts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read alerts" ON alerts FOR SELECT USING (true);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read profiles" ON profiles FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);
