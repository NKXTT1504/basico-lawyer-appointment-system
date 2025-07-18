import { useState, useEffect } from 'react';
import api from '../../../config/axios';
import { Link } from 'react-router-dom';

// Hàm tạo slug từ tên luật sư
const slugify = (name) => {
  return name
    .toLowerCase()
    .normalize('NFD')
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
  const [ratingMap, setRatingMap] = useState({});

  useEffect(() => {
    setIsLoading(true);
    api.auth.get('/api/UserWithLawyerProfile/only-lawyers')
      .then(async res => {
        const list = res.data?.result || [];
        setLawyers(list);

        const specs = Array.from(
          new Set(list.flatMap(l => l.lawyerProfile?.spec || []))
        ).sort();
        setAllSpecializations(specs);

        const ratings = {};
        await Promise.all(
          list.map(async l => {
            try {
              const res = await api.auth.get(`/api/Review/lawyer/${l.lawyerProfile.id}/average-rating`);
              ratings[l.lawyerProfile.id] = res.data;
            } catch {
              ratings[l.lawyerProfile.id] = null;
            }
          })
        );
        setRatingMap(ratings);
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
            <h1 className="text-4xl font-bold text-white mb-4">Đội ngũ luật sư chuyên nghiệp</h1>
            <p className="text-gray-200 text-lg">
              Gặp gỡ các luật sư giàu kinh nghiệm, sẵn sàng hỗ trợ bạn trong các vấn đề pháp lý đa dạng.
            </p>
          </div>
        </div>
      </section>

      <section className="py-16">
        <div className="container mx-auto px-4">
          {/* Bộ lọc tìm kiếm */}
          <div className="bg-white rounded-lg shadow-md p-6 mb-10">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div>
                <label htmlFor="search" className="block text-sm font-medium text-gray-700 mb-2">
                  Tìm kiếm luật sư
                </label>
                <input
                  type="text"
                  id="search"
                  className="w-full border rounded px-4 py-2"
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
                  className="w-full border rounded px-4 py-2"
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

          {/* Danh sách luật sư */}
          {isLoading ? (
            <div className="text-center text-gray-600">Đang tải dữ liệu...</div>
          ) : filteredLawyers.length > 0 ? (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
              {filteredLawyers.map(item => {
                const { user, lawyerProfile } = item;
                const slug = slugify(user.fullName);
                const rating = ratingMap[lawyerProfile.id];

                return (
                  <div key={lawyerProfile.id} className="bg-white rounded-xl shadow-md p-6 flex flex-col items-center text-center transition hover:shadow-lg duration-300">
                    <img
                      src={lawyerProfile.img ? `/images/${lawyerProfile.img}` : '/default-avatar.png'}
                      alt={user.fullName}
                      className="w-28 h-28 rounded-full object-cover mb-4 border-4 border-primary-700"
                    />
                    <h3 className="text-xl font-semibold mb-1 text-primary-800">{user.fullName}</h3>
                    <p className="text-gray-600 text-sm mb-2 italic">{lawyerProfile.bio}</p>

                    {/* Chuyên môn */}
                    <div className="flex flex-wrap justify-center gap-2 mb-3">
                      {(lawyerProfile.spec || []).map((spec, idx) => (
                        <span
                          key={idx}
                          className="bg-primary-100 text-primary-700 text-xs px-2 py-1 rounded-full font-medium"
                        >
                          {spec}
                        </span>
                      ))}
                    </div>

                    {/* Thông tin */}
                    <div className="w-full text-sm text-gray-700 space-y-1 text-center mt-2">
                      <p><span className="font-semibold">Địa chỉ:</span> {lawyerProfile.description}</p>
                      <p><span className="font-semibold">Kinh nghiệm:</span> {lawyerProfile.expYears} năm</p>
                      <p><span className="font-semibold">Giá/giờ:</span> {lawyerProfile.pricePerHour?.toLocaleString()} VNĐ</p>
                      <p>
                        <span className="font-semibold">Đánh giá:</span>{' '}
                        {rating !== null ? (
                          <span className="text-yellow-600 font-semibold">{rating.toFixed(1)} ★</span>
                        ) : (
                          'Chưa có'
                        )}
                      </p>
                    </div>
                    <Link
                      to={`/lawyers/${slug}`}
                      className="mt-4 inline-block bg-primary-700 text-white px-5 py-2 rounded hover:bg-primary-800 transition"
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
              <p className="text-gray-600">Vui lòng thử lại với tiêu chí tìm kiếm khác hoặc xoá bộ lọc.</p>
              <button
                onClick={() => {
                  setSearchTerm('');
                  setSelectedSpecialization('all');
                }}
                className="mt-4 px-4 py-2 border rounded hover:bg-gray-100"
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
