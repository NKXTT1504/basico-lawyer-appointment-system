import { useEffect, useState } from "react";
import api from "../../../config/axios";
import { format, parseISO } from "date-fns";
import vi from "date-fns/locale/vi";
import { ChevronLeft, ChevronRight } from "lucide-react";

const ManageAppointment = () => {
  const [appointments, setAppointments] = useState([]);
  const [currentPage, setCurrentPage] = useState(1);
  const [selectedStatus, setSelectedStatus] = useState('ALL');
  const itemsPerPage = 5;

  const user = JSON.parse(localStorage.getItem("user") || "{}");
  const lawyerId = user?.lawyerId || user?.id;

  useEffect(() => {
    if (!lawyerId) return;

    const fetchAppointments = async () => {
      try {
        const res = await api.appointment.get(`/api/AppointmentWithUserLawyer/by-lawyer/${lawyerId}`);
        setAppointments(Array.isArray(res.data) ? res.data : []);
      } catch (err) {
        console.error("Error fetching appointments:", err);
        setAppointments([]);
      }
    };

    fetchAppointments();
  }, [lawyerId]);

  const handleStatusChange = (id, newStatus) => {
    let url = '';

    switch (newStatus) {
      case 1:
        url = `/api/Appointment/${id}/confirm`;
        break;
      case 2:
        url = `/api/Appointment/${id}/cancel`;
        break;
      case 3:
        url = `/api/Appointment/${id}/complete`;
        break;
      default:
        console.error(`Trạng thái không hỗ trợ: ${newStatus}`);
        return;
    }

    api.appointment.put(url)
      .then(() => {
        setAppointments(prev =>
          prev.map(app =>
            app.id === id ? { ...app, status: newStatus } : app
          )
        );
      })
      .catch(err => {
        console.error(`Lỗi khi cập nhật trạng thái ${newStatus}:`, err);
      });
  };

  const filteredAppointments = appointments
    .slice()
    .sort((a, b) => new Date(b.scheduledAt) - new Date(a.scheduledAt)) // Mới nhất lên trước
    .filter(app => {
      if (selectedStatus === 'ALL') return true;
      return app.status === parseInt(selectedStatus);
    });

  const totalPages = Math.ceil(filteredAppointments.length / itemsPerPage);
  const paginatedAppointments = filteredAppointments.slice(
    (currentPage - 1) * itemsPerPage,
    currentPage * itemsPerPage
  );

  return (
    <div className="p-4">
      <h1 className="text-4xl font-bold text-center mt-10 text-primary">Danh sách cuộc hẹn</h1>

      {/* Filter */}
      <div className="mb-4 mt-6 flex justify-center items-center">
        <label className="mr-2 font-bold text-xl">Tìm kiếm:</label>
        <select
          value={selectedStatus}
          onChange={(e) => {
            setSelectedStatus(e.target.value);
            setCurrentPage(1);
          }}
          className="border p-1 rounded"
        >
          <option value="ALL">Tất cả</option>
          <option value="0">Đang chờ</option>
          <option value="1">Đã xác nhận</option>
          <option value="2">Đã hủy</option>
          <option value="3">Hoàn thành</option>
        </select>
      </div>

      {/* Table */}
      <div className="overflow-x-auto">
        <table className="min-w-full bg-white border border-gray-300 mt-4">
          <thead>
            <tr className="bg-gray-100 text-gray-700">
              <th className="py-2 px-4 border">STT</th>
              <th className="py-2 px-4 border">Khách hàng</th>
              <th className="py-2 px-4 border">Thời gian bắt đầu</th>
              <th className="py-2 px-4 border">Dịch vụ</th>
              <th className="py-2 px-4 border">Trạng thái</th>
              <th className="py-2 px-4 border">Hành động</th>
            </tr>
          </thead>
          <tbody>
            {paginatedAppointments.map((app, index) => {
              const slot = app.slot;
              const scheduledAt = app.scheduledAt;
              const dateTimeStr = `${scheduledAt.slice(0, 10)}T${slot}:00`;
              const dateObj = parseISO(dateTimeStr);
              const formatted = `${slot}, ${format(dateObj, "EEEE, dd/MM/yyyy", { locale: vi })}`;

              return (
                <tr key={app.id} className="text-center">
                  <td className="py-2 px-4 border">{(currentPage - 1) * itemsPerPage + index + 1}</td>
                  <td className="py-2 px-4 border">{app.user.fullName}</td>
                  <td className="py-2 px-4 border">{formatted}</td>
                  <td className="py-2 px-4 border">{app.services.join(", ")}</td>
                  <td className="py-2 px-4 border">
                    {app.status === 0 && <span>Đang chờ</span>}
                    {app.status === 1 && <span className="text-green-600">Đã xác nhận</span>}
                    {app.status === 2 && <span className="text-red-600 font-bold">Đã hủy</span>}
                    {app.status === 3 && <span className="text-green-600 font-bold">Hoàn thành</span>}
                  </td>
                  <td className="py-2 px-4 border space-x-2">
                    {app.status === 0 && (
                      <>
                        <button
                          className="bg-primary-900 text-white py-1 px-3 rounded hover:opacity-80"
                          onClick={() => handleStatusChange(app.id, 1)}
                        >
                          Duyệt
                        </button>
                        <button
                          className="bg-red-600 text-white py-1 px-3 rounded hover:opacity-80 ml-2"
                          onClick={() => handleStatusChange(app.id, 2)}
                        >
                          Hủy
                        </button>
                      </>
                    )}
                    {app.status === 1 && (
                      <button
                        className="bg-primary-900 text-white py-1 px-3 rounded hover:opacity-80"
                        onClick={() => handleStatusChange(app.id, 3)}
                      >
                        Hoàn thành
                      </button>
                    )}
                  </td>
                </tr>
              );
            })}
            {paginatedAppointments.length === 0 && (
              <tr>
                <td colSpan="6" className="py-4 text-gray-500 text-center">
                  Không có cuộc hẹn nào.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

      {/* Pagination */}
      <div className="flex justify-center items-center mt-6 gap-4">
        <button
          onClick={() => setCurrentPage((p) => Math.max(1, p - 1))}
          disabled={currentPage === 1}
          className="p-2 rounded border bg-white hover:bg-gray-100 disabled:opacity-50"
        >
          <ChevronLeft className="w-4 h-4" />
        </button>
        <span className="text-sm font-medium">
          Trang {currentPage} / {totalPages}
        </span>
        <button
          onClick={() => setCurrentPage((p) => Math.min(totalPages, p + 1))}
          disabled={currentPage === totalPages}
          className="p-2 rounded border bg-white hover:bg-gray-100 disabled:opacity-50"
        >
          <ChevronRight className="w-4 h-4" />
        </button>
      </div>
    </div>
  );
};

export default ManageAppointment;