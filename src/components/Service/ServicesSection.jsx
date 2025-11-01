import React, { useState, useEffect } from "react";
import { Link } from "react-router-dom"; // <-- cần import nếu dùng React Router v6
import api from '../../config/axios';
import { getIconComponent, slugify } from '../../data/services';

const ServicesSection = () => {
  const [activeCategory, setActiveCategory] = useState("all");
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
        const svcRes = await api.lawyer.get("/api/Service");
        if (!mounted) return;

        let servicesData = [];
        if (svcRes) {
          const d = svcRes.data;
          if (Array.isArray(d)) servicesData = d;
          else if (d && Array.isArray(d.result)) servicesData = d.result;
        }

        setServices(Array.isArray(servicesData) ? servicesData : []);
      } catch (err) {
        console.error("Service fetch error:", err);
        if (mounted)
          setError(`Không tải được danh sách dịch vụ. Chi tiết: ${err.message || err}`);
        setLoading(false);
        return;
      }

      try {
        const areaRes = await api.lawyer.get("/api/PracticeArea");
        if (!mounted) return;

        let areasData = [];
        if (areaRes) {
          const d = areaRes.data;
          if (Array.isArray(d)) areasData = d;
          else if (d && Array.isArray(d.result)) areasData = d.result;
        }

        if ((!areasData || areasData.length === 0) && Array.isArray(services)) {
          const map = {};
          services.forEach((s) => {
            const pa = s.practiceArea;
            if (pa && pa.code && !map[pa.code]) {
              map[pa.code] = pa;
            }
          });
          areasData = Object.values(map);
        }

        setCategories(Array.isArray(areasData) ? areasData : []);
      } catch (err) {
        console.error("PracticeArea fetch error:", err);
        if (mounted)
          setError(`Không tải được danh mục lĩnh vực. Chi tiết: ${err.message || err}`);
        setLoading(false);
        return;
      }

      if (mounted) setLoading(false);
    })();

    return () => {
      mounted = false;
    };
  }, []);

  const filteredServices =
    activeCategory === "all"
      ? services
      : services.filter(
          (service) =>
            service.practiceArea?.code?.toLowerCase() === activeCategory
        );

  const practiceToIconName = {
    CONTRACT: "FileText",
    BUSINESS: "Briefcase",
    MARRIAGE: "Users",
    INSURANCE: "Shield",
    LABOR: "Users",
    CONSTRUCTION: "Home",
  };

  const IconForPractice = ({ code, className = "h-6 w-6" }) => {
    const name = practiceToIconName[(code || "").toString().toUpperCase()] || "FileText";
    const IconComp = getIconComponent(name);
    return IconComp ? <IconComp className={className} /> : null;
  };

  return (
    <section className="py-20 bg-gradient-to-b from-gray-50 to-white" id="services">
      <div className="container mx-auto px-4 max-w-7xl">
        {/* Header */}
        <div className="text-center max-w-3xl mx-auto mb-16">
          <h2 className="text-4xl md:text-5xl font-bold text-gray-900 mb-6">
            Dịch vụ pháp lý chuyên nghiệp
          </h2>
          <p className="text-lg text-gray-600 leading-relaxed">
            Đội ngũ luật sư giàu kinh nghiệm của chúng tôi cung cấp giải pháp pháp lý toàn diện, 
            phù hợp với nhu cầu cá nhân và doanh nghiệp của bạn.
          </p>
        </div>

        {/* Category Tabs */}
        <div className="flex justify-center mb-14">
          <div className="inline-flex flex-wrap justify-center gap-2 p-2 bg-white rounded-2xl shadow-sm border border-gray-200">
            <button
              onClick={() => setActiveCategory("all")}
              className={`px-5 py-2.5 rounded-xl text-sm font-medium transition-all duration-300 flex items-center gap-2 ${
                activeCategory === "all"
                  ? "bg-primary-700 text-white shadow-md"
                  : "text-gray-700 hover:bg-gray-100"
              }`}
            >
              <IconForPractice code="ALL" className="h-5 w-5" />
              Tất cả
            </button>

            {categories.map((cat) => (
              <button
                key={cat.id ?? cat.code}
                onClick={() => setActiveCategory((cat.code || "").toLowerCase())}
                className={`px-5 py-2.5 rounded-xl text-sm font-medium transition-all duration-300 flex items-center gap-2 ${
                  activeCategory === (cat.code || "").toLowerCase()
                    ? "bg-primary-700 text-white shadow-md"
                    : "text-gray-700 hover:bg-gray-100"
                }`}
              >
                <IconForPractice code={cat.code} className="h-5 w-5" />
                {cat.name}
              </button>
            ))}
          </div>
        </div>

        {/* Error Message */}
        {error && (
          <div className="text-center py-6 text-red-600 bg-red-50 rounded-lg mb-8 max-w-2xl mx-auto">
            {error}
          </div>
        )}

        {/* Services Grid */}
        {loading ? (
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-8">
            {Array.from({ length: 8 }).map((_, i) => (
              <div
                key={i}
                className="bg-white rounded-2xl p-6 shadow-sm border border-gray-100 animate-pulse"
              >
                <div className="flex items-start gap-4">
                  <div className="w-12 h-12 rounded-xl bg-gray-200"></div>
                  <div className="flex-1">
                    <div className="h-5 bg-gray-200 rounded w-3/4 mb-3"></div>
                    <div className="h-3 bg-gray-200 rounded w-full mb-2"></div>
                    <div className="h-3 bg-gray-200 rounded w-5/6"></div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        ) : (
          <>
            {filteredServices.length > 0 ? (
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-8">
                {filteredServices.map((service) => (
                  <Link
                    key={service.id}
                    to={`/services/${slugify(service.name || service.title || String(service.id))}`}
                    className="block group"
                  >
                    <div className="bg-white rounded-2xl p-6 shadow-sm border border-gray-100 hover:shadow-lg transition-all duration-300 h-full transform hover:-translate-y-1">
                      <div className="flex items-start gap-4">
                        <div className="flex-shrink-0 p-3 bg-primary-50 rounded-xl group-hover:bg-primary-100 transition-colors">
                          <IconForPractice
                            code={service.practiceArea?.code}
                            className="h-6 w-6 text-primary-700"
                          />
                        </div>
                        <div className="min-w-0">
                          <h3 className="text-lg font-semibold text-gray-900 mb-2 group-hover:text-primary-700 transition-colors line-clamp-2">
                            {service.name}
                          </h3>
                          <p className="text-gray-600 text-sm leading-relaxed line-clamp-3">
                            {service.description}
                          </p>
                        </div>
                      </div>
                    </div>
                  </Link>
                ))}
              </div>
            ) : (
              <div className="text-center py-16">
                <div className="text-gray-400 mb-4">
                  <IconForPractice code="FileText" className="h-12 w-12 mx-auto opacity-50" />
                </div>
                <p className="text-gray-500 text-lg">Không có dịch vụ nào trong danh mục này.</p>
              </div>
            )}
          </>
        )}

        {/* CTA Button */}
        <div className="text-center mt-16">
          <Link
            to="/services"
            className="inline-flex items-center px-8 py-3 bg-primary-700 text-white font-semibold rounded-full shadow-md hover:bg-primary-800 transition-colors duration-300 focus:outline-none focus:ring-2 focus:ring-primary-500 focus:ring-offset-2"
          >
            Xem tất cả dịch vụ
            <svg
              xmlns="http://www.w3.org/2000/svg"
              className="ml-2 h-5 w-5"
              viewBox="0 0 20 20"
              fill="currentColor"
            >
              <path
                fillRule="evenodd"
                d="M10.293 5.293a1 1 0 011.414 0l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414-1.414L12.586 11H5a1 1 0 110-2h7.586l-2.293-2.293a1 1 0 010-1.414z"
                clipRule="evenodd"
              />
            </svg>
          </Link>
        </div>
      </div>
    </section>
  );
};

export default ServicesSection;