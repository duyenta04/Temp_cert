@document-declaration
Feature: Tạo mới tờ khai đăng ký/thay đổi thông tin sử dụng chứng từ điện tử
  Với vai trò một NNT
  Tôi muốn tạo tờ khai đăng ký/thay đổi thông tin sử dụng chứng từ điện tử với cơ quan thuế

  Background:
    Given người nộp thuế đã đăng nhập vào hệ thống
    And người nộp thuế có quyền đăng ký phát hành chứng từ điện tử

  Rule: Xác định loại tờ khai

    @type-selection
    Scenario: Khóa loại tờ khai "Đăng ký mới" khi MST đã bị từ chối trên hệ thống
      Given MST "0101234567" đã từng nộp tờ khai và tất cả đều bị CQT từ chối
      When người nộp thuế thực hiện lập tờ khai mới
      Then hệ thống tự động gán loại tờ khai là "Đăng ký mới"
      And không cho phép người nộp thuế thay đổi sang "Thay đổi thông tin"

    @type-selection
    Scenario: Cho phép tự chọn loại tờ khai khi MST chưa có dữ liệu trên hệ thống hiện tại
      Given MST "0101234567" chưa có tờ khai nào được ghi nhận trên hệ thống hiện tại
      When người nộp thuế thực hiện lập tờ khai mới
      Then hệ thống mặc định hiển thị loại tờ khai là "Đăng ký mới"
      And người nộp thuế có thể chủ động chọn sang "Thay đổi thông tin"

    @type-selection
    Scenario: Mặc định chọn "Thay đổi thông tin" khi đã có đăng ký được chấp nhận
      Given MST "0101234567" đã có ít nhất một tờ khai ở trạng thái "CQT chấp nhận"
      When người nộp thuế thực hiện lập tờ khai mới
      Then hệ thống tự động gán loại tờ khai là "Thay đổi thông tin"
      And hệ thống cập nhật thông tin dựa trên tờ khai được chấp nhận gần nhất

  Rule: Thông tin đơn vị tự động được điền

    @auto-fill
    Scenario: Hiển thị và khoá thông tin đơn vị từ hồ sơ
      Given người nộp thuế có hồ sơ đăng ký hợp lệ trên hệ thống
      When người nộp thuế tạo tờ khai mới
      Then thông tin đơn vị được tự động điền từ hồ sơ và không thể chỉnh sửa
        | Tên đơn vị           |
        | Mã số thuế           |
        | Cơ quan thuế quản lý |

  Rule: Thông tin liên hệ

    @contact-info @required
    Scenario Outline: Yêu cầu nhập đầy đủ thông tin liên hệ
      Given người nộp thuế đang tạo tờ khai
      When người nộp thuế bỏ trống <field>
      And người nộp thuế gửi tờ khai
      Then hệ thống hiển thị lỗi <error_message>

      Examples:
        | field              | error_message                          |
        | Người liên hệ      | Người liên hệ không được để trống      |
        | Điện thoại liên hệ | Điện thoại liên hệ không được để trống |
        | Địa chỉ liên hệ    | Địa chỉ liên hệ không được để trống    |
        | Email              | Địa chỉ email không được để trống      |

    @contact-info @validation
    Scenario: Kiểm tra định dạng số điện thoại
      Given người nộp thuế đang tạo tờ khai
      When người nộp thuế nhập số điện thoại không hợp lệ
      Then hệ thống hiển thị lỗi "Số điện thoại không hợp lệ"

    @contact-info @validation
    Scenario: Kiểm tra định dạng email
      Given người nộp thuế đang tạo tờ khai
      When người nộp thuế nhập email không hợp lệ
      Then hệ thống hiển thị lỗi "Email không đúng định dạng"

  Rule: Giá trị mặc định khi tạo tờ khai Đăng ký mới

    @default-values @new-registration
    Scenario Outline: Tự động thiết lập giá trị mặc định khi tạo tờ khai Đăng ký mới
      Given MST "0101234567" chưa có tờ khai nào ở trạng thái "CQT chấp nhận"
      When người nộp thuế tạo tờ khai Đăng ký mới
      Then hệ thống tự động chọn <gia_tri_mac_dinh> ở mục <truong>

      Examples:
        | truong                | gia_tri_mac_dinh                                                    |
        | Đối tượng phát hành   | Tổ chức, cá nhân phát hành                                          |
        | Loại hình sử dụng     | Chứng từ điện tử khấu trừ thuế thu nhập cá nhân                     |
        | Hình thức gửi dữ liệu | Thông qua tổ chức cung cấp dịch vụ hóa đơn điện tử                  |

  Rule: Đối tượng phát hành

    @issuer-type
    Scenario: Hiển thị các lựa chọn đối tượng phát hành
      When người nộp thuế tạo tờ khai mới
      Then hệ thống hiển thị các đối tượng phát hành
        | Tổ chức, cá nhân phát hành |
        | Cơ quan thuế phát hành     |

    @issuer-type @required
    Scenario: Yêu cầu chọn ít nhất một đối tượng phát hành
      Given người nộp thuế đang tạo tờ khai
      When người nộp thuế không chọn đối tượng phát hành nào
      And người nộp thuế gửi tờ khai
      Then hệ thống hiển thị lỗi "Phải chọn ít nhất một đối tượng phát hành"

  Rule: Loại hình sử dụng chứng từ điện tử

    @document-type
    Scenario: Hiển thị các loại hình sử dụng có sẵn
      When người nộp thuế tạo tờ khai mới
      Then hệ thống hiển thị các loại hình sử dụng
        | Chứng từ điện tử khấu trừ thuế thu nhập cá nhân                                          |
        | Chứng từ điện tử đối với hoạt động kinh doanh nền tảng số, kinh doanh thương mại điện tử |
        | Biên lai điện tử                                                                          |

    @document-type @required
    Scenario: Yêu cầu chọn ít nhất một loại hình sử dụng
      Given người nộp thuế đang tạo tờ khai
      When người nộp thuế không chọn loại hình sử dụng nào
      And người nộp thuế gửi tờ khai
      Then hệ thống hiển thị lỗi "Phải chọn ít nhất một loại hình sử dụng"

    @document-type @conditional
    Scenario: Hiển thị các loại biên lai con khi chọn "Biên lai điện tử"
      Given người nộp thuế đang tạo tờ khai
      When người nộp thuế chọn "Biên lai điện tử"
      Then hệ thống hiển thị các loại biên lai con
        | Biên lai thu thuế, phí, lệ phí không in sẵn mệnh giá |
        | Biên lai thu thuế, phí, lệ phí in sẵn mệnh giá       |
        | Biên lai thu thuế, phí, lệ phí                        |

    @document-type @conditional
    Scenario: Ẩn các loại biên lai con khi bỏ chọn "Biên lai điện tử"
      Given người nộp thuế đã chọn "Biên lai điện tử"
      When người nộp thuế bỏ chọn "Biên lai điện tử"
      Then hệ thống ẩn các loại biên lai con

  Rule: Hình thức gửi dữ liệu

    @submission-method
    Scenario: Hiển thị các hình thức gửi dữ liệu
      When người nộp thuế tạo tờ khai mới
      Then hệ thống hiển thị các hình thức gửi dữ liệu
        | Truyền qua cổng thông tin điện tử của cơ quan thuế                              |
        | Thông qua tổ chức cung cấp dịch vụ hóa đơn điện tử                             |
        | Thông qua tổ chức cung cấp dịch vụ hóa đơn điện tử được Tổng cục Thuế ủy thác  |

    @submission-method @required
    Scenario: Yêu cầu chọn ít nhất một hình thức gửi dữ liệu
      Given người nộp thuế đang tạo tờ khai
      When người nộp thuế không chọn hình thức gửi dữ liệu nào
      And người nộp thuế gửi tờ khai
      Then hệ thống hiển thị lỗi "Phải chọn ít nhất một hình thức gửi dữ liệu"

  Rule: Hủy bỏ và Nộp tờ khai

    @action
    Scenario: Hủy bỏ việc tạo tờ khai
      Given người nộp thuế đang tạo tờ khai
      When người nộp thuế hủy bỏ
      Then người nộp thuế quay về danh sách tờ khai
      And không có tờ khai mới được tạo

    @action
    Scenario: Nộp tờ khai hợp lệ
      Given người nộp thuế đã điền đầy đủ thông tin hợp lệ
      When người nộp thuế nộp tờ khai cho cơ quan thuế
      Then tờ khai được tạo thành công
      And hệ thống hiển thị thông báo "Tạo tờ khai thành công"
