// pages/payment-success.tsx - FILE MỚI CẦN TẠO
import React, { useEffect, useState } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';

const PaymentSuccess: React.FC = () => {
  const navigate = useNavigate();
  const location = useLocation();
  const [paymentStatus, setPaymentStatus] = useState<'loading' | 'success' | 'error'>('loading');
  const [appointmentData, setAppointmentData] = useState<any>(null);
  const [errorMessage, setErrorMessage] = useState<string>('');

  // Hàm để lấy query parameters từ URL
  const getQueryParams = () => {
    const searchParams = new URLSearchParams(location.search);
    const params: any = {};
    for (const [key, value] of searchParams.entries()) {
      params[key] = value;
    }
    return params;
  };

  useEffect(() => {
    const verifyPaymentAndUpdateAppointment = async () => {
      try {
        const { 
          vnp_TransactionNo, 
          vnp_Amount, 
          vnp_OrderInfo, 
          vnp_ResponseCode,
          appointmentId 
        } = getQueryParams();

        console.log('Payment callback received:', getQueryParams());

        // Kiểm tra response code từ VNPay
        if (vnp_ResponseCode !== '00') {
          setPaymentStatus('error');
          setErrorMessage('Giao dịch thất bại hoặc bị hủy');
          return;
        }

        if (!vnp_TransactionNo || !appointmentId) {
          setPaymentStatus('error');
          setErrorMessage('Thiếu thông tin giao dịch');
          return;
        }

        // Gọi API xác minh thanh toán
        const verifyResponse = await fetch('/api/Payments/verify-payment', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            transactionId: vnp_TransactionNo,
            amount: vnp_Amount,
            orderId: appointmentId,
            responseCode: vnp_ResponseCode
          }),
        });

        const verificationResult = await verifyResponse.json();

        if (verificationResult.isSuccess) {
          setPaymentStatus('success');
          
          // Cập nhật trạng thái appointment
          await fetch(`/api/appointments/${appointmentId}/status`, {
            method: 'PUT',
            headers: {
              'Content-Type': 'application/json',
            },
            body: JSON.stringify({
              status: 'confirmed',
              paymentStatus: 'paid',
              transactionId: vnp_TransactionNo,
              paidAt: new Date().toISOString()
            }),
          });

          // Lấy thông tin appointment để hiển thị
          const appointmentResponse = await fetch(`/api/appointments/${appointmentId}`);
          if (appointmentResponse.ok) {
            const appointment = await appointmentResponse.json();
            setAppointmentData(appointment);
          }

        } else {
          setPaymentStatus('error');
          setErrorMessage(verificationResult.message || 'Xác minh thanh toán thất bại');
        }

      } catch (error) {
        console.error('Lỗi xác minh thanh toán:', error);
        setPaymentStatus('error');
        setErrorMessage('Có lỗi xảy ra khi xác minh thanh toán');
      }
    };

    verifyPaymentAndUpdateAppointment();
  }, [location]);

  const handleViewAppointments = () => {
    navigate('/history-appointments');
  };

  const handleBackToHome = () => {
    navigate('/');
  };

  const handleRetry = () => {
    navigate(-1); // Quay lại trang trước đó
  };

  // Lấy query params cho phần hiển thị
  const queryParams = getQueryParams();

  if (paymentStatus === 'loading') {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <div className="max-w-md w-full bg-white rounded-lg shadow-md p-6 text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-500 mx-auto mb-4"></div>
          <h2 className="text-xl font-semibold text-gray-800 mb-2">Đang xác nhận thanh toán...</h2>
          <p className="text-gray-600">Vui lòng chờ trong giây lát</p>
        </div>
      </div>
    );
  }

  if (paymentStatus === 'error') {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <div className="max-w-md w-full bg-white rounded-lg shadow-md p-6 text-center">
          <div className="w-16 h-16 bg-red-100 rounded-full flex items-center justify-center mx-auto mb-4">
            <span className="text-2xl text-red-500">❌</span>
          </div>
          <h2 className="text-xl font-semibold text-gray-800 mb-2">Thanh toán thất bại</h2>
          <p className="text-gray-600 mb-4">{errorMessage}</p>
          <div className="flex flex-col space-y-3">
            <button 
              onClick={handleRetry}
              className="w-full bg-blue-500 text-white py-2 px-4 rounded hover:bg-blue-600 transition duration-200"
            >
              Thử lại
            </button>
            <button 
              onClick={handleBackToHome}
              className="w-full bg-gray-500 text-white py-2 px-4 rounded hover:bg-gray-600 transition duration-200"
            >
              Về trang chủ
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-2xl mx-auto bg-white rounded-lg shadow-md overflow-hidden">
        {/* Header */}
        <div className="bg-green-500 text-white p-6 text-center">
          <div className="w-20 h-20 bg-white bg-opacity-20 rounded-full flex items-center justify-center mx-auto mb-4">
            <span className="text-3xl">✅</span>
          </div>
          <h1 className="text-2xl font-bold">Thanh toán thành công</h1>
          <p className="opacity-90">Cảm ơn bạn đã sử dụng dịch vụ của chúng tôi</p>
        </div>

        <div className="p-6">
          {/* Thông tin thanh toán */}
          <div className="mb-6">
            <h2 className="text-lg font-semibold text-gray-800 mb-4">Thông tin thanh toán</h2>
            <div className="space-y-3">
              <div className="flex justify-between items-center py-2 border-b">
                <span className="text-gray-600">Mã giao dịch:</span>
                <span className="font-medium">{queryParams.vnp_TransactionNo}</span>
              </div>
              <div className="flex justify-between items-center py-2 border-b">
                <span className="text-gray-600">Số tiền:</span>
                <span className="font-medium text-green-600">
                  {queryParams.vnp_Amount && 
                    (Number(queryParams.vnp_Amount) / 100).toLocaleString('vi-VN')
                  } VND
                </span>
              </div>
              <div className="flex justify-between items-center py-2 border-b">
                <span className="text-gray-600">Thời gian:</span>
                <span className="font-medium">
                  {new Date().toLocaleString('vi-VN')}
                </span>
              </div>
              <div className="flex justify-between items-center py-2 border-b">
                <span className="text-gray-600">Phương thức:</span>
                <span className="font-medium">VNPay</span>
              </div>
            </div>
          </div>

          {/* Thông tin cuộc hẹn */}
          {appointmentData && (
            <div className="mb-6">
              <h2 className="text-lg font-semibold text-gray-800 mb-4">Thông tin cuộc hẹn</h2>
              <div className="space-y-3">
                <div className="flex justify-between items-center py-2 border-b">
                  <span className="text-gray-600">Mã cuộc hẹn:</span>
                  <span className="font-medium">{appointmentData.id}</span>
                </div>
                <div className="flex justify-between items-center py-2 border-b">
                  <span className="text-gray-600">Luật sư:</span>
                  <span className="font-medium">{appointmentData.lawyerName}</span>
                </div>
                <div className="flex justify-between items-center py-2 border-b">
                  <span className="text-gray-600">Thời gian:</span>
                  <span className="font-medium">
                    {new Date(appointmentData.appointmentTime).toLocaleString('vi-VN')}
                  </span>
                </div>
                <div className="flex justify-between items-center py-2 border-b">
                  <span className="text-gray-600">Trạng thái:</span>
                  <span className="font-medium text-green-600">Đã xác nhận</span>
                </div>
              </div>
            </div>
          )}

          {/* Thông báo */}
          <div className="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-6">
            <p className="text-blue-800 text-sm">
              📧 Thông tin chi tiết về cuộc hẹn đã được gửi đến email của bạn. 
              Vui lòng kiểm tra hộp thư đến.
            </p>
          </div>

          {/* Action buttons */}
          <div className="flex flex-col sm:flex-row gap-3">
            <button 
              onClick={handleViewAppointments}
              className="flex-1 bg-blue-500 text-white py-3 px-4 rounded-lg hover:bg-blue-600 transition duration-200 font-medium"
            >
              Xem lịch hẹn của tôi
            </button>
            <button 
              onClick={handleBackToHome}
              className="flex-1 bg-gray-500 text-white py-3 px-4 rounded-lg hover:bg-gray-600 transition duration-200 font-medium"
            >
              Về trang chủ
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default PaymentSuccess;