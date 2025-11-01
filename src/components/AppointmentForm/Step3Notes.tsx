import React, { useState } from 'react';
import { format } from 'date-fns';
import { useNavigate } from 'react-router-dom';
import api from '../../config/axios';

interface Step3NotesProps {
  formData: {
    notes: string;
    date?: string;
    time?: string;
    lawyer: string;
    [key: string]: any;
  };
  updateFormData: (field: string, value: string) => void;
  user: any;
  selectedServices: any[];
  selectedLawyer: any;
  workSlots: any[];
  prevStep: () => void;
  isSubmitting: boolean;
  lawyerDetails: {[key: string]: any};
  onCreateAppointment: (appointmentData: any) => Promise<string>;
  onDirectSuccess: () => void;
}

const Step3Notes: React.FC<Step3NotesProps> = ({
  formData,
  updateFormData,
  user,
  selectedServices,
  selectedLawyer,
  workSlots,
  prevStep,
  isSubmitting,
  lawyerDetails,
  onCreateAppointment,
  onDirectSuccess
}) => {
  const [localError, setLocalError] = useState<string | null>(null);
  const [isPaymentProcessing, setIsPaymentProcessing] = useState(false);
  const [paymentError, setPaymentError] = useState<string | null>(null);
  const navigate = useNavigate();

  // Payment function inline
  const createPaymentUrl = async (paymentData: any) => {
    setIsPaymentProcessing(true);
    setPaymentError(null);

    try {
      console.log('Creating payment URL with data:', paymentData);

      const orderInfo = `Dat lich ${paymentData.serviceNames.join(', ')} - ${paymentData.lawyerName} - ${paymentData.appointmentDate}`;

      const lawyerId = selectedLawyer?.lawyerProfile?.id || selectedLawyer?.id || 1;

      const requestData = {
        vendor: "vnpay",
        orderId: `APPT-${paymentData.appointmentId}-${Date.now()}`,
        lawyerId: lawyerId,
        durationHours: 1,
        appointmentId: paymentData.appointmentId,
        orderInfo: orderInfo,
        returnUrl: `${window.location.origin}/payment-result`,
        amount: paymentData.amount
      };

      console.log('Sending payment request:', requestData);

      const response = await api.appointment.post('/api/Payments/create-url-for-appointment', requestData);
      
      console.log('Payment URL full response:', response);

      // FIX: response.data chính là URL thanh toán
      if (response.data) {
        console.log('Redirecting to VNPay URL:', response.data);
        window.location.href = response.data;
      } else {
        throw new Error('Không nhận được URL thanh toán từ server');
      }

    } catch (error: any) {
      console.error('Payment creation error:', error);
      const errorMessage = error.response?.data?.message || error.message || 'Không thể tạo URL thanh toán';
      setPaymentError(errorMessage);
      throw new Error(errorMessage);
    } finally {
      setIsPaymentProcessing(false);
    }
  };

  // Helper function to get lawyer name safely
  const getLawyerName = () => {
    if (!selectedLawyer) return 'Chưa chọn luật sư';
    
    const lawyerId = selectedLawyer.lawyerProfile?.id || selectedLawyer.id;
    const userDetail = lawyerDetails[lawyerId];
    
    return userDetail?.fullName || 
           selectedLawyer.user?.fullName || 
           selectedLawyer.fullName || 
           'Chưa cập nhật';
  };

  // Helper function to get user info safely
  const getUserInfo = () => {
    if (!user) return { name: 'Ẩn danh', email: 'Chưa cập nhật', phone: 'Chưa cập nhật' };
    
    return {
      name: user.fullName || user.name || 'Ẩn danh',
      email: user.email || 'Chưa cập nhật',
      phone: user.phoneNumber || user.phone || 'Chưa cập nhật'
    };
  };

  // Tính toán 30% giá theo giờ của luật sư
  const calculateDepositAmount = () => {
    const pricePerHour = selectedLawyer?.lawyerProfile?.pricePerHour || selectedLawyer?.pricePerHour || 0;
    return Math.round(pricePerHour * 2 * 0.3);
  };

  // Kiểm tra có cần thanh toán không (2+ dịch vụ)
  const requiresPayment = selectedServices.length >= 2;

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLocalError(null);
    setPaymentError(null);
    
    try {
      console.log('Bắt đầu quá trình đặt lịch...');
      
      // Tạo appointment - backend tự động set status dựa vào số lượng services
      const appointmentId = await onCreateAppointment({
        formData,
        selectedServices,
        selectedLawyer,
        user
      });

      console.log('Appointment created with ID:', appointmentId);

      if (requiresPayment) {
        console.log('Cần thanh toán - chuyển hướng đến VNPay');
        
        // Tạo payment URL và chuyển hướng đến VNPay
        const paymentData = {
          appointmentId,
          amount: calculateDepositAmount(),
          serviceNames: selectedServices.map(service => service.title || service.name),
          lawyerName: getLawyerName(),
          appointmentDate: formData.date ? format(new Date(formData.date), 'dd/MM/yyyy') : ''
        };

        console.log('Creating payment URL with data:', paymentData);
        await createPaymentUrl(paymentData);
        
      } else {
        console.log('Không cần thanh toán - chuyển đến trang thành công');
        onDirectSuccess();
      }
      
    } catch (error: any) {
      console.error('Lỗi trong quá trình đặt lịch:', error);
      const errorMessage = error.response?.data?.message || error.message || 'Có lỗi xảy ra khi đặt lịch. Vui lòng thử lại.';
      
      // Nếu lỗi khi tạo appointment, show error message
      // Nếu lỗi khi tạo payment URL, appointment đã được tạo nhưng ở PaymentPending
      if (error.message?.includes('payment') || error.message?.includes('thanh toán')) {
        setPaymentError(errorMessage);
      } else {
        setLocalError(errorMessage);
      }
    }
  };

  const userInfo = getUserInfo();
  const depositAmount = calculateDepositAmount();

  return (
    <div className="animate-fade-in">
      <h2 className="text-2xl font-bold text-gray-900 mb-6">Xác nhận & {requiresPayment ? 'Thanh toán' : 'Hoàn tất'}</h2>
      
      <div className="mb-6">
        <label className="block text-sm font-semibold text-gray-700 mb-2" htmlFor="notes">
          Ghi chú (không bắt buộc)
        </label>
        <textarea
          id="notes"
          className="w-full px-4 py-3 border border-gray-300 rounded-lg shadow-sm focus:ring-2 focus:ring-primary-500 focus:border-primary-500 transition-colors h-32 resize-none"
          value={formData.notes}
          onChange={(e) => updateFormData('notes', e.target.value)}
          placeholder="Bạn có thể ghi chú thêm về vấn đề pháp lý hoặc yêu cầu đặc biệt..."
        ></textarea>
      </div>

      {/* Thông tin thanh toán - CHỈ HIỆN KHI CÓ 2+ DỊCH VỤ */}
      {requiresPayment && (
        <div className="mb-6 p-6 bg-yellow-50 border border-yellow-200 rounded-lg">
          <h3 className="font-semibold text-yellow-900 mb-3 text-lg">Thông tin thanh toán</h3>
          <div className="space-y-2">
            <div className="flex justify-between">
              <span className="text-yellow-800">Phí đặt cọc (30% giá theo giờ):</span>
              <span className="font-semibold text-yellow-900">
                {new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' }).format(depositAmount)}
              </span>
            </div>
            <p className="text-sm text-yellow-700">
              Vì bạn đã chọn {selectedServices.length} dịch vụ, vui lòng thanh toán trước 30% phí đặt cọc.
              Lịch hẹn sẽ chỉ được xác nhận sau khi thanh toán thành công.
            </p>
          </div>
        </div>
      )}

      {/* Thông báo khi chỉ có 1 dịch vụ */}
      {!requiresPayment && (
        <div className="mb-6 p-6 bg-green-50 border border-green-200 rounded-lg">
          <h3 className="font-semibold text-green-900 mb-3 text-lg">Đặt lịch miễn phí</h3>
          <div className="space-y-2">
            <p className="text-green-800">
              Bạn đã chọn 1 dịch vụ. Lịch hẹn sẽ được đặt miễn phí và chờ luật sư xác nhận.
            </p>
            <p className="text-sm text-green-700">
              Phí dịch vụ sẽ được thanh toán sau khi hoàn tất công việc.
            </p>
          </div>
        </div>
      )}

      {/* Thông tin lịch hẹn */}
      <div className="mb-6 p-6 bg-gray-50 rounded-lg border border-gray-200">
        <h3 className="font-semibold text-gray-900 mb-4 text-lg">Thông tin lịch hẹn</h3>
        
        <div className="space-y-3">
          <div className="flex justify-between">
            <span className="font-medium text-gray-700">Khách hàng:</span>
            <span className="text-gray-900">{userInfo.name}</span>
          </div>
          
          <div className="flex justify-between">
            <span className="font-medium text-gray-700">Email:</span>
            <span className="text-gray-900">{userInfo.email}</span>
          </div>
          
          <div className="flex justify-between">
            <span className="font-medium text-gray-700">Số điện thoại:</span>
            <span className="text-gray-900">{userInfo.phone}</span>
          </div>
          
          {/* Hiển thị tất cả dịch vụ đã chọn */}
          <div className="flex justify-between items-start">
            <span className="font-medium text-gray-700">Dịch vụ:</span>
            <div className="text-right">
              {selectedServices.length > 0 ? (
                <div className="space-y-1">
                  {selectedServices.map((service, index) => (
                    <div key={service.id} className="text-gray-900">
                      {service.title || service.name} {service.price && `- ${service.price}`}
                    </div>
                  ))}
                  <div className="text-sm text-gray-600 mt-1">
                    ({selectedServices.length} dịch vụ)
                  </div>
                </div>
              ) : (
                <span className="text-gray-900">Chưa chọn dịch vụ</span>
              )}
            </div>
          </div>
          
          <div className="flex justify-between">
            <span className="font-medium text-gray-700">Luật sư:</span>
            <span className="text-gray-900">{getLawyerName()}</span>
          </div>
          
          {formData.date && (
            <div className="flex justify-between">
              <span className="font-medium text-gray-700">Ngày:</span>
              <span className="text-gray-900">
                {format(new Date(formData.date), 'dd/MM/yyyy')}
              </span>
            </div>
          )}
          
          {formData.time && (
            <div className="flex justify-between">
              <span className="font-medium text-gray-700">Giờ:</span>
              <span className="text-gray-900">{formData.time}</span>
            </div>
          )}
        </div>
      </div>

      {/* Hiển thị lỗi */}
      {(paymentError || localError) && (
        <div className="mb-4 p-4 bg-red-50 border border-red-200 rounded-lg">
          <p className="text-red-700 font-semibold">{paymentError || localError}</p>
          <p className="text-sm text-red-600 mt-1">
            {paymentError && requiresPayment ? (
              <>
                Lịch hẹn của bạn vẫn được lưu trong hệ thống với trạng thái chờ thanh toán.
                Bạn có thể thử thanh toán lại sau khi quay lại trang này hoặc hủy lịch hẹn nếu không muốn tiếp tục.
              </>
            ) : (
              'Vui lòng thử lại hoặc liên hệ hỗ trợ nếu lỗi tiếp tục xảy ra.'
            )}
          </p>
        </div>
      )}

      {/* Navigation buttons */}
      <div className="flex justify-between pt-6 border-t border-gray-200">
        <button
          type="button"
          onClick={prevStep}
          disabled={isSubmitting || isPaymentProcessing}
          className="px-6 py-3 border border-gray-300 text-gray-700 hover:bg-gray-50 rounded-lg font-medium transition-colors disabled:opacity-50"
        >
          Quay lại
        </button>
        
        <button
          type="button"
          onClick={handleSubmit}
          disabled={isSubmitting || isPaymentProcessing}
          className="px-8 py-3 bg-primary-600 hover:bg-primary-700 text-white rounded-lg font-semibold shadow-sm hover:shadow-md transition-all disabled:bg-gray-300 disabled:cursor-not-allowed flex items-center space-x-2"
        >
          {(isSubmitting || isPaymentProcessing) ? (
            <>
              <svg className="animate-spin h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
              <span>Đang xử lý...</span>
            </>
          ) : (
            <span>
              {requiresPayment ? 'Thanh toán & Xác nhận' : 'Xác nhận đặt lịch'}
            </span>
          )}
        </button>
      </div>
    </div>
  );
};

export default Step3Notes;