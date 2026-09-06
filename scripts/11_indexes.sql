-- Ускоряет поиск заказов конкретного покупателя и JOIN customers -> orders.
-- Используется, например, в запросе №4.
create index idx_orders_customer_id
on orders(customer_id);


-- Ускоряет поиск товаров по категории и JOIN categories -> products.
-- Используется, например, в запросах №5 и №12.
create index idx_products_category_id
on products(category_id);


-- Ускоряет поиск всех продаж конкретного товара.
-- Используется, например, в запросе №9.
create index idx_order_items_product_id
on order_items(product_id);


-- Ускоряет получение истории цен конкретного товара и работу с версиями цен в порядке valid_from.
-- Используется, например, в запросе №16.
create index idx_price_history_product_date
on product_price_history(product_id, valid_from);