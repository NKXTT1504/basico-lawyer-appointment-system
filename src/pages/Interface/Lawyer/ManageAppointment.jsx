import { useEffect, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import api from "../../../config/axios";

const ManageAppointment = () => {
  const [appointments, setAppointments] = useState([]);

  useEffect(() => {
    const fetchAppointments = async () => {
      const res = await api.appointment.get('/api/appointments');
      const appointments = Array.isArray(res.data)
        ? res.data
        : Array.isArray(res.data.result)
          ? res.data.result
          : [];
      setAppointments(appointments);
    };
    fetchAppointments();
  }, []);

  const handleStatusChange = (id, newStatus) => {
    let url = '';

    switch (newStatus) {
      case 'APPROVED':
        url = `/api/Appointment/${id}/confirm`;
        break;
      case 'CANCELLED':
        url = `/api/Appointment/${id}/cancel`;
        break;
      case 'DONE':
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

  return (
    <div className="p-4">
      <h1 className="text-4xl font-bold text-center mt-10 text-primary">Danh sách cuộc hẹn</h1>
      <div className="overflow-x-auto">
        <table className="min-w-full bg-white border border-gray-300 mt-10">
          <thead>
            <tr className="bg-gray-100 text-gray-700">
              <th className="py-2 px-4 border">STT</th>
              <th className="py-2 px-4 border">Khách hàng</th>
              <th className="py-2 px-4 border">Thời gian bắt đầu</th>
              <th className="py-2 px-4 border">Thời gian kết thúc</th>
              <th className="py-2 px-4 border">Trạng thái</th>
              <th className="py-2 px-4 border">Hành động</th>
            </tr>
          </thead>
          <tbody>
            {appointments.map((app, index) => (
              <tr key={app.id} className="text-center">
                <td className="py-2 px-4 border">{index + 1}</td>
                <td className="py-2 px-4 border">{app.customerName}</td>
                <td className="py-2 px-4 border">{app.startTime}</td>
                <td className="py-2 px-4 border">{app.endTime}</td>
                <td className="py-2 px-4 border">{app.status}</td>
                <td className="py-2 px-4 border space-x-2">
                  {app.status === 'PENDING' && (
                    <>
                      <button
                        className="text-green-600 hover:underline"
                        onClick={() => handleStatusChange(app.id, 'APPROVED')}
                      >
                        Approve
                      </button>
                      <button
                        className="text-red-600 hover:underline"
                        onClick={() => handleStatusChange(app.id, 'CANCELLED')}
                      >
                        Cancel
                      </button>
                    </>
                  )}
                  {app.status === 'IN_PROGRESS' && (
                    <button
                      className="text-blue-600 hover:underline"
                      onClick={() => handleStatusChange(app.id, 'DONE')}
                    >
                      Hoàn thành
                    </button>
                  )}
                </td>
              </tr>
            ))}
            {appointments.length === 0 && (
              <tr>
                <td colSpan="6" className="py-4 text-gray-500 text-center">
                  Không có cuộc hẹn nào.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default ManageAppointment;
