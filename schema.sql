

-- 1. Create Restaurants Table
CREATE TABLE restaurants (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    description TEXT,
    cuisine_type TEXT NOT NULL,
    price_range TEXT CHECK (price_range IN ('$', '$$', '$$$', '$$$$')) NOT NULL,
    address TEXT NOT NULL,
    city TEXT NOT NULL,
    state TEXT DEFAULT 'Georgia',
    zip_code TEXT,
    phone TEXT,
    website TEXT,
    email TEXT,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    google_maps_link TEXT,
    hours_monday TEXT,
    hours_tuesday TEXT,
    hours_wednesday TEXT,
    hours_thursday TEXT,
    hours_friday TEXT,
    hours_saturday TEXT,
    hours_sunday TEXT,
    is_premium BOOLEAN DEFAULT FALSE,
    featured BOOLEAN DEFAULT FALSE,
    rating DECIMAL(2,1) CHECK (rating >= 1 AND rating <= 5),
    review_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_restaurants_city ON restaurants(city);
CREATE INDEX idx_restaurants_cuisine_type ON restaurants(cuisine_type);
CREATE INDEX idx_restaurants_is_premium ON restaurants(is_premium);
CREATE INDEX idx_restaurants_featured ON restaurants(featured);
CREATE INDEX idx_restaurants_rating ON restaurants(rating);
CREATE INDEX idx_restaurants_location ON restaurants(latitude, longitude);

-- Create trigger for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_restaurants_updated_at BEFORE UPDATE ON restaurants
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 2. Create Restaurant Images Table
CREATE TABLE restaurant_images (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    restaurant_id UUID REFERENCES restaurants(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    alt_text TEXT,
    is_primary BOOLEAN DEFAULT FALSE,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_restaurant_images_restaurant_id ON restaurant_images(restaurant_id);
CREATE INDEX idx_restaurant_images_is_primary ON restaurant_images(is_primary);

-- 3. Create Restaurant Features Table
CREATE TABLE restaurant_features (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    restaurant_id UUID REFERENCES restaurants(id) ON DELETE CASCADE,
    feature_name TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_restaurant_features_restaurant_id ON restaurant_features(restaurant_id);
CREATE INDEX idx_restaurant_features_feature_name ON restaurant_features(feature_name);

-- Add constraint to ensure valid feature names
ALTER TABLE restaurant_features ADD CONSTRAINT valid_feature_names 
CHECK (feature_name IN (
    'outdoor_seating', 'delivery', 'takeout', 'live_music', 'pet_friendly',
    'wheelchair_accessible', 'parking_available', 'wifi', 'reservations',
    'happy_hour', 'brunch', 'late_night', 'craft_cocktails', 'wine_bar',
    'beer_garden', 'rooftop', 'waterfront', 'historic', 'family_friendly',
    'date_night', 'business_lunch', 'catering', 'private_dining'
));

-- 4. Create Categories Table
CREATE TABLE categories (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    slug TEXT NOT NULL UNIQUE,
    description TEXT,
    icon_name TEXT,
    restaurant_count INTEGER DEFAULT 0,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert default categories
INSERT INTO categories (name, slug, description, icon_name, display_order) VALUES
('Southern Comfort', 'southern-comfort', 'Classic Georgia comfort food', 'utensils', 1),
('BBQ & Smokehouse', 'bbq-smokehouse', 'Authentic Georgia BBQ', 'fire', 2),
('Coastal Seafood', 'coastal-seafood', 'Fresh from Georgia coast', 'fish', 3),
('International Fusion', 'international-fusion', 'Global flavors, Georgia style', 'globe', 4),
('Farm-to-Table', 'farm-to-table', 'Local, fresh ingredients', 'leaf', 5),
('Food Trucks', 'food-trucks', 'Mobile culinary adventures', 'truck', 6),
('Fine Dining', 'fine-dining', 'Premium dining experiences', 'star', 7),
('Family Friendly', 'family-friendly', 'Great for the whole family', 'users', 8),
('Date Night', 'date-night', 'Romantic dining spots', 'heart', 9),
('Pizza & Italian', 'pizza-italian', 'From wood-fired to NY style', 'pizza-slice', 10),
('Quick Bites', 'quick-bites', 'Fast, fresh, and delicious', 'clock', 11),
('Coffee & Desserts', 'coffee-desserts', 'Sweet treats and caffeine', 'coffee', 12);

-- 5. Create Regions Table
CREATE TABLE regions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    slug TEXT NOT NULL UNIQUE,
    description TEXT,
    restaurant_count INTEGER DEFAULT 0,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert Georgia regions
INSERT INTO regions (name, slug, description, latitude, longitude) VALUES
('Atlanta Metro', 'atlanta-metro', 'Urban food scene meets Southern tradition', 33.7490, -84.3880),
('Savannah Coastal', 'savannah-coastal', 'Historic charm with fresh coastal flavors', 32.0835, -81.0998),
('Augusta CSRA', 'augusta-csra', 'Central Savannah River Area delights', 33.4735, -82.0105),
('Columbus Valley', 'columbus-valley', 'Chattahoochee Valley cuisine', 32.4609, -84.9877),
('Macon Central', 'macon-central', 'Heart of Georgia flavors', 32.8407, -83.6324),
('Athens Northeast', 'athens-northeast', 'College town energy with local farm connections', 33.9519, -83.3576),
('South Georgia', 'south-georgia', 'Rural charm and authentic Southern cooking', 31.5804, -83.1557);

-- 6. Create User Favorites Table (Future Feature)
CREATE TABLE user_favorites (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID,
    restaurant_id UUID REFERENCES restaurants(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, restaurant_id)
);

CREATE INDEX idx_user_favorites_user_id ON user_favorites(user_id);
CREATE INDEX idx_user_favorites_restaurant_id ON user_favorites(restaurant_id);

-- 7. Enable Row Level Security on all tables
ALTER TABLE restaurants ENABLE ROW LEVEL SECURITY;
ALTER TABLE restaurant_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE restaurant_features ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE regions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_favorites ENABLE ROW LEVEL SECURITY;

-- 8. Create Public Read Access Policies
CREATE POLICY "Public restaurants are viewable by everyone" ON restaurants
    FOR SELECT USING (true);

CREATE POLICY "Public restaurant images are viewable by everyone" ON restaurant_images
    FOR SELECT USING (true);

CREATE POLICY "Public restaurant features are viewable by everyone" ON restaurant_features
    FOR SELECT USING (true);

CREATE POLICY "Public categories are viewable by everyone" ON categories
    FOR SELECT USING (true);

CREATE POLICY "Public regions are viewable by everyone" ON regions
    FOR SELECT USING (true);

-- 9. Insert Sample Savannah Restaurants (FIXED APOSTROPHE ISSUE)
INSERT INTO restaurants (name, slug, description, cuisine_type, price_range, address, city, phone, website, latitude, longitude, is_premium, featured, rating, review_count) VALUES
('The Grey', 'the-grey', 'Restored Greyhound bus terminal serving elevated Southern cuisine in a stunning Art Deco setting.', 'Southern Comfort', '$$$', '109 Martin Luther King Jr Blvd, Savannah, GA 31401', 'Savannah', '(912) 662-5999', 'https://thegreyrestaurant.com', 32.0758, -81.0912, true, true, 4.6, 1247),
('The Olde Pink House', 'olde-pink-house', 'Historic 18th-century mansion serving refined Southern cuisine in an elegant candlelit atmosphere.', 'Fine Dining', '$$$', '23 Abercorn St, Savannah, GA 31401', 'Savannah', '(912) 232-4286', 'https://plantersinn.com/dining', 32.0809, -81.0912, true, true, 4.4, 2156),
('Zunzis', 'zunzis', 'South African-inspired sandwiches and bowls that have become a Savannah institution.', 'International Fusion', '$', '108 E York St, Savannah, GA 31401', 'Savannah', '(912) 443-9555', 'https://zunzis.com', 32.0807, -81.0912, false, true, 4.5, 892),
('The Collins Quarter', 'collins-quarter', 'Australian-inspired cafe serving exceptional coffee and innovative brunch dishes.', 'Coffee & Desserts', '$$', '151 Bull St, Savannah, GA 31401', 'Savannah', '(912) 777-4147', 'https://thecollinsquarter.com', 32.0809, -81.0912, true, false, 4.3, 1654),
('Husk Savannah', 'husk-savannah', 'Farm-to-table Southern cuisine celebrating local ingredients and heritage recipes.', 'Farm-to-Table', '$$$', '12 W Oglethorpe Ave, Savannah, GA 31401', 'Savannah', '(912) 349-2600', 'https://husksavannah.com', 32.0809, -81.0912, true, true, 4.5, 987);

-- 10. Insert Sample Restaurant Images
INSERT INTO restaurant_images (restaurant_id, image_url, alt_text, is_primary, display_order) VALUES
((SELECT id FROM restaurants WHERE slug = 'the-grey'), 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=800', 'The Grey restaurant interior', true, 1),
((SELECT id FROM restaurants WHERE slug = 'the-grey'), 'https://images.unsplash.com/photo-1546833999-b9f581a1996d?w=800', 'Signature dish at The Grey', false, 2),
((SELECT id FROM restaurants WHERE slug = 'olde-pink-house'), 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800', 'The Olde Pink House historic exterior', true, 1),
((SELECT id FROM restaurants WHERE slug = 'zunzis'), 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=800', 'Zunzis signature sandwich', true, 1),
((SELECT id FROM restaurants WHERE slug = 'collins-quarter'), 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=800', 'Coffee and brunch at Collins Quarter', true, 1);

-- 11. Insert Sample Restaurant Features
INSERT INTO restaurant_features (restaurant_id, feature_name) VALUES
((SELECT id FROM restaurants WHERE slug = 'the-grey'), 'reservations'),
((SELECT id FROM restaurants WHERE slug = 'the-grey'), 'wheelchair_accessible'),
((SELECT id FROM restaurants WHERE slug = 'the-grey'), 'date_night'),
((SELECT id FROM restaurants WHERE slug = 'olde-pink-house'), 'historic'),
((SELECT id FROM restaurants WHERE slug = 'olde-pink-house'), 'reservations'),
((SELECT id FROM restaurants WHERE slug = 'zunzis'), 'takeout'),
((SELECT id FROM restaurants WHERE slug = 'collins-quarter'), 'wifi'),
((SELECT id FROM restaurants WHERE slug = 'collins-quarter'), 'brunch'),
((SELECT id FROM restaurants WHERE slug = 'husk-savannah'), 'reservations');

