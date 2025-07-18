import { useEffect, useState } from "react";
import api from "../../../config/axios";
import { format, parseISO } from "date-fns";
import vi from "date-fns/locale/vi";
import { ChevronLeft, ChevronRight } from "lucide-react";
// import { useNavigate } from "react-router-dom";

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
  // const navigate = useNavigate();

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
        const aDate = getDateTime(a);
        const bDate = getDateTime(b);
        return tab === "upcoming" ? aDate - bDate : bDate - aDate;
      });
  };

  const paginated = (data) => {
    const start = (currentPage - 1) * PAGE_SIZE;
    return data.slice(start, start + PAGE_SIZE);
  };

  // const renderTable = (data, isHistory = false) => {
  //   const pagedData = paginated(data);
  //   const totalPages = Math.ceil(data.length / PAGE_SIZE);
  // };


  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-primary-700"></div>
      </div>
    );
  }
  return (
    <div className="p-6 max-w-7xl mx-auto">
      <h1 className="text-4xl font-bold text-primary-900 text-center mb-10">LỊCH HẸN CỦA BẠN</h1>

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
        <div className="mt-8 bg-white rounded-lg shadow-md overflow-hidden">
          <div className="bg-primary-700 px-6 py-4">
            <h2 className="text-2xl font-bold text-white">
              {activeTab === "upcoming" ? "Cuộc hẹn sắp tới" : "Lịch sử cuộc hẹn"}
            </h2>
          </div>

          <div className="p-6">
            <div className="flex flex-col">
              <div className="-my-2 overflow-x-auto sm:-mx-6 lg:-mx-8">
                <div className="py-2 align-middle inline-block min-w-full sm:px-6 lg:px-8">
                  <div className="shadow overflow-hidden border-b border-gray-200 sm:rounded-lg">
                    <table className="min-w-full divide-y divide-gray-200">
                      <thead className="bg-gray-50">
                        <tr>
                          <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                            Luật sư
                          </th>
                          <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                            Ngày
                          </th>
                          <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                            Dịch vụ
                          </th>
                          <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                            Trạng thái
                          </th>
                        </tr>
                      </thead>
                      <tbody className="bg-white divide-y divide-gray-200">
                        {paginated(filteredAppointments(activeTab)).map((app) => (
                          <tr key={app.id}>
                            <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                              {lawyerMap[app.lawyerId] || "Chưa xác định"}
                            </td>
                            <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                              {format(parseISO(`${app.scheduledAt.slice(0, 10)}T${app.slot}:00`), "EEEE, dd/MM/yyyy", { locale: vi })}
                            </td>
                            <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                              {app.services?.join(", ")}
                            </td>
                            <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                              <span className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${statusMap[app.status].color} bg-${statusMap[app.status].color.split('-')[1]}-100`}>
                                {statusMap[app.status].label}
                              </span>
                            </td>
                          </tr>
                        ))}
                        {paginated(filteredAppointments(activeTab)).length === 0 && (
                          <tr>
                            <td colSpan="4" className="px-6 py-4 text-center text-sm text-gray-500">
                              {activeTab === "upcoming" ? "Không có cuộc hẹn sắp tới." : "Chưa có lịch sử cuộc hẹn."}
                            </td>
                          </tr>
                        )}
                      </tbody>
                    </table>
                  </div>
                </div>
              </div>
            </div>

            {filteredAppointments(activeTab).length > PAGE_SIZE && (
              <div className="mt-4 flex justify-center">
                <nav className="relative z-0 inline-flex rounded-md shadow-sm -space-x-px" aria-label="Pagination">
                  <button
                    onClick={() => setCurrentPage((prev) => Math.max(prev - 1, 1))}
                    className="relative inline-flex items-center px-2 py-2 rounded-l-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50"
                  >
                    <span className="sr-only">Previous</span>
                    <ChevronLeft className="h-5 w-5" aria-hidden="true" />
                  </button>
                  <span className="relative inline-flex items-center px-4 py-2 border border-gray-300 bg-white text-sm font-medium text-gray-700">
                    Page {currentPage} of {Math.ceil(filteredAppointments(activeTab).length / PAGE_SIZE)}
                  </span>
                  <button
                    onClick={() => setCurrentPage((prev) => Math.min(prev + 1, Math.ceil(filteredAppointments(activeTab).length / PAGE_SIZE)))}
                    className="relative inline-flex items-center px-2 py-2 rounded-r-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50"
                  >
                    <span className="sr-only">Next</span>
                    <ChevronRight className="h-5 w-5" aria-hidden="true" />
                  </button>
                </nav>
              </div>
            )}


          </div>
        </div>
      )}
    </div>
  );
};

export default CustomerAppointment;