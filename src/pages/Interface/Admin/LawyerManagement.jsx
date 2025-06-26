import { useState, useEffect } from "react";
import api from "../../../config/axios";

const LawyerManagement = () => {
  const [lawyers, setLawyers] = useState([]);
  const [selectedLawyer, setSelectedLawyer] = useState(null);
  const [slots, setSlots] = useState([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [newSlot, setNewSlot] = useState({
    dayOfWeek: "",
    slot: "",
  });

  const buttonStyle = "bg-primary-700 text-white px-4 py-2 rounded hover:bg-primary-800 transition";

  const daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
  const slotOptions = ["1", "2", "3", "4"];

  const handleSearch = async () => {
    if (!selectedLawyer?.lawyerProfile?.id) {
      setError("Vui lòng chọn luật sư");
      return;
    }
    setLoading(true);
    setError("");
    try {
      const res = await api.lawyer.get(`/api/lawyers/${selectedLawyer.lawyerProfile.id}/workslots`);
      setSlots(res.data.result || res.data);
    } catch (err) {
      setSlots([]);
      setError("Không tìm thấy ca làm hoặc lỗi server.");
    }
    setLoading(false);
  };

  const handleCreate = async () => {
    if (!selectedLawyer?.lawyerProfile?.id || !newSlot.dayOfWeek || !newSlot.slot) {
      setError("Vui lòng nhập đầy đủ thông tin.");
      return;
    }
    setError("");
    try {
      await api.lawyer.post(`/api/lawyers/${selectedLawyer.lawyerProfile.id}/workslots`, { ...newSlot, isActive: true });
      setNewSlot({ dayOfWeek: "", slot: "" });
      handleSearch();
    } catch {
      setError("Tạo ca làm thất bại!");
    }
  };

  const handleDelete = async (slotId) => {
    if (!selectedLawyer?.lawyerProfile?.id) {
      setError("Không tìm thấy thông tin luật sư");
      return;
    }
    try {
      await api.lawyer.delete(`/api/lawyers/${selectedLawyer.lawyerProfile.id}/workslots/${slotId}`);
      setSlots((prev) => prev.filter((s) => s.id !== slotId));
    } catch {
      setError("Xóa ca làm thất bại!");
    }
  };

  const handleEdit = async (slot) => {
    if (!selectedLawyer?.lawyerProfile?.id) {
      setError("Không tìm thấy thông tin luật sư");
      return;
    }
    try {
      await api.lawyer.put(`/api/lawyers/${selectedLawyer.lawyerProfile.id}/workslots/`, { ...slot, isActive: true });
      handleSearch();
    } catch {
      setError("Cập nhật ca làm thất bại!");
    }
  };

  useEffect(() => {
    const fetchLawyers = async () => {
      try {
        const response = await api.auth.get('/api/UserWithLawyerProfile/only-lawyers'); // Adjust the API endpoint
        console.log('Lawyers data:', response.data);
        const lawyersData = response.data.result || response.data || [];
        setLawyers(lawyersData);
        if (lawyersData.length > 0) {
          console.log('First lawyer structure:', lawyersData[0]);
        }
      } catch (error) {
        console.error('Error fetching lawyers:', error);
      }
    };
    fetchLawyers();
  }, []);

  useEffect(() => {
    setSlots([]);
  }, [selectedLawyer]);

  return (
    <div className="max-w-4xl mx-auto py-8 px-4">
      <h2 className="text-3xl md:text-4xl uppercase font-bold text-center mt-10 mb-8 tracking-wider">
        Quản lý ca làm luật sư
      </h2>
      <div className="flex flex-col sm:flex-row gap-3 mb-6 justify-center items-center">
        <select
          value={selectedLawyer?.lawyerProfile?.id || ''}
          onChange={(e) => {
            const selectedId = e.target.value;
            const lawyer = lawyers.find(l => String(l.lawyerProfile?.id) === String(selectedId));
            console.log('Selected ID:', selectedId);
            console.log('Found lawyer:', lawyer);
            setSelectedLawyer(lawyer);
          }}
          className="border px-2 py-2 rounded w-full sm:w-auto"
        >
          <option value="" disabled>
            Chọn luật sư
          </option>
          {Array.isArray(lawyers) && lawyers.length > 0 ? (
            lawyers.map((lawyer) => (
              lawyer?.lawyerProfile?.id ? (
                <option key={lawyer.lawyerProfile.id} value={lawyer.lawyerProfile.id}>
                  {lawyer.user?.fullName || 'Unnamed Lawyer'}
                </option>
              ) : null
            ))
          ) : (
            <option value="">No lawyers available</option>
          )}
        </select>
        <button onClick={handleSearch} className={buttonStyle}>
          Tìm
        </button>
      </div>
      {error && <div className="text-red-600 mb-2 text-center">{error}</div>}
      <div className="mb-6 flex flex-col items-center">
        <h3 className="text-xl font-bold mb-2">Tạo ca làm mới</h3>
        <div className="flex flex-col sm:flex-row gap-2 items-center">
          <select
            value={newSlot.dayOfWeek}
            onChange={(e) =>
              setNewSlot((s) => ({ ...s, dayOfWeek: e.target.value }))
            }
            className="border px-2 py-2 rounded w-full sm:w-auto"
          >
            <option value="">Chọn Thứ</option>
            {daysOfWeek.map((day) => (
              <option key={day} value={day}>{day}</option>
            ))}
          </select>
          <select
            value={newSlot.slot}
            onChange={(e) =>
              setNewSlot((s) => ({ ...s, slot: e.target.value }))
            }
            className="border px-2 py-2 rounded w-full sm:w-auto"
          >
            <option value="">Chọn Slot</option>
            {slotOptions.map((s) => (
              <option key={s} value={s}>{s}</option>
            ))}
          </select>
          <button onClick={handleCreate} className={buttonStyle}>
            Tạo
          </button>
        </div>
      </div>
      {loading ? (
        <p className="text-center">Đang tải...</p>
      ) : (
        <div className="overflow-x-auto">
          <table className="min-w-full border rounded-lg overflow-hidden text-center">
            <thead>
              <tr className="bg-gray-100">
                <th className="border px-4 py-2">Ngày</th>
                <th className="border px-4 py-2">Slot</th>
                <th className="border px-4 py-2">Thao tác</th>
              </tr>
            </thead>
            <tbody>
              {slots.map((slot) => (
                <tr key={slot.id}>
                  <td className="border px-2 py-2">
                    <select
                      value={slot.dayOfWeek}
                      onChange={(e) =>
                        setSlots((prev) =>
                          prev.map((s) =>
                            s.id === slot.id
                              ? { ...s, dayOfWeek: e.target.value }
                              : s
                          )
                        )
                      }
                      className="border px-2 py-1 rounded w-full sm:w-28"
                    >
                      {daysOfWeek.map((day) => (
                        <option key={day} value={day}>{day}</option>
                      ))}
                    </select>
                  </td>
                  <td className="border px-2 py-2">
                    <select
                      value={slot.slot}
                      onChange={(e) =>
                        setSlots((prev) =>
                          prev.map((s) =>
                            s.id === slot.id
                              ? { ...s, slot: e.target.value }
                              : s
                          )
                        )
                      }
                      className="border px-2 py-1 rounded w-full sm:w-12"
                    >
                      {slotOptions.map((s) => (
                        <option key={s} value={s}>{s}</option>
                      ))}
                    </select>
                  </td>
                  <td className="border px-2 py-2 flex gap-2 justify-center">
                    <button
                      onClick={() => handleEdit(slot)}
                      className={buttonStyle}
                    >
                      Lưu
                    </button>
                    <button
                      onClick={() => handleDelete(slot.id)}
                      className={buttonStyle}
                    >
                      Xóa
                    </button>
                  </td>
                </tr>
              ))}
              {slots.length === 0 && (
                <tr>
                  <td colSpan={3} className="text-center py-4">
                    Không có ca làm nào.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
};

export default LawyerManagement;
