import { useParams, Link } from 'react-router-dom';
import { useEffect, useState } from 'react';
import { ArrowLeft, Star } from 'lucide-react';
import api from '../../../config/axios';
import ReviewForm from '../../../components/Testimonial/ReviewForm';

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
  const [averageRating, setAverageRating] = useState(null);
  const [reviewCount, setReviewCount] = useState(0);
  const [reviewCountMap, setReviewCountMap] = useState({});
  const [loading, setLoading] = useState(true);
  const [reviews, setReviews] = useState([]);
  const [showSuccessMessage, setShowSuccessMessage] = useState(false);
  const [userMap, setUserMap] = useState({});

  const fetchReviews = async (lawyerId) => {
    try {
      const reviewRes = await api.auth.get(`/api/Review/lawyer/${lawyerId}`);
      const reviewsData = reviewRes.data || [];

      // Lấy danh sách unique userIds
      const userIds = [...new Set(reviewsData.map(review => review.userId))];

      // Fetch thông tin người dùng
      const userPromises = userIds.map(userId =>
        api.auth.get(`/api/UserWithLawyerProfile/${userId}`)
      );
      const userResponses = await Promise.all(userPromises);

      // Tạo map từ userId đến fullName
      const newUserMap = {};
      userResponses.forEach(response => {
        const userData = response.data.result;
        if (userData && userData.user) {
          newUserMap[userData.user.id] = userData.user.fullName;
        }
      });

      setUserMap(newUserMap);
      setReviews(reviewsData);
      setReviewCount(reviewsData.length); // Thêm dòng này
    } catch (error) {
      console.error("Error fetching reviews:", error);
      setReviews([]);
      setReviewCount(0); // Thêm dòng này
    }
  };

  useEffect(() => {
    const fetchLawyer = async () => {
      try {
        const res = await api.auth.get('/api/UserWithLawyerProfile/only-lawyers');
        const list = res.data.result || [];
        const found = list.find(lawyer => slugify(lawyer.user.fullName) === slug);
        setLawyer(found || null);
        if (found?.lawyerProfile?.id) {
          const ratingRes = await api.auth.get(`/api/Review/lawyer/${found.lawyerProfile.id}/average-rating`);
          setAverageRating(ratingRes.data);

          // Fetch reviews
          await fetchReviews(found.lawyerProfile.id);
        }
      } catch {
        setLawyer(null);
        setAverageRating(null);
        setReviewCount(0);
        setReviewCountMap(reviewCounts);
        setReviews([]);
      } finally {
        setLoading(false);
      }
    };

    fetchLawyer();
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

  const updateReviews = (newReview) => {
    setReviews(prevReviews => [newReview, ...prevReviews]);
    setReviewCount(prevCount => prevCount + 1);
    setAverageRating(prevRating => {
      const totalRating = (prevRating * reviewCount) + newReview.rating;
      return totalRating / (reviewCount + 1);
    });
    setShowSuccessMessage(true);
    setTimeout(() => setShowSuccessMessage(false), 4000);
  };

  const { lawyerProfile, user } = lawyer;

  return (
    <main className="bg-white py-16">
      {showSuccessMessage && (
        <div className="fixed inset-x-0 top-20 z-50 flex justify-center">
          <div className="flex items-center gap-3 bg-green-100 border border-green-300 text-green-800 px-6 py-3 rounded-xl shadow-lg animate-fade-bounce">
            <img
              src="https://cdn-icons-png.flaticon.com/512/190/190411.png"
              alt="Success"
              className="w-6 h-6 animate-scale-pop"
            />
            <span className="font-medium">Đánh giá của bạn đã được gửi thành công!</span>
          </div>
        </div>
      )}
      <div className="container mx-auto px-4 max-w-6xl">
        <Link
          to="/lawyers"
          className="inline-flex items-center text-sm font-medium text-primary-700 hover:text-primary-900 transition-colors duration-200 mb-6"
        >
          <ArrowLeft className="w-4 h-4 mr-2" />
          Quay lại danh sách luật sư
        </Link>

        <div className="bg-white rounded-2xl shadow-lg p-6 md:p-10 grid grid-cols-1 md:grid-cols-3 gap-10">
          <div className="flex justify-center md:justify-start">
            <img
              src={lawyerProfile.img}
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
              <li><strong> Địa chỉ:</strong> {lawyerProfile.description}</li>
              <li><strong> Kinh nghiệm:</strong> {lawyerProfile.expYears} năm</li>
              <li>
                <strong> Đánh giá:</strong>{" "}
                {averageRating !== null ? `${averageRating.toFixed(1)} ⭐` : "Chưa có"}
                <span className="ml-2 text-gray-500 text-sm">
                  ({reviewCount} lượt đánh giá)
                </span>
              </li>
              <li><strong>Giá/giờ:</strong> {lawyerProfile.pricePerHour?.toLocaleString()} VNĐ</li>
              <li><strong>Số hiệu hành nghề:</strong> {lawyerProfile.licenseNum}</li>
              <li><strong>Email:</strong> {user.email}</li>
              <li><strong>SĐT:</strong> {user.phoneNumber}</li>
            </ul>
            {/* Thêm nút xem bằng cấp */}
            <div className="mt-4">
              <Link
                to={`/lawyers/${slugify(user.fullName)}/diploma`}
                className="inline-block px-4 py-2 bg-primary-700 text-white rounded hover:bg-primary-800 transition"
              >
                Xem bằng cấp của luật sư
              </Link>
            </div>
          </div>
        </div>
      </div>

      {/* Phần hiển thị đánh giá */}
      <div className="container mx-auto px-4 max-w-6xl mt-12">
        <h2 className="text-2xl font-bold mb-6">Đánh giá từ khách hàng</h2>
        {reviews.length > 0 ? (
          <div className="space-y-6">
            {reviews
              .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt))
              .map((review) => {
                return (
                  <div key={review.id} className="bg-gray-50 p-6 rounded-lg">
                    <div className="flex items-center justify-between mb-2">
                      <div>
                        <h3 className="text-xl text-gray-800">
                          {userMap[review.userId] || 'Ẩn danh'}                        
                          </h3>
                        <div className="flex items-center mt-1">
                          {[...Array(5)].map((_, i) => (
                            <Star
                              key={i}
                              className={`w-4 h-4 ${i < review.rating ? 'text-yellow-400 fill-current' : 'text-gray-300'
                                }`}
                            />
                          ))}
                          <span className="ml-2 text-sm text-gray-600">
                            {new Date(review.createdAt).toLocaleDateString()}
                          </span>
                        </div>
                      </div>
                    </div>
                    <p className="text-gray-700 mt-2">{review.comment}</p>
                  </div>
                );
              })}
          </div>
        ) : (
          <p className="text-gray-500">Chưa có đánh giá nào cho luật sư này.</p>
        )}
      </div>

      {/* Form đánh giá */}
      <div className="container mx-auto px-4 max-w-6xl mt-12">
        <ReviewForm lawyerId={lawyerProfile.id} onSuccess={updateReviews} />
      </div>
    </main>
  );
};

export default LawyerDetails;
