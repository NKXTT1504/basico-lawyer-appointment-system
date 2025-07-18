import { useEffect, useState } from "react";
import api from "../../../config/axios";
import { format } from "date-fns";

const ReviewManagement = () => {
  const [reviews, setReviews] = useState([]);
  const [lawyerMap, setLawyerMap] = useState({});
  const [userMap, setUserMap] = useState({});
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");
  const [currentPage, setCurrentPage] = useState(1);
  const PAGE_SIZE = 10;

  useEffect(() => {
    const fetchData = async () => {
      setLoading(true);
      try {
        const reviewRes = await api.auth.get("/api/Review");
        const reviewData = Array.isArray(reviewRes.data) ? reviewRes.data : [];
        setReviews(reviewData);

        const uniqueUserIds = new Set();
        const uniqueLawyerIds = new Set();

        reviewData.forEach((r) => {
          if (r.userId) uniqueUserIds.add(r.userId);
          if (r.lawyerId) uniqueLawyerIds.add(r.lawyerId);
        });

        // Fetch user info for both customers and lawyers
        const userFetches = [...uniqueUserIds].map((id) =>
          api.auth.get(`/api/UserWithLawyerProfile/${id}`).then((res) => ({
            id,
            fullName: res.data?.result.user?.fullName || `Người dùng ${id}`,
          }))
        );

        const lawyerFetches = [...uniqueLawyerIds].map((id) =>
          api.auth.get(`/api/UserWithLawyerProfile/${id}`).then((res) => ({
            id,
            fullName: res.data?.result.user?.fullName || `Luật sư ${id}`,
          }))
        );

        const [userResults, lawyerResults] = await Promise.all([
          Promise.all(userFetches),
          Promise.all(lawyerFetches),
        ]);

        const userMap = {};
        userResults.forEach((u) => (userMap[u.id] = u.fullName));
        setUserMap(userMap);

        const lawyerMap = {};
        lawyerResults.forEach((l) => (lawyerMap[l.id] = l.fullName));
        setLawyerMap(lawyerMap);
      } catch {
        setReviews([]);
        setUserMap({});
        setLawyerMap({});
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  const filtered = reviews.filter((r) => {
    const keyword = search.toLowerCase();
    const lawyerName = (lawyerMap[r.lawyerId] || "").toLowerCase();
    const userName = (userMap[r.userId] || "").toLowerCase();
    return (
      lawyerName.includes(keyword) ||
      userName.includes(keyword) ||
      r.comment.toLowerCase().includes(keyword)
    );
  });

  const totalPages = Math.ceil(filtered.length / PAGE_SIZE);
  const paged = filtered.slice((currentPage - 1) * PAGE_SIZE, currentPage * PAGE_SIZE);

  return (
    <div className="p-6 max-w-6xl mx-auto">
      <h1 className="text-4xl text-center font-bold mt-10 text-primary-900">Quản lý đánh giá khách hàng</h1>

      <div className="mt-10 flex items-center gap-4">
        <input
          type="text"
          placeholder="Tìm kiếm theo tên luật sư, khách hàng hoặc nội dung..."
          className="border rounded px-4 py-2 w-full max-w-md"
          value={search}
          onChange={(e) => {
            setSearch(e.target.value);
            setCurrentPage(1);
          }}
        />
      </div>

      <div className="mt-10 overflow-x-auto rounded shadow border">
        <table className="min-w-full bg-white">
          <thead>
            <tr className="bg-gray-100 text-gray-700">
              <th className="py-2 px-4 border">STT</th>
              <th className="py-2 px-4 border">Luật sư</th>
              <th className="py-2 px-4 border">Khách hàng</th>
              <th className="py-2 px-4 border">Số sao</th>
              <th className="py-2 px-4 border">Nội dung</th>
              <th className="py-2 px-4 border">Ngày tạo</th>
            </tr>
          </thead>
          <tbody>
            {paged.map((r, idx) => (
              <tr key={r.id} className="text-center">
                <td className="py-2 px-4 border">{(currentPage - 1) * PAGE_SIZE + idx + 1}</td>
                <td className="py-2 px-4 border">{lawyerMap[r.lawyerId] || r.lawyerId}</td>
                <td className="py-2 px-4 border">{userMap[r.userId] || r.userId}</td>
                <td className="py-2 px-4 border text-yellow-500 font-bold">{r.rating} ★</td>
                <td className="py-2 px-4 border text-left">{r.comment}</td>
                <td className="py-2 px-4 border">{format(new Date(r.createdAt), "dd/MM/yyyy")}</td>
              </tr>
            ))}
            {paged.length === 0 && (
              <tr>
                <td colSpan={6} className="py-6 text-gray-500 text-center">
                  Không có đánh giá nào.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

      {totalPages > 1 && (
        <div className="flex justify-center items-center gap-4 mt-6">
          <button
            onClick={() => setCurrentPage((p) => Math.max(1, p - 1))}
            disabled={currentPage === 1}
            className="p-2 rounded border bg-white hover:bg-gray-100 disabled:opacity-50"
          >
            &larr;
          </button>
          <span className="text-sm font-medium">
            Trang {currentPage} / {totalPages}
          </span>
          <button
            onClick={() => setCurrentPage((p) => Math.min(totalPages, p + 1))}
            disabled={currentPage === totalPages}
            className="p-2 rounded border bg-white hover:bg-gray-100 disabled:opacity-50"
          >
            &rarr;
          </button>
        </div>
      )}
    </div>
  );
};

export default ReviewManagement;
