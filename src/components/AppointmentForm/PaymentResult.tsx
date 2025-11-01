// components/PaymentResult.tsx
import React, { useEffect, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { CheckCircle, XCircle, Loader2, RefreshCw } from 'lucide-react';
import api from '../../config/axios';

const PaymentResult: React.FC = () => {
  const [status, setStatus] = useState<'processing' | 'success' | 'failed'>('processing');
  const [message, setMessage] = useState<string>('');
  const [appointmentId, setAppointmentId] = useState<number | null>(null);
  const [isRetrying, setIsRetrying] = useState(false);
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();

  useEffect(() => {
    const processPaymentResult = async () => {
      try {
        const vnpResponseCode = searchParams.get('vnp_ResponseCode');
        const vnpTransactionNo = searchParams.get('vnp_TransactionNo');
        const vnpAmount = searchParams.get('vnp_Amount');
        const vnpOrderInfo = searchParams.get('vnp_OrderInfo');
        const vnpTxnRef = searchParams.get('vnp_TxnRef');

        console.log('Payment result params:', {
          vnpResponseCode,
          vnpTransactionNo,
          vnpAmount,
          vnpOrderInfo,
          vnpTxnRef
        });

        // Gọi API return endpoint để backend xử lý
        try {
          const queryString = searchParams.toString();
          console.log('Calling return endpoint with params:', queryString);

          const response = await api.appointment.get(`/api/Payments/return?${queryString}`);

          if (response && response.data) {
            const result = response.data;
            console.log('Return endpoint result:', result);

            if (result.status === 'success') {
              setStatus('success');
              setMessage('Thanh toán thành công! Lịch hẹn của bạn đã được xác nhận.');

              // Extract appointmentId từ orderId
              let extractedAppointmentId: number | null = null;
              try {
                const orderId = result.orderId || vnpTxnRef;
                if (orderId) {
                  const match = orderId.match(/(?:APPT|RETRY)-(\d+)-/);
                  if (match && match[1]) {
                    extractedAppointmentId = parseInt(match[1]);
                  }
                }
              } catch (err) {
                console.warn('Could not extract appointmentId from orderId:', err);
              }

              // Nếu không extract được từ orderId, thử gọi API để lấy payment và appointment
              let appointmentData = null;
              const finalAppointmentId = extractedAppointmentId || appointmentId;

              if (finalAppointmentId) {
                try {
                  console.log('Fetching appointment data for ID:', finalAppointmentId);
                  const appointmentResponse = await api.appointment.get(`/api/Payments/by-appointment/${finalAppointmentId}`);
                  if (appointmentResponse?.data) {
                    appointmentData = appointmentResponse.data;
                    console.log('Appointment data fetched:', appointmentData);
                  }
                } catch (err) {
                  console.warn('Could not fetch appointment data:', err);
                  // Fallback: vẫn có appointmentId để hiển thị
                }
              }

              // Chuyển hướng đến trang thành công sau 3 giây
              setTimeout(() => {
                navigate('/appointment-success', {
                  state: {
                    paymentStatus: 'success',
                    transactionNo: result.transactionId,
                    amount: result.amount || (vnpAmount ? parseInt(vnpAmount) / 100 : 0),
                    appointmentData: appointmentData, // Appointment data from API
                    appointmentId: finalAppointmentId
                  }
                });
              }, 3000);
            } else {
              setStatus('failed');
              setMessage(result.message || 'Thanh toán thất bại');

              // Extract appointmentId from orderId if possible (format: APPT-{appointmentId}-{timestamp})
              // Or try to get from payment API
              try {
                const orderId = result.orderId || vnpTxnRef;
                if (orderId) {
                  // Try to extract appointmentId from orderId format: APPT-{id}-{timestamp} or RETRY-{id}-{timestamp}
                  const match = orderId.match(/(?:APPT|RETRY)-(\d+)-/);
                  if (match && match[1]) {
                    setAppointmentId(parseInt(match[1]));
                  } else {
                    // Try to get payment by orderId and extract appointmentId
                    try {
                      const paymentResponse = await api.appointment.get(`/api/Payments/order/${orderId}`);
                      if (paymentResponse?.data?.appointmentId) {
                        setAppointmentId(paymentResponse.data.appointmentId);
                      }
                    } catch (err) {
                      console.warn('Could not fetch payment by orderId:', err);
                    }
                  }
                }
              } catch (err) {
                console.warn('Could not extract appointmentId:', err);
              }
            }
          } else {
            setStatus('failed');
            setMessage('Không thể xác minh thanh toán. Vui lòng thử lại.');
            return;
          }
        } catch (apiError) {
          console.error('API error:', apiError);
          // Fallback to original logic
          if (vnpResponseCode === '00') {
            setStatus('success');
            setMessage('Thanh toán thành công! Lịch hẹn của bạn đã được xác nhận.');

            setTimeout(() => {
              navigate('/appointment-success', {
                state: {
                  paymentStatus: 'success',
                  transactionNo: vnpTransactionNo,
                  amount: vnpAmount ? parseInt(vnpAmount) / 100 : 0,
                  appointmentId: appointmentId
                }
              });
            }, 3000);
          } else {
            setStatus('failed');
            const errorMessages: { [key: string]: string } = {
              '07': 'Giao dịch bị nghi ngờ (gian lận)',
              '09': 'Giao dịch không thành công',
              '10': 'Giao dịch không thành công',
              '11': 'Giao dịch không thành công',
              '12': 'Giao dịch không thành công',
              '13': 'Giao dịch không thành công',
              '24': 'Giao dịch không thành công',
              '51': 'Tài khoản không đủ số dư',
              '65': 'Tài khoản đã vượt quá hạn mức giao dịch',
              '75': 'Ngân hàng thanh toán đang bảo trì',
              '79': 'Khách hàng nhập sai mật khẩu thanh toán',
              '99': 'Lỗi không xác định'
            };

            const errorMessage = errorMessages[vnpResponseCode || '99'] || 'Thanh toán thất bại';
            setMessage(errorMessage);

            // Try to extract appointmentId from orderId
            try {
              const orderId = vnpTxnRef;
              if (orderId) {
                const match = orderId.match(/(?:APPT|RETRY)-(\d+)-/);
                if (match && match[1]) {
                  setAppointmentId(parseInt(match[1]));
                }
              }
            } catch (err) {
              console.warn('Could not extract appointmentId:', err);
            }
          }
        }
      } catch (error) {
        setStatus('failed');
        setMessage('Có lỗi xảy ra khi xử lý kết quả thanh toán');
      }
    };

    processPaymentResult();
  }, [searchParams, navigate]);

  const renderContent = () => {
    switch (status) {
      case 'processing':
        return (
          <div className="text-center">
            <Loader2 className="h-16 w-16 animate-spin text-primary-600 mx-auto mb-4" />
            <h3 className="text-xl font-semibold text-gray-900 mb-2">Đang xử lý kết quả thanh toán...</h3>
            <p className="text-gray-600">Vui lòng chờ trong giây lát.</p>
          </div>
        );

      case 'success':
        return (
          <div className="text-center">
            <CheckCircle className="h-16 w-16 text-green-600 mx-auto mb-4" />
            <h3 className="text-xl font-semibold text-gray-900 mb-2">Thanh toán thành công!</h3>
            <p className="text-gray-600">{message}</p>
            <p className="text-sm text-gray-500 mt-2">Bạn sẽ được chuyển hướng tự động...</p>
          </div>
        );

      case 'failed':
        const handleRetryPayment = async () => {
          if (!appointmentId) {
            setMessage('Không thể xác định lịch hẹn để thử lại thanh toán. Vui lòng quay lại trang đặt lịch.');
            return;
          }

          setIsRetrying(true);
          try {
            // Call retry payment API
            const response = await api.appointment.post(`/api/Payments/retry-payment/${appointmentId}`, {
              vendor: 'vnpay',
              returnUrl: `${window.location.origin}/payment-result`
            });

            if (response?.data) {
              // Redirect to payment URL
              window.location.href = response.data;
            } else {
              throw new Error('Không nhận được URL thanh toán từ server');
            }
          } catch (error: any) {
            console.error('Retry payment error:', error);
            setMessage(error.response?.data?.message || error.message || 'Không thể thử lại thanh toán. Vui lòng thử lại sau.');
            setIsRetrying(false);
          }
        };

        const handleCancelAppointment = async () => {
          if (!appointmentId) {
            setMessage('Không thể xác định lịch hẹn để hủy. Vui lòng quay lại trang đặt lịch.');
            return;
          }

          try {
            await api.appointment.put(`/api/Appointment/${appointmentId}/cancel-payment-pending`);
            setMessage('Đã hủy lịch hẹn thành công.');

            setTimeout(() => {
              navigate('/appointment', {
                state: {
                  paymentStatus: 'cancelled',
                  message: 'Lịch hẹn đã được hủy'
                }
              });
            }, 2000);
          } catch (error: any) {
            console.error('Cancel appointment error:', error);
            setMessage(error.response?.data?.message || 'Không thể hủy lịch hẹn. Vui lòng thử lại sau.');
          }
        };

        return (
          <div className="text-center">
            <XCircle className="h-16 w-16 text-red-600 mx-auto mb-4" />
            <h3 className="text-xl font-semibold text-gray-900 mb-2">Thanh toán thất bại</h3>
            <p className="text-gray-600">{message}</p>

            {appointmentId && (
              <div className="mt-4 space-y-2">
                <p className="text-sm text-gray-500">
                  Lịch hẹn của bạn vẫn được lưu và đang chờ thanh toán. Bạn có thể:
                </p>
                <div className="flex flex-col sm:flex-row gap-2 justify-center mt-4">
                  <button
                    onClick={handleRetryPayment}
                    disabled={isRetrying}
                    className="px-6 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors disabled:opacity-50 flex items-center justify-center gap-2"
                  >
                    {isRetrying ? (
                      <>
                        <Loader2 className="h-4 w-4 animate-spin" />
                        <span>Đang xử lý...</span>
                      </>
                    ) : (
                      <>
                        <RefreshCw className="h-4 w-4" />
                        <span>Thử thanh toán lại</span>
                      </>
                    )}
                  </button>
                  <button
                    onClick={handleCancelAppointment}
                    className="px-6 py-2 bg-gray-600 text-white rounded-lg hover:bg-gray-700 transition-colors"
                  >
                    Hủy lịch hẹn
                  </button>
                  <button
                    onClick={() => navigate('/appointment')}
                    className="px-6 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors"
                  >
                    Quay lại đặt lịch
                  </button>
                </div>
              </div>
            )}

            {!appointmentId && (
              <>
                <p className="text-sm text-gray-500 mt-2">Vui lòng quay lại trang đặt lịch để thử lại.</p>
                <button
                  onClick={() => navigate('/appointment')}
                  className="mt-4 px-6 py-2 bg-primary-600 text-white rounded-lg hover:bg-primary-700 transition-colors"
                >
                  Quay lại đặt lịch
                </button>
              </>
            )}
          </div>
        );

      default:
        return null;
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 flex items-center justify-center p-4">
      <div className="bg-white rounded-lg shadow-md p-8 max-w-md w-full">
        {renderContent()}
      </div>
    </div>
  );
};

export default PaymentResult;