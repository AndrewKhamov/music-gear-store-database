-- Добавление нового бренда
create procedure add_brand(p_brand_name text, p_country text)
language sql
as $$
    insert into brands (brand_name, country)
    values (p_brand_name, p_country);
$$;


-- Добавление нового покупателя
create procedure add_customer(
    p_first_name text,
    p_last_name text,
    p_email text,
    p_city text)
language sql
as $$
    insert into customers (
        first_name,
        last_name,
        email,
        city
	)
    values (
        p_first_name,
        p_last_name,
        p_email,
        p_city
	);
$$;


-- Изменение цены товара с сохранением истории
create procedure change_product_price(p_product_id integer, p_new_price numeric(10, 2))
language sql
as $$
    update product_price_history
    set valid_to = current_timestamp
    where product_id = p_product_id
    and valid_to is null;

    insert into product_price_history (
        product_id,
        price,
        valid_from
	)
    values (
        p_product_id,
        p_new_price,
        current_timestamp
	);
$$;



-- Проверка процедур с помощью транзакции (с ROLLBACK для отката изменений)
begin;

-- Добавление бренда
call add_brand('PRS', 'USA');


-- Добавление покупателя
call add_customer(
    'John',
    'Smith',
    'john.smith@test.com',
    'London'
);


-- Изменение цены товара
call change_product_price(38, 1799.00);


-- Проверка добавленного бренда
select *
from brands
where brand_name = 'PRS';


-- Проверка добавленного покупателя
select *
from customers
where email = 'john.smith@test.com';


-- Проверка изменения цены
select *
from product_price_history
where product_id = 38
order by valid_from;


rollback;