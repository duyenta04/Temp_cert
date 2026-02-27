# =====================================================
# XEM CHI TIẾT CHỨNG TỪ
# =====================================================
# [BDD-FIX] Gộp các scenario action-by-status trùng lặp thành Scenario Outline
# [BDD-FIX] Bỏ DataTable liệt kê enum tính chất → viết scenario theo behavior
# [BDD-FIX] Làm rõ mâu thuẫn action trạng thái "Nháp" với cert-list
#           ⚠️  NOTE: Cần xác nhận với PO về action "Gửi chứng từ" và "Tải chứng từ"
#                     cho trạng thái Nháp — hiện đang mâu thuẫn với cert-list.feature
# =====================================================

@document-detail
Feature: Xem chi tiết chứng từ điện tử
  Với vai trò một người dùng hệ thống
  Tôi muốn xem chi tiết thông tin chứng từ điện tử
  Để nắm đầy đủ nội dung, trạng thái và lịch sử xử lý của chứng từ

  Background:
    Given người dùng đã đăng nhập vào hệ thống
    And người dùng đang ở danh sách chứng từ

  Rule: Xem chi tiết chứng từ

    @document-detail @ui
    Scenario: Truy cập chi tiết chứng từ từ danh sách
      Given danh sách chứng từ hiển thị ít nhất một chứng từ
      When người dùng chọn một chứng từ trong danh sách
      Then hệ thống hiển thị trang chi tiết chứng từ với đầy đủ thông tin:
        | Nhóm thông tin                  |
        | Chi tiết chứng từ đã lập        |
        | Trạng thái chứng từ             |
        | Tính chất chứng từ              |
        | Lịch sử truyền nhận với CQT     |

    @document-detail
    Scenario: Hiển thị đầy đủ thông tin trạng thái chứng từ
      Given người dùng đang xem chi tiết một chứng từ
      Then hệ thống hiển thị cả trạng thái gửi CQT lẫn trạng thái gửi NNT

    @document-detail
    Scenario: Chứng từ gốc bị điều chỉnh hiển thị tính chất "Bị điều chỉnh"
      # [BDD-FIX] Bỏ DataTable liệt kê enum tính chất → viết scenario theo behavior cụ thể
      Given người dùng đang xem chi tiết chứng từ đã có chứng từ điều chỉnh được lập
      Then tính chất chứng từ hiển thị là "Bị điều chỉnh"

    @document-detail
    Scenario: Chứng từ gốc bị thay thế hiển thị tính chất "Bị thay thế"
      Given người dùng đang xem chi tiết chứng từ đã có chứng từ thay thế được lập
      Then tính chất chứng từ hiển thị là "Bị thay thế"

    @document-detail
    Scenario: Hiển thị lịch sử truyền nhận chứng từ với CQT
      Given người dùng đang xem chi tiết một chứng từ
      When người dùng chọn tab "Lịch sử truyền nhận"
      Then hệ thống hiển thị toàn bộ lịch sử truyền nhận chứng từ với cơ quan thuế

  Rule: Hiển thị action theo trạng thái gửi CQT

    @action-by-status
    Scenario: Chứng từ nháp cho phép chỉnh sửa và xóa
      # ⚠️  CẢNH BÁO MÂU THUẪN: Bản gốc có "Gửi chứng từ" và "Tải chứng từ" cho Nháp
      # nhưng cert-list.feature KHÔNG có 2 action này cho trạng thái Nháp.
      # Cần xác nhận với PO trước khi implement. Tạm giữ theo cert-list.feature.
      Given người dùng đang xem chi tiết chứng từ ở trạng thái "Nháp"
      Then người dùng có thể phát hành, xem, sửa và xóa chứng từ
      And người dùng không thể gửi cho khách hàng hoặc tải chứng từ

    @action-by-status
    Scenario: Chứng từ đã gửi CQT cho phép thực hiện đầy đủ các tác nghiệp
      Given người dùng đang xem chi tiết chứng từ ở trạng thái "Đã gửi CQT"
      Then người dùng có thể gửi cho khách hàng, tải xuống, sao chép và lập chứng từ điều chỉnh/thay thế/TBSS
      And người dùng không thể phát hành lại, sửa hoặc xóa chứng từ

    @action-by-status
    Scenario Outline: Chứng từ đã xử lý bởi CQT chỉ cho phép xem và tải xuống
      # [BDD-FIX] Gộp 3 scenario gần giống nhau ("Gửi CQT lỗi", "CQT kiểm tra không hợp lệ",
      # "CQT chấp nhận") thành Scenario Outline vì chúng cùng equivalence class về behavior
      Given người dùng đang xem chi tiết chứng từ ở trạng thái "<trạng_thái>"
      Then người dùng chỉ có thể tải xuống và sao chép chứng từ
      And người dùng không thể sửa, xóa, phát hành lại, gửi cho khách hàng hoặc lập chứng từ điều chỉnh/thay thế/TBSS

      Examples:
        | trạng_thái                    |
        | Gửi CQT lỗi                   |
        | CQT kiểm tra không hợp lệ    |
        | CQT chấp nhận                 |

  Rule: Tải chứng từ

    @download
    Scenario Outline: Tải chứng từ theo định dạng
      Given người dùng đang xem chi tiết chứng từ có action "Tải chứng từ"
      When người dùng tải chứng từ theo định dạng <định_dạng>
      Then hệ thống tải xuống file chứng từ đúng định dạng <định_dạng>

      Examples:
        | định_dạng |
        | PDF       |
        | XML       |

  Rule: Gửi chứng từ cho khách hàng

    @send-to-customer
    Scenario: Gửi chứng từ cho khách hàng khi chứng từ đã phát hành
      Given người dùng đang xem chi tiết chứng từ ở trạng thái cho phép gửi khách hàng
      When người dùng thực hiện gửi chứng từ cho khách hàng
      Then hệ thống gửi chứng từ thành công đến khách hàng
      And trạng thái gửi NNT của chứng từ được cập nhật

  Rule: Sao chép chứng từ

    @copy
    Scenario: Sao chép chứng từ để lập chứng từ mới
      Given người dùng đang xem chi tiết chứng từ có action "Sao chép"
      When người dùng thực hiện sao chép chứng từ
      Then hệ thống tạo bản nháp mới với dữ liệu được sao chép từ chứng từ gốc
      And hệ thống chuyển người dùng đến form lập chứng từ mới

  Rule: Lập chứng từ điều chỉnh, thay thế và thông báo sai sót

    @adjustment
    Scenario: Lập chứng từ điều chỉnh từ chứng từ đã gửi CQT
      Given người dùng đang xem chi tiết chứng từ ở trạng thái "Đã gửi CQT"
      When người dùng thực hiện "Lập chứng từ điều chỉnh"
      Then hệ thống tạo chứng từ điều chỉnh liên kết với chứng từ gốc
      And tính chất của chứng từ gốc được cập nhật thành "Bị điều chỉnh"

    @replacement
    Scenario: Lập chứng từ thay thế từ chứng từ đã gửi CQT
      Given người dùng đang xem chi tiết chứng từ ở trạng thái "Đã gửi CQT"
      When người dùng thực hiện "Lập chứng từ thay thế"
      Then hệ thống tạo chứng từ thay thế liên kết với chứng từ gốc
      And tính chất của chứng từ gốc được cập nhật thành "Bị thay thế"
