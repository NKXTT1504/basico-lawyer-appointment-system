import { useState } from 'react';
import { services, serviceCategories } from '../../../data/services';
import ServiceCard from '../../../components/Service/ServiceCard';

const Services = () => {
  const [activeCategory, setActiveCategory] = useState('all');

  const filteredServices = activeCategory === 'all'
    ? services
    : services.filter(service => service.category.toLowerCase() === activeCategory);

  return (
    <main>
      <section className="bg-primary-700 py-16">
        <div className="container mx-auto px-4">
          <div className="max-w-3xl">
            <h1 className="text-4xl font-bold text-white mb-6">Dịch vụ pháp lý</h1>
            <p className="text-gray-200 text-lg">
              Khám phá phạm vi dịch vụ pháp lý toàn diện của chúng tôi được thiết kế để giải quyết
              nhu cầu cụ thể của bạn với sự chuyên môn và sự quan tâm cá nhân.
            </p>
          </div>
        </div>
      </section>

      <section className="py-16">
        <div className="container mx-auto px-4">
          <div className="mb-10">
            <div className="flex justify-center mb-8">
              <div className="inline-flex flex-wrap justify-center gap-2 p-1 bg-gray-100 rounded-lg">
                {serviceCategories.map(category => (
                  <button
                    key={category.id}
                    className={`px-4 py-2 rounded-md text-sm font-medium transition-colors
                      ${activeCategory === category.id.toLowerCase()
                        ? 'bg-primary-700 text-white'
                        : 'text-gray-700 hover:bg-gray-200'
                      }`}
                    onClick={() => setActiveCategory(category.id.toLowerCase())}
                  >
                    {category.name}
                  </button>
                ))}
              </div>
            </div>

            <p className="text-center text-gray-600 max-w-3xl mx-auto">
              Chọn một danh mục để lọc các dịch vụ của chúng tôi và tìm chính xác những gì bạn đang tìm kiếm.            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {filteredServices.map(service => (
              <ServiceCard key={service.id} service={service} />
            ))}
          </div>
        </div>
      </section>

      <section className="py-16 bg-gray-50">
        <div className="container mx-auto px-4">
          <div className="max-w-3xl mx-auto text-center">
            <h2 className="text-3xl font-bold text-gray-900 mb-6">Cần một giải pháp phù hợp riêng?</h2>
            <p className="text-gray-600 mb-8">
              Đội ngũ pháp lý của chúng tôi sẵn sàng cung cấp hỗ trợ cá nhân hóa phù hợp với tình huống cụ thể của bạn. Hãy liên hệ với chúng tôi ngay hôm nay để thảo luận về nhu cầu pháp lý của bạn.
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
        </div>
      </section>
    </main>
  );
};

export default Services;