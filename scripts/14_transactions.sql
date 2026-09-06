-- Создание заказа и его позиций должно выполняться целиком.
-- Если одна из операций завершится ошибкой, весь заказ можно откатить.

begin;

insert into orders (order_id, customer_id, order_date, status)
values (9999, 1, current_timestamp, 'new');

insert into order_items (order_id, product_id, quantity, unit_price)
values
    (9999, 1, 1, 914.82),
    (9999, 43, 2, 23.49);

select *
from orders
where order_id = 9999;

select *
from order_items
where order_id = 9999;

rollback;

