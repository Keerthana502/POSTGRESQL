-- Drop the existing "locations" table
DROP TABLE IF EXISTS locations;

-- Create a new "locations" table with a geometry column
CREATE TABLE locations (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    geom GEOMETRY(Point, 4326)  -- 4326 is the SRID for WGS 84
);

-- Insert new sample data
INSERT INTO locations (name, geom) VALUES
    ('Point A', ST_SetSRID(ST_MakePoint(-75.1234, 40.4321), 4326)),
    ('Point B', ST_SetSRID(ST_MakePoint(-75.5432, 40.9876), 4326)),
    ('Point C', ST_SetSRID(ST_MakePoint(-74.8765, 39.8765), 4326));

-- Drop the existing "areas_of_interest" table
DROP TABLE IF EXISTS areas_of_interest;

-- Hypothetical areas_of_interest table
CREATE TABLE areas_of_interest (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    geom GEOMETRY(Polygon, 4326)
);

-- Insert sample polygon data
INSERT INTO areas_of_interest (name, geom) VALUES
    ('Area 1', ST_SetSRID(ST_MakePolygon(ST_GeomFromText('LINESTRING(-75 40, -74 40, -74 39, -75 39, -75 40)')), 4326)), 
    ('Area 2', ST_SetSRID(ST_MakePolygon(ST_GeomFromText('LINESTRING(-76 41, -75 41, -75 40, -76 40, -76 41)')), 4326));

-- Retrieve locations of specific features
SELECT id, name, ST_AsText(geom) AS location
FROM locations
WHERE name = 'Point A';

-- Calculate distance between Point A and Point B
SELECT 
    ST_Distance(
        (SELECT geom FROM locations WHERE name = 'Point A'), 
        (SELECT geom FROM locations WHERE name = 'Point B')
    ) AS distance;

-- Calculate areas of interest
SELECT id, name, ST_Area(geom) AS area
FROM areas_of_interest;


-- Analyze the "Retrieve locations of specific features" query
EXPLAIN SELECT id, name, ST_AsText(geom) AS location FROM locations WHERE name = 'Point A';

-- Analyze the "Calculate distance between Point A and Point B" query
EXPLAIN SELECT 
    ST_Distance(
        (SELECT geom FROM locations WHERE name = 'Point A'), 
        (SELECT geom FROM locations WHERE name = 'Point B')
    ) AS distance;

-- Analyze the "Calculate areas of interest" query
EXPLAIN SELECT id, name, ST_Area(geom) AS area FROM areas_of_interest;


-- Sorting and limiting locations
SELECT id, name, ST_AsText(geom) AS location
FROM locations
ORDER BY name ASC
LIMIT 10;


-- Add index on 'name' column in locations table
CREATE INDEX idx_name ON locations (name);

-- Add index on 'name' column in areas_of_interest table
CREATE INDEX idx_name_aoi ON areas_of_interest (name);


-- Rewrite the "Calculate distance between Point A and Point B" query using ST_Distance function directly
SELECT ST_Distance(l1.geom, l2.geom) AS distance
FROM locations l1, locations l2
WHERE l1.name = 'Point A' AND l2.name = 'Point B';
