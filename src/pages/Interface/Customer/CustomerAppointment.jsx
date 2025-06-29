import { useEffect, useState } from "react";
import api from "../../../config/axios";
import { format, parseISO } from "date-fns";
import vi from "date-fns/locale/vi";
import { ChevronLeft, ChevronRight } from "lucide-react";

const statusMap = {
  0: { label: "Đang chờ", color: "text-yellow-600" },
  1: { label: "Đã xác nhận", color: "text-green-600" },
  2: { label: "Đã hủy", color: "text-red-600 font-bold" },
  3: { label: "Hoàn thành", color: "text-green-700 font-bold" },
};

const PAGE_SIZE = 5;

const CustomerAppointment = () => {
  const [appointments, setAppointments] = useState([]);
  const [lawyerMap, setLawyerMap] = useState({});
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState("upcoming");
  const [currentPage, setCurrentPage] = useState(1);

  const user = JSON.parse(localStorage.getItem("user") || "{}");
  const userId = user?.id;

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [appsRes, lawyersRes] = await Promise.all([
          api.appointment.get(`/api/AppointmentWithUserLawyer/by-user/${userId}`),
          api.auth.get(`/api/UserWithLawyerProfile/only-lawyers`),
        ]);

        const appointments = Array.isArray(appsRes.data) ? appsRes.data : [];
        const lawyers = lawyersRes.data?.result || [];

        const map = {};
        lawyers.forEach((lawyer) => {
          map[lawyer.lawyerProfile.id] = lawyer.user.fullName;
        });

        setAppointments(appointments);
        setLawyerMap(map);
      } catch (err) {
        console.error("Lỗi khi tải:", err);
        setAppointments([]);
        setLawyerMap({});
      } finally {
        setLoading(false);
      }
    };

    if (userId) fetchData();
  }, [userId]);

  const filteredAppointments = (tab) => {
    const filterFn = tab === "upcoming"
      ? (app) => app.status === 0 || app.status === 1
      : (app) => app.status === 2 || app.status === 3;

    return appointments
      .filter(filterFn)
      .sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
  };

  const paginated = (data) => {
    const start = (currentPage - 1) * PAGE_SIZE;
    return data.slice(start, start + PAGE_SIZE);
  };

  const renderTable = (data, isHistory = false) => {
    const pagedData = paginated(data);
    const totalPages = Math.ceil(data.length / PAGE_SIZE);

    return (
      <div>
        <div className="overflow-x-auto shadow rounded-md border border-gray-200">
          <table className="w-full text-sm text-center table-auto">
            <thead className="bg-gray-100 text-gray-700">
              <tr>
                <th className="py-3 px-4 border-b">STT</th>
                <th className="py-3 px-4 border-b">Luật sư</th>
                <th className="py-3 px-4 border-b">Thời gian</th>
                <th className="py-3 px-4 border-b">Dịch vụ</th>
                <th className="py-3 px-4 border-b">Trạng thái</th>
              </tr>
            </thead>
            <tbody>
              {pagedData.map((app, idx) => {
                const slot = app.slot;
                const scheduledAt = app.scheduledAt;
                const lawyerName = lawyerMap[app.lawyerId] || "Chưa xác định";

                let formatted = "-";
                if (scheduledAt && slot) {
                  const dateTimeStr = `${scheduledAt.slice(0, 10)}T${slot}:00`;
                  const dateObj = parseISO(dateTimeStr);
                  if (!isNaN(dateObj)) {
                    formatted = `${slot}, ${format(dateObj, "EEEE, dd/MM/yyyy", { locale: vi })}`;
                  }
                }

                const status = statusMap[app.status];

                return (
                  <tr key={app.id} className="text-gray-800">
                    <td className="py-3 px-4 border-b">{(currentPage - 1) * PAGE_SIZE + idx + 1}</td>
                    <td className="py-3 px-4 border-b">{lawyerName}</td>
                    <td className="py-3 px-4 border-b">{formatted}</td>
                    <td className="py-3 px-4 border-b">{app.services?.join(", ")}</td>
                    <td className={`py-3 px-4 border-b ${status.color}`}>{status.label}</td>
                  </tr>
                );
              })}
              {pagedData.length === 0 && (
                <tr>
                  <td colSpan="5" className="py-6 text-gray-500 text-center">
                    {isHistory ? "Chưa có lịch sử." : "Không có cuộc hẹn sắp tới."}
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>

        {/* Pagination */}
        {data.length > PAGE_SIZE && (
          <div className="flex justify-center items-center gap-4 mt-6">
            <button
              onClick={() => setCurrentPage((prev) => Math.max(prev - 1, 1))}
              className="p-2 rounded-full bg-gray-200 hover:bg-gray-300"
              disabled={currentPage === 1}
            >
              <ChevronLeft size={18} />
            </button>
            <span className="font-semibold text-gray-800">
              Trang {currentPage} / {totalPages}
            </span>
            <button
              onClick={() => setCurrentPage((prev) => Math.min(prev + 1, totalPages))}
              className="p-2 rounded-full bg-gray-200 hover:bg-gray-300"
              disabled={currentPage === totalPages}
            >
              <ChevronRight size={18} />
            </button>
          </div>
        )}
      </div>
    );
  };

  const currentData = filteredAppointments(activeTab);

  return (
    <div className="p-6 max-w-7xl mx-auto">
      <h1 className="text-4xl font-bold text-primary-900 text-center mb-10">Lịch hẹn của bạn</h1>

      <div className="flex justify-center gap-4 mb-8">
        <button
          onClick={() => {
            setActiveTab("upcoming");
            setCurrentPage(1);
          }}
          className={`px-6 py-2 rounded-full border transition-all font-medium text-sm md:text-base
            ${activeTab === "upcoming" ? "bg-primary-900 text-white shadow" : "bg-white border-gray-300 text-gray-700 hover:bg-gray-100"}`}
        >
          Cuộc hẹn sắp tới
        </button>

        <button
          onClick={() => {
            setActiveTab("history");
            setCurrentPage(1);
          }}
          className={`px-6 py-2 rounded-full border transition-all font-medium text-sm md:text-base
            ${activeTab === "history" ? "bg-primary-900 text-white shadow" : "bg-white border-gray-300 text-gray-700 hover:bg-gray-100"}`}
        >
          Lịch sử cuộc hẹn
        </button>
      </div>

      {loading ? (
        <div className="text-center text-gray-500">Đang tải dữ liệu...</div>
      ) : (
        <div className="space-y-10">
          {activeTab === "upcoming" && (
            <section>
              <h2 className="text-xl font-semibold text-primary-900 mb-3 text-center">
                Danh sách cuộc hẹn sắp tới
              </h2>
              {renderTable(currentData)}
            </section>
          )}

          {activeTab === "history" && (
            <section>
              <h2 className="text-xl font-semibold text-primary-900 mb-3 text-center">
                Lịch sử cuộc hẹn
              </h2>
              {renderTable(currentData, true)}
            </section>
          )}
        </div>
      )}
    </div>
  );
};

export default CustomerAppointment;
