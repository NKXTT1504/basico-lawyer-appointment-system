// pages/AppointmentSuccess.tsx
import React, { useEffect, useState } from 'react';
import { useLocation, useNavigate } from 'react-router-dom';
import { CheckCircle, Printer, Home, Calendar } from 'lucide-react';
import api from '../../config/axios';

const AppointmentSuccess: React.FC = () => {
  const location = useLocation();
  const navigate = useNavigate();
  const [appointmentData, setAppointmentData] = useState<any>(null);
  const [lawyerDetails, setLawyerDetails] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [loadingLawyer, setLoadingLawyer] = useState(false);

  const { 
    paymentStatus, 
    transactionNo, 
    amount, 
    appointmentData: initialAppointmentData,
    appointmentId 
  } = location.state || {};

  // Mapping giống như trong AppointmentForm
  const slotToTimes: { [key: number]: string } = {
    1: "08:00 ~ 10:00",
    2: "10:00 ~ 12:00", 
    3: "13:00 ~ 15:00",
    4: "15:00 ~ 17:00",
  };

  // Hàm lấy tên luật sư
  const getLawyerName = () => {
    if (lawyerDetails?.result?.user?.fullName) {
      return lawyerDetails.result.user.fullName;
    }
    
    if (appointmentData?.lawyer?.user?.fullName) {
      return appointmentData.lawyer.user.fullName;
    }
    
    return '—';
  };

  // Hàm lấy địa điểm
  const getLocation = () => {
    if (lawyerDetails?.result?.lawyerProfile?.description) {
      return lawyerDetails.result.lawyerProfile.description;
    }
    
    if (appointmentData?.lawyer?.lawyerProfile?.description) {
      return appointmentData.lawyer.lawyerProfile.description;
    }
    
    if (appointmentData?.location) {
      return appointmentData.location;
    }
    
    return '—';
  };

  // Fetch appointment data
  useEffect(() => {
    const fetchAppointmentData = async () => {
      try {
        // Nếu đã có appointmentData từ state, sử dụng luôn
        if (initialAppointmentData) {
          if (initialAppointmentData.Appointment) {
            setAppointmentData({
              ...initialAppointmentData.Appointment,
              payment: initialAppointmentData.Payment
            });
          } else {
            setAppointmentData(initialAppointmentData);
          }
          setLoading(false);
          return;
        }

        // Nếu có appointmentId, fetch từ API
        if (appointmentId) {
          try {
            const paymentResponse = await api.appointment.get(`/api/Payments/by-appointment/${appointmentId}`);
            if (paymentResponse?.data?.Appointment) {
              setAppointmentData({
                ...paymentResponse.data.Appointment,
                payment: paymentResponse.data.Payment
              });
            } else {
              const response = await api.appointment.get(`/api/Appointment/${appointmentId}`);
              setAppointmentData(response.data);
            }
          } catch (err) {
            console.warn('Could not fetch from payment endpoint, trying appointment endpoint:', err);
            try {
              const response = await api.appointment.get(`/api/Appointment/${appointmentId}`);
              setAppointmentData(response.data);
            } catch (err2) {
              console.error('Error fetching appointment data:', err2);
            }
          }
        }
        
        setLoading(false);
      } catch (error) {
        console.error('Error fetching appointment data:', error);
        setLoading(false);
      }
    };

    fetchAppointmentData();
  }, [initialAppointmentData, appointmentId]);

  // Fetch lawyer details khi có appointment data
  useEffect(() => {
    const fetchLawyerDetails = async () => {
      if (!appointmentData) return;

      const lawyerId = appointmentData.lawyerId || 
                      appointmentData.lawyer?.id || 
                      appointmentData.appointment?.lawyerId;

      if (!lawyerId) return;

      try {
        setLoadingLawyer(true);
        const response = await api.auth.get(`/api/UserWithLawyerProfile/${lawyerId}`);
        setLawyerDetails(response.data);
      } catch (error) {
        console.error('Error fetching lawyer details:', error);
      } finally {
        setLoadingLawyer(false);
      }
    };

    fetchLawyerDetails();
  }, [appointmentData]);

  // Hàm format thời gian từ slot
  const formatTimeFromSlot = () => {
    if (!appointmentData) return '—';
    
    const slot = appointmentData.slot || appointmentData.appointment?.slot;
    if (slot !== undefined && slot !== null) {
      const slotNumber = Number(slot);
      if (slotToTimes[slotNumber]) {
        return slotToTimes[slotNumber];
      }
    }
    
    const scheduledAt = appointmentData.scheduledAt || appointmentData.appointment?.scheduledAt;
    if (scheduledAt) {
      const date = new Date(scheduledAt);
      const hours = date.getHours();
      
      if (hours >= 8 && hours < 10) return "08:00 ~ 10:00";
      if (hours >= 10 && hours < 12) return "10:00 ~ 12:00";
      if (hours >= 13 && hours < 15) return "13:00 ~ 15:00";
      if (hours >= 15 && hours < 17) return "15:00 ~ 17:00";
      
      return date.toLocaleString('vi-VN');
    }
    
    return '—';
  };

  // Hàm format ngày
  const formatAppointmentDate = () => {
    if (!appointmentData) return '—';
    
    const scheduledAt = appointmentData.scheduledAt || appointmentData.appointment?.scheduledAt;
    if (scheduledAt) {
      return new Date(scheduledAt).toLocaleDateString('vi-VN');
    }
    
    if (appointmentData.appointmentTime) {
      return new Date(appointmentData.appointmentTime).toLocaleDateString('vi-VN');
    }
    
    return '—';
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary-600 mx-auto mb-4"></div>
          <p>Đang tải thông tin cuộc hẹn...</p>
        </div>
      </div>
    );
  }

  const formatServiceNames = (services: any) => {
    if (!services) return '—';
    
    if (Array.isArray(services)) {
      return services.map(service => 
        typeof service === 'string' ? service : service.name || service.title
      ).join(', ');
    }
    
    if (typeof services === 'string') {
      try {
        const parsed = JSON.parse(services);
        if (Array.isArray(parsed)) {
          return parsed.join(', ');
        }
      } catch {
        return services;
      }
    }
    
    return String(services);
  };

  const displayTime = formatTimeFromSlot();
  const displayDate = formatAppointmentDate();
  const lawyerName = getLawyerName();
  const locationInfo = getLocation();

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-2xl mx-auto px-4">
        {/* Success Header */}
        <div className="bg-white rounded-lg shadow-md p-6 mb-6 text-center">
          <CheckCircle className="h-16 w-16 text-green-600 mx-auto mb-4" />
          <h1 className="text-2xl font-bold text-gray-900 mb-2">Đặt lịch thành công!</h1>
          <p className="text-gray-600">Cảm ơn bạn đã sử dụng dịch vụ của chúng tôi</p>
          
          {(appointmentData?.id || appointmentData?.appointment?.id || appointmentId) && (
            <div className="mt-4 inline-block bg-gray-100 px-3 py-1 rounded-full">
              <span className="text-sm text-gray-700">
                Mã cuộc hẹn: <strong className="font-mono">
                  {appointmentData?.id || appointmentData?.appointment?.id || appointmentId}
                </strong>
              </span>
            </div>
          )}
        </div>

        {/* Appointment Information */}
        <div className="bg-white rounded-lg shadow-md p-6 mb-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Thông tin cuộc hẹn</h2>
          
          <div className="space-y-4">
            <div className="flex justify-between items-center py-2 border-b">
              <span className="text-gray-600">Dịch vụ:</span>
              <span className="font-medium text-right">
                {formatServiceNames(
                  appointmentData?.services || 
                  appointmentData?.appointment?.services || 
                  appointmentData?.service
                )}
              </span>
            </div>
            
            <div className="flex justify-between items-center py-2 border-b">
              <span className="text-gray-600">Luật sư:</span>
              <span className="font-medium">
                {loadingLawyer ? (
                  <span className="text-gray-400">Đang tải...</span>
                ) : (
                  lawyerName
                )}
              </span>
            </div>
            
            <div className="flex justify-between items-center py-2 border-b">
              <span className="text-gray-600">Ngày:</span>
              <span className="font-medium">{displayDate}</span>
            </div>
            
            <div className="flex justify-between items-center py-2 border-b">
              <span className="text-gray-600">Khung giờ:</span>
              <span className="font-medium">{displayTime}</span>
            </div>
            
            <div className="flex justify-between items-center py-2 border-b">
              <span className="text-gray-600">Địa điểm:</span>
              <span className="font-medium">{locationInfo}</span>
            </div>
            
            {(appointmentData?.note || appointmentData?.appointment?.note || appointmentData?.notes) && (
              <div className="flex justify-between items-start py-2 border-b">
                <span className="text-gray-600">Ghi chú:</span>
                <span className="font-medium text-right max-w-xs">
                  {appointmentData?.note || appointmentData?.appointment?.note || appointmentData?.notes}
                </span>
              </div>
            )}
            
            {appointmentData?.Status !== undefined && (
              <div className="flex justify-between items-center py-2">
                <span className="text-gray-600">Trạng thái:</span>
                <span className={`font-medium ${
                  appointmentData.Status === 1 || appointmentData.Status === 'Confirmed' 
                    ? 'text-green-600' 
                    : appointmentData.Status === 4 || appointmentData.Status === 'PaymentPending'
                    ? 'text-yellow-600'
                    : 'text-blue-600'
                }`}>
                  {appointmentData.Status === 1 || appointmentData.Status === 'Confirmed' 
                    ? 'Đã xác nhận' 
                    : appointmentData.Status === 4 || appointmentData.Status === 'PaymentPending'
                    ? 'Chờ thanh toán'
                    : appointmentData.Status === 0 || appointmentData.Status === 'Pending'
                    ? 'Chờ xác nhận'
                    : '—'}
                </span>
              </div>
            )}
          </div>
        </div>

        {/* Payment Information (if available) */}
        {paymentStatus === 'success' && (
          <div className="bg-white rounded-lg shadow-md p-6 mb-6">
            <h2 className="text-lg font-semibold text-gray-900 mb-4">Thông tin thanh toán</h2>
            
            <div className="space-y-3">
              {transactionNo && (
                <div className="flex justify-between items-center py-2 border-b">
                  <span className="text-gray-600">Mã giao dịch:</span>
                  <span className="font-medium font-mono">{transactionNo}</span>
                </div>
              )}
              
              {amount && (
                <div className="flex justify-between items-center py-2 border-b">
                  <span className="text-gray-600">Số tiền:</span>
                  <span className="font-medium text-green-600">
                    {amount.toLocaleString('vi-VN')} VND
                  </span>
                </div>
              )}
              
              <div className="flex justify-between items-center py-2 border-b">
                <span className="text-gray-600">Trạng thái:</span>
                <span className="font-medium text-green-600">Đã thanh toán</span>
              </div>
              
              <div className="flex justify-between items-center py-2 border-b">
                <span className="text-gray-600">Phương thức:</span>
                <span className="font-medium">VNPay</span>
              </div>
            </div>
          </div>
        )}

        {/* Success Message */}
        <div className="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-6">
          <p className="text-blue-800 text-sm">
             Thông tin chi tiết về cuộc hẹn đã được gửi đến email của bạn. 
            Vui lòng kiểm tra hộp thư đến và đến đúng giờ tại địa điểm đã hẹn.
          </p>
          {displayTime && (
            <p className="text-blue-800 text-sm mt-2">
               Lưu ý: Cuộc hẹn của bạn trong khung giờ <strong>{displayTime}</strong>. 
              Vui lòng đến sớm ít nhất 15 phút.
            </p>
          )}
        </div>

        {/* Action Buttons */}
        <div className="flex flex-col sm:flex-row gap-3 justify-center">
          <button
            onClick={() => window.print()}
            className="flex items-center justify-center gap-2 px-6 py-3 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors"
          >
            <Printer className="h-4 w-4" />
            In xác nhận
          </button>
          
          <button
            onClick={() => navigate('/history-appointments')}
            className="flex items-center justify-center gap-2 px-6 py-3 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors"
          >
            <Calendar className="h-4 w-4" />
            Xem lịch hẹn
          </button>
          
          <button
            onClick={() => navigate('/')}
            className="flex items-center justify-center gap-2 px-6 py-3 bg-gray-600 text-white rounded-lg hover:bg-gray-700 transition-colors"
          >
            <Home className="h-4 w-4" />
            Về trang chủ
          </button>
        </div>
      </div>
    </div>
  );
};

export default AppointmentSuccess;