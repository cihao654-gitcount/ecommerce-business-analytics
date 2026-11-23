# 项目文件放在哪里

看分析结论，从 [业务报告](../reports/business_analysis_report.md) 开始。想核对某个数字，则从对应的 SQL 或 Notebook 入手。

| 想找什么 | 去哪里 |
|---|---|
| 原始交易与导入 | 两张原表都在本地工作簿 `data/raw/online_retail_II.xlsx`。表结构见 [01_create_raw_table.sql](../sql/01_create_raw_table.sql)，导入程序见 [import_raw_data.py](../src/import_raw_data.py)。每行保留工作表名称和原始行号。 |
| 为什么保留或排除某条记录 | [数据质量检查](data_quality_report.md) 有异常样例和行号。[清洗规则](cleaning_rules.md) 记录最终取舍，[05_create_sales_view.sql](../sql/05_create_sales_view.sql) 是数据库实际使用的筛选逻辑。 |
| 经营指标 | [06_product_metrics.sql](../sql/06_product_metrics.sql) 按商品汇总数量、金额、发票数，也统计各国客户数。[指标定义](metric_definitions.md) 列出分母和对账值。 |
| 三款午餐袋是怎么选出来的 | [购买频次](../notebooks/03_customer_purchase_frequency.ipynb)、[客户集中度](../notebooks/04_customer_concentration.ipynb)、[缺失编号情景](../notebooks/05_robustness_checks.ipynb)。汇总数据放在 `data/processed/`。 |
| 报告和图表 | `reports/` 放报告，`reports/figures/` 留给报告插图。`dashboards/` 里有可交互的 Power BI 文件和可以直接阅读的 [PDF](../dashboards/ecommerce_sales_analysis.pdf)。 |
| 学习过程 | [启动时的 15 天安排](original_15_day_plan.md) 和 [Day 7 评估](day07_assessment.md) 单独保留，方便回看当时的任务和独立完成情况。 |

根目录的 [README](../README.md) 是项目入口，[requirements.txt](../requirements.txt) 列出 Python 依赖。数据库连接信息放在本地 `.env`，由 `.gitignore` 排除。空目录里的 `.gitkeep` 只是 Git 占位文件。
