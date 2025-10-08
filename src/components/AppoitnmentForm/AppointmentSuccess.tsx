import React from "react";
import { format } from "date-fns";

const AppointmentSuccess = ({
  selectedLawyer,
  user,
  selectedService,
  formData,
  setStep,
  setSubmitSuccess,
  setFormData
}: any) => {
  // Defensive date/time handling
  let dateTimeDisplay = "Không xác định";
  if (formData?.date && formData?.time) {
    try {
      // If formData.date is 'yyyy-MM-dd' and formData.time is '08:00 ~ 10:00'
      const startTime = formData.time.split("~")[0].trim();
      const dateObj = new Date(`${formData.date}T${startTime}:00`);
      if (!isNaN(dateObj.getTime())) {
        dateTimeDisplay = format(dateObj, "dd/MM/yyyy HH:mm");
      }
    } catch {
      dateTimeDisplay = "Không xác định";
    }
  }

  return (
    <div className="bg-white p-8 rounded-lg shadow-md animate-fade-in">
      <div className="text-center">
        <div className="inline-flex items-center justify-center h-16 w-16 rounded-full bg-green-100 text-green-600 mb-6">
          <svg className="h-8 w-8" fill="currentColor" viewBox="0 0 20 20">
            <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
          </svg>
        </div>
        <h2 className="text-2xl font-bold text-gray-900 mb-2">Đặt lịch thành công!</h2>
        <p className="text-gray-600 mb-6">
          Cảm ơn bạn đã đặt lịch. Chúng tôi sẽ gửi email sau khi luật sư {selectedLawyer?.user?.fullName || selectedLawyer?.name} xác nhận tới {user?.email}.
        </p>
        <div className="bg-gray-50 rounded-lg p-6 mb-6 text-left">
          <h3 className="text-lg font-medium text-gray-900 mb-4">Chi tiết lịch hẹn:</h3>
          <div className="space-y-3">
            <p><span className="font-medium">Dịch vụ:</span> {selectedService?.title || selectedService?.name}</p>
            <p><span className="font-medium">Luật sư:</span> {selectedLawyer?.user?.fullName || selectedLawyer?.name}</p>
            <p><span className="font-medium">Ngày & giờ:</span> {dateTimeDisplay}</p>
          </div>
        </div>
        <div className="flex flex-col sm:flex-row justify-center gap-4">
          <a href="/" className="btn-primary">
            Về trang chủ
          </a>
          <button
            onClick={() => {
              setStep(1);
              setSubmitSuccess(false);
              setFormData({
                service: '',
                lawyer: '',
                date: '',
                time: '',
                notes: ''
              });
            }}
            className="btn-outline"
          >
            Đặt lịch mới
          </button>
        </div>
      </div>
    </div>
  );
};

export default AppointmentSuccess;