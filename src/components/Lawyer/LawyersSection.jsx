import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import api from "../../config/axios";
import LawyerCard from "./LawyerCard";

// Hàm tạo slug từ tên
const slugify = (name) => {
  return name
    .toLowerCase()
    .normalize("NFD")
    .replace(/\p{Diacritic}/gu, "")
    .replace(/[^a-z0-9\s-]/g, "")
    .trim()
    .replace(/\s+/g, "-");
};

const LawyersSection = () => {
  const [lawyers, setLawyers] = useState([]);
  const [ratingMap, setRatingMap] = useState({});
  const [reviewCounts, setReviewCounts] = useState({});
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchLawyers = async () => {
      try {
        setLoading(true);

        // 1. Lấy danh sách luật sư
        const res = await api.auth.get("/api/UserWithLawyerProfile/only-lawyers");
        const list = res.data?.result || [];

        // 2. Lấy rating trung bình cho từng luật sư
        const ratings = {};
        await Promise.all(
          list.map(async (item) => {
            const id = item.lawyerProfile.id;
            try {
              const r = await api.auth.get(`/api/Review/lawyer/${id}/average-rating`);
              ratings[id] = r.data;
            } catch {
              ratings[id] = null;
            }
          })
        );
        setRatingMap(ratings);

        // 3. Lấy tất cả reviews để đếm số lượt review
        const reviewRes = await api.auth.get("/api/Review");
        const allReviews = reviewRes.data || [];
        const countMap = {};
        allReviews.forEach((rev) => {
          if (rev.lawyerId) {
            countMap[rev.lawyerId] = (countMap[rev.lawyerId] || 0) + 1;
          }
        });
        setReviewCounts(countMap);

        // 4. Set danh sách luật sư
        setLawyers(list);
      } catch (err) {
        console.error("Lỗi khi tải dữ liệu luật sư:", err);
      } finally {
        setLoading(false);
      }
    };

    fetchLawyers();
  }, []);

  if (loading) {
    return (
      <section className="py-16">
        <div className="container mx-auto text-center text-gray-500">
          Đang tải dữ liệu...
        </div>
      </section>
    );
  }

  // 5. Sắp xếp danh sách theo rating, sau đó theo số lượt review
  const sortedLawyers = [...lawyers].sort((a, b) => {
    const idA = a.lawyerProfile.id;
    const idB = b.lawyerProfile.id;
    const ratingA = ratingMap[idA] || 0;
    const ratingB = ratingMap[idB] || 0;
    if (ratingB !== ratingA) return ratingB - ratingA;

    const countA = reviewCounts[idA] || 0;
    const countB = reviewCounts[idB] || 0;
    return countB - countA;
  });

  return (
    <section className="py-16 bg-gray-50">
      <div className="container mx-auto px-4">
        <div className="text-center mb-10">
          <h2 className="text-3xl font-bold text-gray-800 mb-2">Luật sư nổi bật</h2>
          <p className="text-gray-600">
            Một số luật sư hàng đầu được đánh giá cao bởi khách hàng.
          </p>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-8">
          {sortedLawyers.slice(0, 4).map((item) => {
            const { user, lawyerProfile } = item;
            const slug = slugify(user.fullName);
            const rating = ratingMap[lawyerProfile.id];
            const reviewCount = reviewCounts[lawyerProfile.id] || 0;

            return (
              <LawyerCard
                key={lawyerProfile.id}
                lawyer={{
                  id: lawyerProfile.id,
                  slug,
                  name: user.fullName,
                  photo: lawyerProfile.img,
                  specialization: lawyerProfile.spec || [],
                  experience: lawyerProfile.expYears,
                  description: lawyerProfile.description,
                  rating: rating != null ? rating.toFixed(1) : "Chưa có",
                  reviewCount,
                }}
              />
            );
          })}
        </div>

        <div className="text-center mt-10">
          <Link
            to="/lawyers"
            className="inline-block px-6 py-3 bg-primary-700 text-white rounded-lg hover:bg-primary-800 transition"
          >
            Xem tất cả luật sư
          </Link>
        </div>
      </div>
    </section>
  );
};

export default LawyersSection;
