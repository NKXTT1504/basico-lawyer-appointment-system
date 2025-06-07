import { lawyers } from "../../data/lawyers";
import LawyerCard from "./LawyerCard";
import { ArrowRight } from "lucide-react";

const LawyersSection = () => {
  // Display only 4 lawyers on homepage
  const featuredLawyers = lawyers.slice(0, 4);

  return (
    <section className="py-16 bg-white">
      <div className="container mx-auto px-4">
        <div className="flex flex-col md:flex-row md:items-end justify-between mb-12">
          <div className="max-w-2xl">
            <h2 className="text-3xl font-bold text-gray-900 mb-4">
              Gặp gỡ các luật sư chuyên gia của chúng tôi
            </h2>
            <p className="text-gray-600">
              Đội ngũ luật sư giàu kinh nghiệm của chúng tôi tận tâm cung cấp
              các giải pháp pháp lý được cá nhân hóa. Mỗi luật sư đều có chuyên
              môn riêng và cam kết mang đến thành công cho khách hàng.
            </p>
          </div>
          <a
            href="/lawyers"
            className="group inline-flex items-center text-primary-700 font-medium hover:text-primary-800 mt-4 md:mt-0"
          >
            <span>Xem tất cả luật sư</span>
            <ArrowRight className="ml-2 h-5 w-5 transform group-hover:translate-x-1 transition-transform" />
          </a>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {featuredLawyers.map((lawyer) => (
            <LawyerCard key={lawyer.id} lawyer={lawyer} />
          ))}
        </div>
      </div>
    </section>
  );
};

export default LawyersSection;