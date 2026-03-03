@list-declaration
Feature: Danh sách tờ khai đăng ký sử dụng chứng từ điện tử
  Với vai trò một NNT
  Tôi muốn xem và quản lý danh sách tờ khai đăng ký sử dụng chứng từ điện tử
  Để theo dõi trạng thái các tờ khai đã gửi cho cơ quan thuế

  Background:
    Given người nộp thuế đã đăng nhập vào hệ thống

  Rule: Phân quyền truy cập danh sách tờ khai

    @api @security
    Scenario: Truy cập danh sách khi có quyền
      Given người nộp thuế có quyền đăng ký phát hành chứng từ điện tử
      When người nộp thuế truy cập danh sách tờ khai chứng từ điện tử
      Then hệ thống hiển thị màn hình danh sách tờ khai đăng ký sử dụng chứng từ điện tử

    @api @security
    Scenario: Từ chối truy cập khi không có quyền
      Given người nộp thuế không có quyền đăng ký phát hành chứng từ điện tử
      When người nộp thuế truy cập danh sách tờ khai chứng từ điện tử
      Then hệ thống từ chối truy cập và hiển thị thông báo không có quyền

  Rule: Hiển thị thông tin danh sách tờ khai

    @web @list-view
    Scenario: Hiển thị các cột thông tin cơ bản của mỗi tờ khai
      Given người nộp thuế có quyền đăng ký phát hành chứng từ điện tử
      When người nộp thuế truy cập danh sách tờ khai chứng từ điện tử
      Then mỗi tờ khai hiển thị thông tin
        | Mã tờ khai     |
        | Ngày lập       |
        | Hình thức      |
        | Loại chứng từ  |
        | Trạng thái     |
        | Ngày chấp nhận |
        | Tác vụ         |

    @web @list-view
    Scenario: Hiển thị danh sách rỗng khi chưa có tờ khai
      Given người nộp thuế có quyền đăng ký phát hành chứng từ điện tử
      And người nộp thuế chưa có tờ khai nào
      When người nộp thuế truy cập danh sách tờ khai chứng từ điện tử
      Then hệ thống hiển thị danh sách rỗng

    @api @list-view
    Scenario: Sắp xếp danh sách theo thời gian mới nhất
      Given người nộp thuế có quyền đăng ký phát hành chứng từ điện tử
      And người nộp thuế đã có nhiều tờ khai
      When người nộp thuế truy cập danh sách tờ khai chứng từ điện tử
      Then danh sách tờ khai được sắp xếp theo ngày lập mới nhất trước

  Rule: Mã tờ khai tự sinh theo chuỗi tịnh tiến TKCT000001
    # Định dạng: tiền tố "TKCT" + 6 chữ số tịnh tiến
    # Hệ thống tự động sinh, người dùng không nhập, không thể chỉnh sửa

    @api @auto-fill @read-only
    Scenario: Mã tờ khai được tự động sinh khi tờ khai được tạo
      Given người nộp thuế đã gửi tờ khai hợp lệ
      When hệ thống tiếp nhận tờ khai
      Then hệ thống tự động gán mã tờ khai theo định dạng "TKCT" + 6 chữ số
      And mã tờ khai hiển thị trên danh sách và không thể chỉnh sửa

    @api @auto-fill
    Scenario: Mã tờ khai tịnh tiến theo thứ tự tạo
      Given hệ thống đã có tờ khai với mã "TKCT000001"
      When người nộp thuế tạo thêm tờ khai mới
      Then mã tờ khai mới được gán là "TKCT000002"

  Rule: Ngày lập là ngày người dùng tạo tờ khai trên hệ thống

    @api @auto-fill @read-only
    Scenario: Ngày lập hiển thị đúng ngày tờ khai được tạo
      Given người nộp thuế vừa tạo tờ khai vào ngày xác định
      When người nộp thuế xem danh sách tờ khai
      Then cột ngày lập hiển thị đúng ngày người dùng tạo tờ khai
      And ngày lập không thể chỉnh sửa

  Rule: Hình thức lấy từ hình thức đăng ký trên tờ khai

    @api @auto-fill
    Scenario: Hình thức hiển thị đúng hình thức đăng ký trên tờ khai
      Given người nộp thuế có tờ khai với hình thức đăng ký xác định
      When người nộp thuế xem danh sách tờ khai
      Then cột hình thức hiển thị đúng hình thức đăng ký ghi trên tờ khai

  Rule: Loại chứng từ lấy từ loại hình sử dụng trên tờ khai

    @api @auto-fill
    Scenario: Loại chứng từ hiển thị đúng loại hình sử dụng trên tờ khai
      Given người nộp thuế có tờ khai với loại hình sử dụng xác định
      When người nộp thuế xem danh sách tờ khai
      Then cột loại chứng từ hiển thị đúng loại hình sử dụng ghi trên tờ khai

  Rule: Trạng thái tờ khai được xác định theo thông điệp CQT trả về
    # Luồng trạng thái theo thông điệp:
    # Gửi Thông điệp 108 lên CQT                → Đã gửi CQT
    # CQT trả Thông điệp 110 - không tiếp nhận  → Gửi CQT lỗi
    # CQT trả Thông điệp 110 - tiếp nhận        → Chờ CQT duyệt
    # CQT trả Thông điệp 111 - không chấp nhận  → CQT không chấp nhận
    # CQT trả Thông điệp 111 - chấp nhận        → CQT chấp nhận

    @api @status
    Scenario: Trạng thái chuyển sang "Gửi CQT lỗi" khi CQT không tiếp nhận qua Thông điệp 110
      Given người nộp thuế có tờ khai ở trạng thái "Đã gửi CQT"
      When hệ thống nhận Thông điệp 110 với kết quả không tiếp nhận từ CQT
      Then trạng thái tờ khai chuyển sang "Gửi CQT lỗi"

    @api @status
    Scenario: Trạng thái chuyển sang "Chờ CQT duyệt" khi CQT tiếp nhận qua Thông điệp 110
      Given người nộp thuế có tờ khai ở trạng thái "Đã gửi CQT"
      When hệ thống nhận Thông điệp 110 với kết quả tiếp nhận từ CQT
      Then trạng thái tờ khai chuyển sang "Chờ CQT duyệt"

    @api @status
    Scenario: Trạng thái chuyển sang "CQT không chấp nhận" khi bị từ chối qua Thông điệp 111
      Given người nộp thuế có tờ khai ở trạng thái "Chờ CQT duyệt"
      When hệ thống nhận Thông điệp 111 với kết quả không chấp nhận từ CQT
      Then trạng thái tờ khai chuyển sang "CQT không chấp nhận"

    @api @status
    Scenario: Trạng thái chuyển sang "CQT chấp nhận" khi được duyệt qua Thông điệp 111
      Given người nộp thuế có tờ khai ở trạng thái "Chờ CQT duyệt"
      When hệ thống nhận Thông điệp 111 với kết quả chấp nhận từ CQT
      Then trạng thái tờ khai chuyển sang "CQT chấp nhận"
      And hệ thống hiển thị module chứng từ điện tử cho người nộp thuế

  Rule: Ngày chấp nhận lấy từ ngày CQT trả về Thông điệp 111

    @api @auto-fill
    Scenario: Ngày chấp nhận hiển thị đúng ngày CQT gửi Thông điệp 111 chấp nhận
      Given người nộp thuế có tờ khai ở trạng thái "CQT chấp nhận"
      When người nộp thuế xem danh sách tờ khai
      Then cột ngày chấp nhận hiển thị đúng ngày CQT trả về Thông điệp 111

    @api @list-view
    Scenario: Ngày chấp nhận để trống khi tờ khai chưa được CQT chấp nhận
      Given người nộp thuế có tờ khai chưa ở trạng thái "CQT chấp nhận"
      When người nộp thuế xem danh sách tờ khai
      Then cột ngày chấp nhận của tờ khai đó để trống

  Rule: Hiển thị thông tin từ chối từ CQT trên danh sách

    @web @list-view @rejection
    Scenario: Hiển thị nguyên nhân từ chối ngay trên danh sách
      Given người nộp thuế có quyền đăng ký phát hành chứng từ điện tử
      And danh sách có tờ khai ở trạng thái "CQT không chấp nhận"
      When người nộp thuế xem danh sách tờ khai chứng từ điện tử
      Then người nộp thuế thấy nguyên nhân từ chối ngay trên danh sách

    @web @list-view @rejection
    Scenario: Nguyên nhân từ chối hiển thị mã lỗi và nội dung
      Given người nộp thuế có quyền đăng ký phát hành chứng từ điện tử
      And danh sách có tờ khai ở trạng thái "CQT không chấp nhận"
      When người nộp thuế xem danh sách tờ khai chứng từ điện tử
      Then nguyên nhân từ chối hiển thị thông tin
        | Mã lỗi   |
        | Nội dung |

  Rule: Thao tác trên danh sách tờ khai

    @web @action
    Scenario: Tạo tờ khai mới từ danh sách
      Given người nộp thuế có quyền đăng ký phát hành chứng từ điện tử
      And người nộp thuế đang xem danh sách tờ khai chứng từ điện tử
      When người nộp thuế chọn tạo tờ khai mới
      Then hệ thống mở form tạo tờ khai đăng ký sử dụng chứng từ điện tử

    @web @action
    Scenario: Xem chi tiết tờ khai từ danh sách
      Given người nộp thuế có quyền đăng ký phát hành chứng từ điện tử
      And người nộp thuế đang xem danh sách tờ khai chứng từ điện tử
      When người nộp thuế chọn xem chi tiết một tờ khai
      Then hệ thống chuyển sang trang chi tiết tờ khai
