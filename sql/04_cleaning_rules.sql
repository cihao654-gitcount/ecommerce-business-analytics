use eco_b_analytics;

# 1.完成正常销售记录的初筛计数
select source_sheet,
       sum(case when invoice not like 'C%' and quantity > 0 and price > 0 then 1 else 0 end) total_count
from raw_transactions group by source_sheet;

# 2.在查询结果中排除跨表重复覆盖
select source_sheet,count(*) total_count
from raw_transactions
where invoice not like 'C%' and quantity > 0 and price > 0
and not (source_sheet = 'Year 2009-2010' and invoice_date between '2010-12-01 08:26:00'
                                                              and '2010-12-09 20:01:00')
group by source_sheet;

# 3.检查同一工作表内部的同值记录
with a as(select source_sheet,count(*) total_count
from raw_transactions
where invoice not like 'C%' and quantity > 0 and price > 0
and not (source_sheet = 'Year 2009-2010' and invoice_date between '2010-12-01 08:26:00'
                                                              and '2010-12-09 20:01:00')
group by invoice, stock_code, description, quantity,
         invoice_date, price, customer_id, country, source_sheet)
select source_sheet, count(*) identical_count from a where total_count > 1 group by source_sheet;

# 4.在这条查询的结果中增加两列：
# - 这些组合一共涉及多少条明细。
# - 假设每组只保留一条，会减少多少条明细
with a as(select source_sheet,count(*) total_count
from raw_transactions
where invoice not like 'C%' and quantity > 0 and price > 0
and not (source_sheet = 'Year 2009-2010' and invoice_date between '2010-12-01 08:26:00'
                                                              and '2010-12-09 20:01:00')
group by invoice, stock_code, description, quantity,
         invoice_date, price, customer_id, country, source_sheet)
select source_sheet, sum(total_count) total_row, count(*) identical_count,
       sum(total_count) - count(*) reduce_row
from a where total_count > 1 group by source_sheet;

# 5.检查可能混入的非商品项目
# 查看是否包含运费、手工调整等项目；编码不以数字开头本身不是删除理由
select stock_code, description, count(*)
from raw_transactions
where invoice not like 'C%' and quantity > 0 and price > 0
and not (source_sheet = 'Year 2009-2010' and invoice_date between '2010-12-01 08:26:00'
                                                              and '2010-12-09 20:01:00')
and stock_code not regexp '^[0-9]'
group by stock_code, description ;

# 6.按工作表统计“建议排除”和“待确认”两类各有多少行
select source_sheet,
       sum(case when stock_code in ('POST','DOT','C2','BANK CHARGES','AMAZONFEE',
'D','ADJUST','ADJUST2','B','TEST001','TEST002','gift_0001_10','gift_0001_20','gift_0001_30',
'gift_0001_40','gift_0001_50','gift_0001_70','gift_0001_80') then 1 else 0 end) suggestion,
       sum(case when stock_code in ('M', 'S') then 1 else 0 end) wait_confirm
from raw_transactions
where invoice not like 'C%' and quantity > 0 and price > 0
and not (source_sheet = 'Year 2009-2010' and invoice_date between '2010-12-01 08:26:00'
                                                              and '2010-12-09 20:01:00')
group by source_sheet;

# 7.以第 2 项保留范围为基础，排除“建议排除”名单中的编码，
# 并将待确认的 M、S 暂时排除出主分析，按工作表统计剩余行数
select source_sheet,count(*) total_count
from raw_transactions
where invoice not like 'C%' and quantity > 0 and price > 0
and not (source_sheet = 'Year 2009-2010' and invoice_date between '2010-12-01 08:26:00'
                                                              and '2010-12-09 20:01:00')
and not (stock_code in ('POST','DOT','C2','BANK CHARGES','AMAZONFEE',
'D','ADJUST','ADJUST2','B','TEST001','TEST002','gift_0001_10','gift_0001_20','gift_0001_30',
'gift_0001_40','gift_0001_50','gift_0001_70','gift_0001_80'))
and not (stock_code in ('M', 'S'))
group by source_sheet;




