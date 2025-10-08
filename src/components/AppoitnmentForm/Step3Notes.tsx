import React from 'react';
import { format } from 'date-fns';

interface Step3NotesProps {
  formData: {
    notes: string;
    date?: string;
    time?: string;
    [key: string]: any;
  };
  updateFormData: (field: string, value: string) => void;
  user: any;
  selectedService: any;
  selectedLawyer: any;
  workSlots: any[];
  prevStep: () => void;
  isSubmitting: boolean;
}

const Step3Notes: React.FC<Step3NotesProps> = ({
  formData,
  updateFormData,
  user,
  selectedService,
  selectedLawyer,
  workSlots,
  prevStep,
  isSubmitting
}) => (
  <div className="animate-fade-in">
    <h2 className="text-2xl font-bold text-gray-900 mb-6">Ghi chú thêm</h2>
    <div className="mb-6">
      <label className="input-label" htmlFor="notes">Ghi chú (không bắt buộc)</label>
      <textarea
        id="notes"
        className="w-full h-32"
        value={formData.notes}
        onChange={(e) => updateFormData('notes', e.target.value)}
        placeholder="Bạn có thể ghi chú thêm về vấn đề pháp lý hoặc yêu cầu đặc biệt..."
      ></textarea>
    </div>
    <div className="mb-6 p-4 bg-gray-50 rounded-lg">
      <h3 className="font-medium text-gray-900 mb-2">Thông tin lịch hẹn:</h3>
      <p><span className="font-medium">Khách hàng:</span> {user?.fullName || user?.name || 'Ẩn danh'}</p>
      <p><span className="font-medium">Email:</span> {user?.email}</p>
      <p><span className="font-medium">Số điện thoại:</span> {user?.phoneNumber || user?.phone}</p>
      <p><span className="font-medium">Dịch vụ:</span> {selectedService?.title}</p>
      <p><span className="font-medium">Luật sư:</span> {selectedLawyer?.user.fullName}</p>
      {formData.date && <p>
        <span className="font-medium">Ngày:</span> {format(new Date(formData.date), 'dd/MM/yyyy')}
      </p>}
      {formData.time && <p><span className="font-medium">Giờ:</span> {formData.time}</p>}
      <p>
        {(() => {
          const slot = workSlots.find(s => String(s.id) === formData.time);
          return slot ? `${slot.dayOfWeek} - Slot ${slot.slot}` : "";
        })()}
      </p>
    </div>
    <div className="flex justify-between mt-6">
      <button
        type="button"
        onClick={prevStep}
        className="btn-outline"
      >
        Quay lại
      </button>
      <button
        type="submit"
        className="btn-primary"
        disabled={isSubmitting}
      >
        {isSubmitting ? (
          <>
            <svg className="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
              <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
              <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
            </svg>
            Đang xử lý...
          </>
        ) : (
          'Xác nhận đặt lịch'
        )}
      </button>
    </div>
  </div>
);

export default Step3Notes;