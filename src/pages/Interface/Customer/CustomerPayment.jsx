import React, { useEffect, useState } from "react";
import api from "../../../config/axios";
import {
  Search,
  Filter,
  Download,
  Eye,
  RefreshCw,
  CheckCircle,
  Clock,
  XCircle,
  AlertCircle,
  DollarSign,
  CreditCard,
  Calendar,
  Copy,
  ExternalLink,
} from "lucide-react";
import { format, parseISO } from "date-fns";
import vi from "date-fns/locale/vi";

const CustomerPaymentManagement = () => {
  const [payments, setPayments] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [searchTerm, setSearchTerm] = useState("");
  const [statusFilter, setStatusFilter] = useState("all");
  const [currentPage, setCurrentPage] = useState(1);
  const [pageSize] = useState(8);
  const [selectedPayment, setSelectedPayment] = useState(null);
  const [showDetailModal, setShowDetailModal] = useState(false);

  const user = JSON.parse(localStorage.getItem("user") || "{}");
  const userId = user?.id;

  // Status options và colors
  const statusOptions = [
    { value: "all", label: "Tất cả trạng thái", color: "gray" },
    { value: "success", label: "Thành công", color: "green" },
    { value: "pending", label: "Chờ xử lý", color: "yellow" },
    { value: "failed", label: "Thất bại", color: "red" },
  ];

  const statusColors = {
    success: "bg-green-100 text-green-800 border-green-200",
    pending: "bg-yellow-100 text-yellow-800 border-yellow-200",
    failed: "bg-red-100 text-red-800 border-red-200",
  };

  const statusIcons = {
    success: CheckCircle,
    pending: Clock,
    failed: XCircle,
  };

  useEffect(() => {
    if (userId) {
      fetchPayments();
    }
  }, [userId, currentPage, statusFilter]);

  const fetchPayments = async () => {
    setLoading(true);
    setError(null);
    try {
      let url = `/api/Payments/by-user/${userId}?page=${currentPage}&pageSize=${pageSize}`;
      
      if (statusFilter !== "all") {
        url += `&status=${statusFilter}`;
      }

      console.log("Fetching customer payments from:", url);
      const response = await api.appointment.get(url);
      console.log("Customer payments data:", response.data);
      
      // Xử lý response data
      const paymentsData = response.data.payments || response.data.Payments || response.data || [];
      setPayments(Array.isArray(paymentsData) ? paymentsData : []);
    } catch (err) {
      console.error("Error fetching customer payments:", err);
      setError("Không thể tải lịch sử thanh toán. Vui lòng thử lại sau.");
    } finally {
      setLoading(false);
    }
  };

  const formatCurrency = (amount) => {
    return new Intl.NumberFormat("vi-VN", {
      style: "currency",
      currency: "VND",
    }).format(amount);
  };

  const formatDate = (dateString) => {
    if (!dateString) return "";
    try {
      const date = parseISO(dateString);
      return format(date, "HH:mm - dd/MM/yyyy", { locale: vi });
    } catch {
      return dateString;
    }
  };

  const formatDateShort = (dateString) => {
    if (!dateString) return "";
    try {
      const date = parseISO(dateString);
      return format(date, "dd/MM/yyyy", { locale: vi });
    } catch {
      return dateString;
    }
  };

  const getStatusBadge = (status) => {
    const StatusIcon = statusIcons[status] || AlertCircle;
    const statusText = status === "success" ? "Thành công" : 
                      status === "pending" ? "Chờ xử lý" : 
                      status === "failed" ? "Thất bại" : status;
    
    return (
      <span
        className={`inline-flex items-center gap-1 px-3 py-1 rounded-full text-sm font-medium border ${statusColors[status] || "bg-gray-100 text-gray-800 border-gray-200"}`}
      >
        <StatusIcon className="h-4 w-4" />
        {statusText}
      </span>
    );
  };

  const handleSearch = (e) => {
    e.preventDefault();
    setCurrentPage(1);
    fetchPayments();
  };

  const handleResetFilters = () => {
    setSearchTerm("");
    setStatusFilter("all");
    setCurrentPage(1);
  };

  const handleViewDetails = (payment) => {
    setSelectedPayment(payment);
    setShowDetailModal(true);
  };

  const handleCopyToClipboard = (text) => {
    navigator.clipboard.writeText(text);
    // Có thể thêm toast notification ở đây
    alert("Đã sao chép vào clipboard!");
  };

  const filteredPayments = payments.filter(payment => {
    const searchLower = searchTerm.toLowerCase();
    return (
      payment.orderId?.toLowerCase().includes(searchLower) ||
      payment.transactionId?.toLowerCase().includes(searchLower) ||
      payment.appointmentId?.toString().includes(searchLower) ||
      formatCurrency(payment.amount).toLowerCase().includes(searchLower)
    );
  });

  // Thống kê nhanh
  const stats = {
    total: payments.length,
    success: payments.filter(p => p.status === "success").length,
    pending: payments.filter(p => p.status === "pending").length,
    failed: payments.filter(p => p.status === "failed").length,
    totalAmount: payments.reduce((sum, p) => sum + (p.amount || 0), 0),
  };

  if (loading && payments.length === 0) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 flex items-center justify-center">
        <div className="text-center">
          <div className="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mb-4"></div>
          <p className="text-gray-600 text-lg">Đang tải lịch sử thanh toán...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 p-4 md:p-6 lg:p-8">
      <div className="max-w-6xl mx-auto space-y-6">
        {/* Header */}
        <div className="bg-white rounded-2xl shadow-lg p-6 border border-blue-100">
          <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
            <div>
              <h1 className="text-3xl font-bold text-gray-900 mb-2">
                Lịch Sử Thanh Toán
              </h1>
              <p className="text-gray-600">
                Theo dõi và quản lý tất cả giao dịch thanh toán của bạn
              </p>
            </div>
            <button
              onClick={fetchPayments}
              className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors shadow-md"
            >
              <RefreshCw className="h-4 w-4" />
              Làm mới
            </button>
          </div>
        </div>

        {/* Statistics Cards */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          <div className="bg-white rounded-xl shadow-lg p-6 border border-gray-200 hover:shadow-xl transition-shadow">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-gray-600">Tổng giao dịch</p>
                <p className="text-2xl font-bold text-gray-900">{stats.total}</p>
              </div>
              <div className="p-3 bg-blue-100 rounded-lg">
                <CreditCard className="h-6 w-6 text-blue-600" />
              </div>
            </div>
          </div>

          <div className="bg-white rounded-xl shadow-lg p-6 border border-gray-200 hover:shadow-xl transition-shadow">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-gray-600">Thành công</p>
                <p className="text-2xl font-bold text-green-600">{stats.success}</p>
              </div>
              <div className="p-3 bg-green-100 rounded-lg">
                <CheckCircle className="h-6 w-6 text-green-600" />
              </div>
            </div>
          </div>

          <div className="bg-white rounded-xl shadow-lg p-6 border border-gray-200 hover:shadow-xl transition-shadow">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-gray-600">Chờ xử lý</p>
                <p className="text-2xl font-bold text-yellow-600">{stats.pending}</p>
              </div>
              <div className="p-3 bg-yellow-100 rounded-lg">
                <Clock className="h-6 w-6 text-yellow-600" />
              </div>
            </div>
          </div>

          <div className="bg-white rounded-xl shadow-lg p-6 border border-gray-200 hover:shadow-xl transition-shadow">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-gray-600">Tổng tiền</p>
                <p className="text-2xl font-bold text-purple-600">
                  {formatCurrency(stats.totalAmount)}
                </p>
              </div>
              <div className="p-3 bg-purple-100 rounded-lg">
                <DollarSign className="h-6 w-6 text-purple-600" />
              </div>
            </div>
          </div>
        </div>

        {/* Filters */}
        <div className="bg-white rounded-xl shadow-lg p-6 border border-gray-200">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4 mb-4">
            {/* Search */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                🔍 Tìm kiếm
              </label>
              <div className="relative">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
                <input
                  type="text"
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  placeholder="Order ID, mã giao dịch, số tiền..."
                  className="pl-10 pr-4 py-3 w-full border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                />
              </div>
            </div>

            {/* Status Filter */}
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-2">
                📊 Trạng thái
              </label>
              <select
                value={statusFilter}
                onChange={(e) => setStatusFilter(e.target.value)}
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
              >
                {statusOptions.map(option => (
                  <option key={option.value} value={option.value}>
                    {option.label}
                  </option>
                ))}
              </select>
            </div>

            {/* Action Buttons */}
            <div className="flex items-end gap-2">
              <button
                onClick={handleSearch}
                className="flex-1 px-4 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors shadow-md"
              >
                Tìm kiếm
              </button>
              <button
                onClick={handleResetFilters}
                className="px-4 py-3 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300 transition-colors"
              >
                Reset
              </button>
            </div>
          </div>
        </div>

        {/* Payments List */}
        <div className="bg-white rounded-xl shadow-lg border border-gray-200 overflow-hidden">
          <div className="px-6 py-4 border-b border-gray-200 bg-gradient-to-r from-blue-50 to-indigo-50">
            <h2 className="text-lg font-semibold text-gray-900">
              Danh sách thanh toán ({filteredPayments.length})
            </h2>
          </div>

          {error ? (
            <div className="p-8 text-center">
              <AlertCircle className="h-16 w-16 text-red-500 mx-auto mb-4" />
              <p className="text-red-600 mb-4 text-lg">{error}</p>
              <button
                onClick={fetchPayments}
                className="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors shadow-md"
              >
                Thử lại
              </button>
            </div>
          ) : filteredPayments.length === 0 ? (
            <div className="p-12 text-center">
              <CreditCard className="h-20 w-20 text-gray-400 mx-auto mb-4" />
              <p className="text-gray-600 text-lg mb-2">Chưa có giao dịch nào</p>
              <p className="text-gray-500">Các giao dịch thanh toán của bạn sẽ xuất hiện ở đây</p>
            </div>
          ) : (
            <>
              {/* Mobile View - Cards */}
              <div className="lg:hidden">
                <div className="p-4 space-y-4">
                  {filteredPayments.map((payment) => (
                    <div key={payment.id} className="bg-gray-50 rounded-lg p-4 border border-gray-200 hover:shadow-md transition-shadow">
                      <div className="flex justify-between items-start mb-3">
                        <div>
                          <div className="flex items-center gap-2 mb-1">
                            <CreditCard className="h-4 w-4 text-gray-500" />
                            <span className="font-semibold text-gray-900">{payment.orderId}</span>
                          </div>
                          <div className="text-sm text-gray-600">
                            {formatDateShort(payment.createdAt)}
                          </div>
                        </div>
                        {getStatusBadge(payment.status)}
                      </div>
                      
                      <div className="grid grid-cols-2 gap-4 text-sm">
                        <div>
                          <span className="text-gray-500">Số tiền:</span>
                          <div className="font-semibold text-green-600">
                            {formatCurrency(payment.amount)}
                          </div>
                        </div>
                        <div>
                          <span className="text-gray-500">Appointment:</span>
                          <div className="font-semibold">#{payment.appointmentId}</div>
                        </div>
                      </div>

                      <div className="mt-3 flex justify-end">
                        <button
                          onClick={() => handleViewDetails(payment)}
                          className="flex items-center gap-1 px-3 py-1 text-blue-600 hover:text-blue-800 transition-colors text-sm"
                        >
                          <Eye className="h-4 w-4" />
                          Chi tiết
                        </button>
                      </div>
                    </div>
                  ))}
                </div>
              </div>

              {/* Desktop View - Table */}
              <div className="hidden lg:block">
                <div className="overflow-x-auto">
                  <table className="w-full">
                    <thead className="bg-gray-50">
                      <tr>
                        <th className="px-6 py-4 text-left text-sm font-semibold text-gray-700 uppercase tracking-wider">
                          Thông tin giao dịch
                        </th>
                        <th className="px-6 py-4 text-left text-sm font-semibold text-gray-700 uppercase tracking-wider">
                          Số tiền
                        </th>
                        <th className="px-6 py-4 text-left text-sm font-semibold text-gray-700 uppercase tracking-wider">
                          Trạng thái
                        </th>
                        <th className="px-6 py-4 text-left text-sm font-semibold text-gray-700 uppercase tracking-wider">
                          Thời gian
                        </th>
                        <th className="px-6 py-4 text-left text-sm font-semibold text-gray-700 uppercase tracking-wider">
                          Thao tác
                        </th>
                      </tr>
                    </thead>
                    <tbody className="bg-white divide-y divide-gray-200">
                      {filteredPayments.map((payment) => (
                        <tr key={payment.id} className="hover:bg-blue-50 transition-colors">
                          <td className="px-6 py-4">
                            <div className="flex items-center gap-3">
                              <div className="p-2 bg-blue-100 rounded-lg">
                                <CreditCard className="h-5 w-5 text-blue-600" />
                              </div>
                              <div>
                                <div className="font-semibold text-gray-900">
                                  {payment.orderId}
                                </div>
                                {payment.transactionId && (
                                  <div className="text-sm text-gray-500 flex items-center gap-1">
                                    TXN: {payment.transactionId}
                                    <button
                                      onClick={() => handleCopyToClipboard(payment.transactionId)}
                                      className="text-gray-400 hover:text-gray-600"
                                    >
                                      <Copy className="h-3 w-3" />
                                    </button>
                                  </div>
                                )}
                                <div className="text-sm text-gray-500">
                                  #{payment.appointmentId} • {payment.vendor?.toUpperCase()}
                                </div>
                              </div>
                            </div>
                          </td>
                          <td className="px-6 py-4">
                            <div className="text-lg font-bold text-green-600">
                              {formatCurrency(payment.amount)}
                            </div>
                          </td>
                          <td className="px-6 py-4">
                            {getStatusBadge(payment.status)}
                          </td>
                          <td className="px-6 py-4">
                            <div className="text-sm text-gray-900">
                              {formatDate(payment.createdAt)}
                            </div>
                          </td>
                          <td className="px-6 py-4">
                            <button
                              onClick={() => handleViewDetails(payment)}
                              className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors shadow-sm"
                            >
                              <Eye className="h-4 w-4" />
                              Chi tiết
                            </button>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>

              {/* Pagination */}
              {filteredPayments.length > pageSize && (
                <div className="px-6 py-4 border-t border-gray-200 bg-gray-50">
                  <div className="flex items-center justify-between">
                    <div className="text-sm text-gray-700">
                      Hiển thị {filteredPayments.length} kết quả
                    </div>
                    <div className="flex gap-2">
                      <button
                        onClick={() => setCurrentPage(prev => Math.max(prev - 1, 1))}
                        disabled={currentPage === 1}
                        className="px-4 py-2 border border-gray-300 rounded-lg disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gray-100 transition-colors"
                      >
                        ← Trước
                      </button>
                      <span className="px-4 py-2 text-gray-700">
                        Trang {currentPage}
                      </span>
                      <button
                        onClick={() => setCurrentPage(prev => prev + 1)}
                        disabled={filteredPayments.length < pageSize}
                        className="px-4 py-2 border border-gray-300 rounded-lg disabled:opacity-50 disabled:cursor-not-allowed hover:bg-gray-100 transition-colors"
                      >
                        Sau →
                      </button>
                    </div>
                  </div>
                </div>
              )}
            </>
          )}
        </div>
      </div>

      {/* Payment Detail Modal */}
      {showDetailModal && selectedPayment && (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-xl shadow-2xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
            <div className="p-6 border-b border-gray-200 bg-gradient-to-r from-blue-50 to-indigo-50">
              <div className="flex items-center justify-between">
                <h3 className="text-xl font-bold text-gray-900">
                  📋 Chi tiết thanh toán
                </h3>
                <button
                  onClick={() => setShowDetailModal(false)}
                  className="text-gray-400 hover:text-gray-600 transition-colors"
                >
                  <XCircle className="h-6 w-6" />
                </button>
              </div>
            </div>

            <div className="p-6 space-y-6">
              {/* Order Info */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <h4 className="text-sm font-medium text-gray-500 mb-2 flex items-center gap-2">
                    <CreditCard className="h-4 w-4" />
                    Order ID
                  </h4>
                  <div className="flex items-center gap-2">
                    <p className="text-lg font-semibold text-gray-900">
                      {selectedPayment.orderId}
                    </p>
                    <button
                      onClick={() => handleCopyToClipboard(selectedPayment.orderId)}
                      className="text-gray-400 hover:text-gray-600"
                    >
                      <Copy className="h-4 w-4" />
                    </button>
                  </div>
                </div>
                <div>
                  <h4 className="text-sm font-medium text-gray-500 mb-2">Mã giao dịch</h4>
                  <div className="flex items-center gap-2">
                    <p className="text-lg font-semibold text-gray-900">
                      {selectedPayment.transactionId || "N/A"}
                    </p>
                    {selectedPayment.transactionId && (
                      <button
                        onClick={() => handleCopyToClipboard(selectedPayment.transactionId)}
                        className="text-gray-400 hover:text-gray-600"
                      >
                        <Copy className="h-4 w-4" />
                      </button>
                    )}
                  </div>
                </div>
              </div>

              {/* Amount & Status */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <h4 className="text-sm font-medium text-gray-500 mb-2">💰 Số tiền</h4>
                  <p className="text-2xl font-bold text-green-600">
                    {formatCurrency(selectedPayment.amount)}
                  </p>
                </div>
                <div>
                  <h4 className="text-sm font-medium text-gray-500 mb-2">📊 Trạng thái</h4>
                  <div className="text-lg">
                    {getStatusBadge(selectedPayment.status)}
                  </div>
                </div>
              </div>

              {/* Vendor & Appointment */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <h4 className="text-sm font-medium text-gray-500 mb-2">🏦 Phương thức</h4>
                  <div className="flex items-center gap-2">
                    <CreditCard className="h-5 w-5 text-gray-400" />
                    <span className="text-lg font-medium text-gray-900 capitalize">
                      {selectedPayment.vendor}
                    </span>
                  </div>
                </div>
                <div>
                  <h4 className="text-sm font-medium text-gray-500 mb-2">📅 Lịch hẹn</h4>
                  <div className="flex items-center gap-2">
                    <Calendar className="h-5 w-5 text-gray-400" />
                    <span className="text-lg font-medium text-gray-900">
                      #{selectedPayment.appointmentId}
                    </span>
                  </div>
                </div>
              </div>

              {/* Dates */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                  <h4 className="text-sm font-medium text-gray-500 mb-2">🕐 Thời gian tạo</h4>
                  <p className="text-lg text-gray-900">
                    {formatDate(selectedPayment.createdAt)}
                  </p>
                </div>
                <div>
                  <h4 className="text-sm font-medium text-gray-500 mb-2">🔄 Cập nhật cuối</h4>
                  <p className="text-lg text-gray-900">
                    {formatDate(selectedPayment.updatedAt)}
                  </p>
                </div>
              </div>

              {/* Message */}
              {selectedPayment.message && (
                <div>
                  <h4 className="text-sm font-medium text-gray-500 mb-2">💬 Thông báo</h4>
                  <p className="text-lg text-gray-900 bg-gray-50 p-4 rounded-lg border">
                    {selectedPayment.message}
                  </p>
                </div>
              )}
            </div>

            <div className="p-6 border-t border-gray-200 bg-gray-50">
              <div className="flex justify-end gap-3">
                <button
                  onClick={() => setShowDetailModal(false)}
                  className="px-6 py-2 bg-gray-300 text-gray-700 rounded-lg hover:bg-gray-400 transition-colors"
                >
                  Đóng
                </button>
                {selectedPayment.status === "pending" && (
                  <button
                    onClick={() => {
                      // Handle retry payment or contact support
                      alert("Liên hệ hỗ trợ để được giúp đỡ!");
                    }}
                    className="px-6 py-2 bg-orange-600 text-white rounded-lg hover:bg-orange-700 transition-colors"
                  >
                    Cần hỗ trợ
                  </button>
                )}
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default CustomerPaymentManagement;