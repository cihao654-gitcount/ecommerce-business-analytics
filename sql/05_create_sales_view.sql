use eco_b_analytics;
# 确定最终筛选规则，创建视图v_sales_transactions筛选出有效数据
# 视图就是把一条查询保存到数据库里，并给它起一个名字。以后可以像查询表一样使用它，不用每次重写那一长串筛选条件。
# 视图保存的是查询逻辑，不是另存一份数据。原表数据变化后，再查询视图，结果也会随之变化
create view v_sales_transactions as select *
from raw_transactions
where invoice not like 'C%' and quantity > 0 and price > 0
and not (source_sheet = 'Year 2009-2010' and invoice_date between '2010-12-01 08:26:00'
                                                              and '2010-12-09 20:01:00')
and not (stock_code in ('POST','DOT','C2','BANK CHARGES','AMAZONFEE',
'D','ADJUST','ADJUST2','B','TEST001','TEST002','gift_0001_10','gift_0001_20','gift_0001_30',
'gift_0001_40','gift_0001_50','gift_0001_70','gift_0001_80'))
and not (stock_code in ('M', 'S'));
select * from v_sales_transactions limit 0,5;