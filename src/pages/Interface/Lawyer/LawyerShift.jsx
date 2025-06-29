import React, { useState, useEffect } from 'react';
import api from '../../../config/axios';

const dayLabels = {
  Monday: 'Thứ Hai',
  Tuesday: 'Thứ Ba',
  Wednesday: 'Thứ Tư',
  Thursday: 'Thứ Năm',
  Friday: 'Thứ Sáu',
  Saturday: 'Thứ Bảy',
  Sunday: 'Chủ Nhật'
};

const slotLabels = ['8:00 - 10:00', '10:00 - 12:00', '13:00 - 15:00', '15:00 - 17:00'];
const slotNames = ['1', '2', '3', '4'];

const LawyerShift = () => {
  const [shifts, setShifts] = useState([]);
  const user = JSON.parse(localStorage.getItem("user"));
  const [lawyerId, setLawyerId] = useState(null);

  useEffect(() => {
    // Lấy lawyerId từ profile
    const fetchLawyerId = async () => {
      try {
        const res = await api.lawyer.get(`/api/Lawyer/GetProfileByUserId/${user.id}`);
        setLawyerId(res.data.result.id);
      } catch {
        setLawyerId(null);
      }
    };
    if (user?.id) fetchLawyerId();
  }, [user]);

  useEffect(() => {
    if (!lawyerId) return;
    api.lawyer.get(`/api/lawyers/${lawyerId}/workslots`)
      .then(res => setShifts(res.data.result || res.data))
      .catch(() => setShifts([]));
  }, [lawyerId]);

  const getSlotAvailability = (slotIndex, day) => {
    const shift = shifts.find(s => s.dayOfWeek === day && s.slot === (slotIndex + 1).toString());
    return shift?.isActive;
  };

  return (
    <main className="bg-gray-100 py-16">
      <div className="container mx-auto px-4">
        <h1 className="text-4xl font-bold text-center mb-10 text-primary-800">LỊCH LÀM VIỆC CỦA BẠN</h1>

        <div className="overflow-x-auto bg-white rounded-lg shadow-lg">
          <table className="min-w-full text-sm border-collapse">
            <thead>
              <tr className="bg-primary-800 text-white">
                <th className="px-4 py-3 text-left border border-primary-700">Slot</th>
                <th className="px-4 py-3 text-left border border-primary-700">Khung giờ</th>
                {Object.entries(dayLabels).map(([key, label]) => (
                  <th key={key} className="px-4 py-3 text-center border border-primary-700">
                    {label}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {slotLabels.map((slotLabel, index) => (
                <tr key={index} className={index % 2 === 0 ? 'bg-gray-50' : 'bg-white'}>
                  <td className="px-4 py-3 font-semibold border border-gray-200">{slotNames[index]}</td>
                  <td className="px-4 py-3 font-semibold border border-gray-200">{slotLabel}</td>
                  {Object.keys(dayLabels).map((day, dayIndex) => {
                    const available = getSlotAvailability(index, day);
                    return (
                      <td
                        key={day}
                        className={`px-4 py-3 text-center border border-gray-200 ${available
                          ? 'bg-[#E6F0F8] text-[#0D63A5]'
                          : 'bg-gray-100 text-gray-500'
                          }${dayIndex !== 6 ? 'border-r border-gray-200' : ''}`}
                      >
                        {available ? (
                          <span className="inline-flex items-center justify-center w-6 h-6  bg-[#0D63A5] rounded-full text-white">
                            ✓
                          </span>
                        ) : (
                          <span className="inline-flex items-center justify-center w-6 h-6 bg-gray-400 rounded-full text-white">
                            ✗
                          </span>
                        )}
                      </td>
                    );
                  })}
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </main>
  );
};

export default LawyerShift;
