// components/AppointmentForm/AppointmentSuccessDirect.tsx
import React, { useEffect, useState } from 'react';
import { Printer, Home, Calendar, CheckCircle } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import api from '../../config/axios';

interface AppointmentSuccessDirectProps {
  selectedLawyer?: any;
  user?: any;
  selectedService?: any;
  formData?: any;
  setStep?: (n: number) => void;
  setSubmitSuccess?: (v: boolean) => void;
  setFormData?: (data: any) => void;
  onClose?: () => void;
}

const AppointmentSuccessDirect: React.FC<AppointmentSuccessDirectProps> = (props) => {
  const {
    selectedLawyer,
    user,
    selectedService,
    formData,
    setSubmitSuccess,
    setFormData,
    onClose,
  } = props;

  const navigate = useNavigate();
  const [lawyerDetails, setLawyerDetails] = useState<any>(null);
  const [loadingLawyer, setLoadingLawyer] = useState(false);

  // Mapping giống như trong AppointmentForm
  const slotToTimes: { [key: number]: string } = {
    1: "08:00 ~ 10:00",
    2: "10:00 ~ 12:00", 
    3: "13:00 ~ 15:00",
    4: "15:00 ~ 17:00",
  };

  // Fetch lawyer details khi component mount
  useEffect(() => {
    const fetchLawyerDetails = async () => {
      if (!selectedLawyer) return;

      const lawyerId = selectedLawyer.lawyerProfile?.id || selectedLawyer.id;

      if (!lawyerId) return;

      try {
        setLoadingLawyer(true);
        console.log('Fetching lawyer details for ID:', lawyerId);
        const response = await api.auth.get(`/api/UserWithLawyerProfile/${lawyerId}`);
        setLawyerDetails(response.data);
        console.log('Lawyer details:', response.data);
      } catch (error) {
        console.error('Error fetching lawyer details:', error);
      } finally {
        setLoadingLawyer(false);
      }
    };

    fetchLawyerDetails();
  }, [selectedLawyer]);

  // Hàm lấy tên luật sư từ API
  const getLawyerName = () => {
    // Ưu tiên từ lawyer details API
    if (lawyerDetails?.result?.user?.fullName) {
      return lawyerDetails.result.user.fullName;
    }
    
    // Fallback từ selectedLawyer prop
    if (selectedLawyer?.user?.fullName) {
      return selectedLawyer.user.fullName;
    }
    
    if (selectedLawyer?.fullName) {
      return selectedLawyer.fullName;
    }
    
    return '—';
  };

  // Hàm lấy địa điểm từ API
  const getLocation = () => {
    // Ưu tiên từ lawyer details API
    if (lawyerDetails?.result?.lawyerProfile?.description) {
      return lawyerDetails.result.lawyerProfile.description;
    }
    
    // Fallback từ selectedLawyer prop
    if (selectedLawyer?.lawyerProfile?.description) {
      return selectedLawyer.lawyerProfile.description;
    }
    
    if (formData?.location) {
      return formData.location;
    }
    
    return '—';
  };

  // Hàm format thời gian từ slot (nếu có slot trong formData)
  const formatTimeFromSlot = () => {
    if (!formData?.time) return formData?.time || '—';
    
    // Nếu time đã là dạng "08:00 ~ 10:00" thì giữ nguyên
    if (formData.time.includes('~')) {
      return formData.time;
    }
    
    // Nếu có slot number trong formData, convert sang time range
    if (formData.slot) {
      const slotNumber = Number(formData.slot);
      if (slotToTimes[slotNumber]) {
        return slotToTimes[slotNumber];
      }
    }
    
    return formData.time;
  };

  const formatServiceNames = (services: any) => {
    if (!services) return '—';
    
    if (Array.isArray(services)) {
      return services.map(service => 
        typeof service === 'string' ? service : service.title || service.name
      ).join(', ');
    }
    
    return String(services);
  };

  const handleClose = () => {
    if (typeof onClose === 'function') return onClose();
    if (typeof setSubmitSuccess === 'function') {
      setSubmitSuccess(false);
      if (typeof setFormData === 'function') {
        setFormData({ service: [], lawyer: '', date: '', time: '', notes: '' });
      }
      return;
    }
    // fallback: go home
    window.location.href = '/';
  };

  const displayTime = formatTimeFromSlot();
  const lawyerName = getLawyerName();
  const locationInfo = getLocation();

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-2xl mx-auto px-4">
        {/* Success Header */}
        <div className="bg-white rounded-lg shadow-md p-6 mb-6 text-center">
          <CheckCircle className="h-16 w-16 text-green-600 mx-auto mb-4" />
          <h1 className="text-2xl font-bold text-gray-900 mb-2">Đặt Lịch Thành Công!</h1>
          <p className="text-gray-600 mb-4">Lịch hẹn của bạn đã được gửi đến luật sư và đang chờ xác nhận</p>
        </div>

        {/* Appointment Information */}
        <div className="bg-white rounded-lg shadow-md p-6 mb-6">
          <h2 className="text-lg font-semibold text-gray-900 mb-4">Thông Tin Cuộc Hẹn</h2>
          
          <div className="space-y-4">
            <div className="flex justify-between items-center py-2 border-b">
              <span className="text-gray-600">Dịch vụ:</span>
              <span className="font-medium text-right">
                {formatServiceNames(selectedService)}
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
            
            {formData?.date && (
              <div className="flex justify-between items-center py-2 border-b">
                <span className="text-gray-600">Ngày:</span>
                <span className="font-medium">
                  {new Date(formData.date).toLocaleDateString('vi-VN')}
                </span>
              </div>
            )}
            
            {displayTime && (
              <div className="flex justify-between items-center py-2 border-b">
                <span className="text-gray-600">Khung giờ:</span>
                <span className="font-medium">{displayTime}</span>
              </div>
            )}
            
            <div className="flex justify-between items-center py-2 border-b">
              <span className="text-gray-600">Địa điểm:</span>
              <span className="font-medium">
                {loadingLawyer ? (
                  <span className="text-gray-400">Đang tải...</span>
                ) : (
                  locationInfo
                )}
              </span>
            </div>
            
            {formData?.notes && (
              <div className="flex justify-between items-start py-2 border-b">
                <span className="text-gray-600">Ghi chú:</span>
                <span className="font-medium text-right max-w-xs">
                  {formData.notes}
                </span>
              </div>
            )}
            
            {/* Trạng thái mặc định cho đặt 1 dịch vụ */}
            <div className="flex justify-between items-center py-2">
              <span className="text-gray-600">Trạng thái:</span>
              <span className="font-medium text-blue-600">
                Chờ luật sư xác nhận
              </span>
            </div>
          </div>
        </div>

        {/* Important Notice */}
        <div className="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-6">
          <h3 className="font-semibold text-blue-900 mb-2">Lưu Ý Quan Trọng</h3>
          <ul className="text-blue-800 space-y-2 text-sm">
            <li>• Lịch hẹn của bạn đã được gửi đến luật sư và đang chờ xác nhận</li>
            <li>• Bạn sẽ nhận được email thông báo khi luật sư xác nhận lịch hẹn</li>
            <li>• Vui lòng kiểm tra email và đến đúng giờ tại địa điểm đã hẹn</li>
            {displayTime && (
              <li>• Khung giờ: <strong>{displayTime}</strong> - vui lòng đến sớm ít nhất 15 phút</li>
            )}
          </ul>
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
            onClick={handleClose}
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

export default AppointmentSuccessDirect;