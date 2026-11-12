use eco_b_analytics;
# 1.查看两表中明细行数以及最早最晚日期，并且统计发票日期的缺失值数量
select source_sheet, count(*) total_rows, min(invoice_date) early_date,
max(invoice_date) latest_date, sum(case when invoice_date is null then 1 else 0 end) missing_count
from raw_transactions group by source_sheet;

# 2.统计两张表中完全相同的内容
with same_row as(select count(distinct source_sheet) same,
                        sum(case when source_sheet = 'Year 2009-2010' then 1 else 0 end) sheet1_same,
                        sum(case when source_sheet = 'Year 2010-2011' then 1 else 0 end) sheet2_same
                 from raw_transactions
group by invoice, stock_code, description, quantity, invoice_date, price, customer_id, country)
select sum(case when same = 2 then 1 else 0 end) total_same_count,
       sum(sheet1_same) sheet1_same_count,
       sum(sheet2_same) sheet2_same_count
from same_row where same = 2;

# 验证重复区间
select distinct source_sheet,
       count(*) sheet_row
from raw_transactions
where invoice_date between '2010-12-01 08:26:00' and '2010-12-09 20:01:00' group by source_sheet;

# 查询在当前重复区间中表1和表2不相同的行数
with same_row as(select count(distinct source_sheet) same,
                        sum(case when source_sheet = 'Year 2009-2010' then 1 else 0 end) sheet1_same,
                        sum(case when source_sheet = 'Year 2010-2011' then 1 else 0 end) sheet2_same
                 from raw_transactions
group by invoice, stock_code, description, quantity, invoice_date, price, customer_id, country)
select count(*)
from same_row where same = 2 and sheet1_same <> sheet2_same;

# 3.完成字段的缺失检查
select source_sheet, count(*) total_row,
            sum(case when invoice is null then 1 else 0 end) invoice_null_count,
            sum(case when stock_code is null then 1 else 0 end) stockcode_null_count,
            sum(case when description is null then 1 else 0 end) description_null_count,
            sum(case when quantity is null then 1 else 0 end) quantity_null_count,
            sum(case when invoice_date is null then 1 else 0 end) invoicedate_null_count,
            sum(case when price is null then 1 else 0 end) price_null_count,
            sum(case when customer_id is null then 1 else 0 end) customerid_null_count,
            sum(case when country is null then 1 else 0 end) country_null_count
       from raw_transactions group by source_sheet;
# 使用CET语句统计缺失字段的缺失率
with null_count as(select source_sheet, count(*) total_row,
            sum(case when invoice is null then 1 else 0 end) invoice_null_count,
            sum(case when stock_code is null then 1 else 0 end) stockcode_null_count,
            sum(case when description is null then 1 else 0 end) description_null_count,
            sum(case when quantity is null then 1 else 0 end) quantity_null_count,
            sum(case when invoice_date is null then 1 else 0 end) invoicedate_null_count,
            sum(case when price is null then 1 else 0 end) price_null_count,
            sum(case when customer_id is null then 1 else 0 end) customerid_null_count,
            sum(case when country is null then 1 else 0 end) country_null_count
       from raw_transactions group by source_sheet)
select source_sheet,
       round(description_null_count / total_row * 100, 4) descnull_rate, # 缺失行数 / 对应工作表的 total_row × 100%
       round(customerid_null_count / total_row * 100, 4) custnull_rate
       from null_count;

# 4.检查文本字段中的空字符串和纯空格内容
select source_sheet,
       sum(case when invoice = '' then 1 else 0 end) invoice_null_count,
       sum(case when stock_code = '' then 1 else 0 end) stockcode_null_count,
       sum(case when description = '' then 1 else 0 end) description_null_count,
       sum(case when country = '' then 1 else 0 end) country_null_count
from raw_transactions group by source_sheet;

select source_sheet,
       sum(case when char_length(invoice) > 0 and char_length(trim(invoice)) = 0
       then 1 else 0 end) invoice_count,
       sum(case when char_length(stock_code) > 0 and char_length(trim(stock_code)) = 0
       then 1 else 0 end) stockcode_count,
       sum(case when char_length(description) > 0 and char_length(trim(description)) = 0
       then 1 else 0 end) description_count,
       sum(case when char_length(country) > 0 and char_length(trim(country)) = 0
       then 1 else 0 end) country_count
from raw_transactions group by source_sheet;

# 5.检查数量、价格与取消标记的组合分布  # 注意c表示以C开头的发票号，n表示不以C开头的发票号，1表示大于0，0表示等于零，2表示小于零
select source_sheet,
       sum(case when invoice like 'C%' and quantity > 0 and price > 0 then 1 else 0 end) c11,
       sum(case when invoice like 'C%' and quantity > 0 and price = 0 then 1 else 0 end) c10,
       sum(case when invoice like 'C%' and quantity > 0 and price < 0 then 1 else 0 end) c12,
       sum(case when invoice like 'C%' and quantity < 0 and price > 0 then 1 else 0 end) c21,
       sum(case when invoice like 'C%' and quantity < 0 and price = 0 then 1 else 0 end) c20,
       sum(case when invoice like 'C%' and quantity < 0 and price < 0 then 1 else 0 end) c22,
       sum(case when invoice not like 'C%' and quantity > 0 and price > 0 then 1 else 0 end) n11,
       sum(case when invoice not like 'C%' and quantity > 0 and price = 0 then 1 else 0 end) n10,
       sum(case when invoice not like 'C%' and quantity > 0 and price < 0 then 1 else 0 end) n12,
       sum(case when invoice not like 'C%' and quantity < 0 and price > 0 then 1 else 0 end) n21,
       sum(case when invoice not like 'C%' and quantity < 0 and price = 0 then 1 else 0 end) n20,
       sum(case when invoice not like 'C%' and quantity < 0 and price < 0 then 1 else 0 end) n22
from raw_transactions group by source_sheet;

# 6.把“发票号以 C 开头，但购买数量大于零”的原始记录查出来
select * from raw_transactions where invoice like 'C%' and quantity > 0;

# 7.查出单价小于零的原始记录
select * from raw_transactions where price < 0;

# 8.查看单价为零的记录具体是什么内容
select * from raw_transactions where price = 0 and source_sheet = 'Year 2009-2010' order by source_row limit 0, 10;
select * from raw_transactions where price = 0 and source_sheet = 'Year 2010-2011' order by source_row limit 0, 10;

# 9.检查全部零单价记录中，有多少条带有客户编号
select source_sheet,count(*) total_count,
       sum(case when customer_id is null then 1 else 0 end) null_count,
       sum(case when customer_id is not null then 1 else 0 end) notnull_count
       from raw_transactions where price = 0 group by source_sheet;






