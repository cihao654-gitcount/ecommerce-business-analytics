# Day 14｜项目交接与复现记录

2026 年 11 月 24 日，Windows。本次用提交 `859dcaf` 对应的本地项目、已有 Python 环境和原始 Excel，从一个新建的空 MySQL 库开始复算。交接时要分清两件事：这台机器能否重算出相同结果，另一位同事换目录、换环境后能否照着做。

## 复算用了什么

| 项目 | 实际使用 |
|---|---|
| 数据 | UCI Online Retail II，两个工作表。本地工作簿大小 45,622,278 字节，SHA-256 为 `BCBE73B35F5B7BABF197FB0CB983A11F5D9FF929078D4AA53D171B1F2DF2E980`。 |
| 解释器与数据库 | Python 3.12.10、MySQL 8.0.46、utf8mb4。测试库为 `eco_day14_20261124_151506_549214`。 |
| 分析依赖 | pandas 3.1.1、NumPy 2.5.4、openpyxl 3.1.5、SQLAlchemy 2.1.8、PyMySQL 1.2.3、python-dotenv 1.2.4。现有虚拟环境运行 `pip check` 通过。 |
| 核对基准 | 全数据视图行数、12 个月经营指标、三款午餐袋的商品级汇总、RED 的缺编号情景。全年范围含 2010-12-01、不含 2011-12-01。[指标及原对账值](metric_definitions.md) |

## 接手后按什么顺序运行

1. **准备输入。** 从 [UCI 数据集](https://doi.org/10.24432/C5CG6D) 下载工作簿并放到 `data/raw/online_retail_II.xlsx`。在项目根目录按 [README](../README.md) 准备 Python 环境。数据库连接用本地 `.env`，需设置 `DB_HOST`、`DB_PORT`、`DB_USER`、`DB_PASSWORD`、`DB_NAME`。
2. **建表、验连接、导入。** 使用一个新库，先把 SQL 副本中的固定库名 `eco_b_analytics` 和 Python 进程的 `DB_NAME` 都指向该库。运行 [01 建表](../sql/01_create_raw_table.sql)，再运行 `python src/check_db_connection.py`，看到预期库名后执行 `python src/import_raw_data.py`。导入脚本会检查目标表是否为空。
3. **从原表得到分析视图。** 依序执行 [02 导入核对](../sql/02_validate_import.sql)、[03 质量检查](../sql/03_data_quality_checks.sql)、[04 清洗规则](../sql/04_cleaning_rules.sql) 和 [05 创建视图](../sql/05_create_sales_view.sql)。05 使用 `CREATE VIEW`，此步骤适用于尚未建过该视图的库。
4. **复算结果。** 执行 [06 经营指标](../sql/06_product_metrics.sql) 和 [07 阶段核对](../sql/07_stage_assessment.sql)。Notebook 从项目根目录按 01 至 05 顺序运行。01 读 Excel，02 比较 SQL 和 pandas 的去重结果，03、04 分别导出 `repeat_ratio.csv`、`top5_ratio.csv`，05 检查缺少客户编号的销量对结论有多大影响。换机器前，把 02 至 05 中的绝对配置路径和 03、04 的导出路径改为本机项目位置。
5. **看报表。** 可直接打开 [PDF](../dashboards/ecommerce_sales_analysis.pdf) 或 [Power BI 文件](../dashboards/ecommerce_sales_analysis.pbix)。要在新电脑刷新，先确认 MySQL 连接目标和两个 CSV 的源路径。打开已有 PDF 只能验证交付物可读。刷新验证还需单独进行。

## 本次核对结果

7 份编号 SQL 全部在测试库执行完毕。建表脚本由空库创建步骤接管建库语句，其余 SQL 仅在测试副本中改了目标库名。连接检查和 Excel 导入使用项目原脚本。

| 对账项 | 新库实测 | 对照结果 |
|---|---:|---|
| 两张工作表导入行数 | 525,461 ＋ 541,910 ＝ 1,067,371 | 两个来源分别一致 |
| 清洗视图，全时段 | 1,015,088 行 | 与[清洗记录](cleaning_rules.md)一致 |
| 主分析期明细、不同发票 | 502,730 行、18,957 张 | 一致 |
| 主分析期销量、正向交易金额 | 5,263,820 件、9,655,939.793 英镑 | 一致，报表展示 9,655,939.79 英镑 |
| 有客户编号的明细 | 379,098 行 | 明细覆盖率 75.41% |
| 2011 年 11 月重复购买核验 | 4,629 个客户与商品组合、412 名不同客户 | 与[阶段核对记录](day07_assessment.md)一致 |
| 两份 Power BI 商品汇总 CSV | 三款商品的各列与原文件一致 | 按商品编码排序后比较，包括描述、人数、销量和比例 |
| RED 缺编号情景 | 已确认 17.90%，极端假设 26.34% | 与[情景计算](../notebooks/05_robustness_checks.ipynb)一致 |

5 份 Notebook 的 Python 代码按单元顺序重跑，每份使用独立变量空间。测试进程覆盖了目标库名，两份 CSV 的输出在执行时指向临时目录，从而可以和旧文件逐列比较。本次使用已有项目解释器，没有另建 Jupyter 内核或重新安装依赖。

## 公开前的检查

检查时，本地分支比本机记录的 `origin/main` 超前 13 个提交。对提交中的 Markdown 核对了 52 处本地引用，其中 1 处链接的目标未被纳入该提交。Git 跟踪了 33 个文件，包含业务报告、PBIX 和 PDF。最大文件是 PBIX，14,891,133 字节。[15 天任务清单](original_15_day_plan.md) 当时未跟踪，但目录说明引用了它。据此版本交接需将清单纳入版本管理，或调整引用。

`.env`、原始 Excel 和两份派生 CSV 均由 Git 忽略。接手人需要自己下载原表并重算 CSV。当前跟踪文本、本地引用可达历史中的 41 个文本对象，以及 PBIX 中的 18 个 JSON 文件经检查，没有命中本地数据库口令及本次检查的常见明文凭据模式。检查范围未覆盖 PBIX 的压缩模型内部和远端服务器设置。发布 PBIX 前还要在 Power BI Desktop 检查数据源设置与模型中的客户级明细。若只对外展示汇总，PDF 已能阅读两页结果。

业务报告已列出原数据作者 Daqing Chen、UCI 数据集、CC BY 4.0 许可及项目对数据所作的处理。[业务报告与署名](../reports/business_analysis_report.md)

## 交接结论

**本机空库复算通过，跨机器交接有条件通过。** 48 个 Notebook 代码单元及两份输出表已核对。当前最直接的移交障碍是四份 Notebook 写死本机的配置路径，其中两份还写死 CSV 路径。建议统一从项目目录定位文件，按表中实测版本补充依赖信息，并把缺失的文档引用纳入同一提交。接手人随后可在另一个目录、新虚拟环境下重跑并刷新 Power BI，再记录一次结果。

此次检查使用独立库，保留该库供本地追查。SQL 逻辑、原始分析库、Notebook 和交付 CSV 均未改写。没有提交或发布操作。

