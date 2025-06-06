
const About = () => {
  return (
    <main>
      <section className="bg-primary-700 py-16">
        <div className="container mx-auto">
          <div className="max-w-3xl">
            <h1 className="text-4xl font-bold text-white mb-6">Giới thiệu</h1>
            <p className="text-gray-200 text-lg">
              BASICO là hãng Luật đã thành danh trong lĩnh vực Ngân hàng, Chứng
              khoán và Đầu tư.
            </p>
          </div>
        </div>
      </section>

      <section className="py-16">
        <div className="container mx-auto">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-12 items-center mb-16">
            <div>
              <div className="flex items-center mb-6">
                <div className="w-1 bg-gray-900 h-8 mr-4"></div>
                <h2 className="text-3xl font-bold text-gray-900">
                  Mục tiêu của Basico
                </h2>
              </div>
              <p className="text-gray-600 mb-4">
                1. Trở thành sự lựa chọn số 1 trong việc cung cấp các dịch vụ tư
                vấn pháp lý, giải pháp pháp lý toàn diện cho các ngân hàng, công
                ty chứng khoán và các định chế tài chính.
              </p>
              <p className="text-gray-600">
                2. Trở thành sự lựa chọn hiển nhiên của cộng đồng doanh nghiệp
                trong việc cung cấp các dịch vụ pháp lý, giúp doanh nghiệp có
                nền tảng pháp lý vững chắc trong thiết lập cơ cấu tổ chức, hoạt
                động nghiệp vụ, giao dịch kinh doanh phù hợp với Pháp luật và
                chuẩn mực quốc tế.
              </p>
            </div>
            <div>
              <img
                src="/src/assets/image/ls_Hai_doanhnghiep.jpg"
                alt="Luật sư và Doanh nghiệp"
                className="rounded-lg shadow-lg"
                style={{ width: "100%", height: "400px" }}
              />
            </div>
          </div>

          <div className="max-w-4xl mx-auto mb-16">
            <h2 className="text-3xl font-bold text-gray-900 mb-6 text-center">
              Giá trị cốt lõi
            </h2>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
              <div className="bg-white p-6 rounded-lg shadow-md">
                <div className="h-12 w-12 bg-primary-100 text-primary-700 rounded-full flex items-center justify-center mb-4">
                  <svg
                    className="h-6 w-6"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth={2}
                      d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"
                    />
                  </svg>
                </div>
                <h3 className="text-xl font-medium text-gray-900 mb-2">
                  Chính trực
                </h3>
                <p className="text-gray-600">
                  Chúng tôi tuân thủ các tiêu chuẩn đạo đức cao nhất và luôn đặt
                  lợi ích tốt nhất của khách hàng lên hàng đầu.
                </p>
              </div>

              <div className="bg-white p-6 rounded-lg shadow-md">
                <div className="h-12 w-12 bg-primary-100 text-primary-700 rounded-full flex items-center justify-center mb-4">
                  <svg
                    className="h-6 w-6"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth={2}
                      d="M13 10V3L4 14h7v7l9-11h-7z"
                    />
                  </svg>
                </div>
                <h3 className="text-xl font-medium text-gray-900 mb-2">
                  Xuất sắc
                </h3>
                <p className="text-gray-600">
                  Chúng tôi phấn đấu đạt sự xuất sắc trong mọi khía cạnh của
                  công việc, từ giao tiếp với khách hàng đến chiến lược pháp lý
                  và đại diện tại tòa án.
                </p>
              </div>

              <div className="bg-white p-6 rounded-lg shadow-md">
                <div className="h-12 w-12 bg-primary-100 text-primary-700 rounded-full flex items-center justify-center mb-4">
                  <svg
                    className="h-6 w-6"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth={2}
                      d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"
                    />
                  </svg>
                </div>
                <h3 className="text-xl font-medium text-gray-900 mb-2">
                  Khách hàng là trung tâm
                </h3>
                <p className="text-gray-600">
                  Chúng tôi ưu tiên hiểu rõ nhu cầu và mục tiêu của khách hàng,
                  cung cấp sự quan tâm cá nhân hóa và giải pháp pháp lý phù hợp
                  cho từng trường hợp.
                </p>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section className="py-16 bg-gray-50">
        <div className="container mx-auto px-4 text-center">
          <h2 className="text-3xl font-bold text-gray-900 mb-6">
            Bạn đã sẵn sàng để bắt đầu?
          </h2>
          <p className="text-gray-600 max-w-3xl mx-auto mb-8">
            Đội ngũ luật sư giàu kinh nghiệm của chúng tôi sẵn sàng giúp bạn
            vượt qua mọi thách thức pháp lý. Hãy đặt lịch tư vấn ngay hôm nay để
            thảo luận về trường hợp của bạn với một chuyên gia.
          </p>
          <div className="flex flex-col sm:flex-row justify-center gap-4">
            <a href="/contact" className="btn-outline">
              Liên hệ với chúng tôi
            </a>
            <a href="/appointment" className="btn-primary">
              Đặt lịch tư vấn
            </a>
          </div>
        </div>
      </section>
    </main>
  );
};

export default About;
