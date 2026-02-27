@certificate-create
Feature: Lập chứng từ khấu trừ thuế thu nhập cá nhân
  Để ghi nhận việc khấu trừ thuế cho cá nhân và hộ kinh doanh
  Với vai trò kế toán
  Tôi cần lập chứng từ khấu trừ thuế thu nhập cá nhân

  Background:
    Given kế toán đã đăng nhập vào hệ thống
    And kế toán có quyền quản lý chứng từ
    And hệ thống có các mẫu chứng từ đã đăng ký

  Rule: Mẫu chứng từ cố định theo năm hiện tại

    @fixed-template @auto-template
    Scenario: Ký hiệu chứng từ tự động dùng 2 chữ số cuối của năm hiện tại
      # [BDD-FIX] Gộp 2 scenario duplicate cùng tên thành 1 scenario rõ ràng hơn
      Given năm hiện tại là 2026
      When kế toán bắt đầu lập chứng từ mới
      Then ký hiệu chứng từ là "CT/26E"
      And mẫu đầy đủ hiển thị là "03/TNCN-CT/26E"

    @fixed-template @template-structure
    Scenario: Cấu trúc ký hiệu chứng từ
      Given mẫu chứng từ "03/TNCN-CT/26E"
      Then ký hiệu chứng từ "CT/26E" có cấu trúc:
        | Vị trí | Ký tự | Ý nghĩa                        |
        | 1-2    | CT    | Viết tắt của "Chứng từ"        |
        | 3      | /     | Ký tự phân cách                |
        | 4-5    | 26    | 2 chữ số cuối năm lập (2026)   |
        | 6      | E     | Hình thức điện tử (Electronic) |

    @fixed-template @display
    Scenario: Mẫu chứng từ hiển thị cố định và không thể thay đổi
      Given kế toán vào màn hình lập chứng từ
      And năm hiện tại là 2026
      Then mẫu chứng từ hiển thị là "03/TNCN-CT/26E"
      And mẫu không thể thay đổi

  Rule: Số chứng từ chỉ sinh khi phát hành

    @auto-number @draft
    Scenario: Lưu nháp không sinh số chứng từ
      Given kế toán đang lập chứng từ
      When kế toán lưu nháp
      Then chứng từ có trạng thái "Nháp"
      And số chứng từ chưa được sinh ra

    @auto-number @publish
    Scenario: Sinh số chứng từ tự động khi phát hành
      Given chứng từ có trạng thái "Nháp"
      And hệ thống đã có chứng từ đã phát hành
      When kế toán phát hành chứng từ
      Then số chứng từ mới lớn hơn số chứng từ trước đó đúng 1 đơn vị
      And chứng từ được gửi lên CQT với số vừa sinh

  Rule: Chọn ngày chứng từ

    @date-selection
    Scenario: Chọn ngày chứng từ
      Given kế toán đang lập chứng từ
      When kế toán chọn ngày "15/01/2026"
      Then ngày chứng từ là "15/01/2026"

  Rule: Tra cứu thông tin người nộp thuế

    @taxpayer-lookup
    Scenario: Tra cứu thành công từ mã số thuế
      Given kế toán đang nhập thông tin người nộp thuế
      When kế toán tra cứu mã số thuế "8765432100"
      Then hệ thống điền tự động thông tin người nộp thuế

    @taxpayer-lookup
    Scenario: Tra cứu không tìm thấy — cho phép nhập thủ công
      Given kế toán đang nhập thông tin người nộp thuế
      When kế toán tra cứu mã số thuế không tồn tại
      Then hệ thống thông báo không tìm thấy
      And hệ thống cho phép nhập thủ công

  Rule: Thông tin người nộp thuế

    @taxpayer-info @validation
    Scenario: Yêu cầu có mã số thuế hoặc CCCD
      Given kế toán đang lập chứng từ
      And không có mã số thuế
      And không có số CCCD
      When kế toán lưu chứng từ
      Then hệ thống hiển thị lỗi "Phải nhập Mã số thuế hoặc Số CCCD"

    @taxpayer-info @validation
    Scenario Outline: Kiểm tra định dạng mã số thuế
      # [BDD-FIX] Đổi placeholder <r> → <result> cho nhất quán và dễ đọc
      Given kế toán đang nhập mã số thuế
      When kế toán nhập mã số thuế "<value>"
      Then hệ thống <result>

      Examples:
        | value         | result                                |
        | 0123456789    | chấp nhận mã số thuế                  |
        | 0123456789012 | chấp nhận mã số thuế                  |
        | 012345        | hiển thị lỗi "MST phải 10 hoặc 13 số" |
        | ABC123        | hiển thị lỗi "MST chỉ chứa số"        |

    @taxpayer-info @validation
    Scenario: Yêu cầu chọn cá nhân cư trú
      Given kế toán đang lập chứng từ
      And chưa chọn cá nhân cư trú
      When kế toán lưu chứng từ
      Then hệ thống hiển thị lỗi "Phải chọn Cá nhân cư trú"

    @taxpayer-info @validation
    Scenario Outline: Yêu cầu các trường bắt buộc
      Given kế toán đang lập chứng từ
      And trường <field> để trống
      When kế toán lưu chứng từ
      Then hệ thống hiển thị lỗi "<error_message>"

      Examples:
        | field         | error_message                     |
        | Họ và tên     | Họ và tên không được để trống     |
        | Địa chỉ       | Địa chỉ không được để trống       |
        | Quốc tịch     | Quốc tịch không được để trống     |
        | Số điện thoại | Số điện thoại không được để trống |

  Rule: Nhập thông tin khoản thu nhập

    @income-info @input
    Scenario: Nhập các trường thông tin thu nhập
      Given kế toán đang ở phần "Thông tin thuế thu nhập cá nhân khấu trừ"
      When kế toán nhập thông tin:
        | Trường                      | Giá trị    |
        | Khoản thu nhập              | Tiền lương |
        | Năm                         | 2025       |
        | Từ tháng                    | 1          |
        | Đến tháng                   | 12         |
        | Bảo hiểm                    | 3,150,000  |
        | Khoản từ thiện, nhân đạo    | 500,000    |
        | Quỹ hưu trí tự nguyện       | 1,000,000  |
        | Tổng thu nhập chịu thuế     | 30,000,000 |
        | Tổng thu nhập tính thuế     | 25,350,000 |
        | Số thuế                     | 3,602,500  |
      Then thông tin được lưu vào chứng từ

    @income-info @validation
    Scenario: Yêu cầu nhập khoản thu nhập
      Given kế toán đang nhập thông tin thuế
      And trường "Khoản thu nhập" để trống
      When kế toán lưu chứng từ
      Then hệ thống hiển thị lỗi "Khoản thu nhập không được để trống"

    @income-info @validation
    Scenario: Yêu cầu chọn khoảng thời gian hợp lệ
      Given kế toán đang nhập thông tin thuế
      And "Từ tháng" là 5
      When kế toán chọn "Đến tháng" là 3
      Then hệ thống hiển thị lỗi "Đến tháng phải lớn hơn hoặc bằng Từ tháng"

    @income-info @validation
    Scenario Outline: Kiểm tra định dạng số tiền
      # [BDD-FIX] Đổi placeholder <r> → <result> cho nhất quán và dễ đọc
      Given kế toán đang nhập thông tin thuế
      When kế toán nhập "<field>" với giá trị "<value>"
      Then hệ thống <result>

      Examples:
        | field                   | value      | result                                      |
        | Bảo hiểm                | 3150000    | chấp nhận giá trị                           |
        | Tổng thu nhập chịu thuế | 30,000,000 | chấp nhận giá trị                           |
        | Số thuế                 | -1000      | hiển thị lỗi "Số tiền phải lớn hơn 0"       |
        | Bảo hiểm                | abc        | hiển thị lỗi "Số tiền không đúng định dạng" |

  Rule: Nhập thông tin cho nhiều tháng

    @multi-month @input
    Scenario: Thông tin thu nhập áp dụng cho cả khoảng thời gian được chọn
      Given kế toán đang nhập thông tin thuế
      When kế toán chọn:
        | Từ tháng  | 1    |
        | Đến tháng | 12   |
        | Năm       | 2025 |
      And kế toán nhập các thông tin thu nhập và thuế
      Then thông tin được áp dụng cho cả 12 tháng từ 1/2025 đến 12/2025

  Rule: Kiểm tra tính hợp lý của dữ liệu

    @validation @logic
    Scenario: Cảnh báo khi thu nhập tính thuế lớn hơn thu nhập chịu thuế
      # [BDD-FIX] Xóa ký tự "|" thừa cuối dòng (syntax error)
      Given kế toán đang nhập thông tin thuế
      And "Tổng thu nhập chịu thuế" là 30,000,000 VNĐ
      When kế toán nhập "Tổng thu nhập tính thuế" là 35,000,000 VNĐ
      Then hệ thống hiển thị cảnh báo "Thu nhập tính thuế không nên lớn hơn thu nhập chịu thuế"
      And cho phép kế toán tiếp tục nếu chắc chắn

  Rule: Xem trước chứng từ

    @preview
    Scenario: Xem trước chứng từ với đầy đủ thông tin
      Given kế toán đang lập chứng từ
      And đã nhập đầy đủ thông tin
      When kế toán xem trước chứng từ
      Then chứng từ được hiển thị dạng xem trước với mẫu hiện tại
      And tất cả thông tin đã nhập được hiển thị
      And thông tin không thể chỉnh sửa trong chế độ xem trước

    @preview
    Scenario: Xem trước với thông tin chưa đầy đủ
      Given kế toán đang lập chứng từ
      And một số thông tin còn thiếu
      When kế toán xem trước chứng từ
      Then chứng từ được hiển thị dạng xem trước với mẫu hiện tại
      And các trường thiếu hiển thị trống

  Rule: Lưu nháp không cần validate

    @draft
    Scenario: Lưu nháp với thông tin chưa đầy đủ
      Given kế toán đang lập chứng từ
      And chưa nhập đầy đủ thông tin bắt buộc
      When kế toán lưu nháp
      Then chứng từ được lưu thành công
      And trạng thái chứng từ là "Nháp"

    @draft
    Scenario: Lưu nháp ngay khi bắt đầu chưa nhập gì
      Given kế toán vào màn hình lập chứng từ
      And chưa nhập bất kỳ thông tin nào
      When kế toán lưu nháp
      Then chứng từ được lưu nháp thành công
      And số chứng từ chưa được sinh ra

    @draft
    Scenario: Chỉnh sửa chứng từ nháp
      Given chứng từ có trạng thái "Nháp"
      When kế toán mở chứng từ nháp
      Then kế toán có thể chỉnh sửa các trường thông tin

    @draft @save
    Scenario: Lưu nháp lần 2 cập nhật thông tin mà không thay đổi trạng thái
      # [BDD-FIX] Tách scenario procedure-driven (2 cặp When-Then) thành 1 scenario
      # tập trung vào behavior: "lưu lại nhiều lần vẫn giữ trạng thái Nháp"
      Given chứng từ đang ở trạng thái "Nháp" và đã được lưu ít nhất một lần
      When kế toán chỉnh sửa thông tin và lưu nháp lại
      Then thông tin mới được cập nhật vào chứng từ
      And trạng thái chứng từ vẫn là "Nháp"

    @draft @delete
    Scenario: Xóa chứng từ nháp sau khi xác nhận
      # [BDD-FIX] Tách scenario procedure-driven (2 cặp When-Then) thành 1 scenario
      # tập trung vào outcome: "chứng từ bị xóa sau khi xác nhận"
      Given chứng từ có trạng thái "Nháp"
      When kế toán xác nhận xóa chứng từ
      Then chứng từ bị xóa khỏi hệ thống

  Rule: Phát hành chứng từ - Validate và gửi CQT

    @publish @validation
    Scenario: Phát hành thất bại khi thiếu thông tin bắt buộc
      # [BDD-FIX] Bỏ "hệ thống thực hiện validate đầy đủ" (không đo được)
      # → mô tả outcome rõ ràng
      Given chứng từ có trạng thái "Nháp"
      And chưa nhập đầy đủ thông tin bắt buộc
      When kế toán phát hành chứng từ
      Then hệ thống hiển thị thông báo lỗi cho các trường bắt buộc còn thiếu
      And chứng từ vẫn ở trạng thái "Nháp"

    @publish
    Scenario: Phát hành chứng từ hợp lệ thành công
      Given chứng từ có trạng thái "Nháp"
      And đã nhập đầy đủ thông tin bắt buộc
      When kế toán phát hành chứng từ
      Then số chứng từ được sinh tự động
      And thông điệp 211 được gửi lên CQT
      And trạng thái chứng từ chuyển thành "Đã gửi CQT"

    @publish @message-211
    Scenario: Gửi thông điệp 211 khi phát hành
      Given chứng từ đã validate đầy đủ
      And mẫu chứng từ "03/TNCN-CT/26E"
      And số chứng từ cuối là "0000100"
      When hệ thống phát hành chứng từ
      Then số chứng từ mới "0000101" được sinh ra
      And thông điệp 211 được tạo với:
        | Mẫu chứng từ   | Số chứng từ | Dữ liệu XML        |
        | 03/TNCN-CT/26E | 0000101     | <dữ liệu chứng từ> |
      And thông điệp 211 được gửi lên CQT
      And trạng thái chuyển thành "Đã gửi CQT"

  Rule: Nhận thông điệp 213 từ CQT

    @message-213 @success
    Scenario: CQT chấp nhận chứng từ
      Given chứng từ có trạng thái "Đã gửi CQT"
      When thông điệp 213 được nhận với kết quả "Hợp lệ"
      Then trạng thái chứng từ chuyển thành "CQT chấp nhận"
      And chứng từ không thể chỉnh sửa

    @message-213 @validation-error
    Scenario: CQT kiểm tra không hợp lệ — kế toán phải lập chứng từ mới
      Given chứng từ có trạng thái "Đã gửi CQT"
      When thông điệp 213 được nhận với kết quả "Không hợp lệ"
      And thông điệp 213 chứa lỗi:
        | Mã lỗi | Mô tả lỗi                       |
        | E001   | Mã số thuế không đúng định dạng |
      Then trạng thái chứng từ chuyển thành "CQT kiểm tra không hợp lệ"
      And chi tiết lỗi từ CQT được hiển thị
      And chứng từ không thể chỉnh sửa

    @message-213 @technical-error
    Scenario: Lỗi kỹ thuật khi gửi CQT
      Given chứng từ có trạng thái "Đã gửi CQT"
      When thông điệp 213 được nhận với lỗi kỹ thuật
      Then trạng thái chuyển thành "Gửi CQT lỗi"
      And thông báo lỗi kỹ thuật được hiển thị

  Rule: Trạng thái chứng từ và chuyển đổi

    @status @lifecycle
    Scenario: Các trạng thái trong vòng đời chứng từ
      Then hệ thống hỗ trợ các trạng thái:
        | Trạng thái                 | Mô tả                              |
        | Nháp                       | Chưa phát hành, có thể sửa         |
        | Đã gửi CQT                 | Đã gửi 211, chờ CQT phản hồi       |
        | CQT kiểm tra không hợp lệ  | CQT trả 213 không hợp lệ           |
        | CQT chấp nhận              | CQT trả 213 hợp lệ                 |
        | Gửi CQT lỗi                | Lỗi kỹ thuật khi gửi               |

    @status @transition
    Scenario Outline: Chuyển đổi trạng thái hợp lệ
      Given chứng từ có trạng thái "<from_status>"
      When <event> xảy ra
      Then trạng thái chứng từ chuyển thành "<to_status>"

      Examples:
        | from_status  | event                    | to_status                     |
        | Nháp         | phát hành thành công     | Đã gửi CQT                    |
        | Đã gửi CQT   | nhận 213 hợp lệ          | CQT chấp nhận                 |
        | Đã gửi CQT   | nhận 213 không hợp lệ   | CQT kiểm tra không hợp lệ    |
        | Đã gửi CQT   | nhận 213 lỗi kỹ thuật   | Gửi CQT lỗi                   |
