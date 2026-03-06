@document-declaration
Feature: Tạo mới tờ khai đăng ký/thay đổi thông tin sử dụng chứng từ điện tử
  Với vai trò một NNT
  Tôi muốn tạo tờ khai đăng ký/thay đổi thông tin sử dụng chứng từ điện tử
  Để gửi cho cơ quan thuế xét duyệt

  Background:
    Given người nộp thuế đã đăng nhập vào hệ thống
    And người nộp thuế có quyền đăng ký phát hành chứng từ điện tử

  Rule: Xác định loại tờ khai

    @web @type-selection
    Scenario: Cho phép tự chọn loại tờ khai khi MST chưa có dữ liệu trên hệ thống
      Given MST chưa có tờ khai nào được ghi nhận trên hệ thống
      When người nộp thuế thực hiện lập tờ khai mới
      Then hệ thống mặc định hiển thị loại tờ khai là "Đăng ký mới"
      And người nộp thuế có thể chủ động chọn sang "Thay đổi thông tin"

    @web @type-selection
    Scenario: Mặc định chọn "Thay đổi thông tin" khi đã có tờ khai được chấp nhận
      Given MST đã có ít nhất một tờ khai ở trạng thái "CQT chấp nhận"
      When người nộp thuế thực hiện lập tờ khai mới
      Then hệ thống tự động gán loại tờ khai là "Thay đổi thông tin"
      And hệ thống tự động điền thông tin dựa trên tờ khai được chấp nhận gần nhất

  Rule: Thông tin đơn vị tự động được điền và không thể chỉnh sửa

    @web @auto-fill @read-only
    Scenario: Hiển thị và khóa thông tin đơn vị từ hồ sơ
      Given người nộp thuế có hồ sơ đăng ký hợp lệ trên hệ thống
      When người nộp thuế tạo tờ khai mới
      Then thông tin đơn vị được tự động điền từ hồ sơ và không thể chỉnh sửa
        | Tên đơn vị           |
        | Mã số thuế           |
        | Cơ quan thuế quản lý |

  Rule: Thông tin liên hệ bắt buộc nhập

    @web @contact-info @auto-fill
    Scenario: Tự động điền thông tin liên hệ từ phân hệ "Thông tin đơn vị"
      Given người nộp thuế đang tạo tờ khai mới
      When người nộp thuế mở form tạo tờ khai
      Then hệ thống tự động điền thông tin liên hệ từ phân hệ "Thông tin đơn vị"
        | Người liên hệ      |
        | Điện thoại liên hệ |
        | Địa chỉ liên hệ    |
        | Email              |

    @web @contact-info @editable
    Scenario: Cho phép chỉnh sửa thông tin liên hệ được tự động điền
      Given thông tin liên hệ đã được tự động điền từ phân hệ "Thông tin đơn vị"
      When người nộp thuế chỉnh sửa các trường thông tin liên hệ
      Then hệ thống cho phép cập nhật giá trị các trường thông tin liên hệ

    @api @contact-info @required
    Scenario Outline: Yêu cầu nhập đầy đủ thông tin liên hệ
      Given người nộp thuế đang tạo tờ khai
      When người nộp thuế bỏ trống "<trường>"
      And người nộp thuế gửi tờ khai
      Then hệ thống hiển thị lỗi "<thông_báo_lỗi>"

      Examples:
        | trường             | thông_báo_lỗi                          |
        | Người liên hệ      | Người liên hệ không được để trống      |
        | Điện thoại liên hệ | Điện thoại liên hệ không được để trống |
        | Địa chỉ liên hệ    | Địa chỉ liên hệ không được để trống    |
        | Email              | Địa chỉ email không được để trống      |

    @api @contact-info @validation
    Scenario: Kiểm tra định dạng số điện thoại
      Given người nộp thuế đang tạo tờ khai
      When người nộp thuế nhập số điện thoại không hợp lệ
      Then hệ thống hiển thị lỗi "Số điện thoại không hợp lệ"

    @api @contact-info @validation
    Scenario: Kiểm tra định dạng email
      Given người nộp thuế đang tạo tờ khai
      When người nộp thuế nhập email không hợp lệ
      Then hệ thống hiển thị lỗi "Email không đúng định dạng"

    @api @contact-info @validation
    Scenario Outline: Kiểm tra độ dài trường thông tin
      Given người nộp thuế đang tạo tờ khai
      When người nộp thuế nhập "<trường>" vượt quá <giới_hạn> ký tự
      Then hệ thống hiển thị lỗi "<thông_báo_lỗi>"

      Examples:
        | trường             | giới_hạn | thông_báo_lỗi                                  |
        | Người liên hệ      |       50 | Tên người liên hệ không được vượt quá 50 ký tự |
        | Điện thoại liên hệ |       20 | Số điện thoại không được vượt quá 20 ký tự     |
        | Địa chỉ liên hệ    |      400 | Địa chỉ không được vượt quá 400 ký tự          |
        | Email              |       50 | Email không được vượt quá 50 ký tự             |

  Rule: Tự động điền thông tin từ tờ khai gần nhất khi thay đổi thông tin

    @web @auto-fill @change-info
    Scenario: Tự động điền thông tin liên hệ từ tờ khai được chấp nhận gần nhất
      Given MST đã có tờ khai ở trạng thái "CQT chấp nhận"
      When người nộp thuế tạo tờ khai "Thay đổi thông tin"
      Then hệ thống tự động điền thông tin liên hệ từ tờ khai được chấp nhận gần nhất
        | Người liên hệ      |
        | Điện thoại liên hệ |
        | Địa chỉ liên hệ    |
        | Email              |

    @web @auto-fill @change-info
    Scenario: Tự động điền cấu hình từ tờ khai được chấp nhận gần nhất
      Given MST đã có tờ khai ở trạng thái "CQT chấp nhận"
      When người nộp thuế tạo tờ khai "Thay đổi thông tin"
      Then hệ thống tự động điền cấu hình từ tờ khai được chấp nhận gần nhất
        | Đối tượng phát hành   |
        | Loại hình sử dụng     |
        | Hình thức gửi dữ liệu |
        | Thông tin chữ ký số   |

  Rule: Giá trị mặc định khi tạo tờ khai Đăng ký mới

    @web @default-values @new-registration
    Scenario: Tự động thiết lập giá trị mặc định khi tạo tờ khai Đăng ký mới
      Given MST chưa có tờ khai nào ở trạng thái "CQT chấp nhận"
      When người nộp thuế tạo tờ khai Đăng ký mới
      Then hệ thống tự động chọn các giá trị mặc định
        | Đối tượng phát hành   | Tổ chức, cá nhân phát hành                         |
        | Loại hình sử dụng     | Chứng từ điện tử khấu trừ thuế thu nhập cá nhân    |
        | Hình thức gửi dữ liệu | Thông qua tổ chức cung cấp dịch vụ hóa đơn điện tử |

  Rule: NNT chỉ thuộc một đối tượng phát hành duy nhất

    @web @issuer-type
    Scenario: Hiển thị các lựa chọn đối tượng phát hành
      Given người nộp thuế đang tạo tờ khai
      When người nộp thuế xem mục đối tượng phát hành
      Then hệ thống hiển thị các đối tượng phát hành
        | Tổ chức, cá nhân phát hành |
        | Cơ quan thuế phát hành     |

    @api @issuer-type @required
    Scenario: Tờ khai bị từ chối khi chưa chọn đối tượng phát hành
      Given người nộp thuế đang tạo tờ khai
      When người nộp thuế không chọn đối tượng phát hành nào
      And người nộp thuế gửi tờ khai
      Then hệ thống hiển thị lỗi "Phải chọn ít nhất một đối tượng phát hành"

    # --- Bổ sung ---
    @api @issuer-type @mutual-exclusive
    Scenario: Tờ khai bị từ chối khi chọn đồng thời cả hai đối tượng phát hành
      Given người nộp thuế đang tạo tờ khai
      When người nộp thuế chọn cả "Tổ chức, cá nhân phát hành" và "Cơ quan thuế phát hành"
      And người nộp thuế gửi tờ khai
      Then hệ thống từ chối tờ khai
      And hệ thống thông báo mỗi NNT chỉ được chọn một đối tượng phát hành

  Rule: Loại hình sử dụng chứng từ điện tử

    @web @document-type
    Scenario: Hiển thị các loại hình sử dụng có sẵn
      Given người nộp thuế đang tạo tờ khai
      When người nộp thuế xem mục loại hình sử dụng
      Then hệ thống hiển thị các loại hình sử dụng
        | Chứng từ điện tử khấu trừ thuế thu nhập cá nhân                                                         |
        | Chứng từ điện tử khấu trừ thuế đối với hoạt động kinh doanh trên nền tảng thương mại điện tử, nền tảng số |
        | Biên lai điện tử                                                                                         |

    @api @document-type @required
    Scenario: Tờ khai bị từ chối khi chưa chọn loại hình sử dụng
      Given người nộp thuế đang tạo tờ khai
      When người nộp thuế không chọn loại hình sử dụng nào
      And người nộp thuế gửi tờ khai
      Then hệ thống hiển thị lỗi "Phải chọn ít nhất một loại chứng từ điện tử"

    @web @document-type @conditional
    Scenario: Hiển thị các loại biên lai con khi chọn "Biên lai điện tử"
      Given người nộp thuế đang tạo tờ khai
      When người nộp thuế chọn "Biên lai điện tử"
      Then hệ thống hiển thị các loại biên lai con
        | Biên lai thu thuế, phí, lệ phí không in sẵn mệnh giá |
        | Biên lai thu thuế, phí, lệ phí in sẵn mệnh giá       |
        | Biên lai thu thuế, phí, lệ phí                       |

    @web @document-type @conditional
    Scenario: Ẩn các loại biên lai con khi bỏ chọn "Biên lai điện tử"
      Given người nộp thuế đã chọn "Biên lai điện tử"
      When người nộp thuế bỏ chọn "Biên lai điện tử"
      Then hệ thống ẩn các loại biên lai con

    @web @document-type @conditional
    Scenario: Cho phép chọn một hoặc nhiều loại biên lai con
      Given người nộp thuế đã chọn "Biên lai điện tử"
      When người nộp thuế chọn một hoặc nhiều loại biên lai con
      Then hệ thống ghi nhận tất cả các loại biên lai được chọn

    @web @document-type @conditional @required
    Scenario: Tờ khai bị từ chối khi chọn "Biên lai điện tử" nhưng không chọn loại con
      Given người nộp thuế đã chọn "Biên lai điện tử"
      And người nộp thuế không chọn loại biên lai con nào
      When người nộp thuế gửi tờ khai
      Then hệ thống hiển thị lỗi "Phải chọn loại biên lai điện tử"

    # --- Bổ sung ---
    # Biên lai điện tử (bao gồm các loại con) chỉ dành cho Cơ quan thuế phát hành
    # Tổ chức, cá nhân phát hành chỉ được dùng chứng từ khấu trừ thuế
    @api @document-type @issuer-compatibility
    Scenario Outline: Tờ khai bị từ chối khi Tổ chức, cá nhân phát hành chọn loại Biên lai
      Given người nộp thuế đã chọn đối tượng phát hành là "Tổ chức, cá nhân phát hành"
      When người nộp thuế chọn loại hình sử dụng "<loại_biên_lai>"
      And người nộp thuế gửi tờ khai
      Then hệ thống từ chối tờ khai
      And hệ thống thông báo loại hình sử dụng không phù hợp với đối tượng phát hành đã chọn

      Examples:
        | loại_biên_lai                                         |
        | Biên lai thu thuế, phí, lệ phí không in sẵn mệnh giá |
        | Biên lai thu thuế, phí, lệ phí in sẵn mệnh giá       |
        | Biên lai thu thuế, phí, lệ phí                       |

    @api @document-type @issuer-compatibility
    Scenario Outline: Tổ chức, cá nhân phát hành được phép chọn loại hình chứng từ khấu trừ
      Given người nộp thuế đã chọn đối tượng phát hành là "Tổ chức, cá nhân phát hành"
      When người nộp thuế chọn loại hình sử dụng "<loại_hình_hợp_lệ>"
      And người nộp thuế gửi tờ khai hợp lệ
      Then hệ thống chấp nhận tờ khai

      Examples:
        | loại_hình_hợp_lệ                                                                                           |
        | Chứng từ điện tử khấu trừ thuế thu nhập cá nhân                                                            |
        | Chứng từ điện tử khấu trừ thuế đối với hoạt động kinh doanh trên nền tảng thương mại điện tử, nền tảng số  |

  Rule: Hình thức gửi dữ liệu chứng từ điện tử

    @web @submission-method
    Scenario: Hiển thị các hình thức gửi dữ liệu
      Given người nộp thuế đang tạo tờ khai
      When người nộp thuế xem mục hình thức gửi dữ liệu
      Then hệ thống hiển thị các hình thức gửi dữ liệu
        | Trên cổng thông tin điện tử của cơ quan thuế                                   |
        | Thông qua tổ chức cung cấp dịch vụ hóa đơn điện tử                             |
        | Thông qua tổ chức cung cấp dịch vụ hóa đơn điện tử được Tổng cục Thuế ủy thác |

    @api @submission-method @required
    Scenario: Tờ khai bị từ chối khi chưa chọn hình thức gửi dữ liệu
      Given người nộp thuế đang tạo tờ khai
      When người nộp thuế không chọn hình thức gửi dữ liệu nào
      And người nộp thuế gửi tờ khai
      Then hệ thống hiển thị lỗi "Phải chọn ít nhất một hình thức gửi dữ liệu"

    # --- Bổ sung ---
    # Mỗi tờ khai chỉ đăng ký một kênh truyền nhận dữ liệu với CQT
    @api @submission-method @single-selection
    Scenario: Tờ khai bị từ chối khi chọn nhiều hơn một hình thức gửi dữ liệu
      Given người nộp thuế đang tạo tờ khai
      When người nộp thuế chọn nhiều hơn một hình thức gửi dữ liệu
      And người nộp thuế gửi tờ khai
      Then hệ thống từ chối tờ khai
      And hệ thống thông báo chỉ được chọn một hình thức gửi dữ liệu

    # Biên lai không in sẵn MG và in sẵn MG bắt buộc phải gửi qua tổ chức cung cấp dịch vụ
    @api @submission-method @document-type-compatibility
    Scenario Outline: Tờ khai bị từ chối khi gửi biên lai thu thuế qua cổng CQT
      Given người nộp thuế đã chọn loại hình sử dụng "<loại_biên_lai>"
      When người nộp thuế chọn hình thức "Trên cổng thông tin điện tử của cơ quan thuế"
      And người nộp thuế gửi tờ khai
      Then hệ thống từ chối tờ khai
      And hệ thống thông báo loại biên lai này phải gửi qua tổ chức cung cấp dịch vụ hóa đơn điện tử

      Examples:
        | loại_biên_lai                                         |
        | Biên lai thu thuế, phí, lệ phí không in sẵn mệnh giá |
        | Biên lai thu thuế, phí, lệ phí in sẵn mệnh giá       |

    # Chứng từ khấu trừ TNCN chỉ được dùng cổng CQT khi là Cơ quan thuế phát hành
    @api @submission-method @tncn-portal-restriction
    Scenario: Tờ khai bị từ chối khi Tổ chức, cá nhân phát hành gửi chứng từ TNCN qua cổng CQT
      Given người nộp thuế đã chọn đối tượng phát hành là "Tổ chức, cá nhân phát hành"
      And người nộp thuế đã chọn loại hình sử dụng "Chứng từ điện tử khấu trừ thuế thu nhập cá nhân"
      When người nộp thuế chọn hình thức "Trên cổng thông tin điện tử của cơ quan thuế"
      And người nộp thuế gửi tờ khai
      Then hệ thống từ chối tờ khai
      And hệ thống thông báo NNT không thuộc trường hợp được sử dụng cổng CQT cho loại chứng từ này

    @api @submission-method @tncn-portal-restriction
    Scenario: Cơ quan thuế phát hành được gửi chứng từ TNCN qua cổng CQT
      Given người nộp thuế đã chọn đối tượng phát hành là "Cơ quan thuế phát hành"
      And người nộp thuế đã chọn loại hình sử dụng "Chứng từ điện tử khấu trừ thuế thu nhập cá nhân"
      When người nộp thuế chọn hình thức "Trên cổng thông tin điện tử của cơ quan thuế"
      And người nộp thuế gửi tờ khai hợp lệ
      Then hệ thống chấp nhận tờ khai

  Rule: Quản lý chữ ký số

    @api @signature
    Scenario: Thêm chữ ký số hợp lệ vào tờ khai
      Given người nộp thuế đang tạo tờ khai
      When người nộp thuế thêm chữ ký số còn hiệu lực và MST khớp với MST đơn vị
      Then chữ ký số được thêm vào danh sách với thông tin
        | Tổ chức chứng thực CKS |
        | Số Serial CKS          |
        | Hiệu lực từ ngày       |
        | Hiệu lực đến ngày      |
        | Hình thức đăng ký      |

    @web @signature
    Scenario: Xóa chữ ký số khỏi tờ khai
      Given người nộp thuế đang tạo tờ khai có nhiều chữ ký số
      When người nộp thuế xóa một chữ ký số
      Then chữ ký số được xóa khỏi danh sách

    @api @signature @required
    Scenario: Yêu cầu có ít nhất một chữ ký số hợp lệ
      Given người nộp thuế đang tạo tờ khai
      And tờ khai chưa có chữ ký số nào
      When người nộp thuế gửi tờ khai
      Then hệ thống hiển thị lỗi "Phải có ít nhất một chữ ký số hợp lệ"

    @api @signature @validation
    Scenario: Chữ ký số phải còn hiệu lực
      Given người nộp thuế đang tạo tờ khai
      When người nộp thuế thêm chữ ký số đã hết hiệu lực
      Then hệ thống từ chối và thông báo chữ ký số không còn hiệu lực

    @api @signature @validation
    Scenario: MST trên chữ ký số phải trùng với MST tờ khai
      Given người nộp thuế đang tạo tờ khai
      When người nộp thuế thêm chữ ký số có MST khác với MST đơn vị
      Then hệ thống từ chối và thông báo MST trên chữ ký số không khớp

  Rule: Hiệu năng tạo tờ khai

    @web @performance
    Scenario: Form tạo tờ khai load nhanh
      Given người nộp thuế có quyền đăng ký phát hành chứng từ điện tử
      When người nộp thuế mở form tạo tờ khai
      Then form hiển thị đầy đủ trong vòng 2 giây

    @web @performance
    Scenario: Tự động điền thông tin hoàn thành nhanh
      Given MST đã có tờ khai ở trạng thái "CQT chấp nhận"
      When người nộp thuế tạo tờ khai "Thay đổi thông tin"
      Then thông tin được tự động điền hoàn tất trong vòng 1 giây

  Rule: Hủy bỏ việc tạo tờ khai

    @web @action
    Scenario: Hủy bỏ việc tạo tờ khai
      Given người nộp thuế đang tạo tờ khai
      When người nộp thuế hủy bỏ
      Then người nộp thuế quay về danh sách tờ khai
      And không có tờ khai mới được tạo

  Rule: Sinh mã tờ khai tịnh tiến cho tờ khai chứng từ điện tử

    @api @declaration-code
    Scenario: Gán mã tờ khai đầu tiên cho MST chưa có tờ khai
      Given MST chưa có tờ khai nào trên hệ thống
      When người nộp thuế tạo tờ khai mới
      Then hệ thống gán mã tờ khai là "TKCT000001"

    @api @declaration-code
    Scenario: Mã tờ khai tăng dần dựa trên tờ khai gần nhất của MST
      Given MST đã có tờ khai gần nhất với mã "TKCT000005"
      When người nộp thuế tạo tờ khai mới
      Then hệ thống gán mã tờ khai là "TKCT000006"

    @api @declaration-code
    Scenario: Mã tờ khai bị từ chối vẫn được tính vào chuỗi tịnh tiến
      Given MST đã có tờ khai mã "TKCT000003" ở trạng thái "CQT từ chối"
      When người nộp thuế tạo tờ khai mới
      Then hệ thống gán mã tờ khai là "TKCT000004"

  Rule: Tạo nội dung XML tờ khai theo định dạng CQT

    @api @xml-generation @header
    Scenario: XML chứa thông tin chung của tờ khai
      Given người nộp thuế đã tạo tờ khai với  đầy đủ thông tin 
      When hệ thống sinh nội dung XML tờ khai
      Then phần thông tin chung trong XML chứa đầy đủ thông tin đơn vị và liên hệ
        | thong_tin_chung         |xml expect
        | Hình thức               |HThuc
        | Tên người nộp thuế      |TNNT
        | Mã số thuế              |MST
        | Cơ quan thuế quản lý    |CQTQLy
        | Mã cơ quan thuế quản lý |MCQTQLy
        | Người liên hệ           |NLHe
        | Địa chỉ liên hệ         |DCLHe
        | Email                   |DCTDTu
        | Điện thoại liên hệ      |DTLHe
        | Địa danh                |DDanh
        | Ngày lập                |NLap
      And XML chứa loại tờ khai phù hợp với lựa chọn của người nộp thuế

    @api @xml-generation @issuer-flags
    Scenario Outline: XML thể hiện đối tượng phát hành dưới dạng có/không
      Given người nộp thuế đã tạo tờ khai
      And người nộp thuế đã chọn đối tượng phát hành <đối_tượng_chọn>
      When hệ thống sinh nội dung XML tờ khai
      Then mục đối tượng phát hành trong XML đánh dấu "có" cho <đối_tượng_chọn>
      And đánh dấu "không" cho các đối tượng phát hành còn lại

      Examples:
        | đối_tượng_chọn                                       |xml expect
        | Tổ chức, cá nhân phát hành                           |TCCNPHanh
        | Cơ quan thuế phát hành                               |CQTPHanh

    @api @xml-generation @usage-type-flags
    Scenario Outline: XML thể hiện loại hình sử dụng dưới dạng có/không
      Given người nộp thuế đã tạo tờ khai
      And người nộp thuế đã chọn loại hình sử dụng <loại_hình_chọn>
      When hệ thống sinh nội dung XML tờ khai
      Then mục loại hình sử dụng trong XML đánh dấu "có" cho <loại_hình_chọn>
      And đánh dấu "không" cho các loại hình sử dụng còn lại

      Examples:
        | loại_hình_chọn                                                                |xml expect
        | Chứng từ điện tử khấu trừ thuế thu nhập cá nhân                               |CTTNCNhan
        | Chứng từ điện tử đối với hoạt động kinh doanh nền tảng số, thương mại điện tử |CTKTTTMDTu
        | Biên lai thu thuế, phí, lệ phí không in sẵn mệnh giá                          |BLTPLPKIn
        | Biên lai thu thuế, phí, lệ phí in sẵn mệnh giá                                |BLTPLPIn
        | Biên lai thu thuế, phí, lệ phí                                                |BLTTPLPhi

    @api @xml-generation @transmission-flags
    Scenario Outline: XML thể hiện hình thức gửi dữ liệu dưới dạng có/không
      Given người nộp thuế đã tạo tờ khai
      And người nộp thuế đã chọn hình thức gửi dữ liệu <hình_thức_chọn>
      When hệ thống sinh nội dung XML tờ khai
      Then mục hình thức gửi dữ liệu trong XML đánh dấu "có" cho <hình_thức_chọn>
      And đánh dấu "không" cho các hình thức gửi dữ liệu còn lại

      Examples:
        | hình_thức_chọn                                                     |xml expect
        | Trên cổng thông tin điện tử của cơ quan thuế                       |CDLQCCQT
        | Thông qua tổ chức cung cấp dịch vụ hóa đơn điện tử                 |CDLQTCTN
        | Thông qua tổ chức cung cấp dịch vụ HĐĐT được Tổng cục Thuế ủy thác |CDLQTCTNUT

    @api @xml-generation @signature
    Scenario: XML chứa đầy đủ thông tin chữ ký số đã đăng ký
      Given người nộp thuế đã tạo tờ khai với nhiều chữ ký số
      When hệ thống sinh nội dung XML tờ khai
      Then mục chứng thư số sử dụng trong XML chứa đầy đủ thông tin mỗi chữ ký
        | thong_tin_cks          |xml expect
        | Số thứ tự              |STT
        | Tổ chức chứng thực     |TTChuc
        | Số serial chứng thư số |Seri
        | Hiệu lực từ ngày       |TNgay
        | Hiệu lực đến ngày      |DNgay
        | Hình thức đăng ký      |HThuc
      And các chữ ký số được sắp xếp theo thứ tự đăng ký
