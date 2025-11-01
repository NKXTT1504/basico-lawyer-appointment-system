import { useState, useEffect } from 'react';
import ServiceCard from '../../../components/Service/ServiceCard';
import api from '../../../config/axios';

const Services = () => {
  const [activeCategory, setActiveCategory] = useState('all');
  const [services, setServices] = useState([]);
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    let mounted = true;
    setLoading(true);
    setError(null);

    (async () => {
      try {
        const svcRes = await api.lawyer.get('/api/Service');
        if (!mounted) return;

        let servicesData = [];
        if (svcRes) {
          const d = svcRes.data;
          if (Array.isArray(d)) servicesData = d;
          else if (d && Array.isArray(d.result)) servicesData = d.result;
        }
        setServices(Array.isArray(servicesData) ? servicesData : []);
      } catch (err) {
        console.error('Service fetch error:', err);
        if (mounted) setError(`Không tải được danh sách dịch vụ. Chi tiết: ${err.message || err}`);
        setLoading(false);
        return;
      }

      try {
        const areaRes = await api.lawyer.get('/api/PracticeArea');
        if (!mounted) return;

        let areasData = [];
        if (areaRes) {
          const d = areaRes.data;
          if (Array.isArray(d)) areasData = d;
          else if (d && Array.isArray(d.result)) areasData = d.result;
        }

        // fallback: derive categories from services' practiceArea
        if ((!areasData || areasData.length === 0) && Array.isArray(services)) {
          const map = {};
          services.forEach((s) => {
            const pa = s.practiceArea;
            if (pa && pa.code && !map[pa.code]) map[pa.code] = pa;
          });
          areasData = Object.values(map);
        }

        setCategories(Array.isArray(areasData) ? areasData : []);
      } catch (err) {
        console.error('PracticeArea fetch error:', err);
        if (mounted) setError(`Không tải được danh mục lĩnh vực. Chi tiết: ${err.message || err}`);
        setLoading(false);
        return;
      }

      if (mounted) setLoading(false);
    })();

    return () => {
      mounted = false;
    };
  }, []);

  const filteredServices = activeCategory === 'all'
    ? services
    : services.filter(s => (s.practiceArea?.code || '').toLowerCase() === activeCategory);

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
                <button
                  onClick={() => setActiveCategory('all')}
                  className={`px-4 py-2 rounded-md text-sm font-medium transition-colors
                    ${activeCategory === 'all' ? 'bg-primary-700 text-white' : 'text-gray-700 hover:bg-gray-200'}`}
                >
                  Tất cả
                </button>

                {categories.map(cat => (
                  <button
                    key={cat.id ?? cat.code}
                    onClick={() => setActiveCategory((cat.code || '').toLowerCase())}
                    className={`px-4 py-2 rounded-md text-sm font-medium transition-colors
                      ${activeCategory === (cat.code || '').toLowerCase() ? 'bg-primary-700 text-white' : 'text-gray-700 hover:bg-gray-200'}`}
                  >
                    {cat.name}
                  </button>
                ))}
              </div>
            </div>

            <p className="text-center text-gray-600 max-w-3xl mx-auto">
              Chọn một danh mục để lọc các dịch vụ của chúng tôi và tìm chính xác những gì bạn đang tìm kiếm.
            </p>
          </div>

          {error && (
            <div className="text-center py-6 text-red-600 bg-red-50 rounded-lg mb-8 max-w-2xl mx-auto">
              {error}
            </div>
          )}

          {loading ? (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
              {Array.from({ length: 6 }).map((_, i) => (
                <div key={i} className="bg-white rounded-2xl p-6 shadow-sm border border-gray-100 animate-pulse">
                  <div className="h-4 bg-gray-200 rounded w-3/4 mb-3"></div>
                  <div className="h-3 bg-gray-200 rounded w-full mb-2"></div>
                  <div className="h-3 bg-gray-200 rounded w-5/6"></div>
                </div>
              ))}
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
              {filteredServices.map(service => (
                <ServiceCard key={service.id} service={service} />
              ))}
            </div>
          )}
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
              <a href="/contact" className="btn-outline">Liên hệ với chúng tôi</a>
              <a href="/appointment" className="btn-primary">Đặt lịch tư vấn</a>
            </div>
          </div>
        </div>
      </section>
    </main>
  );
};

export default Services;