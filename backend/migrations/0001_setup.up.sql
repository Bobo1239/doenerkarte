-- EPSG:4326 WGS 84
CREATE TABLE kebab (
    id serial,
    name varchar NOT NULL,
    address varchar NOT NULL,
    price_cents integer,
    rating real NOT NULL,
    position geometry(Point, 4326) NOT NULL
);

CREATE INDEX kebab_position_idx
ON kebab
USING GIST (position);
