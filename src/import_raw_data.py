from pathlib import Path
import pandas as pd
from sqlalchemy import create_engine
from sqlalchemy import URL
from sqlalchemy import text
import os
from dotenv import load_dotenv


# 读取excel表中数据
project_root = Path(__file__).resolve().parent.parent
data_path = project_root / "data" / "raw" / "online_retail_II.xlsx"
sheet1 = pd.read_excel(data_path, sheet_name="Year 2009-2010")
sheet2 = pd.read_excel(data_path, sheet_name="Year 2010-2011")
for sheet_name, sheet in (("Year 2009-2010", sheet1),
                          ("Year 2010-2011",sheet2)):
    sheet.rename(columns={"Invoice": "invoice", "StockCode": "stock_code","Description": "description",
                          "Quantity": "quantity", "InvoiceDate": "invoice_date","Price": "price","Customer ID":"customer_id",
                          "Country": "country"}, inplace=True)
    sheet["source_sheet"] = sheet_name
    sheet["source_row"] = range(2, len(sheet) + 2)
print(sheet1.head())
print(sheet2.head())
print(len(sheet1))
print(len(sheet2))


# 将数据导入数据库
env_path = project_root / ".env"  # 读取项目根目录的.env
load_dotenv(dotenv_path=env_path)  # 把配置加载到当前Python进程的环境变量中
db_host = os.getenv("DB_HOST")
db_port = int(os.getenv("DB_PORT", "3306"))  # 这里的第二个参数3306是备用值，如果env文件中DB_PORT没有对应值就用备用值
db_user = os.getenv("DB_USER")
db_password = os.getenv("DB_PASSWORD")
db_name = os.getenv("DB_NAME")
db_url = URL.create(
    drivername="mysql+pymysql",
    host=db_host,
    port=db_port,
    username=db_user,
    password=db_password,
    database=db_name,
    query={"charset": "utf8mb4"}
)   # 构建连接配置
engine = create_engine(db_url)  # 创建连接引擎
with engine.begin() as conn:  # 开启一个事务
    result = conn.execute(text("select count(*) from raw_transactions"))
    row_count = result.scalar_one()  # 把查询返回的一行一列结果取成一个数值，返回给row_count
    if row_count > 0:
        raise ValueError("目标表中已有数据，请勿重复导入")  # 若表中已有数据，raise会抛出异常，停止后续执行，并让这个事务回滚
    else:
        for sheet in (sheet1, sheet2):  # 将两张工作表的数据写入表raw_transactions
            sheet.to_sql("raw_transactions", conn, if_exists="append",
                         index=False, chunksize=1000) # 参1：目标表名， 参2： 连接对象 参3： 若目标表已存在就将数据追加到后面  参4：不写入索引列  参5：一次写入1000条数据
print("写入成功！")



