import { useParams, Link } from 'react-router-dom';
import { useEffect, useState } from 'react';
import api from '../../../config/axios';

const slugify = (name) => {
  return name
    .toLowerCase()
    .normalize('NFD')
    .replace(/\p{Diacritic}/gu, '')
    .replace(/[^a-z0-9\s-]/g, '')
    .trim()
    .replace(/\s+/g, '-');
};

const LawyerDetails = () => {
  const { slug } = useParams();
  const [lawyer, setLawyer] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    api.auth.get('/api/UserWithLawyerProfile/only-lawyers')
      .then(res => {
        const list = res.data.result || [];
        const found = list.find(lawyer => slugify(lawyer.user.fullName) === slug);
        setLawyer(found || null);
      })
      .catch(() => setLawyer(null))
      .finally(() => setLoading(false));
  }, [slug]);

  if (loading) {
    return <div className="container mx-auto px-4 py-16 text-center text-gray-600">Đang tải dữ liệu...</div>;
  }

  if (!lawyer || !lawyer.lawyerProfile || !lawyer.user) {
    return (
      <div className="container mx-auto px-4 py-16 text-center">
        <h2 className="text-2xl font-bold text-gray-900 mb-4">Không tìm thấy luật sư</h2>
        <Link to="/lawyers" className="inline-block px-4 py-2 bg-primary-900 text-white rounded hover:opacity-90">
          Quay lại danh sách luật sư
        </Link>
      </div>
    );
  }

  const { lawyerProfile, user } = lawyer;

  return (
    <main className="bg-white py-16">
      <div className="container mx-auto px-4 max-w-6xl">
        <Link
          to="/lawyers"
          className="text-sm text-primary-900 hover:underline inline-flex items-center mb-6"
        >
          &larr; Quay lại danh sách
        </Link>

        <div className="bg-white rounded-2xl shadow-lg p-6 md:p-10 grid grid-cols-1 md:grid-cols-3 gap-10">
          <div className="flex justify-center md:justify-start">
            <img
              src={lawyerProfile.img ? `/images/${lawyerProfile.img}` : '/default-avatar.png'}
              alt={user.fullName}
              className="w-64 h-64 rounded-xl object-cover shadow-md"
            />
          </div>

          <div className="md:col-span-2 text-gray-800">
            <h1 className="text-3xl font-bold mb-2">{user.fullName}</h1>
            <p className="text-gray-500 mb-4">{lawyerProfile.bio}</p>

            <div className="flex flex-wrap gap-2 mb-4">
              {(lawyerProfile.spec || []).map((spec, idx) => (
                <span
                  key={idx}
                  className="inline-block bg-primary-100 text-primary-900 text-sm font-medium px-3 py-1 rounded-full"
                >
                  {spec}
                </span>
              ))}
            </div>

            <ul className="space-y-2 text-sm">
              <li><strong>📍 Địa chỉ:</strong> {lawyerProfile.description}</li>
              <li><strong>🎓 Kinh nghiệm:</strong> {lawyerProfile.expYears} năm</li>
              <li><strong>⭐ Đánh giá:</strong> {lawyerProfile.rating} ★</li>
              <li><strong>💰 Giá/giờ:</strong> {lawyerProfile.pricePerHour?.toLocaleString()} VNĐ</li>
              <li><strong>🧾 Số hiệu hành nghề:</strong> {lawyerProfile.licenseNum}</li>
              <li><strong>📧 Email:</strong> {user.email}</li>
              <li><strong>📞 SĐT:</strong> {user.phoneNumber}</li>
            </ul>

            <div className="mt-6">
              <Link
                to={`/appointment?lawyer=${lawyerProfile.id}`}
                className="inline-block bg-primary-700 text-white px-6 py-3 rounded-lg font-semibold hover:opacity-90 transition"
              >
                Đặt lịch tư vấn
              </Link>
            </div>
          </div>
        </div>
      </div>
    </main>
  );
};

export default LawyerDetails;
