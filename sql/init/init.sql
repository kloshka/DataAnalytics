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

CREATE TABLE dim_store (
    store_id BIGSERIAL PRIMARY KEY,
    store_name VARCHAR(200),
    store_location VARCHAR(200),
    store_city VARCHAR(100),
    store_state VARCHAR(100),
    store_country VARCHAR(100),
    store_phone VARCHAR(30),
    store_email VARCHAR(200)
);

CREATE TABLE dim_supplier (
    supplier_id BIGSERIAL PRIMARY KEY,
    supplier_name VARCHAR(200),
    supplier_contact VARCHAR(200),
    supplier_email VARCHAR(200),
    supplier_phone VARCHAR(30),
    supplier_address TEXT,
    supplier_city VARCHAR(100),
    supplier_country VARCHAR(100)
);

CREATE TABLE dim_product (
    product_id INTEGER PRIMARY KEY,
    product_name VARCHAR(200),
    category_id BIGINT REFERENCES dim_category(category_id),
    product_price NUMERIC(10,2),
    product_quantity INTEGER,
    pet_category VARCHAR(50),
    product_weight NUMERIC(10,2),
    product_color VARCHAR(50),
    product_size VARCHAR(50),
    product_brand VARCHAR(100),
    product_material VARCHAR(100),
    product_description TEXT,
    product_rating NUMERIC(3,1),
    product_reviews INTEGER,
    product_release_date DATE,
    product_expiry_date DATE,
    supplier_id BIGINT REFERENCES dim_supplier(supplier_id)
);

CREATE TABLE dim_date (
    date_id BIGSERIAL PRIMARY KEY,
    full_date DATE UNIQUE,
    year INTEGER,
    month INTEGER,
    day INTEGER
);

CREATE TABLE fact_sales (
    fact_id BIGSERIAL PRIMARY KEY,
    source_row_id INTEGER,
    sale_date_id BIGINT REFERENCES dim_date(date_id),
    customer_id INTEGER REFERENCES dim_customer(customer_id),
    pet_id BIGINT REFERENCES dim_pet(pet_id),
    seller_id INTEGER REFERENCES dim_seller(seller_id),
    product_id INTEGER REFERENCES dim_product(product_id),
    store_id BIGINT REFERENCES dim_store(store_id),
    supplier_id BIGINT REFERENCES dim_supplier(supplier_id),
    sale_quantity INTEGER,
    sale_total_price NUMERIC(10,2)
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

-- Категории выносим в отдельное измерение 
INSERT INTO dim_category(
    category_name
)
SELECT DISTINCT
    product_category
FROM public.mock_data
WHERE product_category IS NOT NULL;


INSERT INTO dim_store(
    store_name,
    store_location,
    store_city,
    store_state,
    store_country,
    store_phone,
    store_email
)
SELECT DISTINCT
    store_name,
    store_location,
    store_city,
    store_state,
    store_country,
    store_phone,
    store_email
FROM public.mock_data;

INSERT INTO dim_supplier(
    supplier_name,
    supplier_contact,
    supplier_email,
    supplier_phone,
    supplier_address,
    supplier_city,
    supplier_country
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
    product_name,
    category_id,
    product_price,
    product_quantity,
    pet_category,
    product_weight,
    product_color,
    product_size,
    product_brand,
    product_material,
    product_description,
    product_rating,
    product_reviews,
    product_release_date,
    product_expiry_date,
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
    s.supplier_name IS NOT DISTINCT FROM m.supplier_name AND
    s.supplier_contact IS NOT DISTINCT FROM m.supplier_contact AND
    s.supplier_email IS NOT DISTINCT FROM m.supplier_email AND
    s.supplier_phone IS NOT DISTINCT FROM m.supplier_phone AND
    s.supplier_address IS NOT DISTINCT FROM m.supplier_address AND
    s.supplier_city IS NOT DISTINCT FROM m.supplier_city AND
    s.supplier_country IS NOT DISTINCT FROM m.supplier_country
WHERE m.sale_product_id IS NOT NULL
ORDER BY m.sale_product_id, m.id;

INSERT INTO dim_date(
    full_date,
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
    sale_date_id,
    customer_id,
    pet_id,
    seller_id,
    product_id,
    store_id,
    supplier_id,
    sale_quantity,
    sale_total_price
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
    m.sale_total_price
FROM public.mock_data m
JOIN dim_date d ON
    d.full_date = m.sale_date
JOIN dim_customer c ON
    c.customer_id = m.sale_customer_id
JOIN dim_pet pet ON
    pet.pet_type IS NOT DISTINCT FROM m.customer_pet_type AND
    pet.pet_name IS NOT DISTINCT FROM m.customer_pet_name AND
    pet.pet_breed IS NOT DISTINCT FROM m.customer_pet_breed
JOIN dim_seller s ON
    s.seller_id = m.sale_seller_id
JOIN dim_store st ON
    st.store_name IS NOT DISTINCT FROM m.store_name AND
    st.store_location IS NOT DISTINCT FROM m.store_location AND
    st.store_city IS NOT DISTINCT FROM m.store_city AND
    st.store_state IS NOT DISTINCT FROM m.store_state AND
    st.store_country IS NOT DISTINCT FROM m.store_country AND
    st.store_phone IS NOT DISTINCT FROM m.store_phone AND
    st.store_email IS NOT DISTINCT FROM m.store_email
JOIN dim_product p ON
    p.product_id = m.sale_product_id
JOIN dim_supplier sup ON
    sup.supplier_name IS NOT DISTINCT FROM m.supplier_name AND
    sup.supplier_contact IS NOT DISTINCT FROM m.supplier_contact AND
    sup.supplier_email IS NOT DISTINCT FROM m.supplier_email AND
    sup.supplier_phone IS NOT DISTINCT FROM m.supplier_phone AND
    sup.supplier_address IS NOT DISTINCT FROM m.supplier_address AND
    sup.supplier_city IS NOT DISTINCT FROM m.supplier_city AND
    sup.supplier_country IS NOT DISTINCT FROM m.supplier_country;

SELECT COUNT(*) AS mock_data_rows FROM public.mock_data;
SELECT COUNT(*) AS fact_sales_rows FROM fact_sales;

-- выручка и количество по категориям.
SELECT
    c.category_name,
    SUM(f.sale_quantity) AS total_qty,
    SUM(f.sale_total_price) AS total_revenue
FROM fact_sales f
JOIN dim_product p ON f.product_id = p.product_id
JOIN dim_category c ON p.category_id = c.category_id
GROUP BY c.category_name
ORDER BY total_revenue DESC;

--топ магазинов по выручке.
SELECT
    s.store_name,
    s.store_city,
    s.store_country,
    SUM(f.sale_total_price) AS total_revenue
FROM fact_sales f
JOIN dim_store s ON f.store_id = s.store_id
GROUP BY s.store_name, s.store_city, s.store_country
ORDER BY total_revenue DESC
LIMIT 10;

-- топ поставщиков по выручке.
SELECT
    sup.supplier_name,
    SUM(f.sale_total_price) AS total_revenue
FROM fact_sales f
JOIN dim_supplier sup ON f.supplier_id = sup.supplier_id
GROUP BY sup.supplier_name
ORDER BY total_revenue DESC
LIMIT 10;
