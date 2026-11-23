# 电商复购分析：哪款午餐袋值得先做提醒测试？

三款候选午餐袋的复购率都在 51% 左右。RED RETROSPOT 有 272 名可识别客户在观察期内再次购买，比 SUKI DESIGN 多 50 人。两款商品的前五大客户销量占比只差 0.68 个百分点。因此，这份报告建议先拿 RED 做小规模提醒测试。提醒到底能带来多少额外购买，还要靠对照组来判断。

[阅读业务报告](reports/business_analysis_report.md) · [查看两页看板（PDF）](dashboards/ecommerce_sales_analysis.pdf) · [打开 Power BI 文件](dashboards/ecommerce_sales_analysis.pbix)

## 数据和口径

这是基于公开交易记录的个人作品集项目。Daqing Chen 的 *Online Retail II* 收录了一家英国网络零售商从 2009 年 12 月 1 日到 2011 年 12 月 9 日的交易。本项目取其中 12 个完整月（2010 年 12 月至 2011 年 11 月）。两张工作表有九天重叠，入库时保留来源，分析时只取其中一份。商品交易金额按数量乘单价计算，未扣除后续退款。[UCI 原始数据](https://archive.ics.uci.edu/dataset/502/online+retail+ii) · [CC BY 4.0 许可](https://creativecommons.org/licenses/by/4.0/) · [清洗规则](docs/cleaning_rules.md)

几项容易混淆的数字：

- **18,957 张发票**覆盖 3,797 款商品。全店正向商品交易金额为 **9,655,939.79 英镑**。
- **复购**按同一客户、同一商品的不同发票计数。RED 有 524 名可识别购买客户，其中 272 人至少买过两次，复购率为 51.91%。
- **19.55%** 是 RED 前五大客户占已识别销量的比例。还有 1,616 件销量缺客户编号，实际买家未知。[指标定义与对账](docs/metric_definitions.md)

## 从哪里看计算过程

MySQL 负责存储交易明细、处理跨表重叠和计算经营指标。Python 和 pandas 用来核对客户购买次数、集中度和缺失编号的影响。Power BI 第一页可以按国家看全店交易，第二页比较三款候选商品。脚本、笔记本和结果文件的位置见[项目目录](docs/PROJECT_STRUCTURE.md)。

## 在 Windows 上查看原始数据

项目开发环境为 Python 3.12.10。下面的命令在项目根目录运行。已有虚拟环境时，从安装依赖开始。依赖清单只锁定了部分版本，整套项目的空库复现仍待验证。

```powershell
py -3.12 -m venv .venv
```

```powershell
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
```

从上面的 UCI 页面下载并解压工作簿，保留 Excel 格式，放在：

```text
data/raw/online_retail_II.xlsx
```

在 PyCharm 中打开 [01_data_overview.ipynb](notebooks/01_data_overview.ipynb)，选择项目的 `.venv` 内核，也可以从终端启动 Jupyter：

```powershell
.\.venv\Scripts\python.exe -m notebook
```

重启内核后，先确认解释器和工作目录：

```python
import sys
from pathlib import Path

print(sys.executable)
print(Path.cwd())
```

输入文件的相对路径从项目根目录起算。如果当前目录恰好是 `notebooks`，运行 `%cd ..` 即可回到根目录。找不到文件先检查位置，导入模块报错先检查内核。确认后从头运行所有单元，两张工作表应各有 8 列，行数如下。

| 工作表 | 明细行数 | Customer ID 缺失明细行数 | 缺失明细行占比 |
|---|---:|---:|---:|
| Year 2009-2010 | 525,461 | 107,927 | 20.5395% |
| Year 2010-2011 | 541,910 | 135,080 | 24.9266% |

这里数的是明细行。同一个客户可以有多行交易，无法从缺编号的行数倒推出缺了多少位客户。
