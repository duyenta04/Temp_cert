# ============================================================
# QUẢN LÝ DANH SÁCH CHỨNG TỪ
# ============================================================
# [BDD-FIX] Thêm Feature declaration bị thiếu
# [BDD-FIX] Chuyển ngôi thứ nhất ("tôi") sang ngôi thứ ba ("người dùng")
# [BDD-FIX] Tách Background dùng chung thay vì lặp Given ở mỗi scenario
# ============================================================

Feature: Quản lý danh sách chứng từ khấu trừ thuế TNCN
  Với vai trò kế toán có quyền quản lý chứng từ
  Người dùng cần xem và quản lý danh sách chứng từ điện tử
  Để theo dõi trạng thái và thực hiện các thao tác cần thiết

  Background:
    Given người dùng đã đăng nhập với vai trò NNT
    And người dùng có quyền "Quản lý chứng từ"

  Rule: Truy cập và hiển thị danh sách chứng từ

    @document-list @ui
    Scenario: Truy cập chức năng quản lý chứng từ
      # [BDD-FIX] Bỏ "click vào mục" (imperative/UI detail) → mô tả behavior
      When người dùng truy cập vào chức năng quản lý chứng từ
      Then danh sách chứng từ được hiển thị

    @document-list @ui
    Scenario: Danh sách chứng từ hiển thị đủ thông tin để người dùng theo dõi
      # [BDD-FIX] Bỏ DataTable liệt kê cột UI → mô tả thông tin business quan trọng
      Given người dùng đang xem danh sách chứng từ
      Then mỗi chứng từ trong danh sách hiển thị số chứng từ, ngày lập, ký hiệu, họ tên người nộp thuế, số thuế và trạng thái gửi CQT

    @document-list @filter
    Scenario: Bộ lọc thời gian mặc định là "Tháng này"
      Given người dùng đang xem danh sách chứng từ
      Then bộ lọc thời gian hiển thị phạm vi mặc định là tháng hiện tại

    @document-list @filter
    Scenario: Lọc danh sách theo trạng thái gửi CQT
      # [BDD-FIX] Bỏ Scenario Outline kiểm tra UI component type (Dropdown/Multi-select)
      # → Viết scenario theo behavior thực sự
      Given người dùng đang xem danh sách chứng từ
      When người dùng lọc theo trạng thái gửi CQT là "Đã gửi CQT"
      Then danh sách chỉ hiển thị các chứng từ có trạng thái "Đã gửi CQT"

    @document-list @filter
    Scenario: Lọc danh sách theo tính chất chứng từ
      Given người dùng đang xem danh sách chứng từ
      When người dùng lọc theo tính chất chứng từ là "Chứng từ gốc"
      Then danh sách chỉ hiển thị các chứng từ gốc

    @document-list @filter
    Scenario: Lọc danh sách theo khoảng thời gian tùy chọn
      Given người dùng đang xem danh sách chứng từ
      When người dùng lọc theo khoảng thời gian từ "01/01/2026" đến "31/01/2026"
      Then danh sách chỉ hiển thị các chứng từ có ngày lập trong tháng 01/2026

    @document-list @search
    Scenario: Tìm kiếm chứng từ theo số chứng từ
      Given người dùng đang xem danh sách chứng từ
      When người dùng tìm kiếm với từ khóa "0000123"
      Then danh sách hiển thị các chứng từ có số chứng từ chứa "0000123"

    @document-list @search
    Scenario: Tìm kiếm chứng từ theo mã số thuế người nộp
      Given người dùng đang xem danh sách chứng từ
      When người dùng tìm kiếm với từ khóa "0123456789"
      Then danh sách hiển thị các chứng từ của người nộp thuế có MST chứa "0123456789"

  Rule: Hành động theo trạng thái chứng từ

    @document-list @actions
    Scenario: Chứng từ nháp cho phép chỉnh sửa và xóa
      # [BDD-FIX] Tách Scenario Outline "action theo trạng thái" thành các scenario
      # rõ ràng theo từng nhóm behavior thay vì 1 DataTable lớn khó đọc
      Given người dùng đang xem danh sách chứng từ
      And có chứng từ ở trạng thái "Nháp"
      Then người dùng có thể phát hành, xem, sửa và xóa chứng từ đó

    @document-list @actions
    Scenario: Chứng từ phát hành lỗi cho phép phát hành lại và tải xuống
      Given người dùng đang xem danh sách chứng từ
      And có chứng từ ở trạng thái "Phát hành lỗi"
      Then người dùng có thể phát hành lại và tải chứng từ đó
      And người dùng không thể sửa hoặc xóa chứng từ đó

    @document-list @actions
    Scenario: Chứng từ đã gửi CQT cho phép gửi khách hàng và lập chứng từ liên quan
      Given người dùng đang xem danh sách chứng từ
      And có chứng từ ở trạng thái "Đã gửi CQT"
      Then người dùng có thể gửi cho khách hàng, tải xuống, sao chép và lập chứng từ điều chỉnh/thay thế/TBSS
      And người dùng không thể phát hành lại, sửa hoặc xóa chứng từ đó

    @document-list @actions
    Scenario: Chứng từ CQT kiểm tra không hợp lệ cho phép phát hành lại
      Given người dùng đang xem danh sách chứng từ
      And có chứng từ ở trạng thái "CQT kiểm tra không hợp lệ"
      Then người dùng có thể phát hành lại và tải chứng từ đó
      And người dùng không thể sửa, xóa hoặc lập chứng từ liên quan

  Rule: Xử lý hàng loạt

    @document-list @batch-actions
    Scenario: Gửi chứng từ hàng loạt cho khách hàng
      # [BDD-FIX] Thêm When còn thiếu, mô tả behavior cụ thể thay vì liệt kê action
      Given người dùng đã chọn nhiều chứng từ ở trạng thái cho phép gửi khách hàng
      When người dùng thực hiện gửi hàng loạt
      Then hệ thống gửi tất cả chứng từ đã chọn đến khách hàng tương ứng

    @document-list @batch-actions
    Scenario: Tải hàng loạt chứng từ
      Given người dùng đã chọn nhiều chứng từ
      When người dùng tải hàng loạt
      Then hệ thống tải xuống tất cả chứng từ đã chọn

    @document-list @batch-actions
    Scenario: Xóa hàng loạt chứng từ nháp
      Given người dùng đã chọn nhiều chứng từ ở trạng thái "Nháp"
      When người dùng xác nhận xóa hàng loạt
      Then tất cả chứng từ đã chọn bị xóa khỏi hệ thống

    @document-list @single-actions
    Scenario: Phát hành chỉ thực hiện được trên từng chứng từ
      # [BDD-FIX] Thêm When còn thiếu
      Given người dùng đã chọn nhiều chứng từ ở trạng thái "Nháp"
      When người dùng thực hiện phát hành
      Then hệ thống chỉ cho phép phát hành từng chứng từ một
