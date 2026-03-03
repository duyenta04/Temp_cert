@certificate-tncn-create
Feature: Lập chứng từ khấu trừ thuế thu nhập cá nhân
  Với vai trò một NNT
  Tôi muốn lập chứng từ khấu trừ thuế TNCN
  Để cấp cho cá nhân/hộ kinh doanh bị khấu trừ thuế thu nhập cá nhân

  Background:
    Given người nộp thuế đã đăng nhập vào hệ thống
    And người nộp thuế có quyền quản lý chứng từ

  Rule: Tên chứng từ tự động gán và không thể chỉnh sửa

    @auto-fill @read-only
    Scenario: Hiển thị tên chứng từ mặc định
      Given người nộp thuế mở form lập chứng từ TNCN mới
      Then hệ thống hiển thị tên chứng từ là "CHỨNG TỪ KHẤU TRỪ THUẾ THU NHẬP CÁ NHÂN"
      And tên chứng từ không thể chỉnh sửa

  Rule: Mẫu chứng từ mặc định hiển thị dạng "03/TNCN - CT/XXE" với XX là 2 chữ số cuối năm hiện tại
    # Mẫu số chứng từ: 03/TNCN (cố định)
    # Ký hiệu chứng từ: CT/ + XX (2 chữ số cuối năm dương lịch) + E (điện tử)
    # Ví dụ năm 2026: hiển thị "03/TNCN - CT/26E"
    # Hệ thống tự động ghi nhận năm lập chứng từ hiện tại vào ký hiệu

    @auto-fill @read-only
    Scenario: Hiển thị mẫu chứng từ mặc định theo năm hiện tại
      Given người nộp thuế mở form lập chứng từ TNCN mới
      Then hệ thống hiển thị mẫu chứng từ theo định dạng "03/TNCN - CT/XXE"
      And XX là hai chữ số cuối của năm dương lịch hiện tại
      And mẫu chứng từ không thể chỉnh sửa

    @auto-fill @symbol
    Scenario: Ký hiệu chứng từ tự động cập nhật theo năm lập
      Given năm hiện tại là 2026
      When người nộp thuế mở form lập chứng từ TNCN mới
      Then hệ thống hiển thị mẫu chứng từ là "03/TNCN - CT/26E"

  Rule: Số chứng từ tự động gán khi phát hành

    @certificate-number @auto-fill
    Scenario: Số chứng từ được tự động gán khi phát hành thành công
      Given người nộp thuế đã điền đầy đủ thông tin chứng từ hợp lệ
      When người nộp thuế phát hành chứng từ
      Then hệ thống tự động gán số chứng từ

    @certificate-number @validation
    Scenario: Số chứng từ không vượt quá 7 chữ số
      Given người nộp thuế đã điền đầy đủ thông tin chứng từ hợp lệ
      When người nộp thuế phát hành chứng từ
      Then số chứng từ được gán tối đa 7 chữ số

  Rule: Thông tin tổ chức trả thu nhập tự động điền từ hồ sơ đơn vị

    @auto-fill @read-only
    Scenario: Hiển thị và khóa thông tin tổ chức từ hồ sơ
      Given người nộp thuế có hồ sơ đơn vị hợp lệ trên hệ thống
      When người nộp thuế mở form lập chứng từ TNCN mới
      Then thông tin tổ chức trả thu nhập được tự động điền từ hồ sơ và không thể chỉnh sửa
        | Tên đơn vị    |
        | Mã số thuế    |
        | Địa chỉ       |
        | Số điện thoại  |

  Rule: Thông tin cá nhân/hộ kinh doanh bắt buộc nhập

    @individual-info @required
    Scenario Outline: Yêu cầu nhập đầy đủ thông tin bắt buộc
      Given người nộp thuế đang lập chứng từ TNCN
      When người nộp thuế bỏ trống <trường>
      And người nộp thuế lưu chứng từ
      Then hệ thống hiển thị lỗi "<thông_báo_lỗi>"

      Examples:
        | trường              | thông_báo_lỗi                              |
        | Họ và tên           | Họ và tên không được để trống               |
        | Mã số thuế          | Mã số thuế không được để trống              |
        | Địa chỉ             | Địa chỉ không được để trống                 |
        | CCCD/Hộ chiếu       | Số CCCD/Hộ chiếu không được để trống        |
        | Số điện thoại        | Số điện thoại không được để trống            |

    @individual-info @validation
    Scenario Outline: Kiểm tra độ dài trường thông tin cá nhân
      Given người nộp thuế đang lập chứng từ TNCN
      When người nộp thuế nhập <trường> vượt quá <giới_hạn> ký tự
      Then hệ thống hiển thị lỗi "<thông_báo_lỗi>"

      Examples:
        | trường         | giới_hạn | thông_báo_lỗi                                  |
        | Họ và tên      | 400      | Họ và tên không được vượt quá 400 ký tự         |
        | Địa chỉ        | 400      | Địa chỉ không được vượt quá 400 ký tự           |
        | Mã số thuế     | 14       | Mã số thuế không được vượt quá 14 ký tự         |
        | CCCD/Hộ chiếu  | 20       | Số CCCD/Hộ chiếu không được vượt quá 20 ký tự   |
        | Số điện thoại   | 20       | Số điện thoại không được vượt quá 20 ký tự       |
        | Email          | 50       | Email không được vượt quá 50 ký tự               |
        | Ghi chú        | 255      | Ghi chú không được vượt quá 255 ký tự            |

  Rule: Kiểm tra định dạng thông tin cá nhân

    @individual-info @validation
    Scenario: Kiểm tra định dạng mã số thuế cá nhân
      Given người nộp thuế đang lập chứng từ TNCN
      When người nộp thuế nhập mã số thuế không đúng định dạng
      Then hệ thống hiển thị lỗi "Mã số thuế phải là 10 hoặc 13 ký tự số"

    @individual-info @validation
    Scenario: Kiểm tra định dạng email
      Given người nộp thuế đang lập chứng từ TNCN
      When người nộp thuế nhập email không đúng định dạng
      Then hệ thống hiển thị lỗi "Email không đúng định dạng"

    @individual-info @validation
    Scenario: Kiểm tra định dạng số điện thoại
      Given người nộp thuế đang lập chứng từ TNCN
      When người nộp thuế nhập số điện thoại không hợp lệ
      Then hệ thống hiển thị lỗi "Số điện thoại không hợp lệ"

  Rule: Quốc tịch chỉ yêu cầu khi cá nhân không phải Việt Nam

    @nationality @conditional
    Scenario: Không yêu cầu nhập quốc tịch khi cá nhân là người Việt Nam
      Given người nộp thuế đang lập chứng từ TNCN
      And cá nhân bị khấu trừ là người Việt Nam
      Then trường quốc tịch không bắt buộc nhập

    @nationality @conditional
    Scenario: Yêu cầu nhập quốc tịch khi cá nhân không phải người Việt Nam
      Given người nộp thuế đang lập chứng từ TNCN
      And cá nhân bị khấu trừ không phải người Việt Nam
      Then trường quốc tịch bắt buộc nhập

  Rule: Xác định tình trạng cư trú của cá nhân

    @residency
    Scenario: Mặc định chọn tình trạng cư trú
      Given người nộp thuế mở form lập chứng từ TNCN mới
      Then tình trạng cư trú mặc định là "Cư trú"

    @residency
    Scenario: Cho phép chọn tình trạng không cư trú
      Given người nộp thuế đang lập chứng từ TNCN
      When người nộp thuế chọn tình trạng "Không cư trú"
      Then hệ thống ghi nhận tình trạng cư trú là "Không cư trú"

    @residency @required
    Scenario: Bắt buộc phải chọn tình trạng cư trú
      Given người nộp thuế đang lập chứng từ TNCN
      When người nộp thuế không chọn tình trạng cư trú
      And người nộp thuế lưu chứng từ
      Then hệ thống hiển thị lỗi "Phải chọn tình trạng cư trú"

  Rule: Email và ghi chú là trường không bắt buộc

    @individual-info @optional
    Scenario: Cho phép bỏ trống email và ghi chú khi lập chứng từ
      Given người nộp thuế đang lập chứng từ TNCN
      And người nộp thuế đã điền đầy đủ các trường bắt buộc
      When người nộp thuế bỏ trống email và ghi chú
      And người nộp thuế lưu chứng từ
      Then chứng từ được lưu thành công

  Rule: Hủy bỏ việc tạo chứng từ

    @action
    Scenario: Hủy bỏ việc tạo chứng từ quay về danh sách
      Given người nộp thuế đang lập chứng từ TNCN
      When người nộp thuế hủy bỏ
      Then người nộp thuế quay về danh sách chứng từ
      And không có chứng từ mới được tạo
