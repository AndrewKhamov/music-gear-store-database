-- 1. Получаем все актуальные товары с текущей ценой реализации до 500
select p.product_id, p.product_name, ph.price
from products p
join product_price_history ph on p.product_id = ph.product_id
where p.is_active = true
	and ph.valid_to is null
    and ph.price < 500
order by ph.price desc;


-- 2. Количество товаров каждого бренда
select b.brand_name, count(*) as products_count
from brands b
join products p on b.brand_id = p.brand_id
group by b.brand_name
order by products_count desc;


-- 3. Бренды, у которых >3 товаров
select brand_id, count(*) as products_count
from products
group by brand_id
having count(*) > 3;


-- 4. Покупатели без заказов
select c.customer_id, c.first_name, c.last_name
from customers c
left join orders o on c.customer_id = o.customer_id
where o.order_id is null;


-- 5. Категории, в которых нет товаров
select c.category_name
from products p
right join categories c on p.category_id = c.category_id
where p.product_id is null;


-- 6. Сравниваем по месяцам сколько новых клиентов зарегистрировалось и сколько заказов было сделано.
-- Поскольку есть месяцы без заказов или без регистраций, используем full join, чтобы их не потерять
with registrations as (
    select date_trunc('month', registered_at) as month,
    count(*) as customers
    from customers
    group by month
),
orders_by_month as (
    select date_trunc('month', order_date) as month,
    count(*) as orders
    from orders
    group by month
)
select month, customers, orders
from registrations
full join orders_by_month using (month)
order by month;


-- 7. Товары дороже средней текущей цены. 
select product_id, price
from product_price_history
where valid_to is null
    and price > (
        select avg(price)
        from product_price_history
        where valid_to is null
    );


--8. Покупатели с отменёнными заказами
select customer_id, first_name, last_name
from customers
where customer_id in (
    select customer_id
    from orders
    where status = 'cancelled'
);


-- 9. Товары, которые покупали хотя бы один раз
select product_id, product_name
from products p
where exists (
    select 1
    from order_items oi
    where oi.product_id = p.product_id
);


-- 10. Товары, дороже хотя бы одной электрогитары (категория с id = 3)
select product_id, price
from product_price_history
where valid_to is null
    and price > any (
        select ph.price
        from product_price_history ph 
        join products p on ph.product_id = p.product_id
        where p.category_id = 3
        and ph.valid_to is null
    );


-- 11. Товары, дороже всех электрогитар (категория с id = 3)
select product_id, price
from product_price_history
where valid_to is null
    and price > all (
        select ph.price
        from product_price_history ph 
        join products p on ph.product_id = p.product_id
        where p.category_id = 3
        and ph.valid_to is null
    );


--12. Товары, дороже средней цены в своей категории
select p.product_name, ph.price
from products p 
join product_price_history ph on p.product_id = ph.product_id
where ph.valid_to is null
    and ph.price > (
        select avg(ph2.price)
        from products p2
        join product_price_history ph2 on p2.product_id = ph2.product_id
        where p2.category_id = p.category_id
        and ph2.valid_to is null
    );


-- 13. Выводим список категорий вместе с родительскими категориями (self-join)
select c.category_name, p.category_name as parent_category
from categories c
left join categories p on c.parent_category_id = p.category_id;


-- 14. Рейтинг товаров по текущей цене
select product_id, price, rank() over (order by price desc) as price_rank
from product_price_history
where valid_to is null;


--15. Для каждого заказа выводим полную стоимость каждой позиции (item_sum) и общую стоимость заказа (order_sum)
select order_id, product_id, quantity * unit_price as item_sum,
sum(quantity * unit_price) over (partition by order_id) as order_sum
from order_items;


--16. Предыдущая цена товара
select product_id, price,
lag(price) over (partition by product_id order by valid_from) as previous_price
from product_price_history;


-- 17. Отображаем вторую десятку товаров, отсортированных по id.
select product_id, product_name
from products
order by product_id
limit 10
offset 10;


-- 18. С помощью рекурсии выводим для каждой категории id ее родителя (если есть) 
-- и полную глубину дерева (level - количество родительских категорий)
with recursive category_tree as (
    select
        category_id,
        category_name,
        parent_category_id,
        0 as level
    from categories
    where parent_category_id is null

    union all

    select
        c.category_id,
        c.category_name,
        c.parent_category_id,
        t.level + 1
    from categories c
    join category_tree t
        on c.parent_category_id = t.category_id
)
select *
from category_tree
order by level, category_name;