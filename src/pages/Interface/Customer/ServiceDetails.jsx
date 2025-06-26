import { useParams, Link } from 'react-router-dom';
import { services, getIconComponent } from '../../../data/services';
import { ArrowLeft, Check } from 'lucide-react';

const ServiceDetails = () => {
  const { id } = useParams();
  const service = services.find(s => s.id === id);

  if (!service) {
    return (
      <div className="container mx-auto px-4 py-16 text-center">
        <h2 className="text-2xl font-bold text-gray-900 mb-4">Dịch vụ không tồn tại</h2>
        <p className="text-gray-600 mb-6">Dịch vụ bạn đang tìm kiếm không tồn tại hoặc đã bị gỡ bỏ.</p>
        <Link to="/services" className="btn-primary">
          Xem tất cả dịch vụ
        </Link>
      </div>
    );
  }

  const IconComponent = getIconComponent(service.icon);

  const benefits = [
    'Tư vấn pháp lý chuyên sâu phù hợp với tình huống cụ thể của bạn',
    'Giao tiếp rõ ràng xuyên suốt quá trình',
    'Chiến lược pháp lý hiệu quả để đạt kết quả tối ưu',
    'Giá cả minh bạch, không có phí ẩn',
    'Hỗ trợ và đồng hành liên tục'
  ];

  const processSteps = [
    {
      title: 'Tư vấn ban đầu',
      description: 'Gặp gỡ luật sư của chúng tôi để thảo luận về nhu cầu và mục tiêu của bạn.'
    },
    {
      title: 'Phân tích vụ việc',
      description: 'Luật sư sẽ phân tích kỹ lưỡng vụ việc và xây dựng chiến lược cụ thể.'
    },
    {
      title: 'Triển khai',
      description: 'Chúng tôi thực hiện chiến lược pháp lý và cập nhật cho bạn từng bước.'
    },
    {
      title: 'Giải quyết',
      description: 'Đạt được kết quả tốt nhất với sự hỗ trợ tận tâm của chúng tôi.'
    }
  ];

  return (
    <main>
      <section className="bg-primary-700 py-16">
        <div className="container mx-auto px-4">
          <Link to="/services" className="inline-flex items-center text-white hover:text-accent-300 mb-6 transition-colors">
            <ArrowLeft className="h-5 w-5 mr-2" />
            <span>Quay lại tất cả dịch vụ</span>
          </Link>

          <div className="flex items-center mb-6">
            <div className="p-4 bg-white rounded-lg mr-4">
              <IconComponent className="h-8 w-8 text-primary-700" />
            </div>
            <h1 className="text-4xl font-bold text-white">{service.title}</h1>
          </div>

          <div className="max-w-3xl text-white">
            <p className="text-xl text-gray-200 mb-6">{service.description}</p>

            <div className="flex flex-wrap gap-6">
              <div>
                <span className="block text-gray-300 text-sm">Mức giá</span>
                <span className="text-lg font-medium text-white">{service.price}</span>
              </div>

              <div>
                <span className="block text-gray-300 text-sm">Thời lượng</span>
                <span className="text-lg font-medium text-white">{service.duration}</span>
              </div>

              <div>
                <span className="block text-gray-300 text-sm">Danh mục</span>
                <span className="text-lg font-medium text-white">{service.category}</span>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section className="py-16">
        <div className="container mx-auto px-4">
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-12">
            <div className="lg:col-span-2">
              <h2 className="text-3xl font-bold text-gray-900 mb-6">Tổng quan dịch vụ</h2>

              <div className="prose max-w-none mb-12">
                <p className="mb-4">
                  Dịch vụ {service.title.toLowerCase()} của chúng tôi cung cấp hỗ trợ pháp lý toàn diện để giúp bạn xử lý các vấn đề pháp lý phức tạp một cách tự tin. Dù bạn đang đối mặt với tình huống khó khăn hay cần lời khuyên chủ động, đội ngũ luật sư của chúng tôi luôn sẵn sàng đồng hành.
                </p>

                <p className="mb-4">
                  Với nhiều năm kinh nghiệm chuyên môn trong lĩnh vực {service.title.toLowerCase()}, đội ngũ của chúng tôi đã xử lý thành công nhiều trường hợp đa dạng và phức tạp. Chúng tôi hiểu rằng mỗi vụ việc là duy nhất, vì vậy sẽ xây dựng chiến lược phù hợp nhất với bạn.
                </p>

                <p>
                  Phương pháp làm việc của chúng tôi kết hợp giữa chuyên môn pháp lý sâu rộng và sự tập trung vào khách hàng, đảm bảo bạn nhận được cả sự đại diện pháp lý xuất sắc và sự hỗ trợ tận tâm.
                </p>
              </div>

              <div className="mb-12">
                <h3 className="text-2xl font-bold text-gray-900 mb-6">Quy trình của chúng tôi</h3>

                <div className="space-y-6">
                  {processSteps.map((step, index) => (
                    <div key={index} className="flex">
                      <div className="flex-shrink-0">
                        <div className="flex items-center justify-center h-10 w-10 rounded-full bg-primary-100 text-primary-700 font-bold">
                          {index + 1}
                        </div>
                      </div>
                      <div className="ml-4">
                        <h4 className="text-lg font-medium text-gray-900">{step.title}</h4>
                        <p className="text-gray-600">{step.description}</p>
                      </div>
                    </div>
                  ))}
                </div>
              </div>

              <div>
                <h3 className="text-2xl font-bold text-gray-900 mb-6">Vì sao chọn chúng tôi</h3>

                <ul className="space-y-4">
                  {benefits.map((benefit, index) => (
                    <li key={index} className="flex items-start">
                      <Check className="h-6 w-6 text-green-500 mr-2 flex-shrink-0" />
                      <span className="text-gray-700">{benefit}</span>
                    </li>
                  ))}
                </ul>
              </div>
            </div>

            <div>
              <div className="bg-gray-50 rounded-lg p-6 shadow-md sticky top-24">
                <h3 className="text-xl font-bold text-gray-900 mb-4">Sẵn sàng bắt đầu?</h3>
                <p className="text-gray-600 mb-6">
                  Đặt lịch tư vấn với luật sư chuyên môn về {service.title.toLowerCase()} để thảo luận nhu cầu cụ thể của bạn.
                </p>

                <Link 
                  to={`/appointment?service=${service.id}`}
                  className="btn-primary w-full justify-center mb-4"
                >
                  Đặt lịch tư vấn
                </Link>

                <Link 
                  to="/contact"
                  className="btn-outline w-full justify-center"
                >
                  Liên hệ với chúng tôi
                </Link>

                <div className="mt-6 pt-6 border-t border-gray-200">
                  <h4 className="font-medium text-gray-900 mb-3">Cần thêm thông tin?</h4>
                  <p className="text-gray-600 text-sm mb-4">
                    Gọi cho chúng tôi để nhận tư vấn nhanh hoặc đặt câu hỏi về dịch vụ.
                  </p>
                  <a 
                    href="tel:+12125551234" 
                    className="block text-center py-2 text-primary-700 font-medium hover:text-primary-800"
                  >
                    +1 (212) 555-1234
                  </a>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section className="py-16 bg-gray-50">
        <div className="container mx-auto px-4 text-center">
          <h2 className="text-3xl font-bold text-gray-900 mb-6">Khám phá các dịch vụ khác</h2>
          <p className="text-gray-600 max-w-3xl mx-auto mb-10">
            Khám phá các dịch vụ pháp lý toàn diện của chúng tôi để đáp ứng mọi nhu cầu pháp lý của bạn.
          </p>

          <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
            {services
              .filter(s => s.id !== service.id)
              .slice(0, 4)
              .map(s => {
                const ServiceIcon = getIconComponent(s.icon);
                return (
                  <Link 
                    key={s.id}
                    to={`/services/${s.id}`}
                    className="bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow text-center"
                  >
                    <div className="p-3 bg-primary-50 rounded-full w-14 h-14 flex items-center justify-center mx-auto mb-4">
                      <ServiceIcon className="h-7 w-7 text-primary-700" />
                    </div>
                    <h4 className="text-xl font-medium text-gray-900">{s.title}</h4>
                  </Link>
                );
              })}
          </div>
        </div>
      </section>
    </main>
  );
};

export default ServiceDetails;
