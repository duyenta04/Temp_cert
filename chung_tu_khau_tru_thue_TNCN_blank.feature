# language: vi
Feature: Chứng từ khấu trừ thuế thu nhập cá nhân (Mẫu 03/TNCN)
  Là tổ chức trả thu nhập
  Tôi muốn lập chứng từ khấu trừ thuế TNCN
  Để xác nhận số thuế đã khấu trừ cho cá nhân

  Background:
    Given tổ chức trả thu nhập đã đăng nhập vào hệ thống
    And tổ chức trả thu nhập có mã số thuế hợp lệ

  # ─────────────────────────────────────────────
  # I. THÔNG TIN TỔ CHỨC TRẢ THU NHẬP
  # ─────────────────────────────────────────────

  Scenario: Điền thông tin tổ chức trả thu nhập
    Given người dùng đang ở màn hình tạo chứng từ mới
    When người dùng nhập thông tin tổ chức trả thu nhập
      | Trường             | Giá trị |
      | Tên tổ chức        |         |
      | Mã số thuế         |         |
      | Địa chỉ            |         |
      | Điện thoại         |         |
    Then hệ thống lưu thông tin tổ chức thành công

  # ─────────────────────────────────────────────
  # II. THÔNG TIN CÁ NHÂN
  # ─────────────────────────────────────────────

  Scenario: Điền thông tin cá nhân nhận thu nhập
    Given thông tin tổ chức trả thu nhập đã được điền đầy đủ
    When người dùng nhập thông tin cá nhân
      | Trường                              | Giá trị |
      | Họ và tên                           |         |
      | Mã số thuế                          |         |
      | Quốc tịch                           |         |
      | Loại cư trú                         |         |
      | Địa chỉ                             |         |
      | Điện thoại liên hệ                  |         |
      | Số định danh / hộ chiếu             |         |
      | Địa chỉ thư điện tử                 |         |
      | Ghi chú                             |         |
    Then hệ thống lưu thông tin cá nhân thành công

  Scenario Outline: Xác định loại cư trú của cá nhân
    Given cá nhân đang được khai báo trên chứng từ
    When người dùng chọn loại cư trú là "<loại_cư_trú>"
    Then hệ thống áp dụng quy tắc tính thuế theo "<quy_tắc_thuế>"

    Examples:
      | loại_cư_trú          | quy_tắc_thuế                    |
      | Cá nhân cư trú       | Thuế theo biểu lũy tiến từng phần |
      | Cá nhân không cư trú | Thuế 20% trên tổng thu nhập      |

  # ─────────────────────────────────────────────
  # III. THÔNG TIN THUẾ TNCN KHẤU TRỪ
  # ─────────────────────────────────────────────

  Scenario: Điền thông tin thuế TNCN khấu trừ
    Given thông tin cá nhân đã được điền đầy đủ
    When người dùng nhập thông tin thuế TNCN
      | Trường                                    | Giá trị |
      | Khoản thu nhập                            |         |
      | Khoản đóng bảo hiểm bắt buộc             |         |
      | Khoản đóng từ thiện, nhân đạo, khuyến học |         |
      | Quỹ hưu trí tự nguyện được trừ            |         |
      | Thời điểm trả thu nhập - từ tháng         |         |
      | Thời điểm trả thu nhập - đến tháng        |         |
      | Năm                                       |         |
      | Tổng thu nhập chịu thuế phải khấu trừ     |         |
      | Tổng thu nhập tính thuế                   |         |
      | Số thuế TNCN đã khấu trừ                  |         |
    Then hệ thống tính toán và hiển thị tổng số thuế khấu trừ

  Scenario: Xuất chứng từ sau khi hoàn tất
    Given toàn bộ thông tin trên chứng từ đã được điền đầy đủ và hợp lệ
    When người dùng xác nhận và ký số chứng từ
    Then hệ thống sinh ra chứng từ với số thứ tự tự động
    And chứng từ được lưu với trạng thái "Đã phát hành"
