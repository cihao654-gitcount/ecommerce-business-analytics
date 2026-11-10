create database if not exists eco_b_analytics;
use eco_b_analytics;
create table if not exists raw_transactions(
    raw_id int primary key auto_increment,
    invoice varchar(20),
    stock_code varchar(20),
    description varchar(255),
    quantity int,
    invoice_date datetime,
    price decimal(10, 3) , # 数据精度待实际验证
    customer_id int,
    country varchar(20),
    source_sheet varchar(20) not null ,
    source_row int not null  # 对应 Excel 实际行号，第一条数据为第 2 行，表头不导入
);
desc raw_transactions;
show create table raw_transactions;
select * from raw_transactions;