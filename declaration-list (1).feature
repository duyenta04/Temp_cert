@list-declaration
Feature: Danh sách tờ khai đăng ký sử dụng chứng từ điện tử

  Background:
    Given người nộp thuế đã đăng nhập vào hệ thống
    And người nộp thuế có quyền đăng ký phát hành chứng từ điện tử

  Rule: Quản lý danh sách tờ khai

    @list-view
    Scenario: Truy cập danh sách tờ khai
      When người nộp thuế chọn menu đăng ký chứng từ điện tử
      Then hệ thống hiển thị danh sách tờ khai

    @list-view
    Scenario: Hiển thị thông tin cơ bản của mỗi tờ khai
      Given người nộp thuế đang xem danh sách tờ khai
      Then mỗi tờ khai hiển thị thông tin
        | Mã tờ khai     |
        | Ngày lập       |
        | Hình thức      |
        | Loại chứng từ  |
        | Trạng thái     |
        | Ngày chấp nhận |
        | Tác vụ         |

    @list-view @rejection
    Scenario: Hiển thị nguyên nhân từ chối ngay trên danh sách
      Given người nộp thuế đang xem danh sách tờ khai
      And danh sách có tờ khai bị từ chối
      When người nộp thuế xem tờ khai có trạng thái "CQT không chấp nhận"
      Then người nộp thuế thấy nguyên nhân từ chối ngay trên danh sách

    @list-view @rejection
    Scenario: Nguyên nhân từ chối của CQT hiển thị thông tin tóm tắt
      Given người nộp thuế đang xem danh sách tờ khai
      When tờ khai có trạng thái "CQT không tiếp nhận"
      Then nguyên nhân từ chối hiển thị thông tin
        | Mã lỗi   |
        | Nội dung |

    @list-view @actions
    Scenario: Tạo tờ khai mới từ danh sách
      Given người nộp thuế đang xem danh sách tờ khai
      When người nộp thuế chọn tạo tờ khai mới
      Then hệ thống mở tờ khai mới để người nộp thuế điền thông tin

    @list-view @actions
    Scenario: Xem chi tiết tờ khai từ danh sách
      Given người nộp thuế đang xem danh sách tờ khai
      And danh sách có ít nhất một tờ khai
      When người nộp thuế chọn xem chi tiết một tờ khai
      Then hệ thống hiển thị đầy đủ thông tin tờ khai đó
