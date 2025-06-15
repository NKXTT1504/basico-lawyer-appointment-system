import React, { useState } from "react";
import api from "../../../config/axios";

const LawyerManagement = () => {
  const [lawyerId, setLawyerId] = useState("");
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
    setLoading(true);
    setError("");
    try {
      const res = await api.lawyer.get(`/api/lawyers/${lawyerId}/workslots`);
      setSlots(res.data.result || res.data);
    } catch (err) {
      setSlots([]);
      setError("Không tìm thấy ca làm hoặc lỗi server.");
    }
    setLoading(false);
  };

  const handleCreate = async () => {
    if (!lawyerId || !newSlot.dayOfWeek || !newSlot.slot) {
      setError("Vui lòng nhập đầy đủ thông tin.");
      return;
    }
    setError("");
    try {
      await api.lawyer.post(`/api/lawyers/${lawyerId}/workslots`, { ...newSlot, isActive: true });
      setNewSlot({ dayOfWeek: "", slot: "" });
      handleSearch();
    } catch {
      setError("Tạo ca làm thất bại!");
    }
  };

  const handleDelete = async  (lawyerId, slotId) => {
    try {
      await api.lawyer.delete(`/api/lawyers/${lawyerId}/workslots/${slotId}`);
      setSlots((prev) => prev.filter((s) => s.id !== slotId));
    } catch {
      setError("Xóa ca làm thất bại!");
    }
  };

  const handleEdit = async (slot) => {
    try {
      await api.lawyer.put(`/api/lawyers/${lawyerId}/workslots/`, { ...slot, isActive: true });
      handleSearch();
    } catch {
      setError("Cập nhật ca làm thất bại!");
    }
  };

  return (
    <div className="max-w-4xl mx-auto py-8 px-4">
      <h2 className="text-3xl md:text-4xl uppercase font-bold text-center mt-10 mb-8 tracking-wider">
        Quản lý ca làm luật sư
      </h2>
      <div className="flex flex-col sm:flex-row gap-3 mb-6 justify-center items-center">
        <input
          type="text"
          placeholder="Nhập Lawyer ID"
          value={lawyerId}
          onChange={(e) => setLawyerId(e.target.value)}
          className="border px-2 py-2 rounded w-full sm:w-auto"
        />
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
                      onClick={() => handleDelete(lawyerId, slot.id)}
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
