Feature: Chi tiết tờ khai đăng ký sử dụng chứng từ điện tử

  Background:
    Given người nộp thuế đã đăng nhập vào hệ thống
    And người nộp thuế có quyền đăng ký phát hành chứng từ điện tử

  Rule: Xem chi tiết tờ khai và hành động theo trạng thái

    @detail-view
    Scenario: Xem chi tiết tờ khai
      Given người nộp thuế đang xem danh sách tờ khai
      When người nộp thuế chọn xem chi tiết một tờ khai
      Then hệ thống hiển thị đầy đủ thông tin của tờ khai
        | Loại tờ khai          |
        | Thông tin đơn vị      |
        | Thông tin liên hệ     |
        | Đối tượng phát hành   |
        | Loại chứng từ         |
        | Hình thức gửi dữ liệu |
        | Thông tin chữ ký số   |
        | Trạng thái            |
        | Ngày lập              |

    @detail-view @rejection
    Scenario: Hiển thị chi tiết lý do từ chối khi tờ khai bị từ chối
      Given người nộp thuế đang xem chi tiết tờ khai có trạng thái "CQT không chấp nhận"
      When người nộp thuế xem lý do từ chối
      Then hệ thống hiển thị lý do từ chối từ cơ quan thuế bao gồm
        | Mã lỗi   |
        | Nội dung |

  Rule: Hành động theo trạng thái

    @actions
    Scenario Outline: Hiển thị hành động tương ứng với trạng thái tờ khai
      Given người nộp thuế đang xem chi tiết tờ khai
      And tờ khai có trạng thái <status>
      Then hệ thống hiển thị hành động <actions>

      Examples:
        | status              | actions                       |
        | Đã gửi CQT          | Đóng                          |
        | CQT không chấp nhận | Đóng, Lập tờ khai mới         |
        | Chờ CQT duyệt       | Đóng                          |
        | CQT chấp nhận       | Đóng                          |
