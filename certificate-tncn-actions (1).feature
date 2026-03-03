@certificate-tncn-actions
Feature: Hành động trên chứng từ khấu trừ thuế TNCN
  Với vai trò một NNT
  Tôi muốn thực hiện các hành động trên chứng từ khấu trừ thuế TNCN
  Để quản lý vòng đời chứng từ theo đúng quy trình

  Background:
    Given người nộp thuế đã đăng nhập vào hệ thống
    And người nộp thuế có quyền quản lý chứng từ

  Rule: Hành động phụ thuộc vào trạng thái CQT của chứng từ

    @action
    Scenario Outline: Hiển thị hành động tương ứng với trạng thái chứng từ
      Given người nộp thuế đang xem chi tiết chứng từ TNCN
      And chứng từ có trạng thái <trạng_thái>
      Then hệ thống hiển thị các hành động <hành_động>

      Examples:
        | trạng_thái                | hành_động                                                  |
        | Nháp                      | Phát hành, Tải chứng từ, Sao chép, Xem, Sửa, Xóa           |
        | Gửi CQT lỗi               | Tải chứng từ, Sao chép, Xem                                |
        | Đã gửi CQT                | Tải chứng từ, Sao chép, Điều chỉnh/Thay thế/TBSS, Xem      |
        | CQT kiểm tra không hợp lệ | Tải chứng từ, Sao chép, Xem                                |
        | CQT chấp nhận             | Gửi chứng từ cho KH, Tải chứng từ, Sao chép, Xem           |

  Rule: Phát hành chứng từ nháp

    @action @publish
    Scenario: Phát hành chứng từ nháp thành công
      Given người nộp thuế đang xem chứng từ TNCN ở trạng thái "Nháp"
      And chứng từ đã được điền đầy đủ thông tin hợp lệ
      When người nộp thuế phát hành chứng từ
      Then chứng từ được phát hành thành công
      And hệ thống tự động gán số chứng từ

    @action @publish @validation
    Scenario: Không thể phát hành khi thiếu thông tin bắt buộc
      Given người nộp thuế đang xem chứng từ TNCN ở trạng thái "Nháp"
      And chứng từ chưa được điền đầy đủ thông tin bắt buộc
      When người nộp thuế phát hành chứng từ
      Then hệ thống hiển thị các lỗi validation tương ứng
      And chứng từ không được phát hành

  Rule: Gửi chứng từ cho người nộp thuế qua email

    @action @send-nnt
    Scenario: Gửi chứng từ đã gửi CQT cho NNT
      Given người nộp thuế đang xem chứng từ TNCN ở trạng thái "CQT chấp nhận"
      And chứng từ có thông tin email cá nhân
      When người nộp thuế gửi chứng từ cho NNT
      Then hệ thống gửi chứng từ qua email cho cá nhân bị khấu trừ

    @action @send-nnt @validation
    Scenario: Yêu cầu email khi chứng từ chưa có email cá nhân
      Given người nộp thuế đang xem chứng từ TNCN
      And chứng từ chưa có thông tin email cá nhân
      When người nộp thuế gửi chứng từ cho NNT
      Then hệ thống yêu cầu nhập email trước khi gửi

  Rule: Tải chứng từ PDF/XML

    @action @download
    Scenario Outline: Tải chứng từ ở các trạng thái cho phép
      Given người nộp thuế đang xem chứng từ TNCN ở trạng thái "<trạng_thái>"
      When người nộp thuế tải chứng từ
      Then hệ thống cho phép tải chứng từ thành công

      Examples:
        | trạng_thái                 |
        | Nháp                       |
        | Gửi CQT lỗi               |
        | Đã gửi CQT                |
        | CQT kiểm tra không hợp lệ |
        | CQT chấp nhận             |

    @action @download
    Scenario: Hỗ trợ tải chứng từ ở định dạng PDF và XML
      Given người nộp thuế đang xem chứng từ TNCN
      When người nộp thuế chọn tải chứng từ
      Then hệ thống hiển thị 2 tùy chọn định dạng
        | PDF |
        | XML |

  Rule: Sao chép chứng từ
    # Sao chép chỉ khả dụng với: Gửi CQT lỗi, Đã gửi CQT, CQT kiểm tra không hợp lệ, CQT chấp nhận
    # Chứng từ Nháp KHÔNG có chức năng sao chép

    @action @copy
    Scenario: Không cho phép sao chép chứng từ ở trạng thái nháp
      Given người nộp thuế có chứng từ TNCN ở trạng thái "Nháp"
      When người nộp thuế xem danh sách hành động trên chứng từ
      Then hệ thống không hiển thị chức năng sao chép

    @action @copy
    Scenario: Sao chép chứng từ đã gửi CQT tạo bản nháp mới
      Given người nộp thuế có chứng từ TNCN ở trạng thái "Đã gửi CQT"
      When người nộp thuế sao chép chứng từ
      Then hệ thống tạo chứng từ nháp mới với thông tin từ chứng từ gốc
      And chứng từ mới có trạng thái "Nháp"

    @action @copy @corrective-flow
    Scenario: Sao chép chứng từ bị CQT từ chối để tạo chứng từ sửa lỗi
      Given người nộp thuế có chứng từ TNCN ở trạng thái "CQT kiểm tra không hợp lệ"
      When người nộp thuế sao chép chứng từ
      Then hệ thống tạo chứng từ nháp mới với thông tin từ chứng từ bị từ chối
      And người nộp thuế có thể chỉnh sửa để khắc phục lỗi từ CQT

    @action @copy @corrective-flow
    Scenario: Sao chép chứng từ gửi CQT lỗi để gửi lại
      Given người nộp thuế có chứng từ TNCN ở trạng thái "Gửi CQT lỗi"
      When người nộp thuế sao chép chứng từ
      Then hệ thống tạo chứng từ nháp mới với thông tin từ chứng từ lỗi
      And người nộp thuế có thể phát hành chứng từ mới để gửi lại CQT

  Rule: Sửa chứng từ nháp

    @action @edit
    Scenario: Cho phép sửa chứng từ ở trạng thái nháp
      Given người nộp thuế đang xem chứng từ TNCN ở trạng thái "Nháp"
      When người nộp thuế chọn sửa chứng từ
      Then hệ thống mở form chỉnh sửa chứng từ

    @action @edit
    Scenario Outline: Không cho phép sửa chứng từ ở trạng thái khác nháp
      Given người nộp thuế đang xem chứng từ TNCN ở trạng thái "<trạng_thái>"
      Then hệ thống không hiển thị chức năng sửa

      Examples:
        | trạng_thái                 |
        | Gửi CQT lỗi               |
        | Đã gửi CQT                |
        | CQT kiểm tra không hợp lệ |
        | CQT chấp nhận             |

  Rule: Xóa chứng từ nháp

    @action @delete
    Scenario: Cho phép xóa chứng từ ở trạng thái nháp
      Given người nộp thuế đang xem chứng từ TNCN ở trạng thái "Nháp"
      When người nộp thuế chọn xóa chứng từ
      And người nộp thuế xác nhận xóa
      Then chứng từ được xóa khỏi danh sách

    @action @delete
    Scenario: Hiển thị xác nhận trước khi xóa chứng từ
      Given người nộp thuế đang xem chứng từ TNCN ở trạng thái "Nháp"
      When người nộp thuế chọn xóa chứng từ
      Then hệ thống hiển thị thông báo xác nhận trước khi xóa

    @action @delete
    Scenario Outline: Không cho phép xóa chứng từ ở trạng thái khác nháp
      Given người nộp thuế đang xem chứng từ TNCN ở trạng thái "<trạng_thái>"
      Then hệ thống không hiển thị chức năng xóa

      Examples:
        | trạng_thái                 |
        | Gửi CQT lỗi               |
        | Đã gửi CQT                |
        | CQT kiểm tra không hợp lệ |
        | CQT chấp nhận             |

  Rule: Lập chứng từ điều chỉnh

    @action @adjustment
    Scenario: Cho phép lập chứng từ điều chỉnh từ chứng từ đã gửi CQT
      Given người nộp thuế đang xem chứng từ TNCN ở trạng thái "Đã gửi CQT"
      When người nộp thuế chọn lập chứng từ điều chỉnh
      Then hệ thống mở form lập chứng từ điều chỉnh

    @action @adjustment
    Scenario: Chứng từ điều chỉnh liên kết với chứng từ gốc
      Given người nộp thuế đã lập chứng từ điều chỉnh từ chứng từ gốc
      Then chứng từ điều chỉnh có tính chất "Chứng từ điều chỉnh"
      And chứng từ điều chỉnh hiển thị thông tin liên kết đến chứng từ gốc

    @action @adjustment
    Scenario: Tính chất chứng từ gốc chuyển thành "Bị điều chỉnh"
      Given người nộp thuế đã phát hành chứng từ điều chỉnh thành công
      Then tính chất của chứng từ gốc chuyển sang "Chứng từ bị điều chỉnh"

  Rule: Lập chứng từ thay thế

    @action @replacement
    Scenario: Cho phép lập chứng từ thay thế từ chứng từ đã gửi CQT
      Given người nộp thuế đang xem chứng từ TNCN ở trạng thái "Đã gửi CQT"
      When người nộp thuế chọn lập chứng từ thay thế
      Then hệ thống mở form lập chứng từ thay thế

    @action @replacement
    Scenario: Chứng từ thay thế kế thừa dữ liệu từ chứng từ gốc
      Given người nộp thuế chọn lập chứng từ thay thế từ chứng từ gốc
      Then form lập chứng từ thay thế được điền sẵn thông tin từ chứng từ gốc
      And người nộp thuế có thể chỉnh sửa thông tin

    @action @replacement
    Scenario: Tính chất chứng từ gốc chuyển thành "Bị thay thế"
      Given người nộp thuế đã phát hành chứng từ thay thế thành công
      Then tính chất của chứng từ gốc chuyển sang "Chứng từ bị thay thế"

  Rule: Thao tác hàng loạt trên danh sách

    @action @batch
    Scenario: Phát hành hàng loạt chứng từ nháp
      Given người nộp thuế đang xem danh sách chứng từ TNCN
      And danh sách có nhiều chứng từ ở trạng thái "Nháp"
      When người nộp thuế chọn nhiều chứng từ nháp và phát hành hàng loạt
      Then tất cả chứng từ được chọn được phát hành thành công

    @action @batch
    Scenario: Gửi NNT hàng loạt
      Given người nộp thuế đang xem danh sách chứng từ TNCN
      When người nộp thuế chọn nhiều chứng từ và gửi NNT hàng loạt
      Then hệ thống gửi email cho tất cả cá nhân tương ứng

    @action @batch
    Scenario: Tải hàng loạt chứng từ
      Given người nộp thuế đang xem danh sách chứng từ TNCN
      When người nộp thuế chọn nhiều chứng từ và tải hàng loạt
      Then hệ thống tải xuống tất cả chứng từ được chọn

    @action @batch
    Scenario: Xóa hàng loạt chứng từ nháp
      Given người nộp thuế đang xem danh sách chứng từ TNCN
      And danh sách có nhiều chứng từ ở trạng thái "Nháp"
      When người nộp thuế chọn nhiều chứng từ nháp và xóa hàng loạt
      And người nộp thuế xác nhận xóa
      Then tất cả chứng từ nháp được chọn bị xóa khỏi danh sách
