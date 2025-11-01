import React, { useEffect, useState } from 'react';
import { format, addDays, isSameDay as dateFnsIsSameDay } from 'date-fns';
import { Calendar, Clock } from 'lucide-react';

interface Step2DateTimeProps {
  formData: {
    date?: string;
    time?: string;
    [key: string]: any;
  };
  updateFormData: (field: string, value: string) => void;
  errors: Record<string, string>;
  getAvailableTimes: () => string[];
  selectedServices: any[];
  selectedLawyer: any;
  prevStep: () => void;
  nextStep: () => void;
  lawyerDetails: {[key: string]: any}; // Thêm prop này
}

const Step2DateTime: React.FC<Step2DateTimeProps> = ({
  formData,
  updateFormData,
  errors,
  getAvailableTimes,
  selectedServices,
  selectedLawyer,
  prevStep,
  nextStep,
  lawyerDetails // Nhận prop lawyerDetails
}) => {
  const [currentMonth, setCurrentMonth] = useState<Date>(new Date());

  // Đồng bộ tháng hiển thị với ngày đã chọn (nếu có)
  useEffect(() => {
    if (formData.date) {
      const selectedDate = new Date(formData.date);
      if (!isNaN(selectedDate.getTime())) {
        setCurrentMonth(selectedDate);
      }
    }
  }, [formData.date]);

  // === Hàm hỗ trợ lịch ===
  const getFirstDayOfMonth = (date: Date) => {
    return new Date(date.getFullYear(), date.getMonth(), 1);
  };

  const getLastDayOfMonth = (date: Date) => {
    return new Date(date.getFullYear(), date.getMonth() + 1, 0);
  };

  const getDaysInMonth = (date: Date): Date[] => {
    const firstDay = getFirstDayOfMonth(date);
    const lastDay = getLastDayOfMonth(date);

    const startDate = new Date(firstDay);
    startDate.setDate(startDate.getDate() - firstDay.getDay()); // Chủ nhật = 0

    const endDate = new Date(lastDay);
    endDate.setDate(endDate.getDate() + (6 - lastDay.getDay())); // Đủ 6 hàng

    const days: Date[] = [];
    while (startDate <= endDate) {
      days.push(new Date(startDate));
      startDate.setDate(startDate.getDate() + 1);
    }
    return days;
  };

  // === Giới hạn ngày hợp lệ ===
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const maxDate = addDays(new Date(today), 6);

  const isDateInRange = (date: Date): boolean => {
    const d = new Date(date);
    d.setHours(0, 0, 0, 0);
    return d >= today && d <= maxDate;
  };

  const isSameDay = (d1: Date, d2: Date): boolean => {
    return dateFnsIsSameDay(d1, d2);
  };

  // === Sắp xếp giờ ===
  const sortedTimes = [...getAvailableTimes()].sort((a, b) => {
    const getStartMinutes = (timeRange: string) => {
      const [h, m] = timeRange.split('~')[0].trim().split(':').map(Number);
      return h * 60 + m;
    };
    return getStartMinutes(a) - getStartMinutes(b);
  });

  // === Render lịch ===
  const renderCalendar = () => {
    const days = getDaysInMonth(currentMonth);
    const weekdays = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];

    return (
      <div className="border rounded-lg shadow-sm overflow-hidden">
        {/* Header: điều hướng tháng */}
        <div className="flex justify-between items-center p-3 bg-gray-50">
          <button
            type="button"
            onClick={() => setCurrentMonth(new Date(currentMonth.getFullYear(), currentMonth.getMonth() - 1, 1))}
            className="p-1 rounded hover:bg-gray-200"
          >
            &larr;
          </button>
          <h3 className="font-semibold text-gray-800">
            {format(currentMonth, 'MMMM yyyy')}
          </h3>
          <button
            type="button"
            onClick={() => setCurrentMonth(new Date(currentMonth.getFullYear(), currentMonth.getMonth() + 1, 1))}
            className="p-1 rounded hover:bg-gray-200"
          >
            &rarr;
          </button>
        </div>

        {/* Tiêu đề ngày trong tuần */}
        <div className="grid grid-cols-7 gap-0 border-b">
          {weekdays.map((day) => (
            <div
              key={day}
              className="py-2 text-center text-xs font-medium text-gray-500"
            >
              {day}
            </div>
          ))}
        </div>

        {/* Các ngày */}
        <div className="grid grid-cols-7 gap-0">
          {days.map((day, idx) => {
            const isSelected = formData.date
              ? isSameDay(day, new Date(formData.date))
              : false;
            const isToday = isSameDay(day, today);
            const isInRange = isDateInRange(day);
            const isOtherMonth = day.getMonth() !== currentMonth.getMonth();

            return (
              <button
                key={idx}
                type="button"
                onClick={() => {
                  if (isInRange) {
                    updateFormData('date', format(day, 'yyyy-MM-dd'));
                  }
                }}
                disabled={!isInRange}
                className={`h-12 text-sm font-medium transition-colors flex items-center justify-center
                  ${isOtherMonth ? 'text-gray-300' : ''}
                  ${isToday && !isSelected ? 'bg-blue-50 text-blue-600 border border-blue-200' : ''}
                  ${isSelected ? 'bg-primary-600 text-white' : ''}
                  ${!isInRange && !isOtherMonth ? 'text-gray-300 cursor-not-allowed' : ''}
                  ${isInRange && !isSelected && !isToday ? 'text-gray-700 hover:bg-gray-100' : ''}
                  ${!isOtherMonth ? 'border border-transparent hover:border-gray-300' : ''}
                `}
              >
                {day.getDate()}
              </button>
            );
          })}
        </div>
      </div>
    );
  };

  // Helper function to get lawyer name safely - sử dụng lawyerDetails
  const getLawyerName = () => {
    if (!selectedLawyer) return 'Chưa chọn luật sư';
    
    const lawyerId = selectedLawyer.lawyerProfile?.id || selectedLawyer.id;
    const userDetail = lawyerDetails[lawyerId];
    
    return userDetail?.fullName || 
           selectedLawyer.user?.fullName || 
           selectedLawyer.fullName || 
           'Chưa cập nhật';
  };

  return (
    <div className="animate-fade-in">
      <h2 className="text-2xl font-bold text-gray-900 mb-6">Chọn ngày & giờ</h2>

      {/* Lịch tháng */}
      <div className="mb-6">
        <label className="block text-gray-700 font-medium mb-3 flex items-center">
          <Calendar className="h-5 w-5 mr-2 text-primary-600" />
          Chọn ngày
        </label>
        {renderCalendar()}
        {errors.date && <p className="text-red-500 text-sm mt-2">{errors.date}</p>}
      </div>

      {/* Chọn giờ */}
      <div className="mb-6">
        <label className="block text-gray-700 font-medium mb-2 flex items-center">
          <Clock className="h-5 w-5 mr-2 text-primary-600" />
          Chọn giờ
        </label>
        {sortedTimes.length === 0 ? (
          <p className="text-gray-500">Luật sư không làm việc ngày này.</p>
        ) : (
          <div className="grid grid-cols-2 sm:grid-cols-3 gap-2">
            {sortedTimes.map((time) => (
              <button
                key={time}
                type="button"
                className={`py-2 px-3 rounded-md text-center text-sm transition-colors ${
                  formData.time === time
                    ? 'bg-primary-600 text-white'
                    : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                }`}
                onClick={() => updateFormData('time', time)}
              >
                {time}
              </button>
            ))}
          </div>
        )}
        {errors.time && <p className="text-red-500 text-sm mt-1">{errors.time}</p>}
      </div>

      {/* Tóm tắt */}
      <div className="mb-6 p-4 bg-gray-50 rounded-lg">
        <h3 className="font-medium text-gray-900 mb-2">Tóm tắt lịch hẹn:</h3>
        
        {/* Hiển thị tất cả dịch vụ đã chọn */}
        <div className="mb-2">
          <span className="font-medium">Dịch vụ:</span>
          {selectedServices.length > 0 ? (
            <div className="mt-1">
              {selectedServices.map((service, index) => (
                <div key={service.id} className="text-gray-700">
                  • {service.title || service.name} {service.price && `- ${service.price}`}
                </div>
              ))}
              <div className="text-sm text-gray-600 mt-1">
                ({selectedServices.length} dịch vụ)
              </div>
            </div>
          ) : (
            <span className="text-gray-700"> Chưa chọn dịch vụ</span>
          )}
        </div>
        
        <p>
          <span className="font-medium">Luật sư:</span>{' '}
          {getLawyerName()}
        </p>
        {formData.date && (
          <p>
            <span className="font-medium">Ngày:</span>{' '}
            {format(new Date(formData.date), 'dd/MM/yyyy')}
          </p>
        )}
        {formData.time && (
          <p>
            <span className="font-medium">Giờ:</span> {formData.time}
          </p>
        )}
      </div>

      {/* Nút điều hướng */}
      <div className="flex justify-between">
        <button 
          type="button" 
          onClick={prevStep} 
          className="px-6 py-3 border border-gray-300 text-gray-700 hover:bg-gray-50 rounded-lg font-medium transition-colors"
        >
          Quay lại
        </button>
        <button 
          type="button" 
          onClick={nextStep} 
          className="px-6 py-3 bg-primary-600 hover:bg-primary-700 text-white rounded-lg font-medium transition-colors"
        >
          Tiếp tục
        </button>
      </div>
    </div>
  );
};

export default Step2DateTime;