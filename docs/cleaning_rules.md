# 销售视图怎样从原表取数

原表有 **1,067,371 行**。按下述规则处理后，`eco_b_analytics.v_sales_transactions` 在两个工作表的完整期间保留 **1,015,088 行**。原表逐行保留，视图仍含全部 11 个字段，可以从 `raw_id`、`source_sheet` 和 `source_row` 查回来源。规则整理于 2026-11-13，视图定义和行数于次日核对。[清洗检查 SQL，第 1—7 项](../sql/04_cleaning_rules.sql) · [视图定义](../sql/05_create_sales_view.sql) · [原始数据质量检查](data_quality_report.md)

## 先选正向记录，再处理跨表覆盖

发票号不以 C 开头，`quantity > 0` 且 `price > 0`。数据库按大小写不敏感规则比较发票号。三个条件同时满足的行才进入初筛，交易是否已交付仍需其他凭证。客户编号为空时先保留，后续按客户算复购或集中度时再筛。

2010-12-01 08:26:00 至 2010-12-09 20:01:00 两端均计入重叠段，保留 `Year 2010-2011`。第一张表在这段时间原有 22,523 行，通过正向初筛的有 22,016 行，所以这一步扣 22,016 行。

| 工作表 | 初筛行数 | 其中跨表排除行数 | 保留行数 |
|---|---:|---:|---:|
| Year 2009-2010 | 511565 | 22016 | 489549 |
| Year 2010-2011 | 530105 | 0 | 530105 |
| 合计 | 1041670 | 22016 | 1019654 |

## 同一张表出现多条同值明细怎么办

按 `source_sheet` 和八个业务字段分组，沿用数据库的字段类型与文本比较规则。`raw_id`、`source_row` 用来追溯来源，不进入业务分组。

| 工作表 | 多行同值组合数 | 涉及明细行数 | 假设每组保留一行，会减少的行数 |
|---|---:|---:|---:|
| Year 2009-2010 | 6094 | 12609 | 6515 |
| Year 2010-2011 | 4842 | 10068 | 5226 |

最后一列展示了强行每组只留一行的代价。公开数据缺少行项目编号来判断相同明细是否重复录入，因此两张表各自原有的出现次数都保留。这个取舍会影响件数和金额。

## 逐项检查字母开头的编码

上一步保留的数据里，SQL 第 5 项找出了 **4,709 行、40 个编码与描述组合**。`POST` 是邮费，`DCGS0068` 却是宠物项圈，只看首字符会错删实物。视图按明细表里的编码名单筛选。表中保留原描述，包括银行手续费的前导空格和手工调整的尾部空格。

| 商品编码 | 商品描述（原值） | 明细行数 | 视图处理 | 判断理由 |
|---|---|---:|---|---|
| `POST` | `POSTAGE` | 1851 | 排除 | 邮费 |
| `DOT` | `DOTCOM POSTAGE` | 1415 | 排除 | 网店邮费 |
| `C2` | `CARRIAGE` | 267 | 排除 | 运输费 |
| `BANK CHARGES` | ` Bank Charges` | 2 | 排除 | 银行手续费，描述带前导空格 |
| `BANK CHARGES` | `Bank Charges` | 32 | 排除 | 银行手续费 |
| `AMAZONFEE` | `AMAZON FEE` | 3 | 排除 | 平台费用，具体收费项目未知 |
| `D` | `Discount` | 5 | 排除 | 折扣 |
| `ADJUST` | `Adjustment by john on 26/01/2010 16` | 20 | 排除 | 手工调整，原因未知 |
| `ADJUST` | `Adjustment by john on 26/01/2010 17` | 16 | 排除 | 同编码下的另一条调整描述 |
| `ADJUST2` | `Adjustment by Peter on Jun 25 2010 ` | 3 | 排除 | 手工调整，描述末尾有空格 |
| `B` | `Adjust bad debt` | 1 | 排除 | 坏账调整，此行单价为正 |
| `TEST001` | `This is a test product.` | 9 | 排除 | 测试商品 |
| `TEST002` | `This is a test product.` | 1 | 排除 | 测试商品 |
| `M` | `Manual` | 861 | 暂缓纳入 | 手工记账，用途不明 |
| `S` | `SAMPLES` | 3 | 暂缓纳入 | 样品，有数量且单价为正 |
| `gift_0001_10` | `Dotcomgiftshop Gift Voucher £10.00` | 14 | 排除 | 礼券，按面额单列 |
| `gift_0001_20` | `Dotcomgiftshop Gift Voucher £20.00` | 26 | 排除 | 礼券，按面额单列 |
| `gift_0001_30` | `Dotcomgiftshop Gift Voucher £30.00` | 24 | 排除 | 礼券，按面额单列 |
| `gift_0001_40` | `Dotcomgiftshop Gift Voucher £40.00` | 5 | 排除 | 礼券，按面额单列 |
| `gift_0001_50` | `Dotcomgiftshop Gift Voucher £50.00` | 6 | 排除 | 礼券，按面额单列 |
| `gift_0001_70` | `Dotcomgiftshop Gift Voucher £70.00` | 1 | 排除 | 礼券，按面额单列 |
| `gift_0001_80` | `Dotcomgiftshop Gift Voucher £80.00` | 1 | 排除 | 礼券，按面额单列 |
| `DCGS0058` | `MISO PRETTY  GUM` | 30 | 保留 | 具体商品，未见仅因编码形式而排除的依据 |
| `DCGS0068` | `DOGS NIGHT COLLAR` | 2 | 保留 | 宠物项圈 |
| `DCGS0004` | `HAYNES CAMPER SHOULDER BAG` | 4 | 保留 | 肩包 |
| `DCGS0076` | `SUNJAR LED NIGHT NIGHT LIGHT` | 14 | 保留 | 灯具 |
| `DCGS0003` | `BOXED GLASS ASHTRAY` | 13 | 保留 | 玻璃烟灰缸 |
| `DCGS0072` | `CAT CAMOUFLAGUE COLLAR` | 3 | 保留 | 宠物项圈 |
| `DCGS0044` | `HANDZ-OFF CAR FRESHENER` | 1 | 保留 | 车用香氛商品 |
| `DCGS0066N` | `NAVY CUDDLES DOG HOODIE` | 2 | 保留 | 宠物服装 |
| `PADS` | `PADS TO MATCH ALL CUSHIONS` | 17 | 保留 | 与靠垫配套的垫芯或垫子 |
| `DCGS0069` | `OOH LA LA DOGS COLLAR` | 5 | 保留 | 宠物项圈 |
| `DCGS0070` | `CAMOUFLAGE DOG COLLAR` | 2 | 保留 | 宠物项圈 |
| `DCGS0075` | `CAMOUFLAGUE DOG LEAD` | 1 | 保留 | 宠物牵引绳 |
| `DCGS0041` | `HAYNES MINI-COOPER PLAYING CARDS` | 1 | 保留 | 扑克牌 |
| `DCGS0037` | `KEY-RING CORKSCREW` | 1 | 保留 | 钥匙圈开瓶器 |
| `DCGSSBOY` | `BOYS PARTY BAG` | 21 | 保留 | 派对袋 |
| `DCGSSGIRL` | `GIRLS PARTY BAG` | 23 | 保留 | 派对袋 |
| `SP1002` | `KID'S CHALKBOARD/EASEL` | 2 | 保留 | 儿童黑板或画架 |
| `DCGS0062` | `ROAD-RAGE CAR FRESHENER` | 1 | 保留 | 车用香氛商品 |

其中 **143 行**作为实物保留，**3,702 行**因费用、调整、测试项目或礼券等原因排除。另有 **864 行**属于 `M` 和 `S`，用途待确认，暂不进视图。礼券仍有交易价值，这次单列是因为推广对象限于实物。以上判断依据公开描述，未获企业凭证确认；数字开头的编码也不能仅凭外形认定用途。

## 按工作表对账

| 工作表 | 初筛并排除跨表覆盖后 | 非商品等分类排除 | 待确认暂不纳入 | 视图保留行数 |
|---|---:|---:|---:|---:|
| Year 2009-2010 | 489549 | 1682 | 540 | 487327 |
| Year 2010-2011 | 530105 | 2020 | 324 | 527761 |
| 合计 | 1019654 | 3702 | 864 | 1015088 |

例如第一张表：489,549 − 1,682 − 540 = 487,327。下游统计每款商品的件数时累加 `quantity`，统计购买次数时对 `invoice` 去重，同一发票上的同款多行只计一次。分析全年经营或客户行为时还需加上对应日期；上表是视图的全时段行数。

原表导入后，先运行 [04_cleaning_rules.sql](../sql/04_cleaning_rules.sql) 核对计数。库中尚无同名视图时，再运行 [05_create_sales_view.sql](../sql/05_create_sales_view.sql)。已有视图可以直接查，源数据变动后应重新对账。

```sql
select source_sheet, count(*) as total_count
from eco_b_analytics.v_sales_transactions
group by source_sheet;
```
