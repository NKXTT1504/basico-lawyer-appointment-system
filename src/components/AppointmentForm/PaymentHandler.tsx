// hooks/usePayment.ts
import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import api from '../../config/axios';

interface PaymentData {
  appointmentId: string;
  amount: number;
  serviceNames: string[];
  lawyerName: string;
  appointmentDate: string;
}

export const usePayment = () => {
  const [isProcessing, setIsProcessing] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const navigate = useNavigate();

  const createPaymentUrl = async (paymentData: PaymentData) => {
    setIsProcessing(true);
    setError(null);

    try {
      console.log('Creating payment URL with data:', paymentData);

      // Tạo orderInfo từ dữ liệu
      const orderInfo = `Dat lich ${paymentData.serviceNames.join(', ')} - ${paymentData.lawyerName} - ${paymentData.appointmentDate}`;

      const requestData = {
        vendor: "vnpay",
        orderId: `APPT-${paymentData.appointmentId}-${Date.now()}`,
        lawyerId: parseInt(paymentData.appointmentId.split('-')[1]) || 0, // Giả sử appointmentId có format "lawyerId-appointmentId"
        durationHours: 1, // Mặc định 1 giờ, bạn có thể tính toán dựa trên dịch vụ
        orderInfo: orderInfo,
        returnUrl: `${window.location.origin}/payment-result`,
        amount: paymentData.amount
      };

      console.log('Sending payment request:', requestData);

      const response = await api.appointment.post('/api/Payments/create-url-for-appointment', requestData);
      
      console.log('Payment URL response:', response.data);

      if (response.data.paymentUrl) {
        // Chuyển hướng đến trang thanh toán VNPay
        window.location.href = response.data.paymentUrl;
      } else {
        throw new Error('Không nhận được URL thanh toán từ server');
      }

    } catch (error: any) {
      console.error('Payment creation error:', error);
      const errorMessage = error.response?.data?.message || error.message || 'Không thể tạo URL thanh toán';
      setError(errorMessage);
      throw new Error(errorMessage);
    } finally {
      setIsProcessing(false);
    }
  };

  return {
    createPaymentUrl,
    isProcessing,
    error
  };
};