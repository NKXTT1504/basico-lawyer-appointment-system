# Cách fix CORS error cho Firebase Storage

## Vấn đề:
Khi web app chạy trên `http://localhost:5173` cố gắng load images từ Firebase Storage, browser sẽ chặn request vì CORS policy.

## Giải pháp:

### Option 1: Cấu hình CORS trong Firebase Storage

1. Cài đặt `gsutil` từ Google Cloud SDK
2. Tạo file `cors.json`:
```json
[
  {
    "origin": ["http://localhost:5173", "https://your-production-domain.com"],
    "method": ["GET", "HEAD"],
    "responseHeader": ["Content-Type"],
    "maxAgeSeconds": 3600
  }
]
```

3. Upload CORS config:
```bash
gsutil cors set cors.json gs://your-firebase-storage-bucket.appspot.com
```

### Option 2: Sử dụng CDN hoặc Proxy

Thay vì trỏ trực tiếp đến Firebase Storage URL, bạn có thể:

1. Sử dụng CDN (như Cloudflare)
2. Tạo proxy endpoint trong backend để load images
3. Sử dụng Firebase Functions để proxy requests

### Option 3: Bỏ qua (Khuyến nghị)

CORS error này chỉ là **warning trong console**, không ảnh hưởng functionality vì:
- `errorBuilder` đã handle error
- UI vẫn hiển thị fallback avatar
- App vẫn hoạt động bình thường

**Nếu muốn giảm noise trong console**, có thể:
- Để imageUrl rỗng nếu không có ảnh thật
- Sử dụng local images thay vì Firebase Storage trong development

