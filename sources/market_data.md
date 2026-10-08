# Nguồn số liệu công khai dùng để hiệu chỉnh dữ liệu dummy

Số liệu tra cứu ngày 07/10/2026.
- **[suy ra]**: tính từ các số đã có trích dẫn.
- **[ƯỚC TÍNH]**: giả định, chưa có nguồn xác minh.

## 1. Quy mô thị trường phi nhân thọ (doanh thu phí bảo hiểm gốc)

| Kỳ | Tỷ VND | Tăng trưởng | Nguồn |
|---|---:|---:|---|
| 2024 | 79.348 | +11,7% | IAV: https://iav.vn/tong-quan,-so-lieu-thi-truong-bao-hiem/254773-254773-mot-so-hoat-dong-noi-bat-cua-thi-truong-bao-hiem-viet-nam-ca-nam-2024 |
| 2024 (số của Bộ Tài chính) | 78.291 | +10,21% | MOF: https://mof.gov.vn/quan-ly-giam-sat-bao-hiem/thong-tin-thi-truong/mofucm346776 |
| 2025 | 88.054 | +10,95% | MOF Bản tin 01/2026: https://mof.gov.vn/quan-ly-giam-sat-bao-hiem/ban-tin-thi-truong-bao-hiem-toan-cau/ban-tin-thi-truong-bao-hiem-thang-12026 |

## 2. Cơ cấu theo nghiệp vụ

Nguồn: IAV 2024 và MOF 2025, cùng URL như mục 1.

| Nghiệp vụ | 2024 (tỷ) | % 2024 [suy ra] | 2025 (tỷ) | % 2025 |
|---|---:|---:|---:|---:|
| Sức khỏe (gồm tai nạn con người) | 28.744 | 36,2% | 31.676 | 35,97% |
| Xe cơ giới | 18.693 | 23,6% | 20.976 | 23,82% |
| – TNDS bắt buộc | 4.537 | 5,7% | | |
| – Xe tự nguyện | 14.155 | 17,8% | | |
| Cháy nổ (bắt buộc 9.923 + tự nguyện 6.714) | 16.637 | 21,0% | 13.544 | 15,38% |
| Tài sản | | | 8.559 | 9,72% |

**Cách áp vào dummy.** Bốn nghiệp vụ thuộc phạm vi POC năm 2025 cộng lại được 74.755 tỷ. Tỷ trọng giữa các nhóm POC được tính lại trên tổng này:

| Nhóm POC | Gồm | Tỷ trọng |
|---|---|---:|
| Con người | Sức khỏe | 42,4% |
| Xe | Xe cơ giới | 28,1% |
| Tài sản | Cháy nổ 18,1% + Tài sản 11,4% | 29,5% |

- Trong Xe: TNDS bắt buộc ≈ **24%**, vật chất xe ≈ **76%** (theo tỷ lệ 4.537 / 18.693 năm 2024).
- Trong Con người: chưa có số public chia theo sản phẩm. **[ƯỚC TÍNH]** sức khỏe 70%, tai nạn/sinh mạng 15%, du lịch 8%, học sinh 7%.

## 3. Thị phần và quy mô doanh nghiệp

Top 5 năm 2025 (MOF Bản tin 01/2026):

| Doanh nghiệp | Thị phần |
|---|---:|
| PVI | 16,93% |
| Bảo Việt | 12,58% |
| Bảo Minh | 6,80% |
| MIC | 6,15% |
| BIC | 5,83% |

Nhóm hạng 6–10 có thị phần khoảng 4–5,5%.

**Cách áp vào dummy.** Doanh nghiệp giả lập "Tổng công ty Bảo hiểm DEMO" có thị phần khoảng **4,5%** trên 4 nghiệp vụ POC, tương đương **~3.360 tỷ năm 2025**. Năm 2024 lấy bằng 2025 / 1,11, theo tăng trưởng thị trường.

**Mô hình tổ chức "Tổng công ty → công ty thành viên".** Đây là mô hình công khai của các DNBH lớn:
- Bảo hiểm Bảo Việt: 79 công ty thành viên (BVH Integrated Report 2024: https://static2.vietstock.vn/vietstock/2025/4/22/20250422_bvh_250422_integrated_report_2024.pdf).
- PVI Insurance: 47 công ty thành viên (https://www.pvi.com.vn/vi/services/mang-luoi).

## 4. Kênh phân phối

| Chỉ số | Số liệu | Nguồn |
|---|---|---|
| Phí qua môi giới 2025 | 11.905 tỷ, ≈13,5% thị trường [suy ra] | MOF Bản tin 01/2026 |
| Bancassurance của một DNBH (MIC, 2023) | 32% doanh thu. Mục tiêu chung của ngành ≈30% | https://www.pjico.com.vn/bao-hiem-phi-nhan-tho-day-manh-ban-cheo-qua-ngan-hang.html |
| Kênh TMĐT/API của một DNBH lớn (2024) | ≈800 tỷ, ≈6% phí gốc [suy ra] | PVI Annual Report 2024: https://static2.vietstock.vn/vietstock/2025/3/19/3_pvi_2025_3_19_fb26c59_en_annualreport_2024.pdf |

**Cách áp vào dummy [ƯỚC TÍNH]:** trực tiếp + đại lý ≈55%, bancassurance ≈17%, môi giới ≈13%, điện tử ≈7%, đại lý tổ chức khác ≈8%.

## 5. Phí niêm yết công khai, dùng làm mức phí dummy

| Sản phẩm | Mức phí | Nguồn |
|---|---|---|
| TNDS bắt buộc ô tô dưới 6 chỗ, không kinh doanh | 437.000 đ (chưa VAT), 480.700 đ (có VAT) | NĐ 67/2023/NĐ-CP; online.pvi.com.vn; baovietonline.com.vn |
| TNDS mô tô | 60.500–66.000 đ (có VAT) | online.pvi.com.vn/san-pham; baovietonline.com.vn |
| Vật chất xe ô tô | 0,5–3,5% giá trị xe/năm | https://online.pvi.com.vn/kien-thuc/bao-hiem-o-to-bao-nhieu-tien |
| Học sinh | Phổ biến 100.000 đ/học sinh/năm | https://cafef.vn/dau-nam-hoc-bo-100000-dong-mua-bao-hiem-than-the-cho-con-hang-trieu-phu-huynh-co-the-bo-qua-dieu-nay-188240923103450415.chn |
| Du lịch trong nước | từ 17.000 đ/chuyến | baovietonline.com.vn |
| Du lịch quốc tế | từ 100.000 đ/người | online.pvi.com.vn |
| Sức khỏe cá nhân | từ 1,4–1,5 triệu/năm; gói cao cấp ≈6,2 triệu | baovietonline.com.vn |
| Nhà tư nhân / căn hộ | từ 220.000–270.000 đ/năm | baovietonline.com.vn; online.pvi.com.vn |

## 6. Mùa vụ

| Mẫu hình | Số liệu | Nguồn / mức chắc chắn |
|---|---|---|
| Toàn thị trường 2024 theo quý | Q1 25,2% · Q2 24,0% · Q3 24,4% · Q4 26,3% | [suy ra] từ số lũy kế IAV. Doanh thu khá đều, Q4 và Q1 nhích nhẹ |
| Học sinh | Thu phí đầu năm học, đỉnh tháng 8–10 | CafeF 23/9/2024; https://huaf.edu.vn/bao-hiem-sinh-vien/ |
| Du lịch cao điểm hè/Tết; xe cuối năm; sức khỏe nhóm tái tục đầu năm | | **[ƯỚC TÍNH]** |

## 7. Tỷ giá hạch toán USD/VND năm 2025

Đây là tỷ giá hạch toán do Kho bạc Nhà nước công bố hằng tháng (thuvienphapluat.vn). Năm 2024: **[ƯỚC TÍNH]** nội suy theo tỷ giá trung tâm của NHNN.

| T1 | T2 | T3 | T4 | T5 | T6 | T7 | T8 | T9 | T10 | T11 | T12 |
|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 24.283 | 24.334 | 24.539 | 24.786 | 24.901 | 24.954 | 25.007 | 25.151 | 25.252 | 25.214 | 25.120 | 25.118 |

## 8. Bảo hiểm PVI — số liệu công khai (căn cứ hiệu chỉnh chính)

**Phí bảo hiểm gốc theo nghiệp vụ** (tỷ đồng). Nguồn: BCTC kiểm toán 2025 của Tổng công ty Bảo hiểm PVI, thuyết minh 21 — https://adminweb.pvi.com.vn/wp-content/uploads/2026/05/2025Q4_Audited_FSs_En.pdf

| Nghiệp vụ | 2024 | 2025 |
|---|---:|---:|
| Tài sản & thiệt hại (gồm kỹ thuật, năng lượng) | 4.138,0 | 3.781,2 |
| Cháy nổ | 3.005,9 | 3.451,2 |
| Sức khỏe & tai nạn con người | 2.220,7 | 3.213,4 |
| Xe cơ giới | 1.662,2 | 1.822,7 |
| Thân tàu & P&I | 1.130,7 | 1.221,9 |
| Gián đoạn kinh doanh | 230,4 | 481,6 |
| Hàng hóa vận chuyển | 365,5 | 429,2 |
| Trách nhiệm | 324,6 | 394,8 |
| Hàng không | 434,2 | 388,5 |
| Tín dụng, nông nghiệp | 48,6 | 55,8 |
| Thuần sau giảm trừ | 13.368,2 | 14.908,3 |

**Phí gốc hợp nhất theo quý** (BCTC quý PVI Holdings, thuyết minh 21): 2024 là 31,5 / 21,5 / 26,6 / 20,5%; 2025 là 29,7 / 24,1 / 24,8 / 21,4%.

**Kênh điện tử:** gần 800 tỷ năm 2024 (BCTN 2024), "gần gấp đôi" năm 2025 (BCTN 2025). Đối tác API: Vietnam Airlines, MobiFone, Viettel, Thế Giới Di Động, Shopee.

**Bancassurance:** Nam A Bank, Woori Bank; PVI Link thành lập 2025 (pvi.com.vn). Không có số doanh thu.

**Mốc hợp đồng lớn (ngoài phạm vi POC):**

| Hợp đồng | Phí | Nguồn |
|---|---|---|
| Hàng không Vietnam Airlines | 540–617 tỷ/năm | tinnhanhchungkhoan.vn, fireant.vn |
| Công trình Nhiệt điện Quảng Trạch I | > 365 tỷ | tinnhanhchungkhoan.vn |
| Công trình nhà ga Long Thành (6 công ty) | 118,9 tỷ | baodauthau.vn |
| Đội tàu Vinalines | 76 tàu, STBH 565 triệu USD | pvn.vn |

**Mô tả định tính:** sức khỏe PVI chủ yếu là bảo hiểm nhóm doanh nghiệp (FPTS, báo cáo định giá PVI 04/2025).
