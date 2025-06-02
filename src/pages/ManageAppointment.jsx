import { useEffect, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import api from "../config/axios";

const ManageAppointment = () => {
  const { appointmentId } = useParams();
  const navigate = useNavigate();
  const [appointment, setAppointment] = useState(null);
  const [error, setError] = useState(null);
  const [loading, setLoading] = useState(true);
  const [appointments, setAppointments] = useState([]);
  const [filterStatus, setFilterStatus] = useState('all');

  useEffect(() => {
    api.get('/api/appointments')
      .then(res => setAppointments(res.data))
      .catch(err => console.error(err));
  }, []);

  const filteredAppointments =
    filterStatus === 'all'
      ? appointments
      : appointments.filter(app => app.status === filterStatus);

  const handleStatusChange = (id, newStatus) => {
    api.put(`/api/appointments/${id}/status`, { status: newStatus })
      .then(() => {
        setAppointments(prev =>
          prev.map(app =>
            app.id === id ? { ...app, status: newStatus } : app
          )
        );
      })
      .catch(err => console.error(err));
  };

  return (
    <main className="p-6">
      <div className="container mx-auto px-4 text-center">
        <h1 className="text-4xl font-bold mt-10">QUẢN LÍ CUỘC HẸN</h1>
      </div>

      {/* Filter buttons */}
      <div className="mt-10 flex-wrap flex justify-center items-center gap-10">
        {['all', 'PENDING', 'APPROVED', 'IN_PROGRESS', 'DONE', 'CANCELLED'].map(status => (
          <button
            key={status}
            className={`px-4 py-2 rounded-md text-sm font-medium border 
              ${filterStatus === status
                ? 'bg-primary-700 text-white'
                : 'text-gray-700 hover:bg-gray-100'}`}
            onClick={() => setFilterStatus(status)}
          >
            {status === 'all' ? 'TẤT CẢ' :
              status === 'PENDING' ? 'ĐANG CHỜ' :
              status === 'APPROVED' ? 'ĐÃ DUYỆT' :
              status === 'IN_PROGRESS' ? 'ĐANG DIỄN RA' :
              status === 'DONE' ? 'HOÀN THÀNH' :
              status === 'CANCELLED' ? 'BỊ HỦY' : status}
          </button>
        ))}
      </div>

      {/* Appointment table */}
      <div className="mt-10 overflow-x-auto">
        <table className="w-full table-auto border-collapse border border-gray-200">
          <thead>
            <tr className="bg-gray-100">
              <th className="border p-2">Khách hàng</th>
              <th className="border p-2">Dịch vụ</th>
              <th className="border p-2">Ngày</th>
              <th className="border p-2">Thời gian</th>
              <th className="border p-2">Trạng thái</th>
              <th className="border p-2">Thao tác</th>
            </tr>
          </thead>
          <tbody>
            {filteredAppointments.map(app => (
              <tr key={app.id} className="hover:bg-gray-50">
                <td className="border p-2">{app.customerName}</td>
                <td className="border p-2">{app.serviceName}</td>
                <td className="border p-2">{app.date}</td>
                <td className="border p-2">{app.time}</td>
                <td className="border p-2">{app.status}</td>
                <td className="border p-2 flex gap-2">
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
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </main>
  );
};

export default ManageAppointment;
