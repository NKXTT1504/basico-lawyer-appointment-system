import Hero from '../../../components/Hero';
import ServicesSection from '../../../components/Service/ServicesSection';
import LawyersSection from '../../../components/Lawyer/LawyersSection';
import TestimonialsSection from '../../../components/Testimonial/TestimonialsSection';
import ContactSection from '../../../components/ContactSection';

const Home = () => {
  return (
    <main>
      <Hero />
      <div className="py-16 bg-white">
        <div className="container mx-auto px-4">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-12 items-center">
            <div>
              <img
                src="https://images.pexels.com/photos/5668858/pexels-photo-5668858.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2"
                alt="Legal Professionals"
                className="rounded-lg shadow-lg"
              />
            </div>
            <div>
              <h2 className="text-3xl font-bold text-gray-900 mb-6">Về Basico</h2>
              <p className="text-gray-600 mb-4">
                Được thành lập vào năm 2010, Basico đã khẳng định mình là nhà cung cấp dịch vụ pháp lý toàn diện hàng đầu.
                Đội ngũ luật sư giàu kinh nghiệm của chúng tôi tận tâm cung cấp các giải pháp pháp lý đặc biệt phù hợp với nhu cầu riêng của từng
                khách hàng.
              </p>
              <p className="text-gray-600 mb-6">
                Chúng tôi tự hào về cách tiếp cận lấy khách hàng làm trung tâm, kết hợp chuyên môn pháp lý với sự quan tâm cá nhân
                để đảm bảo kết quả tốt nhất có thể cho những người chúng tôi phục vụ. Cam kết của chúng tôi về sự xuất sắc và chính trực đã
                giành được sự tin tưởng của cả cá nhân và doanh nghiệp.
              </p>
              <div className="grid grid-cols-2 gap-6">
                <div>
                  <h4 className="text-xl font-bold text-primary-700">15+</h4>
                  <p className="text-gray-600">Năm kinh nghiệm</p>
                </div>
                <div>
                  <h4 className="text-xl font-bold text-primary-700">500+</h4>
                  <p className="text-gray-600">Khách hàng hài lòng</p>
                </div>
                <div>
                  <h4 className="text-xl font-bold text-primary-700">25+</h4>
                  <p className="text-gray-600">Luật sư chuyên môn</p>
                </div>
                <div>
                  <h4 className="text-xl font-bold text-primary-700">98%</h4>
                  <p className="text-gray-600">Tỉ lệ thành công</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
      <ServicesSection />
      <div className="py-16 bg-primary-700 text-white">
        <div className="container mx-auto px-4">
          <div className="text-center max-w-3xl mx-auto">
            <h2 className="text-3xl font-bold text-white mb-6">Cần hỗ trợ pháp lý?</h2>
            <p className="text-gray-200 mb-8">
              Đội ngũ luật sư giàu kinh nghiệm của chúng tôi luôn sẵn sàng giúp bạn giải quyết mọi thách thức pháp lý.
              Lên lịch tư vấn ngay hôm nay để thảo luận về trường hợp của bạn với một chuyên gia.
            </p>
            <a
              href="/appointment"
              className="btn bg-white text-primary-700 hover:bg-gray-100 font-medium"
            >
              Đặt tư vấn
            </a>
          </div>
        </div>
      </div>
      <LawyersSection />
      <TestimonialsSection />
      <ContactSection />
    </main>
  );
};

export default Home;