import api from "../config/axios";

export interface CreatePaymentForAppointmentPayload {
  vendor: string; // "vnpay" | "momo"
  orderId: string;
  lawyerId: number;
  durationHours: number;
  orderInfo?: string;
  returnUrl?: string;
  // ipnUrl omitted intentionally
}

export interface CreatePaymentResponse {
  vendor: string;
  paymentUrl: string; // hoặc PaymentUrl tuỳ backend
  orderId: string;
  qrImageBase64?: string;
}

export async function createPaymentForAppointment(
  payload: CreatePaymentForAppointmentPayload
): Promise<CreatePaymentResponse> {
  const res = await api.post("/api/payments/create-url-for-appointment", payload);
  // normalize keys to lowercase if backend returns PascalCase
  const data = res.data || {};
  return {
    vendor: data.vendor || data.Vendor,
    paymentUrl: data.paymentUrl || data.PaymentUrl || data.payment_url,
    orderId: data.orderId || data.OrderId,
    qrImageBase64: data.qrImageBase64 || data.QrImageBase64,
  };
}