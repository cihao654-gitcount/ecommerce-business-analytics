# E-commerce Business Analytics

An end-to-end e-commerce business analytics project using SQL, Python, pandas, and Power BI.

**Project Status:** In Progress

## 1. Project Overview

This project aims to analyze e-commerce business data to identify sales trends, understand customer purchasing behavior, evaluate customer retention, and discover potential business improvement opportunities.

The project covers the complete data analytics workflow, from data extraction and cleaning to business analysis, visualization, and reporting.

## 2. Business Objectives

The main objectives of this project are:

- Analyze sales performance and order trends.
- Understand customer purchasing behavior.
- Evaluate customer retention and repeat purchase patterns.
- Identify potential factors affecting business performance.
- Develop data-driven business recommendations.

## 3. Dataset


- Dataset Source: Online Retail II
- Data Coverage: 2009-12-01 至 2011-12-09
- Data License: CC BY 4.0（知识共享署名 4.0 国际）
- Data Format: 	Excel 工作簿（.xlsx）/online_retail_II.xlsx/Year 2009-2010,Year 2010-2011
- Official Source: [Online Retail II — UCI Machine Learning Repository](https://archive.ics.uci.edu/dataset/502/online+retail+ii)
- License Requirements: 按照 [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) 使用及分享数据时，需要适当署名、提供许可证链接，并注明是否对数据进行了修改。
## 4. Technology Stack

| Technology | Purpose |
|---|---|
| MySQL | Data storage and SQL analysis |
| Python 3.12 | Data processing and analysis |
| pandas | Data cleaning and manipulation |
| NumPy | Numerical computation |
| Jupyter Notebook | Exploratory Data Analysis |
| Matplotlib / Seaborn | Data visualization |
| Power BI | Business intelligence dashboards |
| Git / GitHub | Version control and project management |

## 5. Project Workflow

1. Business Understanding
2. Data Collection and Database Design
3. Data Cleaning and Quality Validation
4. SQL-Based Data Analysis
5. Exploratory Data Analysis (EDA)
6. Business Metrics Analysis
7. Power BI Dashboard Development
8. Business Insights and Recommendations

## 6. Project Structure

```text
ecommerce-business-analytics/
├── data/
│   ├── raw/
│   └── processed/
├── sql/
├── notebooks/
├── src/
├── reports/
│   └── figures/
├── dashboards/
├── docs/
├── README.md
├── requirements.txt
└── .gitignore
```

## 7. Key Findings

To be completed after the analysis.

## 8. Business Recommendations

To be completed after validating the analytical findings.

## 9. How to Run

当前可运行内容为 `notebooks/01_data_overview.ipynb`：读取两个工作表、查看字段与样例，并统计客户编号缺失的明细行数和比例。SQL 分析和 Power BI 看板将在后续阶段补充。

### 9.1 准备 Python 环境

当前项目使用 Windows 和 Python 3.12.10。以下命令均在项目根目录（包含 `README.md` 和 `requirements.txt` 的文件夹）的 PowerShell 终端中执行。

如果尚未创建虚拟环境，在安装 Python 3.12 后执行；已有可用 `.venv` 时跳过：

```powershell
py -3.12 -m venv .venv
```

首次准备环境或依赖清单变更时，使用项目解释器安装依赖：

```powershell
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
```

上述命令不需要先激活虚拟环境。`openpyxl` 用于读取本项目的 Excel 文件。当前依赖清单尚未全部固定版本，因此不能保证未来重新安装时得到完全一致的环境；新环境完整复现仍待验收。

### 9.2 准备原始数据

从第 3 节的 UCI 官方链接下载 Online Retail II，解压后将工作簿保存到：

```text
data/raw/online_retail_II.xlsx
```

保留原始 Excel 格式与文件内容，不要通过修改扩展名将其当作 CSV。工作簿应包含 `Year 2009-2010` 和 `Year 2010-2011` 两个工作表。原始数据目录已设置 Git 忽略规则，取得代码后需要另行准备数据。

### 9.3 打开 Notebook 并核对运行位置

可以在 PyCharm 中打开项目和 `notebooks/01_data_overview.ipynb`，将 Notebook 内核关联到项目的 `.venv/Scripts/python.exe`。也可以在项目根目录运行以下命令，通过浏览器打开该 Notebook：

```powershell
.\.venv\Scripts\python.exe -m notebook
```

选择项目虚拟环境对应的 Python 内核。先重启内核（暂不运行全部单元），再在一个临时代码单元中执行：

```python
import sys
from pathlib import Path

print(sys.executable)
print(Path.cwd())
```

解释器应指向本项目的 `.venv`。当前读取代码使用 `./data/raw/...`，因此运行工作目录必须是项目根目录；相对路径以工作目录为基准，并非始终以 Notebook 文件所在目录为基准。

如果输出已经是项目根目录，无需调整。如果输出是项目内的 `notebooks` 文件夹，在临时单元执行 `%cd ..` 回到上一级，再次检查目录。如果输出是其他位置，先核对项目与 Jupyter 启动配置，不要直接套用 `%cd ..`。

### 9.4 顺序运行与核对结果

确认内核和工作目录后，执行“运行全部单元”（Run All），等待完成并保存 Notebook。此时不要再次重启内核；以后重启时，应重新核对工作目录。

预期所有代码单元无报错，两个工作表各有 8 个字段，并得到以下原始数据初查结果：

| 工作表 | 明细行数 | Customer ID 缺失明细行数 | 缺失明细行占比 |
|---|---:|---:|---:|
| Year 2009-2010 | 525,461 | 107,927 | 20.5395% |
| Year 2010-2011 | 541,910 | 135,080 | 24.9266% |

以上均为原始明细行统计，缺失明细行数不等于缺失客户人数。两张表尚未合并、清洗或去重。

若提示文件不存在，先检查工作目录、文件名和数据位置；若提示缺少模块，先核对 Notebook 使用的解释器是否为项目虚拟环境，再检查依赖安装情况。

## 10. Limitations

Dataset limitations, analytical assumptions, and potential biases will be documented after data validation.

## 11. Author

Personal data analytics portfolio project.