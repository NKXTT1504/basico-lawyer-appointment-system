import React from 'react';
import { CreditCard, AlertCircle, X } from 'lucide-react';

interface PaymentInformProps {
  open: boolean;
  count?: number;
  onConfirm: () => void;
  onCancel: () => void;
  onRemoveOneService?: () => void;
}

const PaymentInform: React.FC<PaymentInformProps> = ({ 
  open, 
  count = 0, 
  onConfirm, 
  onCancel,
  onRemoveOneService 
}) => {
  if (!open) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4" role="dialog" aria-modal="true">
      {/* Backdrop với hiệu ứng mờ */}
      <div 
        className="absolute inset-0 bg-black/60 backdrop-blur-sm transition-opacity duration-300"
        onClick={onCancel}
      />
      
      {/* Modal */}
      <div
        className="relative bg-white rounded-lg shadow-lg max-w-md w-full transform transition-all duration-300 scale-100"
        onClick={(e) => e.stopPropagation()}
      >
        {/* Header */}
        <div className="flex items-center justify-between p-6 border-b border-gray-200">
          <div className="flex items-center space-x-3">
            <div className="p-2 bg-primary-100 rounded-lg">
              <CreditCard className="h-6 w-6 text-primary-600" />
            </div>
            <div>
              <h3 className="text-lg font-semibold text-gray-900">Thông báo đặt cọc</h3>
              <p className="text-sm text-gray-500 mt-1">Chính sách đặt lịch nhiều dịch vụ</p>
            </div>
          </div>
          <button
            onClick={onCancel}
            className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
          >
            <X className="h-5 w-5 text-gray-400 hover:text-gray-600" />
          </button>
        </div>

        {/* Content */}
        <div className="p-6">
          <div className="flex items-start space-x-3 mb-4">
            <AlertCircle className="h-5 w-5 text-amber-500 mt-0.5 flex-shrink-0" />
            <div>
              <p className="text-gray-700 leading-relaxed">
                Bạn đã chọn <span className="font-medium text-primary-700">{count} dịch vụ</span>. 
                Theo chính sách của chúng tôi, cần đặt cọc trước <span className="font-medium">30%</span> 
                của giờ làm luật sư để tiến hành đặt lịch.
              </p>
            </div>
          </div>

          {/* Thông tin chi tiết */}
          <div className="bg-primary-50 border border-primary-200 rounded-lg p-4 mb-6">
            <div className="flex items-center space-x-2 mb-2">
              <div className="w-2 h-2 bg-primary-500 rounded-full"></div>
              <span className="text-sm font-medium text-primary-800">Chi tiết đặt cọc</span>
            </div>
            <div className="space-y-2 text-sm text-primary-700">
              <div className="flex justify-between">
                <span>Số dịch vụ:</span>
                <span className="font-medium">{count} dịch vụ</span>
              </div>
              <div className="flex justify-between">
                <span>Tỷ lệ đặt cọc:</span>
                <span className="font-medium">30%</span>
              </div>
              <div className="flex justify-between border-t border-primary-200 pt-2">
                <span>Phương thức:</span>
                <span className="font-medium">Chuyển khoản ngân hàng</span>
              </div>
            </div>
          </div>

          {/* Lưu ý */}
          <div className="bg-amber-50 border border-amber-200 rounded-lg p-4 mb-6">
            <div className="flex items-start space-x-2">
              <div className="w-2 h-2 bg-amber-500 rounded-full mt-2 flex-shrink-0"></div>
              <div>
                <p className="text-sm text-amber-800 leading-relaxed">
                  <strong>Lưu ý quan trọng:</strong> Bạn có thể chọn ít hơn {count} dịch vụ 
                  để không cần đặt cọc. Đặt cọc sẽ được hoàn trả 100% nếu hủy lịch trước 24 giờ.
                </p>
              </div>
            </div>
          </div>
        </div>

        {/* Footer với buttons */}
        <div className="flex flex-col sm:flex-row gap-3 p-6 border-t border-gray-200 bg-gray-50 rounded-b-lg">
          <button
            type="button"
            onClick={onRemoveOneService}
            className="flex-1 px-4 py-2 rounded-md border border-gray-300 text-gray-700 hover:bg-gray-100 transition-colors font-medium flex items-center justify-center space-x-2"
          >
            <span>Chọn ít hơn</span>
            <span className="bg-gray-200 text-gray-600 px-2 py-1 rounded text-sm">
              {count - 1} dịch vụ
            </span>
          </button>
          <button
            type="button"
            onClick={onConfirm}
            className="flex-1 px-4 py-2 bg-primary-700 hover:bg-primary-800 text-white rounded-md font-medium transition-colors flex items-center justify-center space-x-2"
          >
            <CreditCard className="h-4 w-4" />
            <span>Xác nhận đặt cọc</span>
          </button>
        </div>
      </div>
    </div>
  );
};

export default PaymentInform;