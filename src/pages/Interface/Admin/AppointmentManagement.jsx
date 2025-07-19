import { useEffect, useState } from "react";
import api from "../../../config/axios";
import * as XLSX from "xlsx";

const statusMap = {
  0: { label: "Chờ xác nhận", color: "text-yellow-600" },
  1: { label: "Đã xác nhận", color: "text-blue-600" },
  2: { label: "Hoàn thành", color: "text-green-600" },
  3: { label: "Đã hủy", color: "text-red-600" },
};

const slotToTime = {
  "1": "08:00 ~ 10:00",
  "2": "10:00 ~ 12:00",
  "3": "13:00 ~ 15:00",
  "4": "15:00 ~ 17:00",
};

const PAGE_SIZE = 5;

const AppointmentManagement = () => {
  const [appointments, setAppointments] = useState([]);
  const [lawyerNames, setLawyerNames] = useState({});
  const [loading, setLoading] = useState(true);
  const [statusFilter, setStatusFilter] = useState("all");
  const [dateFilter, setDateFilter] = useState("");
  const [sortOrder, setSortOrder] = useState("desc");
  const [currentPage, setCurrentPage] = useState(1);

  useEffect(() => {
    const fetchAppointments = async () => {
      setLoading(true);
      try {
        const res = await api.appointment.get("/api/AppointmentWithUserLawyer/GetAllAppointment");
        const data = res.data.result || [];
        setAppointments(data);

        const lawyerIds = [...new Set(data.map(a => a.lawyerProfile?.userId).filter(Boolean))];
        const nameMap = {};

        await Promise.all(
          lawyerIds.map(async (id) => {
            try {
              const res = await api.auth.get(`/api/UserWithLawyerProfile/${id}`);
              nameMap[id] = res.data?.result.user.fullName || "Không rõ tên";
            } catch {
              nameMap[id] = "Không rõ tên";
            }
          })
        );

        setLawyerNames(nameMap);
      } catch {
        setAppointments([]);
      } finally {
        setLoading(false);
      }
    };

    fetchAppointments();
  }, []);

  const filteredAppointments = appointments
    .filter((a) => {
      const matchStatus = statusFilter === "all" || String(a.status) === statusFilter;
      const matchDate = !dateFilter || a.scheduledAt?.slice(0, 10) === dateFilter;
      return matchStatus && matchDate;
    })
    .sort((a, b) => {
      const dateA = new Date(a.scheduledAt);
      const dateB = new Date(b.scheduledAt);
      return sortOrder === "asc" ? dateA - dateB : dateB - dateA;
    });

  const totalPages = Math.ceil(filteredAppointments.length / PAGE_SIZE);
  const paginatedAppointments = filteredAppointments.slice(
    (currentPage - 1) * PAGE_SIZE,
    currentPage * PAGE_SIZE
  );

  useEffect(() => {
    setCurrentPage(1);
  }, [statusFilter, dateFilter, sortOrder]);

  const exportToExcel = () => {
    const data = filteredAppointments.map((app, idx) => ({
      STT: idx + 1,
      "Khách hàng": app.user?.fullName || "Không rõ",
      "Luật sư": lawyerNames[app.lawyerProfile?.userId] || "Không rõ",
      "Ngày": app.scheduledAt?.slice(0, 10) || "N/A",
      "Khung giờ": slotToTime[app.slot] || "Không xác định",
      "Trạng thái": statusMap[app.status]?.label || "Không xác định",
    }));

    const worksheet = XLSX.utils.json_to_sheet(data);
    const workbook = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(workbook, worksheet, "Danh sách cuộc hẹn");
    XLSX.writeFile(workbook, "DanhSachCuocHen.xlsx");
  };

  return (
    <div className="p-6 max-w-7xl mx-auto">
      <h1 className="text-4xl font-bold text-center mt-10 mb-6">QUẢN LÝ CUỘC HẸN</h1>

      <div className="mb-6 flex flex-wrap justify-center gap-6">
        <div className="text-lg">
          <label className="mr-2 font-medium">Trạng thái:</label>
          <select
            className="border rounded px-3 py-2"
            value={statusFilter}
            onChange={(e) => setStatusFilter(e.target.value)}
          >
            <option value="all">Tất cả</option>
            <option value="0">Chờ xác nhận</option>
            <option value="1">Đã xác nhận</option>
            <option value="2">Hoàn thành</option>
            <option value="3">Đã hủy</option>
          </select>
        </div>

        <div className="text-lg">
          <label className="mr-2 font-medium">Ngày:</label>
          <input
            type="date"
            value={dateFilter}
            onChange={(e) => setDateFilter(e.target.value)}
            className="border rounded px-3 py-2"
          />
        </div>

        <div className="text-lg">
          <label className="mr-2 font-medium">Sắp xếp:</label>
          <select
            className="border rounded px-3 py-2"
            value={sortOrder}
            onChange={(e) => setSortOrder(e.target.value)}
          >
            <option value="desc">Mới nhất</option>
            <option value="asc">Cũ nhất</option>
          </select>
        </div>

        <div className="text-lg">
          <button
            onClick={exportToExcel}
            className="bg-primary-700 text-white px-4 py-2 rounded hover:bg-primary-800 transition"
          >
            Xuất Excel
          </button>
        </div>
      </div>

      <div className="bg-white rounded shadow overflow-x-auto">
        <table className="min-w-full divide-y divide-gray-300 text-center text-lg">
          <thead className="bg-gray-100">
            <tr>
              <th className="px-4 py-3">STT</th>
              <th className="px-4 py-3">Khách hàng</th>
              <th className="px-4 py-3">Luật sư</th>
              <th className="px-4 py-3">Ngày</th>
              <th className="px-4 py-3">Khung giờ</th>
              <th className="px-4 py-3">Trạng thái</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr>
                <td colSpan={6} className="text-center py-8 text-gray-500 text-xl">
                  Đang tải dữ liệu...
                </td>
              </tr>
            ) : paginatedAppointments.length === 0 ? (
              <tr>
                <td colSpan={6} className="text-center py-8 text-gray-500 text-xl">
                  Không có cuộc hẹn nào.
                </td>
              </tr>
            ) : (
              paginatedAppointments.map((app, idx) => (
                <tr key={app.id} className="border-b">
                  <td className="px-4 py-3 font-semibold">
                    {(currentPage - 1) * PAGE_SIZE + idx + 1}
                  </td>
                  <td className="px-4 py-3 font-medium">
                    {app.user?.fullName || "Không rõ"}
                  </td>
                  <td className="px-4 py-3 font-medium">
                    {lawyerNames[app.lawyerProfile?.userId] || "Đang tải..."}
                  </td>
                  <td className="px-4 py-3 font-medium">
                    {app.scheduledAt?.slice(0, 10) || "N/A"}
                  </td>
                  <td className="px-4 py-3 font-medium">
                    {slotToTime[app.slot] || "Không xác định"}
                  </td>
                  <td className={`px-4 py-3 font-bold ${statusMap[app.status]?.color}`}>
                    {statusMap[app.status]?.label || "Không xác định"}
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      {totalPages > 1 && (
        <div className="flex justify-center items-center gap-4 mt-6 text-lg">
          <button
            onClick={() => setCurrentPage((p) => Math.max(1, p - 1))}
            disabled={currentPage === 1}
            className="p-2 rounded border bg-white hover:bg-gray-100 disabled:opacity-50"
          >
            &larr;
          </button>
          <span className="font-semibold">
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

export default AppointmentManagement;
