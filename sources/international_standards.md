# Chuẩn mô hình dữ liệu bảo hiểm quốc tế dùng để đối chiếu

Tài liệu tra cứu ngày 07/10/2026. Mục nào ghi **(chưa xác minh)** là chưa đọc được bản gốc.

## Mô hình v2 so với các chuẩn

| Bảng v2 | IBM IIW / IAA | ACORD P&C | Kimball (DWT 3e, Ch.16) | OMG P&C 1.0 / Microsoft CDM | IFRS 17 / Solvency II / NAIC |
|---|---|---|---|---|---|
| `core.policy` | Agreement (Insurance Agreement) | Policy (PolicyNumber, ContractTerm, LOBCd) | Policy (degenerate dimension) | OMG: Policy · CDM: Policy | Contract → portfolio / group |
| `core.policy_transaction` | Event + Financial Transaction | `BusinessPurposeTypeCd`: NBS / PCH / XLC / REI / RWL | Policy Transaction fact + Transaction Type dim | CDM: **PolicyTransaction** | — |
| `core.transaction_coverage` | Agreement component ↔ Product component; Money Provision | **Coverage**: `CoverageCd`, `WrittenAmt`, **`NetChangeAmt`** (khoản thay đổi phí của giao dịch) | Grain coverage × covered item | OMG: Policy Coverage Part / **Policy Coverage Detail**; CDM: Coverage | Written premium (NAIC Part 1B) |
| `core.coinsurance_share` | Agreement + Party role (insurer) | Thị trường subscription: Written/Signed Line, `leadUnderwriter` (JMRC). **Không phải** `CoinsurancePct` | — | OMG: Policy Amount (Direct / Assumed / Ceded); Oracle OIDF: "Insurance and Reinsurance Participation"; CDM: Insurer | Gross vs own share |
| `core.revenue_allocation` | Account / Organization (Party) | — | Allocated facts | — | — |
| `ref.customer` | Party + Role Player | Insured / Party | Policyholder dim | OMG: Party, Agreement Party Role | — |
| `ref.channel` / `ref.partner` | Party role Intermediary | Producer (`ProducerRoleCd`) | Agent dim | CDM: Agency, Agent, BrokerAgency | Commission |
| `ref.line_of_business` / `ref.product` | Category; Specification, Product | `LOBCd`; Product Model | Coverage dim (supertype/subtype) | CDM: LOB, CoverageLOB, PolicyProduct | **Solvency II LoB 1–12**; NAIC LOB |
| `ref.fx_rate` | Financial Transaction / Account | Currency code | **Multiple currencies**: lưu cả nguyên tệ và tiền chuẩn | — | — |

## Đã áp dụng vào v2

- `ref.transaction_type.acord_business_purpose_cd`: NEW→NBS, RENEW→RWL, các loại SĐBS và REFUND→PCH, CANCEL→XLC.
- `ref.product.solvency2_lob`: ánh xạ sang Solvency II LoB (Delegated Regulation 2015/35, Annex I):

  | Sản phẩm v2 | Solvency II LoB |
  |---|---|
  | TNDS bắt buộc | (4) Motor vehicle liability |
  | Vật chất xe | (5) Other motor |
  | Sức khỏe | (1) Medical expense |
  | Tai nạn, sinh mạng | (2) Income protection — **suy luận** |
  | Du lịch | (1) Medical expense — **suy luận** |
  | Tài sản, cháy nổ | (7) Fire and other damage to property |

- `core.transaction_coverage.premium_orig` lưu **phần thay đổi phí của từng giao dịch**, tương đương `NetChangeAmt` của ACORD.

## Nguồn

**IBM**
- IIW brochure GIM v8.5: https://public.dhe.ibm.com/software/data/sw-library/industry-models/brochures/IBM_Insurance_Information_Warehouse_GIMv85.pdf
- IAA poster: https://public.dhe.ibm.com/software/data/mdm/pdf/IAA_Poster_2006.pdf

**ACORD**
- Reference Architecture: https://www.acord.org/standards-architecture/reference-architecture
- P&C Data Standards: https://www.acord.org/standards-architecture/acord-data-standards/Property_Casualty_Data_Standards
- Mã giao dịch (model viewer bên thứ ba): https://modelviewers.pilotfishtechnology.com/modelviewers/ACORD-PCS/model/codelists/CycleBusinessPurpose.html
- Whitespace JMRC spec (subscription market): https://apidocs.whitespace.co.uk/JMRC%20ACORD%20Specification%20V0.5%20-%20Defined%20Data.pdf

**Kimball**
- InsureCo case: https://www.kimballgroup.com/1995/12/data-warehouse-insurance/
- Multiple currencies: https://www.kimballgroup.com/data-warehouse-business-intelligence-resources/kimball-techniques/dimensional-modeling-techniques/multiple-currencies/
- Supertype/subtype: https://www.kimballgroup.com/data-warehouse-business-intelligence-resources/kimball-techniques/dimensional-modeling-techniques/supertype-subtype-heterogeneous/
- Số trang Chương 16: **(chưa xác minh)**

**Các mô hình ngành khác**
- OMG P&C Data Model 1.0: https://www.omg.org/spec/PC/1.0/About-PC
- Microsoft CDM P&C: https://learn.microsoft.com/en-us/common-data-model/schema/core/industrycommon/financialservices/propertyandcasualtydatamodel/overview
- Oracle Insurance Data Foundation: https://www.oracle.com/a/ocom/docs/industries/financial-services/insurance-data-warehouse-ds.pdf

**Kế toán và giám sát**
- IFRS 17: https://www.iasplus.com/en/standards/ifrs/ifrs-17
- Ví dụ PAA của IFRS Foundation: https://www.ifrs.org/content/dam/ifrs/supporting-implementation/ifrs-17/premium-allocation-approach-example.pdf
- Solvency II Annex I: https://www.legislation.gov.uk/eur/2015/35/annex/I/adopted

## Dataset public tham khảo

Các dataset này **không** dùng để hiệu chỉnh số. Số liệu được hiệu chỉnh theo thị trường Việt Nam, xem [market_data.md](market_data.md).

| Dataset | Nội dung | License |
|---|---|---|
| CASdatasets `freMTPL2`, `fremotor1prem0304` | Motor Pháp; có phí theo từng quyền lợi, kênh, vùng | GPL |
| CAS Loss Reserving DB | NAIC Schedule P; earned premium Direct / Ceded / Net | — |
| Kaggle Travel Insurance | Agency type, distribution channel, net sales, commission | ODbL |
