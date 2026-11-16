use eco_b_analytics;
# 1.编写商品核心指标查询
select stock_code, sum(quantity) sale_quantity,
       sum(quantity * price) sale_total, count(distinct invoice) purchase_count
from v_sales_transactions
where invoice_date >= '2010-12-01' and invoice_date < '2011-12-01'
group by stock_code order by sale_total desc;

# 2.统计每件商品的购买客户来自哪些国家
# 注意这里查出的客户数量仅为可识别客户id的客户数量，并不包括客户id为空的订单
select stock_code, country, count(distinct customer_id) customer_count
from v_sales_transactions
where invoice_date >= '2010-12-01' and invoice_date < '2011-12-01'
and customer_id is not null
group by stock_code, country order by stock_code, customer_count desc;

# 3.统计客户编号的明细覆盖率。
# 在同一文件末尾追加查询，使用同一视图、同一日期范围，输出一行：
# - 总明细行数。
# - 客户编号存在的明细行数。
# - 客户编号缺失的明细行数。
# - 客户编号存在的行数占总明细行数的百分比，保留两位小数
# 注意：这个比例叫明细覆盖率，不能叫客户覆盖率，因为我们不知道缺失编号的记录涉及多少客户
select count(*) total_count,
       count(case when customer_id is not null then customer_id end) exist_count,
       sum(case when customer_id is null then 1 else 0 end) not_exist_count,
       round((count(case when customer_id is not null then customer_id end) / count(*) * 100), 2) exist_rate
from v_sales_transactions
where invoice_date >= '2010-12-01' and invoice_date < '2011-12-01';




