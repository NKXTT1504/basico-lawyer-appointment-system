import { useEffect, useState } from "react";
import api from "../../../config/axios";
import { format, parseISO } from "date-fns";
import vi from "date-fns/locale/vi";
import { ChevronLeft, ChevronRight } from "lucide-react";
import { toast } from "react-toastify"; // Nếu bạn dùng react-toastify để thông báo

const statusMap = {
  0: { label: "Đang chờ", color: "text-yellow-600" },
  1: { label: "Đã xác nhận", color: "text-green-600" },
  2: { label: "Đã hủy", color: "text-red-600 font-bold" },
  3: { label: "Hoàn thành", color: "text-green-700 font-bold" },
};

const PAGE_SIZE = 5;

const slotToTime = {
  "1": "08:00 ~ 10:00",
  "2": "10:00 ~ 12:00",
  "3": "13:00 ~ 15:00",
  "4": "15:00 ~ 17:00",
};

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
      .sort((a, b) => {
        const getDateTime = (app) => {
          if (!app.scheduledAt || !app.slot) return new Date(0);
          return new Date(`${app.scheduledAt}T${app.slot}:00`);
        };
        return tab === "upcoming"
          ? getDateTime(a) - getDateTime(b)
          : getDateTime(b) - getDateTime(a);
      });
  };

  const paginated = (data) => {
    const start = (currentPage - 1) * PAGE_SIZE;
    return data.slice(start, start + PAGE_SIZE);
  };

  // Hàm xử lý hủy cuộc hẹn
  const handleCancel = async (id) => {
    if (!window.confirm("Bạn có chắc chắn muốn hủy cuộc hẹn này?")) return;
    try {
      await api.appointment.put(`/api/Appointment/${id}/cancel`);
      toast?.success?.("Hủy cuộc hẹn thành công!"); // Nếu dùng toast
      // Reload lại danh sách
      setLoading(true);
      const appsRes = await api.appointment.get(`/api/AppointmentWithUserLawyer/by-user/${userId}`);
      setAppointments(Array.isArray(appsRes.data) ? appsRes.data : []);
    } catch (err) {
      toast?.error?.("Hủy cuộc hẹn thất bại!");
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-primary-700"></div>
      </div>
    );
  }

  return (
    <div className="p-6 max-w-7xl mx-auto">
      <h1 className="text-4xl font-extrabold text-primary-900 text-center mb-10">LỊCH HẸN CỦA BẠN</h1>

      <div className="flex justify-center gap-4 mb-8">
        <button
          onClick={() => {
            setActiveTab("upcoming");
            setCurrentPage(1);
          }}
          className={`px-6 py-3 rounded-full border font-bold text-lg transition-all
            ${activeTab === "upcoming" ? "bg-primary-900 text-white shadow" : "bg-white border-gray-300 text-gray-700 hover:bg-gray-100"}`}
        >
          Cuộc hẹn sắp tới
        </button>

        <button
          onClick={() => {
            setActiveTab("history");
            setCurrentPage(1);
          }}
          className={`px-6 py-3 rounded-full border font-bold text-lg transition-all
            ${activeTab === "history" ? "bg-primary-900 text-white shadow" : "bg-white border-gray-300 text-gray-700 hover:bg-gray-100"}`}
        >
          Lịch sử cuộc hẹn
        </button>
      </div>

      <div className="mt-8 bg-white rounded-lg shadow-md overflow-hidden">
        <div className="bg-primary-700 px-6 py-5">
        </div>

        <div className="p-6">
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200 text-base">
              <thead className="bg-gray-100">
                <tr>
                  <th className="px-6 py-4 text-center font-bold text-gray-700 uppercase tracking-wider">Luật sư</th>
                  <th className="px-6 py-4 text-center font-bold text-gray-700 uppercase tracking-wider">Ngày</th>
                  <th className="px-6 py-4 text-center font-bold text-gray-700 uppercase tracking-wider">Dịch vụ</th>
                  <th className="px-6 py-4 text-center font-bold text-gray-700 uppercase tracking-wider">Trạng thái</th>
                  <th className="px-6 py-4 text-center font-bold text-gray-700 uppercase tracking-wider">Thao tác</th> {/* Thêm cột thao tác */}
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {paginated(filteredAppointments(activeTab)).map((app) => (
                  <tr key={app.id}>
                    <td className="px-6 py-4 text-center font-bold text-gray-900">
                      {lawyerMap[app.lawyerId] || "Chưa xác định"}
                    </td>
                    <td className="px-6 py-4 text-center font-bold text-gray-700">
                      {(() => {
                        const timeRange = slotToTime[app.slot];
                        if (!app.scheduledAt || !timeRange) return "Không xác định";
                        const startTime = timeRange.split("~")[0].trim();
                        const dateStr = `${app.scheduledAt.slice(0, 10)}T${startTime}:00`;
                        const dateObj = parseISO(dateStr);
                        return !isNaN(dateObj)
                          ? `${timeRange}, ${format(dateObj, "EEEE, dd/MM/yyyy", { locale: vi })}`
                          : "Không xác định";
                      })()}
                    </td>
                    <td className="px-6 py-4 text-center font-bold text-gray-700">
                      {app.services?.join(", ")}
                    </td>
                    <td className="px-6 py-4 text-center font-bold">
                      <span className={`px-3 py-1 inline-flex text-base font-bold rounded-full ${statusMap[app.status].color}`}>
                        {statusMap[app.status].label}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-center font-bold">
                      {(activeTab === "upcoming" && (app.status === 0 || app.status === 1)) ? (
                        <button
                          onClick={() => handleCancel(app.id)}
                          className="px-3 py-1 bg-red-500 text-white rounded hover:bg-red-600 transition"
                        >
                          Hủy
                        </button>
                      ) : (
                        <span className="text-gray-400">-</span>
                      )}
                    </td>
                  </tr>
                ))}
                {paginated(filteredAppointments(activeTab)).length === 0 && (
                  <tr>
                    <td colSpan="5" className="px-6 py-6 text-center text-base text-gray-500 font-semibold">
                      {activeTab === "upcoming" ? "Không có cuộc hẹn sắp tới." : "Chưa có lịch sử cuộc hẹn."}
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>

          {filteredAppointments(activeTab).length > PAGE_SIZE && (
            <div className="mt-6 flex justify-center">
              <nav className="inline-flex shadow-sm" aria-label="Pagination">
                <button
                  onClick={() => setCurrentPage((prev) => Math.max(prev - 1, 1))}
                  className="px-3 py-2 border border-gray-300 bg-white text-base font-bold text-gray-500 hover:bg-gray-100 rounded-l-md"
                >
                  <ChevronLeft className="h-5 w-5" />
                </button>
                <span className="px-4 py-2 border border-gray-300 bg-white text-base font-bold text-gray-700">
                  Trang {currentPage} / {Math.ceil(filteredAppointments(activeTab).length / PAGE_SIZE)}
                </span>
                <button
                  onClick={() => setCurrentPage((prev) => Math.min(prev + 1, Math.ceil(filteredAppointments(activeTab).length / PAGE_SIZE)))}
                  className="px-3 py-2 border border-gray-300 bg-white text-base font-bold text-gray-500 hover:bg-gray-100 rounded-r-md"
                >
                  <ChevronRight className="h-5 w-5" />
                </button>
              </nav>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default CustomerAppointment;
