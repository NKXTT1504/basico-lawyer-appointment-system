import React, { useEffect, useState } from "react";
import api from "../../../config/axios";
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  Legend,
  LabelList,
} from "recharts";

const Dashboard = () => {
  const [reviewStats, setReviewStats] = useState([]);
  const [bookingStats, setBookingStats] = useState([]);
  const [cancelStats, setCancelStats] = useState([]);
  const [loading, setLoading] = useState(true);

  const now = new Date();
  const month = now.getMonth();
  const year = now.getFullYear();

  useEffect(() => {
    const fetchData = async () => {
      setLoading(true);
      try {
        const [reviewRes, appRes] = await Promise.all([
          api.auth.get("/api/Review"),
          api.appointment.get("/api/AppointmentWithUserLawyer/GetAllAppointment"),
        ]);

        const reviews = Array.isArray(reviewRes.data) ? reviewRes.data : [];
        const appointments = appRes.data?.result || [];

        const reviewsThisMonth = reviews.filter((r) => {
          const d = new Date(r.createdAt);
          return d.getMonth() === month && d.getFullYear() === year;
        });

        const completedAppointments = appointments.filter((a) => {
          const d = new Date(a.scheduledAt);
          return a.status === 3 && d.getMonth() === month && d.getFullYear() === year;
        });

        const cancelledAppointments = appointments.filter((a) => {
          const d = new Date(a.scheduledAt);
          return a.status === 1 && d.getMonth() === month && d.getFullYear() === year;
        });

        // Aggregation
        const lawyerReviewCount = {};
        const lawyerBookingCount = {};
        const lawyerCancelCount = {};

        reviewsThisMonth.forEach((r) => {
          const id = r.lawyerId;
          if (!id) return;
          lawyerReviewCount[id] = (lawyerReviewCount[id] || 0) + 1;
        });

        completedAppointments.forEach((a) => {
          const id = a.lawyerProfile?.userId;
          if (!id) return;
          lawyerBookingCount[id] = (lawyerBookingCount[id] || 0) + 1;
        });

        cancelledAppointments.forEach((a) => {
          const id = a.lawyerProfile?.userId;
          if (!id) return;
          lawyerCancelCount[id] = (lawyerCancelCount[id] || 0) + 1;
        });

        const allLawyerIds = [
          ...new Set([
            ...Object.keys(lawyerReviewCount),
            ...Object.keys(lawyerBookingCount),
            ...Object.keys(lawyerCancelCount),
          ]),
        ];

        const lawyerMap = {};
        const lawyerAvgRatingMap = {};

        await Promise.all(
          allLawyerIds.map(async (id) => {
            try {
              const [userRes, avgRes] = await Promise.all([
                api.auth.get(`/api/UserWithLawyerProfile/${id}`),
                api.auth.get(`/api/Review/lawyer/${id}/average-rating`),
              ]);
              lawyerMap[id] = userRes.data?.result?.user?.fullName || `Luật sư ${id}`;
              lawyerAvgRatingMap[id] = avgRes.data || 0;
            } catch {
              lawyerMap[id] = `Luật sư ${id}`;
              lawyerAvgRatingMap[id] = 0;
            }
          })
        );

        // Build unified data by lawyer
        const reviewData = allLawyerIds.map((id) => ({
          name: lawyerMap[id],
          avgRating: parseFloat((lawyerAvgRatingMap[id] || 0).toFixed(2)),
          count: lawyerReviewCount[id] || 0,
        }));

        const bookingData = allLawyerIds.map((id) => ({
          name: lawyerMap[id],
          "Cuộc hẹn hoàn thành": lawyerBookingCount[id] || 0,
        }));

        const cancelData = allLawyerIds.map((id) => ({
          name: lawyerMap[id],
          "Cuộc hẹn bị hủy": lawyerCancelCount[id] || 0,
        }));

        setReviewStats(reviewData);
        setBookingStats(bookingData);
        setCancelStats(cancelData);
      } catch (err) {
        console.error("Lỗi khi lấy dữ liệu:", err);
        setReviewStats([]);
        setBookingStats([]);
        setCancelStats([]);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  return (
    <div className="p-6 max-w-6xl mx-auto">
      <h1 className="text-4xl font-bold text-center mt-10 mb-10 text-primary-900">
        THỐNG KÊ TỔNG QUÁT
      </h1>

      {loading ? (
        <div className="text-center text-lg text-gray-500 py-20">
          Đang tải dữ liệu...
        </div>
      ) : (
        <>
          {/* Biểu đồ đánh giá */}
          <div className="bg-white rounded shadow p-6 mb-10">
            <h2 className="text-2xl font-bold mb-4 text-primary-700 text-center">
              TỔNG ĐÁNH GIÁ LUẬT SƯ
            </h2>
            <ResponsiveContainer width="100%" height={300}>
              <BarChart
                data={reviewStats}
                margin={{ top: 20, right: 30, left: 20, bottom: 60 }}
              >
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="name" angle={-30} textAnchor="end" interval={0} height={80} />
                <YAxis domain={[0, 5]} />
                <Tooltip
                  formatter={(value, name, props) => {
                    const count = props.payload?.count;
                    return [`${value} (${count} lượt)`, "Rating"];
                  }}
                />
                <Legend />
                <Bar dataKey="avgRating" name="Rating" fill="#EAB308">
                  <LabelList
                    dataKey="count"
                    content={({ x, y, width, value }) => (
                      <text
                        x={x + width / 2}
                        y={y - 10}
                        fill="#1F2937"
                        fontSize={12}
                        fontWeight="bold"
                        textAnchor="middle"
                      >
                        {value} lượt
                      </text>
                    )}
                  />
                </Bar>
              </BarChart>
            </ResponsiveContainer>
          </div>

          {/* Biểu đồ hoàn thành */}
          <div className="bg-white rounded shadow p-6 mb-10">
            <h2 className="text-2xl font-bold mb-4 text-primary-700 text-center">
              CUỘC HẸN HOÀN TẤT
            </h2>
            <ResponsiveContainer width="100%" height={300}>
              <BarChart
                data={bookingStats}
                margin={{ top: 20, right: 30, left: 20, bottom: 60 }}
              >
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="name" angle={-30} textAnchor="end" interval={0} height={80} />
                <YAxis />
                <Tooltip />
                <Legend />
                <Bar dataKey="Cuộc hẹn hoàn thành" fill="#16A34A" />
              </BarChart>
            </ResponsiveContainer>
          </div>

          {/* Biểu đồ bị hủy */}
          <div className="bg-white rounded shadow p-6 mb-10">
            <h2 className="text-2xl font-bold mb-4 text-primary-700 text-center">
              CUỘC HẸN BỊ HỦY
            </h2>
            <ResponsiveContainer width="100%" height={300}>
              <BarChart
                data={cancelStats}
                margin={{ top: 20, right: 30, left: 20, bottom: 60 }}
              >
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="name" angle={-30} textAnchor="end" interval={0} height={80} />
                <YAxis />
                <Tooltip />
                <Legend />
                <Bar dataKey="Cuộc hẹn bị hủy" fill="#DC2626" />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </>
      )}
    </div>
  );
};

export default Dashboard;
