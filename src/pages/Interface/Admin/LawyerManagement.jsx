import { useState, useEffect } from "react";
import * as XLSX from "xlsx";
import api from "../../../config/axios";
import { FaBan } from 'react-icons/fa';

const PAGE_SIZE = 5;

const daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
const slotOptions = ["1", "2", "3", "4"];
const buttonStyle = "bg-primary-700 text-white px-4 py-2 rounded hover:bg-primary-800 transition";

const LawyerManagement = () => {
  const [lawyers, setLawyers] = useState([]);
  const [selectedLawyer, setSelectedLawyer] = useState(null);
  const [slots, setSlots] = useState([]);
  const [filteredSlots, setFilteredSlots] = useState([]);
  const [dayFilter, setDayFilter] = useState("");
  const [newSlot, setNewSlot] = useState({ dayOfWeek: "", slot: "" });
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const [currentPage, setCurrentPage] = useState(1);

  const handleSearch = async () => {
    if (!selectedLawyer?.lawyerProfile?.id) {
      setError("Vui lòng chọn luật sư");
      return;
    }
    setLoading(true);
    setError("");
    try {
      const res = await api.lawyer.get(`/api/lawyers/${selectedLawyer.lawyerProfile.id}/workslots`);
      const sorted = [...(res.data.result || res.data || [])].sort((a, b) => {
        const dayA = daysOfWeek.indexOf(a.dayOfWeek);
        const dayB = daysOfWeek.indexOf(b.dayOfWeek);
        return dayA === dayB ? a.slot - b.slot : dayA - dayB;
      });
      setSlots(sorted);
    } catch {
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
    try {
      await api.lawyer.post(`/api/lawyers/${selectedLawyer.lawyerProfile.id}/workslots`, {
        ...newSlot,
        isActive: true,
      });
      setNewSlot({ dayOfWeek: "", slot: "" });
      handleSearch();
    } catch {
      setError("Tạo ca làm thất bại!");
    }
  };

  const handleDelete = async (slotId) => {
    try {
      await api.lawyer.delete(`/api/lawyers/${selectedLawyer.lawyerProfile.id}/workslots/${slotId}`);
      setSlots((prev) => prev.filter((s) => s.id !== slotId));
    } catch {
      setError("Xóa ca làm thất bại!");
    }
  };

  const handleEdit = async (slot) => {
    try {
      await api.lawyer.put(`/api/lawyers/${selectedLawyer.lawyerProfile.id}/workslots/${slot.id}`, {
        id: slot.id,
        dayOfWeek: slot.dayOfWeek,
        slot: slot.slot,
        isActive: true,
        lawyerId: selectedLawyer.lawyerProfile.id,
      });
      handleSearch();
    } catch {
      setError("Cập nhật ca làm thất bại!");
    }
  };

  const exportToExcel = () => {
    const data = filteredSlots.map((s) => ({
      "Thứ": s.dayOfWeek,
      "Slot": s.slot,
    }));
    const worksheet = XLSX.utils.json_to_sheet(data);
    const workbook = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(workbook, worksheet, "CaLam");
    XLSX.writeFile(workbook, `calam-${selectedLawyer?.user?.fullName || "lawyer"}.xlsx`);
  };

  useEffect(() => {
    const fetchLawyers = async () => {
      try {
        const res = await api.auth.get('/api/UserWithLawyerProfile/only-lawyers');
        setLawyers(res.data.result || []);
      } catch {
        setLawyers([]);
      }
    };
    fetchLawyers();
  }, []);

  useEffect(() => {
    const filtered = dayFilter ? slots.filter(s => s.dayOfWeek === dayFilter) : slots;
    setFilteredSlots(filtered);
    setCurrentPage(1);
  }, [dayFilter, slots]);

  useEffect(() => {
    if (selectedLawyer?.lawyerProfile?.id) {
      handleSearch();
    } else {
      setSlots([]);
      setFilteredSlots([]);
      setDayFilter("");
    }
  }, [selectedLawyer]);


  const totalPages = Math.ceil(filteredSlots.length / PAGE_SIZE);
  const paginatedSlots = filteredSlots.slice((currentPage - 1) * PAGE_SIZE, currentPage * PAGE_SIZE);

  return (
    <div className="max-w-4xl mx-auto py-8 px-4">
      <h2 className="text-3xl md:text-4xl uppercase font-bold text-center mt-10 mb-8 tracking-wider">
        QUẢN LÍ CA LÀM CỦA LUẬT SƯ
      </h2>

      <div className="flex flex-wrap gap-3 mb-6 justify-center items-center">
        <select
          value={selectedLawyer?.lawyerProfile?.id || ''}
          onChange={(e) => {
            const id = e.target.value;

            if (!id) {
              setSelectedLawyer(null);
              setSlots([]);
              setFilteredSlots([]);
              setDayFilter("");
              return;
            }

            const lawyer = lawyers.find(l => String(l.lawyerProfile?.id) === id);
            setSelectedLawyer(lawyer);
          }}
          className="border px-3 py-2 rounded"
        >
          <option value="">Chọn luật sư</option>
          {lawyers.map((l) => (
            <option key={l.lawyerProfile.id} value={l.lawyerProfile.id}>
              {l.user?.fullName}
            </option>
          ))}
        </select>

        <select
          value={dayFilter}
          onChange={(e) => setDayFilter(e.target.value)}
          className="border px-3 py-2 rounded"
        >
          <option value="">Lọc theo ngày</option>
          {daysOfWeek.map((day) => (
            <option key={day} value={day}>{day}</option>
          ))}
        </select>

        {filteredSlots.length > 0 && (
          <button onClick={exportToExcel} className={buttonStyle}>Xuất Excel</button>
        )}
      </div>

      <div className="flex flex-col sm:flex-row justify-center items-center gap-4 mb-4">
        <select
          value={newSlot.dayOfWeek}
          onChange={(e) => setNewSlot({ ...newSlot, dayOfWeek: e.target.value })}
          className="border px-3 py-2 rounded"
        >
          <option value="">Chọn thứ</option>
          {daysOfWeek.map((day) => (
            <option key={day} value={day}>{day}</option>
          ))}
        </select>
        <select
          value={newSlot.slot}
          onChange={(e) => setNewSlot({ ...newSlot, slot: e.target.value })}
          className="border px-3 py-2 rounded"
        >
          <option value="">Chọn slot</option>
          {slotOptions.map((s) => <option key={s} value={s}>{s}</option>)}
        </select>
        <button onClick={handleCreate} className={buttonStyle}>Tạo</button>
      </div>

      {error && <div className="text-red-600 text-center mb-2">{error}</div>}

      <div className="overflow-x-auto">
        <table className="min-w-full border rounded-lg text-center">
          <thead className="bg-gray-100">
            <tr>
              <th className="border px-4 py-2">Thứ</th>
              <th className="border px-4 py-2">Slot</th>
              <th className="border px-4 py-2">Thao tác</th>
            </tr>
          </thead>
          <tbody>
            {paginatedSlots.map((slot) => (
              <tr key={slot.id}>
                <td className="border px-3 py-2">
                  <select
                    value={slot.dayOfWeek}
                    onChange={(e) =>
                      setSlots(prev => prev.map(s => s.id === slot.id ? { ...s, dayOfWeek: e.target.value } : s))
                    }
                    className="border px-2 py-1 rounded"
                  >
                    {daysOfWeek.map(day => <option key={day} value={day}>{day}</option>)}
                  </select>
                </td>
                <td className="border px-3 py-2">
                  <select
                    value={slot.slot}
                    onChange={(e) =>
                      setSlots(prev => prev.map(s => s.id === slot.id ? { ...s, slot: e.target.value } : s))
                    }
                    className="border px-2 py-1 rounded"
                  >
                    {slotOptions.map(s => <option key={s} value={s}>{s}</option>)}
                  </select>
                </td>
                <td className="border px-3 py-2">
                  <div className="flex flex-row items-center justify-center gap-4">
                    {/* Nhóm nút Lưu */}
                    <div>
                      <button
                        onClick={() => handleEdit(slot)}
                        className="bg-primary-700 hover:bg-primary-800 text-white px-4 py-1 rounded-lg shadow transition"
                      >
                        Lưu
                      </button>
                    </div>

                    {/* Nhóm nút Xóa hoặc thông báo */}
                    <div>
                      {slot.isActive ? (
                        <button
                          onClick={() => handleDelete(slot.id)}
                          className="bg-red-600 hover:bg-red-700 text-white px-4 py-1 rounded-lg shadow transition"
                        >
                          Xóa
                        </button>
                      ) : (
                       <FaBan title="Không thể xóa do cuộc hẹn đang diễn ra!" className="text-red-600 w-12 h-8" />
                      )}
                    </div>
                  </div>
                </td>
              </tr>
            ))}
            {paginatedSlots.length === 0 && (
              <tr><td colSpan={3} className="text-center py-4">Không có ca làm nào.</td></tr>
            )}
          </tbody>
        </table>
      </div>

      {totalPages > 1 && (
        <div className="flex justify-center items-center gap-4 mt-6 text-lg">
          <button
            onClick={() => setCurrentPage(p => Math.max(1, p - 1))}
            disabled={currentPage === 1}
            className="p-2 border rounded hover:bg-gray-200 disabled:opacity-50"
          >←</button>
          <span>Trang {currentPage} / {totalPages}</span>
          <button
            onClick={() => setCurrentPage(p => Math.min(totalPages, p + 1))}
            disabled={currentPage === totalPages}
            className="p-2 border rounded hover:bg-gray-200 disabled:opacity-50"
          >→</button>
        </div>
      )}
    </div>
  );
};

export default LawyerManagement;
