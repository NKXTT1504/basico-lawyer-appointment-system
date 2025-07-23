import { Link } from "react-router-dom";
import { ArrowRight } from "lucide-react";

const Hero = () => {
  return (
    <div className="relative bg-hero-pattern bg-cover bg-center min-h-[90vh] flex items-center">
      <div className="container mx-auto px-4">
        <div className="max-w-3xl text-white animate-fade-in">
          <h1 className="text-4xl md:text-5xl lg:text-6xl font-serif font-bold text-white leading-tight mb-6">
            Giải pháp chuyên nghiệp
            <br />
            <span className="text-accent-300">Vì sự thành công của bạn</span>
          </h1>
          <p className="text-lg md:text-xl text-gray-100 mb-8">
            Đội ngũ luật sư giàu kinh nghiệm của chúng tôi cung cấp các dịch vụ
            pháp lý cá nhân để giúp bạn giải quyết các vấn đề pháp lý phức tạp
            một cách tự tin và an tâm.
          </p>
          <div className="flex flex-col sm:flex-row gap-4">
            <Link to="/appointment" className="group bg-primary-900 btn text-white hover:bg-white hover:text-primary-700 transition-all">
              Đặt lịch tư vấn
            </Link>
            <Link
              to="/services"
              className="group bg-primary-900 btn border-2 border-white text-white hover:bg-white hover:text-primary-700 transition-all"
            >
              <span>Khám phá dịch vụ</span>
              <ArrowRight className="ml-2 h-5 w-5 transform group-hover:translate-x-1 transition-transform" />
            </Link>
          </div>

          <div className="mt-12 grid grid-cols-1 md:grid-cols-3 gap-6">
            <div className="bg-white bg-opacity-10 backdrop-blur-sm p-6 rounded-lg border border-white border-opacity-20">
              <h3 className="text-xl font-semibold text-white mb-2">
                Luật sư giàu kinh nghiệm
              </h3>
              <p className="text-gray-200">
                Luật sư của chúng tôi có trung bình hơn 10 năm kinh nghiệm trong
                lĩnh vực chuyên môn của họ.
              </p>
            </div>
            <div className="bg-white bg-opacity-10 backdrop-blur-sm p-6 rounded-lg border border-white border-opacity-20">
              <h3 className="text-xl font-semibold text-white mb-2">
                Giải Pháp Cá Nhân Hóa
              </h3>
              <p className="text-gray-200">
                Chiến lược pháp lý được thiết kế riêng để phù hợp với nhu cầu cụ
                thể của bạn.
              </p>
            </div>
            <div className="bg-white bg-opacity-10 backdrop-blur-sm p-6 rounded-lg border border-white border-opacity-20">
              <h3 className="text-xl font-semibold text-white mb-2">
                Tập Trung Vào Khách Hàng
              </h3>
              <p className="text-gray-200">
                Chúng tôi ưu tiên sự giao tiếp rõ ràng và dịch vụ xuất sắc.
              </p>
            </div>
          </div>
        </div>
      </div>

      <div className="absolute bottom-0 left-0 right-0 h-24 bg-gradient-to-t from-gray-50 to-transparent"></div>
    </div>
  );
};

export default Hero;
