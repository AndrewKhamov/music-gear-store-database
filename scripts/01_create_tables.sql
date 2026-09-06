-- 1. Бренды

create table brands (
    brand_id serial primary key,
    brand_name varchar(100) unique not null,
    country varchar(100)
);


-- 2. Категории

create table categories (
    category_id serial primary key,
    category_name varchar(100) not null,
    parent_category_id integer references categories(category_id)
);


-- 3. Покупатели

create table customers (
    customer_id serial primary key,
    first_name varchar(100) not null,
    last_name varchar(100) not null,
    email varchar(255) unique not null,
    city varchar(100),
    registered_at timestamp not null default current_timestamp
);


-- 4. Товары

create table products (
    product_id serial primary key,
    product_name varchar(255) not null,
    sku varchar(50) unique not null,
    brand_id integer not null references brands(brand_id),
    category_id integer not null references categories(category_id),
    created_at timestamp not null default current_timestamp,
    is_active boolean not null default true
);


-- 5. Заказы

create table orders (
    order_id serial primary key,
    customer_id integer not null references customers(customer_id),
    order_date timestamp not null default current_timestamp,
    status varchar(20) not null,

    check (
        status in ('new', 'paid', 'shipped', 'completed', 'cancelled')
    )
);


-- 6. Позиции заказов

create table order_items (
    order_id integer not null references orders(order_id),
    product_id integer not null references products(product_id),
    quantity integer not null check (quantity > 0),
    unit_price numeric(10, 2) not null check (unit_price >= 0),

    primary key (order_id, product_id)
);


-- 7. История цен

create table product_price_history (
    price_history_id serial primary key,
    product_id integer not null references products(product_id),
    price numeric(10, 2) not null check (price > 0),
    valid_from timestamp not null,
    valid_to timestamp,

    check (
        valid_to is null
        or valid_to > valid_from
    )
);