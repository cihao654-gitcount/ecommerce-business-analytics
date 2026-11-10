from sqlalchemy import create_engine
from sqlalchemy import URL
from sqlalchemy import text
from pathlib import Path
import os
from dotenv import load_dotenv
project_root = Path(__file__).resolve().parent.parent # - __file__：当前脚本的位置,第一个parent得到src文件夹,第二个parent得到项目根目录
data_path = project_root / "data" / "raw" / "online_retail_II.xlsx" # 拼接数据路径
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
with engine.connect() as conn:
    result = conn.execute(text("select database(), version()"))
    print(result.fetchall())