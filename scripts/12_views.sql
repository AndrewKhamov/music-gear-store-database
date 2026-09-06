-- 1. Текущая цена каждого товара.
-- Упрощает запросы, где не нужна полная история изменения цен.

create view current_product_prices as
select p.product_id, p.product_name, p.category_id, 
p.brand_id, ph.price
from products p
join product_price_history ph on p.product_id = ph.product_id
where ph.valid_to is null;


-- 2. Общая стоимость каждого заказа.
-- Позволяет не повторять расчет quantity * unit_price.

create view order_totals as
select order_id, sum(quantity * unit_price) as total_amount
from order_items
group by order_id;