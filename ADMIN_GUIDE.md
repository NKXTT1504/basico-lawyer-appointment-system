# Hướng dẫn sử dụng hệ thống Admin

## Tổng quan
Hệ thống admin được thiết kế để quản lý toàn bộ ứng dụng đặt lịch luật sư, bao gồm:
- Quản lý đặt lịch
- Quản lý nhân viên
- Quản lý khách hàng
- Quản lý luật sư

## Cách truy cập

### 1. Đăng ký tài khoản Admin
1. Từ trang đăng nhập chính, nhấn "Đăng ký Admin"
2. Điền đầy đủ thông tin:
   - Họ và tên
   - Email
   - Mật khẩu
   - Xác nhận mật khẩu
3. Nhấn "Đăng ký"

### 2. Đăng nhập Admin
1. Từ trang đăng nhập chính, nhấn "Đăng nhập Admin"
2. Sử dụng thông tin đăng nhập mặc định:
   - **Email**: admin@basico.com
   - **Mật khẩu**: admin123
3. Hoặc sử dụng tài khoản đã đăng ký

## Chức năng chính

### 1. Dashboard Admin
- **Thống kê tổng quan**: Hiển thị số lượng nhân viên, khách hàng, luật sư, đặt lịch
- **Trạng thái đặt lịch**: Thống kê theo trạng thái (chờ xác nhận, đã xác nhận, hoàn thành, hủy bỏ)
- **Thao tác nhanh**: Truy cập nhanh đến các trang quản lý

### 2. Quản lý đặt lịch
- **Xem danh sách**: Tất cả đặt lịch với bộ lọc theo trạng thái
- **Cập nhật trạng thái**: 
  - Chờ xác nhận → Đã xác nhận
  - Đã xác nhận → Hoàn thành
  - Hủy bỏ đặt lịch
- **Xóa đặt lịch**: Xóa vĩnh viễn đặt lịch
- **Thông tin chi tiết**: Khách hàng, luật sư, thời gian, phí, ghi chú

### 3. Quản lý nhân viên
- **Xem danh sách**: Tất cả nhân viên với thông tin chi tiết
- **Thêm nhân viên**: Tạo tài khoản nhân viên mới
- **Chỉnh sửa**: Cập nhật thông tin nhân viên (đang phát triển)
- **Xóa nhân viên**: Xóa vĩnh viễn nhân viên
- **Thông tin**: Họ tên, email, số điện thoại, chức vụ, phòng ban, lương, địa chỉ

### 4. Quản lý khách hàng
- **Xem danh sách**: Tất cả khách hàng với thông tin chi tiết
- **Thêm khách hàng**: Tạo hồ sơ khách hàng mới
- **Chỉnh sửa**: Cập nhật thông tin khách hàng (đang phát triển)
- **Xóa khách hàng**: Xóa vĩnh viễn khách hàng
- **Thông tin**: Họ tên, email, số điện thoại, địa chỉ, ngày sinh, giới tính, nghề nghiệp, ghi chú

### 5. Quản lý luật sư
- **Xem danh sách**: Tất cả luật sư với thông tin chi tiết
- **Thêm luật sư**: Tạo hồ sơ luật sư mới
- **Chỉnh sửa**: Cập nhật thông tin luật sư (đang phát triển)
- **Xóa luật sư**: Xóa vĩnh viễn luật sư
- **Thông tin**: Họ tên, email, số điện thoại, địa chỉ, chuyên môn, số chứng chỉ, kinh nghiệm, phí tư vấn, tiểu sử, ngôn ngữ, chứng chỉ

## Dữ liệu mẫu
Hệ thống tự động tạo dữ liệu mẫu khi khởi động lần đầu:
- 1 tài khoản admin mặc định
- 2 nhân viên mẫu
- 2 khách hàng mẫu
- 2 luật sư mẫu
- 2 đặt lịch mẫu

## Lưu trữ dữ liệu
- Tất cả dữ liệu được lưu trữ local trên thiết bị
- Sử dụng SharedPreferences để lưu trữ
- Dữ liệu sẽ được giữ lại giữa các lần khởi động ứng dụng

## Bảo mật
- Mật khẩu được lưu trữ dạng plain text (chỉ dành cho demo)
- Trong môi trường thực tế, cần mã hóa mật khẩu
- Kiểm tra quyền truy cập admin trước khi cho phép truy cập các trang quản lý

## Lưu ý
- Chức năng chỉnh sửa đang được phát triển
- Hệ thống chỉ dành cho demo và testing
- Cần cải thiện UI/UX cho môi trường production
- Cần thêm validation và error handling tốt hơn

