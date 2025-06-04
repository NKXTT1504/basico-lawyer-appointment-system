import React, { useState, useEffect } from 'react';

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

  useEffect(() => {
    fetch('http://localhost:5173/api/lich-truc')
      .then(res => res.json())
      .then(data => setShifts(data))
      .catch(err => console.error('Lỗi tải dữ liệu:', err));
  }, []);

  const getSlotAvailability = (slotIndex, day) => {
    const shift = shifts.find(s => s.day === day);
    if (!shift) return false;
    return [shift.slot1, shift.slot2, shift.slot3, shift.slot4][slotIndex];
  };

  return (
    <main className="bg-700 py-16 text-white">
      <div className="container mx-auto px-4">
        <h1 className="text-4xl font-bold text-center mb-10 text-primary">LỊCH LÀM VIỆC</h1>
        <div className="overflow-x-auto bg-white text-black rounded-lg shadow-md">
          <table className="min-w-full text-sm table-fixed">
            <thead className="bg-primary-800 text-white">
              <tr>
                <th className="px-2 py-2 text-center">Slot</th>
                <th className="px-4 py-2 text-center">Khung giờ</th>
                {Object.entries(dayLabels).map(([key, label]) => (
                  <th key={key} className="px-2 py-2 text-center">{label}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {slotLabels.map((slotLabel, index) => (
                <tr key={index} className="border-t">
                  <td className="px-2 py-2 font-semibold text-center">{slotNames[index]}</td>
                  <td className="px-4 py-2 font-semibold text-center">{slotLabel}</td>
                  {Object.keys(dayLabels).map(day => {
                    const available = getSlotAvailability(index, day);
                    return (
                      <td
                        key={day}
                        className={`px-2 py-2 text-center font-medium ${
                          available ? 'bg-green-100 text-green-700' : 'bg-gray-200 text-gray-600'
                        }`}
                      >
                        {available ? '√' : '☓'}
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
