import React from "react";

const LawyerProfile = () => {
  return (
    <main className="bg-white min-h-screen text-gray-900">
      {/* Banner */}
      <section className="bg-primary-700 py-10 text-white">
        <div className="container mx-auto px-4 flex items-center gap-8">
          {/* Ảnh luật sư */}
          <img
            src="https://via.placeholder.com/160"
            alt="Ảnh Luật sư"
            className="w-40 h-40 rounded-full border-4 border-white object-cover"
          />
          {/* Thông tin cơ bản */}
          <div>
            <h1 className="text-5xl font-bold mt-10 text-white">Nguyễn Văn An</h1>
            <p className="text-lg mt-5 text-accent-300">Email: nguyenvanan@legal.vn</p>
          </div>
        </div>
      </section>

      {/* Nội dung chi tiết */}
      <section className="container mx-auto px-4 py-10">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-10">
          {/* Bio */}
          <div>
            <h2 className="text-2xl font-semibold text-primary-700 mb-4">Giới thiệu</h2>
            <p className="text-gray-700 leading-relaxed">
              Luật sư Nguyễn Văn An có hơn 10 năm kinh nghiệm trong lĩnh vực pháp lý.
              Từng là cố vấn pháp luật cho nhiều doanh nghiệp trong và ngoài nước, ông
              chuyên xử lý các vụ việc về doanh nghiệp, sở hữu trí tuệ và đầu tư nước ngoài.
            </p>
          </div>

          {/* Thông tin thêm */}
          <div>
            <h2 className="text-2xl font-semibold text-primary-700 mb-4">Thông tin chuyên môn</h2>
            <ul className="text-gray-700 space-y-2">
              <li><strong>Lĩnh vực chuyên môn:</strong> Luật Doanh nghiệp, Đầu tư, Sở hữu trí tuệ</li>
              <li><strong>Năm kinh nghiệm:</strong> 10 năm</li>
              <li><strong>Địa điểm:</strong> Hà Nội, Việt Nam</li>
              <li>
                <strong>Đánh giá:</strong>{" "}
                <span className="text-accent-300 font-medium">4.9/5 ★</span>
              </li>
              <li><strong>Mã số : </strong>789</li>
              <li><strong>Giá: </strong>1.500.000đ / giờ</li>
            </ul>
          </div>
        </div>
      </section>
    </main>
  );
};

export default LawyerProfile;