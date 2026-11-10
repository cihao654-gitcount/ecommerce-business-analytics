use eco_b_analytics;
# 按照source_sheet分组查看明细行数，不同source_row的数量，最小、最大source_row，customer_id缺失的明细行数
select source_sheet,count(*) total_row, count(distinct source_row) dif_row,
max(source_row) max_row, min(source_row) min_row,
sum(case when customer_id is null then 1 else 0 end) null_count
from raw_transactions group by source_sheet;

# 做一次原始值抽样对账，目的在于对比查到的数据库数据与原始excel数据是否一致
select * from raw_transactions where source_sheet = 'Year 2009-2010' and source_row in (2, 525462);
select * from raw_transactions where source_sheet = 'Year 2010-2011' and source_row in (2, 541911);

-- 导入校验结果（2026-11-10）
-- 工作表 | 明细数 | 不同来源行号数 | 最小行号 | 最大行号 | 客户编号缺失数
-- Year 2009-2010 | 525461 | 525461 | 2 | 525462 | 107927
-- Year 2010-2011 | 541910 | 541910 | 2 | 541911 | 135080
-- 合计原始明细：1067371 行。

-- 人工抽样：分别对照两个工作表首尾记录，共 4 条，
-- 8 个业务字段与 Excel 一致。




