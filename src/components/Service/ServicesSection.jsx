import React, { useState } from "react";
import { services, serviceCategories } from "../../data/services";
import ServiceCard from "./ServiceCard";

const ServicesSection = () => {
  const [activeCategory, setActiveCategory] = useState("all");

  const filteredServices =
    activeCategory === "all"
      ? services
      : services.filter(
          (service) => service.category.toLowerCase() === activeCategory
        );

  return (
    <section className="py-16 bg-gray-50" id="services">
      <div className="container mx-auto px-4">
        <div className="text-center max-w-3xl mx-auto mb-12">
          <h2 className="text-3xl font-bold text-gray-900 mb-4">
            Dịch vụ pháp lý của chúng tôi
          </h2>
          <p className="text-gray-600">
            Chúng tôi cung cấp các dịch vụ pháp lý toàn diện phù hợp với nhu cầu
            cụ thể của bạn. Đội ngũ luật sư giàu kinh nghiệm của chúng tôi cung
            cấp hướng dẫn chuyên môn trong nhiều lĩnh vực thực hành.{" "}
          </p>
        </div>

        <div className="flex justify-center mb-8">
          <div className="inline-flex flex-wrap justify-center gap-2 p-1 bg-gray-100 rounded-lg">
            {serviceCategories.map((category) => (
              <button
                key={category.id}
                className={`px-4 py-2 rounded-md text-sm font-medium transition-colors
                  ${
                    activeCategory === category.id.toLowerCase()
                      ? "bg-primary-700 text-white"
                      : "text-gray-700 hover:bg-gray-200"
                  }`}
                onClick={() => setActiveCategory(category.id.toLowerCase())}
              >
                {category.name}
              </button>
            ))}
          </div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {filteredServices.map((service) => (
            <ServiceCard key={service.id} service={service} />
          ))}
        </div>

        <div className="text-center mt-12">
          <a href="/services" className="btn-primary">
            Tất cả dịch vụ
          </a>
        </div>
      </div>
    </section>
  );
};

export default ServicesSection;
