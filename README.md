# POC Doanh thu bảo hiểm v2: dữ liệu nguồn dummy có căn cứ public

**Phạm vi:** sinh **dữ liệu nguồn** giả lập, gồm danh mục và giao dịch bảo hiểm, đủ thông tin để phân tích doanh thu theo 6 chiều: Thời gian, Kênh bán, Nghiệp vụ, Sản phẩm, Đơn vị, Khách hàng.

Mọi danh mục, quy tắc và con số đều có căn cứ từ **nguồn public**: luật, nghị định, thông tư, số liệu IAV và MOF, sản phẩm công khai của các DNBH, các chuẩn mô hình dữ liệu ngành. Bộ dữ liệu **không** chứa dữ liệu nội bộ của khách hàng.

## Các file

Mọi file SQL đều viết cho **PostgreSQL ≥ 12**. Đã chạy thử trên PostgreSQL 16.2.

| File | Nội dung |
|---|---|
| [01_ddl.sql](01_ddl.sql) | Tạo 2 schema: `ref` (16 bảng danh mục) và `core` (5 bảng giao dịch) |
| [01b_column_comments.sql](01b_column_comments.sql) | `COMMENT ON TABLE/COLUMN` tiếng Việt cho 21 bảng, 114 cột. Không bắt buộc, nhưng giúp các công cụ như DBeaver hay pgAdmin hiển thị mô tả |
| [02_data.sql](02_data.sql) | Dữ liệu dummy 2024–2025 dạng INSERT, gói trong một transaction |
| [build_v2.py](build_v2.py) | Script sinh dữ liệu. Seed cố định, không cần kết nối DB |
| [docs/POC_Doanh_thu_BH_v2.html](docs/POC_Doanh_thu_BH_v2.html) | **Tài liệu tổng hợp trong 1 file HTML**: tổng quan, căn cứ thiết kế, data dictionary (có ô lọc), nguồn, phụ lục DDL |
| [docs/Data_Dictionary_v2.xlsx](docs/Data_Dictionary_v2.xlsx) | **Data dictionary Excel**. Mỗi bảng có 1 sheet riêng (tên = `schema.bảng`) gồm thông tin bảng, danh sách cột, khóa ngoại vào/ra và 5 dòng mẫu. Kèm các sheet tổng quan bảng, quan hệ FK, quy tắc nghiệp vụ, kịch bản dữ liệu, danh mục mã |
| [docs/build_docs.py](docs/build_docs.py) + [docs/dictionary_meta.py](docs/dictionary_meta.py) | Script sinh lại HTML, Excel và file comment từ catalog PostgreSQL. Mô tả cột sửa duy nhất ở `dictionary_meta.py` |
| [DESIGN_RATIONALE.md](DESIGN_RATIONALE.md) | **Căn cứ của từng bảng, quy tắc, tham số** và bộ hỏi đáp "Tại sao…" |
| [GENERATION_LOGIC.md](GENERATION_LOGIC.md) | **Logic sinh dữ liệu**: mỗi nghiệp vụ bao nhiêu % doanh thu, bao nhiêu đơn, mỗi đơn bao nhiêu tiền — neo theo BCTC công khai của PVI |
| [docs/Mapping_v2_PIAS.html](docs/Mapping_v2_PIAS.html) | **Mapping v2 ↔ PIAS** có bằng chứng kiểm chứng từng dòng, bảng đối chiếu mã, câu hỏi BA. **Tài liệu nội bộ dự án.** Sinh lại: `python docs/build_mapping.py` (nội dung ở `docs/mapping_meta.py`) |
| [sources/](sources/) | Nguồn pháp lý, số liệu thị trường, chuẩn quốc tế (kèm URL) |

## Cách chạy (PostgreSQL)

Chạy trong thư mục `v2`. Tạo database:

```bash
createdb ins_revenue_poc
```

Tạo bảng:

```bash
psql -d ins_revenue_poc -v ON_ERROR_STOP=1 -f 01_ddl.sql
```

Thêm mô tả bảng và cột (không bắt buộc):

```bash
psql -d ins_revenue_poc -v ON_ERROR_STOP=1 -f 01b_column_comments.sql
```

Nạp dữ liệu:

```bash
psql -d ins_revenue_poc -v ON_ERROR_STOP=1 -f 02_data.sql
```

Muốn dựng lại từ đầu thì bỏ comment dòng `DROP SCHEMA … CASCADE` ở đầu `01_ddl.sql`.

> Lưu ý trên Windows: với `psql` bản Windows, đặt các option (`-d`, `-f`, `-v`) **trước** mọi tham số khác. Option đặt sau chuỗi kết nối có thể bị bỏ qua.

Sinh lại dữ liệu:

```bash
python build_v2.py
```

Sinh lại tài liệu HTML, Excel và file comment. Script dùng PostgreSQL nhúng tạm thời, không cài gì vào máy. Muốn dùng Postgres có sẵn thì đặt biến `PG_URI` trước khi chạy.

```bash
uv run --python 3.11 --with pgserver --with "psycopg[binary]" --with markdown --with openpyxl python docs/build_docs.py
```

## Đặc điểm bộ dữ liệu

Đã chạy thử trên PostgreSQL 16.2. Các kiểm tra toàn vẹn sau đều bằng 0:
- hợp đồng có tỷ lệ đồng bảo hiểm cộng khác 100%;
- hợp đồng có tỷ lệ phân bổ doanh thu cộng khác 100%;
- dòng phí có hoa hồng vượt trần.

| Bảng | Số dòng |
|---|---:|
| `core.policy` (hợp đồng) | 28.902 |
| `core.policy_transaction` (giao dịch; gồm 1.719 SĐBS, hoàn phí, hủy) | 30.621 |
| `core.transaction_coverage` (dòng phí theo sản phẩm) | 34.605 |
| `ref.customer` (khách hàng) | 15.953 |

Quy mô và cơ cấu được hiệu chỉnh theo **số liệu công khai của PVI** (BCTC kiểm toán 2025). Cách làm từng bước xem [GENERATION_LOGIC.md](GENERATION_LOGIC.md). Doanh thu dưới đây tính trên dữ liệu nguồn theo công thức ở mục "Quy tắc doanh thu" của DESIGN_RATIONALE.

| Chỉ tiêu 2025 | Dữ liệu dummy | Mốc công khai |
|---|---:|---|
| Doanh thu phí gốc phạm vi POC | 10.237 tỷ | ≈ 10.378 tỷ (BCTC PVI 2025, 4 nhóm nghiệp vụ POC) |
| Tài sản (gồm cháy nổ) / Con người / Xe | 51,4% / 31,1% / 17,6% | 51,5% / 31,0% / 17,6% |
| Theo quý Q1 / Q2 / Q3 / Q4 | 28,3 / 23,0 / 26,4 / 22,3% | 29,7 / 24,1 / 24,8 / 21,4% (phí gốc PVI 2025) |
| Kênh điện tử / Bancassurance / Môi giới | 8,4% / 8,0% / 17,5% | ≈ 10% (BCTN PVI) / ước tính 5–8% / ước tính 15–20% |
| Khối Trụ sở trực tiếp khai thác | 1.370 tỷ | Mô hình Tổng công ty |
| 10% hợp đồng lớn nhất chiếm | 74% doanh thu | Dáng "ít đơn – nhiều tiền" của cháy nổ, tài sản, sức khỏe nhóm |

## Tình huống có sẵn trong dữ liệu

| Tình huống | Nhận diện | Lưu ý khi sử dụng |
|---|---|---|
| Đồng bảo hiểm (đứng đầu hoặc tham gia) | `core.coinsurance_share` có > 1 dòng / hợp đồng | Chỉ phần `OWN` là doanh thu của công ty |
| Phân bổ doanh thu cho nhiều đơn vị (hợp tác, Trụ sở, kênh số) | `core.revenue_allocation` | Doanh thu theo đơn vị được phân bổ |
| SĐBS tăng/giảm phí, hoàn phí, hủy | `txn_type_code` | Số âm/dương ghi vào kỳ phát sinh; tài khoản 5111 / 5311 / 5321 |
| Giao dịch `PENDING` / `VOID` | `status` | Không phải chứng từ hợp lệ |
| Hiệu lực sau ngày cấp (cả sang năm sau) | `accounting_date` > `txn_date` | Ghi nhận theo `accounting_date` |
| Đơn USD | `currency_code = 'USD'` | Quy đổi theo `fx_rate` của giao dịch |
| Đơn nhiều sản phẩm (vật chất xe + TNDS; cháy nổ + tài sản) | > 1 dòng `transaction_coverage` / giao dịch | Tách theo sản phẩm |
| Đơn lô giấy chứng nhận, "khách lẻ theo bảng kê" | `is_aggregated_retail` | Loại khi phân tích khách hàng định danh |
| Tái tục | `renewal_of_policy_id` | Liên kết hợp đồng năm trước |
| Kênh để trống (~0,5%) | `channel_code IS NULL` | Gán về "Chưa xác định" |
| Trung tâm Kinh doanh số không có tỉnh | `province_code IS NULL` | Vùng miền để trống |
