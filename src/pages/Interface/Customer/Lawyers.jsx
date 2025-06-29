import { useState, useEffect } from 'react';
import api from '../../../config/axios';
import { Link } from 'react-router-dom';

// Hàm tạo slug từ tên luật sư
const slugify = (name) => {
  return name
    .toLowerCase()
    .normalize('NFD') // Bỏ dấu
    .replace(/\p{Diacritic}/gu, '')
    .replace(/[^a-z0-9\s-]/g, '')
    .trim()
    .replace(/\s+/g, '-');
};

const Lawyers = () => {
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedSpecialization, setSelectedSpecialization] = useState('all');
  const [lawyers, setLawyers] = useState([]);
  const [allSpecializations, setAllSpecializations] = useState([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    api.auth.get('/api/UserWithLawyerProfile/only-lawyers')
      .then(res => {
        const list = res.data?.result || [];
        setLawyers(list);

        const specs = Array.from(
          new Set(list.flatMap(l => l.lawyerProfile?.spec || []))
        ).sort();
        setAllSpecializations(specs);
      })
      .catch(err => {
        console.error('Lỗi khi tải danh sách luật sư:', err);
        setLawyers([]);
      })
      .finally(() => setIsLoading(false));
  }, []);

  const filteredLawyers = lawyers.filter(item => {
    const { user, lawyerProfile } = item;

    const matchesSearch =
      (lawyerProfile?.bio?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        lawyerProfile?.description?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        user?.fullName?.toLowerCase().includes(searchTerm.toLowerCase()));

    const matchesSpecialization =
      selectedSpecialization === 'all' ||
      (lawyerProfile?.spec || []).some(spec =>
        spec.toLowerCase() === selectedSpecialization.toLowerCase()
      );

    return matchesSearch && matchesSpecialization;
  });

  return (
    <main>
      <section className="bg-primary-700 py-16">
        <div className="container mx-auto px-4">
          <div className="max-w-3xl">
            <h1 className="text-4xl font-bold text-white mb-6">Đội ngũ luật sư chuyên nghiệp</h1>
            <p className="text-gray-200 text-lg">
              Gặp gỡ các luật sư giàu kinh nghiệm, sẵn sàng hỗ trợ bạn trong các vấn đề pháp lý đa dạng.
            </p>
          </div>
        </div>
      </section>

      <section className="py-16">
        <div className="container mx-auto px-4">
          <div className="bg-white rounded-lg shadow-md p-6 mb-10">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div>
                <label htmlFor="search" className="block text-sm font-medium text-gray-700 mb-2">
                  Tìm kiếm luật sư
                </label>
                <input
                  type="text"
                  id="search"
                  className="w-full"
                  placeholder="Tìm theo tên, tiểu sử hoặc mô tả..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                />
              </div>
              <div>
                <label htmlFor="specialization" className="block text-sm font-medium text-gray-700 mb-2">
                  Lọc theo chuyên môn
                </label>
                <select
                  id="specialization"
                  className="w-full"
                  value={selectedSpecialization}
                  onChange={(e) => setSelectedSpecialization(e.target.value)}
                >
                  <option value="all">Tất cả chuyên môn</option>
                  {allSpecializations.map(spec => (
                    <option key={spec} value={spec}>{spec}</option>
                  ))}
                </select>
              </div>
            </div>
          </div>

          {isLoading ? (
            <div className="text-center">Đang tải dữ liệu...</div>
          ) : filteredLawyers.length > 0 ? (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
              {filteredLawyers.map(item => {
                const { user, lawyerProfile } = item;
                const slug = slugify(user.fullName);

                return (
                  <div key={lawyerProfile.id} className="bg-white rounded-lg shadow-md p-6 flex flex-col items-center">
                    <img
                      src={lawyerProfile.img ? `/images/${lawyerProfile.img}` : '/default-avatar.png'}
                      alt={user.fullName}
                      className="w-32 h-32 rounded-full object-cover mb-4"
                    />
                    <h3 className="text-xl font-bold mb-2">{user.fullName}</h3>
                    <div className="mb-2 text-gray-600 text-sm">{lawyerProfile.bio}</div>
                    <div className="flex flex-wrap gap-1 mb-2">
                      {(lawyerProfile.spec || []).map((spec, idx) => (
                        <span key={idx} className="badge bg-accent-300 text-primary-800">{spec}</span>
                      ))}
                    </div>
                    <div className="mb-2 text-gray-700 text-sm">
                      Kinh nghiệm: {lawyerProfile.expYears} năm
                    </div>
                    <div className="mb-2 text-gray-700 text-sm">
                      Địa chỉ: {lawyerProfile.description}
                    </div>
                    <div className="mb-2 text-yellow-600 text-sm">
                      Đánh giá: {lawyerProfile.rating} ★
                    </div>
                    <div className="mb-2 text-green-700 text-sm">
                      Giá/giờ: {lawyerProfile.pricePerHour?.toLocaleString()} VNĐ
                    </div>
                    <Link
                      to={`/lawyers/${slug}`}
                      className="btn-primary mt-2"
                    >
                      Xem chi tiết
                    </Link>
                  </div>
                );
              })}
            </div>
          ) : (
            <div className="text-center py-12">
              <h3 className="text-xl font-medium text-gray-900 mb-2">Không tìm thấy luật sư</h3>
              <p className="text-gray-600">
                Vui lòng thử lại với tiêu chí tìm kiếm khác hoặc xoá bộ lọc.
              </p>
              <button
                onClick={() => {
                  setSearchTerm('');
                  setSelectedSpecialization('all');
                }}
                className="mt-4 btn-outline"
              >
                Xoá bộ lọc
              </button>
            </div>
          )}
        </div>
      </section>
    </main>
  );
};

export default Lawyers;
