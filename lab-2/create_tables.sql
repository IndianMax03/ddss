CREATE TABLE films(
    id serial PRIMARY KEY,
    name text,
    description text
);
CREATE TABLE reviews(
    id serial PRIMARY KEY,
    film_id integer REFERENCES films(id),
    post text,
    rating integer
);
