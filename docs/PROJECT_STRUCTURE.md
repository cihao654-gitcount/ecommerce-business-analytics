# Project Structure Guide

项目目录结构说明文档，用于记录各文件夹和核心配置文件的用途。

## 1. Directory Structure

```text
ecommerce-business-analytics/
│
├── data/
│   ├── raw/
│   └── processed/
│
├── sql/
├── notebooks/
├── src/
│
├── reports/
│   └── figures/
│
├── dashboards/
├── docs/
│
├── README.md
├── requirements.txt
└── .gitignore
```

## 2. Directory Description

| Directory | Description |
|---|---|
| data/raw/ | 存放从公开数据源获取的原始数据，原则上不直接修改 |
| data/processed/ | 存放经过清洗、转换和处理后的数据 |
| sql/ | 存放 MySQL 建表语句、数据处理 SQL 和业务分析查询 |
| notebooks/ | 存放 Jupyter Notebook，用于探索性数据分析（EDA）和统计分析 |
| src/ | 存放正式的 Python 项目代码和可复用的数据处理模块 |
| reports/ | 存放最终业务分析报告 |
| reports/figures/ | 存放分析过程中生成的图表和可视化图片 |
| dashboards/ | 存放 Power BI 仪表板文件（.pbix）及相关成果 |
| docs/ | 存放项目设计文档、数据字典、指标定义和技术说明 |

## 3. Important File Description

| File | Description |
|---|---|
| README.md | 项目主页，介绍业务背景、技术栈、分析过程和项目成果 |
| requirements.txt | 记录 Python 项目依赖的第三方库及版本 |
| .gitignore | 配置 Git 忽略规则，避免上传缓存、虚拟环境和敏感文件 |
| .gitkeep | 占位文件，用于让 Git 保留尚无其他文件的空目录 |

## 4. Development Principles

1. 原始数据与处理后的数据分开存放。
2. SQL 查询和 Python 核心代码分开管理。
3. 探索性分析与正式业务代码分开管理。
4. 分析结果必须能够追溯到对应的数据和计算过程。
5. 不上传数据库密码、API 密钥及其他敏感信息。
6. 重要代码、文档和分析成果统一使用 Git 进行版本管理。

## 5. Maintenance

当项目目录结构发生变化时，应同步更新本文档，确保项目结构与实际文件保持一致。