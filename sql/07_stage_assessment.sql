use eco_b_analytics;
# 1.找出 2011年11月内，同一客户购买同一商品至少出现在两张不同发票中的组合。只使用客户编号存在的记录
with t1 as(select customer_id, stock_code,
       count(distinct invoice) distinct_count
from v_sales_transactions
where invoice_date >= '2011-11-01' and invoice_date < '2011-12-01'
and customer_id is not null group by customer_id, stock_code)
select * from t1 where distinct_count >= 2 order by distinct_count desc;

# 2.统计重复购买过至少一种商品的可识别客户人数
with t1 as(select customer_id, stock_code,
       count(distinct invoice) distinct_count
from v_sales_transactions
where invoice_date >= '2011-11-01' and invoice_date < '2011-12-01'
and customer_id is not null group by customer_id, stock_code)
select count(distinct customer_id) people_count from t1 where distinct_count >= 2
order by distinct_count desc;

