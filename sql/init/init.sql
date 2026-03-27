DROP TABLE IF EXISTS public.mock_data;

CREATE TABLE public.mock_data (
    id INTEGER,
    customer_first_name VARCHAR(100),
    customer_last_name VARCHAR(100),
    customer_age INTEGER,
    customer_email VARCHAR(200),
    customer_country VARCHAR(100),
    customer_postal_code VARCHAR(20),
    customer_pet_type VARCHAR(50),
    customer_pet_name VARCHAR(100),
    customer_pet_breed VARCHAR(100),
    seller_first_name VARCHAR(100),
    seller_last_name VARCHAR(100),
    seller_email VARCHAR(200),
    seller_country VARCHAR(100),
    seller_postal_code VARCHAR(20),
    product_name VARCHAR(200),
    product_category VARCHAR(100),
    product_price DECIMAL(10,2),
    product_quantity INTEGER,
    sale_date DATE,
    sale_customer_id INTEGER,
    sale_seller_id INTEGER,
    sale_product_id INTEGER,
    sale_quantity INTEGER,
    sale_total_price DECIMAL(10,2),
    store_name VARCHAR(200),
    store_location VARCHAR(200),
    store_city VARCHAR(100),
    store_state VARCHAR(100),
    store_country VARCHAR(100),
    store_phone VARCHAR(30),
    store_email VARCHAR(200),
    pet_category VARCHAR(50),
    product_weight DECIMAL(10,2),
    product_color VARCHAR(50),
    product_size VARCHAR(50),
    product_brand VARCHAR(100),
    product_material VARCHAR(100),
    product_description TEXT,
    product_rating DECIMAL(3,1),
    product_reviews INTEGER,
    product_release_date DATE,
    product_expiry_date DATE,
    supplier_name VARCHAR(200),
    supplier_contact VARCHAR(200),
    supplier_email VARCHAR(200),
    supplier_phone VARCHAR(30),
    supplier_address TEXT,
    supplier_city VARCHAR(100),
    supplier_country VARCHAR(100)
);

COPY public.mock_data FROM '/data/csv/MOCK_DATA.csv' CSV HEADER;
COPY public.mock_data FROM '/data/csv/MOCK_DATA (1).csv' CSV HEADER;
COPY public.mock_data FROM '/data/csv/MOCK_DATA (2).csv' CSV HEADER;
COPY public.mock_data FROM '/data/csv/MOCK_DATA (3).csv' CSV HEADER;
COPY public.mock_data FROM '/data/csv/MOCK_DATA (4).csv' CSV HEADER;
COPY public.mock_data FROM '/data/csv/MOCK_DATA (5).csv' CSV HEADER;
COPY public.mock_data FROM '/data/csv/MOCK_DATA (6).csv' CSV HEADER;
COPY public.mock_data FROM '/data/csv/MOCK_DATA (7).csv' CSV HEADER;
COPY public.mock_data FROM '/data/csv/MOCK_DATA (8).csv' CSV HEADER;
COPY public.mock_data FROM '/data/csv/MOCK_DATA (9).csv' CSV HEADER;

DROP TABLE IF EXISTS fact_sales CASCADE;
DROP TABLE IF EXISTS dim_date CASCADE;
DROP TABLE IF EXISTS dim_product CASCADE;
DROP TABLE IF EXISTS dim_category CASCADE;
DROP TABLE IF EXISTS dim_store CASCADE;
DROP TABLE IF EXISTS dim_store_location CASCADE;
DROP TABLE IF EXISTS dim_supplier CASCADE;
DROP TABLE IF EXISTS dim_seller CASCADE;
DROP TABLE IF EXISTS dim_pet CASCADE;
DROP TABLE IF EXISTS dim_customer CASCADE;

-- Измерения и факт для схемы снежинка
CREATE TABLE dim_customer (
    customer_id INTEGER PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    age INTEGER,
    email VARCHAR(200),
    country VARCHAR(100),
    postal_code VARCHAR(20)
);

CREATE TABLE dim_pet (
    pet_id BIGSERIAL PRIMARY KEY,
    pet_type VARCHAR(50),
    pet_name VARCHAR(100),
    pet_breed VARCHAR(100)
);

CREATE TABLE dim_seller (
    seller_id INTEGER PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(200),
    country VARCHAR(100),
    postal_code VARCHAR(20)
);

CREATE TABLE dim_category (
    category_id BIGSERIAL PRIMARY KEY,
    category_name VARCHAR(100) UNIQUE
);

CREATE TABLE dim_store_location (
    location_id BIGSERIAL PRIMARY KEY,
    location VARCHAR(200),
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100)
);

CREATE TABLE dim_store (
    store_id BIGSERIAL PRIMARY KEY,
    name VARCHAR(200),
    location_id BIGINT REFERENCES dim_store_location(location_id),
    phone VARCHAR(30),
    email VARCHAR(200)
);

CREATE TABLE dim_supplier (
    supplier_id BIGSERIAL PRIMARY KEY,
    name VARCHAR(200),
    contact VARCHAR(200),
    email VARCHAR(200),
    phone VARCHAR(30),
    address TEXT,
    city VARCHAR(100),
    country VARCHAR(100)
);

CREATE TABLE dim_product (
    product_id INTEGER PRIMARY KEY,
    name VARCHAR(200),
    category_id BIGINT REFERENCES dim_category(category_id),
    price NUMERIC(10,2),
    quantity INTEGER,
    pet_category VARCHAR(50),
    weight NUMERIC(10,2),
    color VARCHAR(50),
    size VARCHAR(50),
    brand VARCHAR(100),
    material VARCHAR(100),
    description TEXT,
    rating NUMERIC(3,1),
    reviews INTEGER,
    release_date DATE,
    expiry_date DATE,
    supplier_id BIGINT REFERENCES dim_supplier(supplier_id)
);

CREATE TABLE dim_date (
    date_id BIGSERIAL PRIMARY KEY,
    date_value DATE UNIQUE,
    year INTEGER,
    month INTEGER,
    day INTEGER
);

CREATE TABLE fact_sales (
    fact_id BIGSERIAL PRIMARY KEY,
    source_row_id INTEGER,
    date_id BIGINT REFERENCES dim_date(date_id),
    customer_id INTEGER REFERENCES dim_customer(customer_id),
    pet_id BIGINT REFERENCES dim_pet(pet_id),
    seller_id INTEGER REFERENCES dim_seller(seller_id),
    product_id INTEGER REFERENCES dim_product(product_id),
    store_id BIGINT REFERENCES dim_store(store_id),
    supplier_id BIGINT REFERENCES dim_supplier(supplier_id),
    quantity INTEGER,
    total_price NUMERIC(10,2),
    unit_price NUMERIC(10,2)
);

INSERT INTO dim_customer(
    customer_id,
    first_name,
    last_name,
    age,
    email,
    country,
    postal_code
)
SELECT DISTINCT ON (sale_customer_id)
    sale_customer_id,
    customer_first_name,
    customer_last_name,
    customer_age,
    customer_email,
    customer_country,
    customer_postal_code
FROM public.mock_data
WHERE sale_customer_id IS NOT NULL
ORDER BY sale_customer_id, id;

INSERT INTO dim_pet(
    pet_type,
    pet_name,
    pet_breed
)
SELECT DISTINCT
    customer_pet_type,
    customer_pet_name,
    customer_pet_breed
FROM public.mock_data;

INSERT INTO dim_seller(
    seller_id,
    first_name,
    last_name,
    email,
    country,
    postal_code
)
SELECT DISTINCT ON (sale_seller_id)
    sale_seller_id,
    seller_first_name,
    seller_last_name,
    seller_email,
    seller_country,
    seller_postal_code
FROM public.mock_data
WHERE sale_seller_id IS NOT NULL
ORDER BY sale_seller_id, id;

INSERT INTO dim_category(
    category_name
)
SELECT DISTINCT
    product_category
FROM public.mock_data
WHERE product_category IS NOT NULL;


INSERT INTO dim_store_location(
    location,
    city,
    state,
    country
)
SELECT DISTINCT
    store_location,
    store_city,
    store_state,
    store_country
FROM public.mock_data;


INSERT INTO dim_store(
    name,
    location_id,
    phone,
    email
)
SELECT DISTINCT
    m.store_name,
    l.location_id,
    m.store_phone,
    m.store_email
FROM public.mock_data m
JOIN dim_store_location l ON
    l.location IS NOT DISTINCT FROM m.store_location AND
    l.city IS NOT DISTINCT FROM m.store_city AND
    l.state IS NOT DISTINCT FROM m.store_state AND
    l.country IS NOT DISTINCT FROM m.store_country;

INSERT INTO dim_supplier(
    name,
    contact,
    email,
    phone,
    address,
    city,
    country
)
SELECT DISTINCT
    supplier_name,
    supplier_contact,
    supplier_email,
    supplier_phone,
    supplier_address,
    supplier_city,
    supplier_country
FROM public.mock_data;

INSERT INTO dim_product(
    product_id,
    name,
    category_id,
    price,
    quantity,
    pet_category,
    weight,
    color,
    size,
    brand,
    material,
    description,
    rating,
    reviews,
    release_date,
    expiry_date,
    supplier_id
)
SELECT DISTINCT ON (m.sale_product_id)
    m.sale_product_id,
    m.product_name,
    c.category_id,
    m.product_price,
    m.product_quantity,
    m.pet_category,
    m.product_weight,
    m.product_color,
    m.product_size,
    m.product_brand,
    m.product_material,
    m.product_description,
    m.product_rating,
    m.product_reviews,
    m.product_release_date,
    m.product_expiry_date,
    s.supplier_id
FROM public.mock_data m
LEFT JOIN dim_category c ON c.category_name = m.product_category
LEFT JOIN dim_supplier s ON
    s.name IS NOT DISTINCT FROM m.supplier_name AND
    s.contact IS NOT DISTINCT FROM m.supplier_contact AND
    s.email IS NOT DISTINCT FROM m.supplier_email AND
    s.phone IS NOT DISTINCT FROM m.supplier_phone AND
    s.address IS NOT DISTINCT FROM m.supplier_address AND
    s.city IS NOT DISTINCT FROM m.supplier_city AND
    s.country IS NOT DISTINCT FROM m.supplier_country
WHERE m.sale_product_id IS NOT NULL
ORDER BY m.sale_product_id, m.id;

INSERT INTO dim_date(
    date_value,
    year,
    month,
    day
)
SELECT DISTINCT
    sale_date,
    EXTRACT(YEAR FROM sale_date)::INTEGER,
    EXTRACT(MONTH FROM sale_date)::INTEGER,
    EXTRACT(DAY FROM sale_date)::INTEGER
FROM public.mock_data
WHERE sale_date IS NOT NULL;

INSERT INTO fact_sales(
    source_row_id,
    date_id,
    customer_id,
    pet_id,
    seller_id,
    product_id,
    store_id,
    supplier_id,
    quantity,
    total_price,
    unit_price
)
SELECT
    m.id,
    d.date_id,
    c.customer_id,
    pet.pet_id,
    s.seller_id,
    p.product_id,
    st.store_id,
    sup.supplier_id,
    m.sale_quantity,
    m.sale_total_price,
    CASE
        WHEN m.sale_quantity IS NULL OR m.sale_quantity = 0 THEN NULL
        ELSE ROUND((m.sale_total_price / m.sale_quantity)::NUMERIC, 2)
    END AS unit_price
FROM public.mock_data m
JOIN dim_date d ON
    d.date_value = m.sale_date
JOIN dim_customer c ON
    c.customer_id = m.sale_customer_id
JOIN dim_pet pet ON
    pet.pet_type IS NOT DISTINCT FROM m.customer_pet_type AND
    pet.pet_name IS NOT DISTINCT FROM m.customer_pet_name AND
    pet.pet_breed IS NOT DISTINCT FROM m.customer_pet_breed
JOIN dim_seller s ON
    s.seller_id = m.sale_seller_id
JOIN dim_store_location sl ON
    sl.location IS NOT DISTINCT FROM m.store_location AND
    sl.city IS NOT DISTINCT FROM m.store_city AND
    sl.state IS NOT DISTINCT FROM m.store_state AND
    sl.country IS NOT DISTINCT FROM m.store_country
JOIN dim_store st ON
    st.name IS NOT DISTINCT FROM m.store_name AND
    st.location_id = sl.location_id AND
    st.phone IS NOT DISTINCT FROM m.store_phone AND
    st.email IS NOT DISTINCT FROM m.store_email
JOIN dim_product p ON
    p.product_id = m.sale_product_id
JOIN dim_supplier sup ON
    sup.name IS NOT DISTINCT FROM m.supplier_name AND
    sup.contact IS NOT DISTINCT FROM m.supplier_contact AND
    sup.email IS NOT DISTINCT FROM m.supplier_email AND
    sup.phone IS NOT DISTINCT FROM m.supplier_phone AND
    sup.address IS NOT DISTINCT FROM m.supplier_address AND
    sup.city IS NOT DISTINCT FROM m.supplier_city AND
    sup.country IS NOT DISTINCT FROM m.supplier_country;

SELECT COUNT(*) AS mock_data_rows FROM public.mock_data;
SELECT COUNT(*) AS fact_sales_rows FROM fact_sales;

-- выручка и количество по категориям.
SELECT
    c.category_name,
    SUM(f.quantity) AS total_qty,
    SUM(f.total_price) AS total_revenue
FROM fact_sales f
JOIN dim_product p ON f.product_id = p.product_id
JOIN dim_category c ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY total_revenue DESC;

--топ магазинов по выручке.
SELECT
    s.name,
    sl.city,
    sl.country,
    SUM(f.total_price) AS total_revenue
FROM fact_sales f
JOIN dim_store s ON f.store_id = s.store_id
JOIN dim_store_location sl ON s.location_id = sl.location_id
GROUP BY s.name, sl.city, sl.country
ORDER BY total_revenue DESC
LIMIT 10;

-- топ поставщиков по выручке.
SELECT
    sup.name,
    SUM(f.total_price) AS total_revenue
FROM fact_sales f
JOIN dim_supplier sup ON f.supplier_id = sup.supplier_id
GROUP BY sup.name
ORDER BY total_revenue DESC
LIMIT 10;
