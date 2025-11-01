import React, { useEffect, useState } from "react";
import api from "../../../config/axios";
import {
  BarChart,
  Bar,
  LineChart,
  Line,
  PieChart,
  Pie,
  Cell,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  Legend,
  Area,
  AreaChart,
} from "recharts";
import {
  DollarSign,
  Calendar,
  Star,
  TrendingUp,
  CheckCircle2,
  AlertCircle,
  CreditCard,
} from "lucide-react";

const Dashboard = () => {
  const [statistics, setStatistics] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [dateRange, setDateRange] = useState({
    fromDate: null,
    toDate: null,
  });

  // Color schemes
  const COLORS = {
    primary: "#3B82F6",
    success: "#10B981",
    warning: "#F59E0B",
    danger: "#EF4444",
    info: "#8B5CF6",
  };

  const statusColors = {
    Pending: COLORS.warning,
    Confirmed: COLORS.primary,
    Completed: COLORS.success,
    PaymentPending: COLORS.info,
    Cancelled: COLORS.danger,
    success: COLORS.success,
    pending: COLORS.warning,
    failed: COLORS.danger,
  };

  useEffect(() => {
    fetchDashboardData();
  }, [dateRange]);

const fetchDashboardData = async () => {
  setLoading(true);
  setError(null);
  try {
    let url = "/api/Dashboard/statistics";
    const params = new URLSearchParams();
    
    if (dateRange.fromDate) {
      params.append("fromDate", dateRange.fromDate.toISOString());
    }
    if (dateRange.toDate) {
      params.append("toDate", dateRange.toDate.toISOString());
    }
    
    if (params.toString()) {
      url += `?${params.toString()}`;
    }

    console.log("Fetching dashboard data from:", url);
    const response = await api.auth.get(url); // Sử dụng api.auth.get() như bình thường
    console.log("Dashboard data received:", response.data);
    setStatistics(response.data);
  } catch (err) {
    console.error("Error fetching dashboard data:", err);
    setError("Không thể tải dữ liệu thống kê. Vui lòng thử lại sau.");
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
      const date = new Date(dateString);
      return date.toLocaleDateString("vi-VN");
    } catch {
      return dateString;
    }
  };

  const handleDateChange = (type, value) => {
    setDateRange((prev) => ({
      ...prev,
      [type]: value ? new Date(value) : null,
    }));
  };

  const resetDateRange = () => {
    setDateRange({ fromDate: null, toDate: null });
  };

  // Prepare chart data - SỬA DATA STRUCTURE Ở ĐÂY
  const paymentStatusData = statistics?.payments?.countByStatus
    ? Object.entries(statistics.payments.countByStatus).map(([key, value]) => ({
        name: key === "success" ? "Thành công" : key === "pending" ? "Chờ xử lý" : "Thất bại",
        value,
        status: key,
      }))
    : [];

  const appointmentStatusData = statistics?.appointments?.countByStatus
    ? Object.entries(statistics.appointments.countByStatus).map(([key, value]) => ({
        name: key,
        value,
      }))
    : [];

  const reviewRatingData = statistics?.reviews?.ratingDistribution
    ? Object.entries(statistics.reviews.ratingDistribution).map(([key, value]) => ({
        name: `${key} sao`,
        value,
        rating: parseInt(key),
      }))
    : [];

  // Stat Cards Data - SỬA PROPERTY NAMES
  const statCards = [
    {
      title: "Tổng Thanh Toán",
      value: statistics?.payments?.totalAmount
        ? formatCurrency(statistics.payments.totalAmount)
        : "0 đ",
      icon: DollarSign,
      color: COLORS.success,
      bgColor: "bg-green-50",
      change: "+12.5%",
      subtitle: `${statistics?.payments?.totalCount || 0} giao dịch`,
    },
    {
      title: "Tổng Lịch Hẹn",
      value: statistics?.appointments?.totalCount || 0,
      icon: Calendar,
      color: COLORS.primary,
      bgColor: "bg-blue-50",
      change: "+8.2%",
      subtitle: `50 appointments`, // Temporary fix
    },
    {
      title: "Đánh Giá Trung Bình",
      value: statistics?.reviews?.averageRating
        ? statistics.reviews.averageRating.toFixed(1)
        : "0.0",
      icon: Star,
      color: COLORS.warning,
      bgColor: "bg-yellow-50",
      change: "+2.3%",
      subtitle: `${statistics?.reviews?.totalCount || 0} lượt đánh giá`,
    },
    {
      title: "Lịch Hẹn Hoàn Thành",
      value: statistics?.appointments?.completedAppointments || 0,
      icon: CheckCircle2,
      color: COLORS.success,
      bgColor: "bg-emerald-50",
      change: "+15.1%",
      subtitle: `${statistics?.appointments?.pendingAppointments || 0} chờ xác nhận`,
    },
  ];

  // Thêm debug component để xem data structure
  const DebugInfo = () => (
    <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-4 mb-6">
      <h3 className="font-bold text-yellow-800 mb-2">Debug Info:</h3>
      <pre className="text-xs overflow-auto">
        {JSON.stringify(statistics, null, 2)}
      </pre>
    </div>
  );

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="inline-block animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mb-4"></div>
          <p className="text-gray-600 text-lg">Đang tải dữ liệu...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center p-4">
        <div className="bg-white rounded-lg shadow-lg p-8 max-w-md text-center">
          <AlertCircle className="h-16 w-16 text-red-500 mx-auto mb-4" />
          <h3 className="text-xl font-semibold text-gray-900 mb-2">Lỗi tải dữ liệu</h3>
          <p className="text-gray-600 mb-6">{error}</p>
          <button
            onClick={fetchDashboardData}
            className="px-6 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
          >
            Thử lại
          </button>
        </div>
      </div>
    );
  }

  if (!statistics) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <AlertCircle className="h-16 w-16 text-gray-400 mx-auto mb-4" />
          <p className="text-gray-600 text-lg">Không có dữ liệu</p>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100 p-4 md:p-6 lg:p-8">
      <div className="max-w-7xl mx-auto space-y-6">
        {/* Debug Info - Comment out khi đã chạy ổn */}
        {/* <DebugInfo /> */}

        {/* Header */}
        <div className="bg-white rounded-xl shadow-lg p-6 border border-gray-200">
          <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
            <div>
              <h1 className="text-3xl font-bold text-gray-900 mb-2">
                Dashboard Quản Trị
              </h1>
              <p className="text-gray-600">
                Tổng quan thống kê hệ thống - {dateRange.fromDate && dateRange.toDate
                  ? `${formatDate(dateRange.fromDate)} - ${formatDate(dateRange.toDate)}`
                  : "Tất cả thời gian"}
              </p>
            </div>
            <div className="flex flex-col sm:flex-row gap-3">
              <input
                type="date"
                value={dateRange.fromDate ? dateRange.fromDate.toISOString().split('T')[0] : ''}
                onChange={(e) => handleDateChange("fromDate", e.target.value)}
                className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                placeholder="Từ ngày"
              />
              <input
                type="date"
                value={dateRange.toDate ? dateRange.toDate.toISOString().split('T')[0] : ''}
                onChange={(e) => handleDateChange("toDate", e.target.value)}
                className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                placeholder="Đến ngày"
              />
              {(dateRange.fromDate || dateRange.toDate) && (
                <button
                  onClick={resetDateRange}
                  className="px-4 py-2 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300 transition-colors"
                >
                  Reset
                </button>
              )}
            </div>
          </div>
        </div>

        {/* Stat Cards Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {statCards.map((card, index) => {
            const Icon = card.icon;
            return (
              <div
                key={index}
                className="bg-white rounded-xl shadow-lg p-6 border border-gray-200 hover:shadow-xl transition-shadow duration-300"
              >
                <div className="flex items-center justify-between mb-4">
                  <div className={`${card.bgColor} p-3 rounded-lg`}>
                    <Icon className={`h-6 w-6`} style={{ color: card.color }} />
                  </div>
                  <span className="text-xs font-semibold text-green-600 bg-green-100 px-2 py-1 rounded">
                    {card.change}
                  </span>
                </div>
                <h3 className="text-sm font-medium text-gray-600 mb-1">
                  {card.title}
                </h3>
                <p className="text-2xl font-bold text-gray-900 mb-1">
                  {card.value}
                </p>
                <p className="text-xs text-gray-500">{card.subtitle}</p>
              </div>
            );
          })}
        </div>

        {/* Charts Row 1: Payment & Appointment Overview */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* Payment Status Pie Chart */}
          {paymentStatusData.length > 0 && (
            <div className="bg-white rounded-xl shadow-lg p-6 border border-gray-200">
              <h2 className="text-xl font-bold text-gray-900 mb-4 flex items-center gap-2">
                <CreditCard className="h-5 w-5 text-blue-600" />
                Phân Phối Thanh Toán
              </h2>
              <ResponsiveContainer width="100%" height={300}>
                <PieChart>
                  <Pie
                    data={paymentStatusData}
                    cx="50%"
                    cy="50%"
                    labelLine={false}
                    label={({ name, percent }) =>
                      `${name}: ${(percent * 100).toFixed(0)}%`
                    }
                    outerRadius={100}
                    fill="#8884d8"
                    dataKey="value"
                  >
                    {paymentStatusData.map((entry, index) => (
                      <Cell
                        key={`cell-${index}`}
                        fill={statusColors[entry.status] || COLORS.primary}
                      />
                    ))}
                  </Pie>
                  <Tooltip />
                  <Legend />
                </PieChart>
              </ResponsiveContainer>
            </div>
          )}

          {/* Appointment Status */}
          {appointmentStatusData.length > 0 && (
            <div className="bg-white rounded-xl shadow-lg p-6 border border-gray-200">
              <h2 className="text-xl font-bold text-gray-900 mb-4 flex items-center gap-2">
                <Calendar className="h-5 w-5 text-blue-600" />
                Trạng Thái Lịch Hẹn
              </h2>
              <div className="space-y-4">
                {appointmentStatusData.map((item, index) => (
                  <div key={index} className="flex items-center justify-between">
                    <div className="flex items-center gap-3">
                      <div
                        className="w-4 h-4 rounded"
                        style={{
                          backgroundColor: statusColors[item.name] || COLORS.primary,
                        }}
                      ></div>
                      <span className="text-sm font-medium text-gray-700">
                        {item.name}
                      </span>
                    </div>
                    <div className="flex items-center gap-4">
                      <div className="w-32 bg-gray-200 rounded-full h-2">
                        <div
                          className="h-2 rounded-full"
                          style={{
                            width: `${(item.value / (statistics?.appointments?.totalCount || 1)) * 100}%`,
                            backgroundColor: statusColors[item.name] || COLORS.primary,
                          }}
                        ></div>
                      </div>
                      <span className="text-sm font-bold text-gray-900 w-12 text-right">
                        {item.value}
                      </span>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}
        </div>

        {/* Charts Row 2: Daily Statistics */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* Payment Daily Trend */}
          {statistics?.payments?.dailyStatistics &&
            statistics.payments.dailyStatistics.length > 0 && (
              <div className="bg-white rounded-xl shadow-lg p-6 border border-gray-200">
                <h2 className="text-xl font-bold text-gray-900 mb-4 flex items-center gap-2">
                  <TrendingUp className="h-5 w-5 text-blue-600" />
                  Xu Hướng Thanh Toán Hàng Ngày
                </h2>
                <ResponsiveContainer width="100%" height={300}>
                  <AreaChart
                    data={statistics.payments.dailyStatistics.map((item) => ({
                      date: formatDate(item.date),
                      amount: item.amount || 0,
                      count: item.count,
                    }))}
                  >
                    <CartesianGrid strokeDasharray="3 3" />
                    <XAxis dataKey="date" />
                    <YAxis yAxisId="left" orientation="left" stroke={COLORS.primary} />
                    <YAxis yAxisId="right" orientation="right" stroke={COLORS.success} />
                    <Tooltip
                      formatter={(value, name) => {
                        if (name === "amount") return formatCurrency(value);
                        return value;
                      }}
                    />
                    <Legend />
                    <Area
                      yAxisId="left"
                      type="monotone"
                      dataKey="amount"
                      stroke={COLORS.success}
                      fill={COLORS.success}
                      fillOpacity={0.6}
                      name="Số tiền (VND)"
                    />
                    <Line
                      yAxisId="right"
                      type="monotone"
                      dataKey="count"
                      stroke={COLORS.primary}
                      strokeWidth={2}
                      name="Số lượng"
                    />
                  </AreaChart>
                </ResponsiveContainer>
              </div>
            )}

          {/* Appointment Daily Trend */}
          {statistics?.appointments?.dailyStatistics &&
            statistics.appointments.dailyStatistics.length > 0 && (
              <div className="bg-white rounded-xl shadow-lg p-6 border border-gray-200">
                <h2 className="text-xl font-bold text-gray-900 mb-4 flex items-center gap-2">
                  <Calendar className="h-5 w-5 text-blue-600" />
                  Xu Hướng Lịch Hẹn Hàng Ngày
                </h2>
                <ResponsiveContainer width="100%" height={300}>
                  <LineChart
                    data={statistics.appointments.dailyStatistics.map((item) => ({
                      date: formatDate(item.date),
                      count: item.count,
                    }))}
                  >
                    <CartesianGrid strokeDasharray="3 3" />
                    <XAxis dataKey="date" />
                    <YAxis />
                    <Tooltip />
                    <Legend />
                    <Line
                      type="monotone"
                      dataKey="count"
                      stroke={COLORS.primary}
                      strokeWidth={3}
                      dot={{ fill: COLORS.primary, r: 4 }}
                      name="Số lượng"
                    />
                  </LineChart>
                </ResponsiveContainer>
              </div>
            )}
        </div>

        {/* Charts Row 3: Review Distribution & Vendor Stats */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          {/* Review Rating Distribution */}
          {reviewRatingData.length > 0 && (
            <div className="bg-white rounded-xl shadow-lg p-6 border border-gray-200">
              <h2 className="text-xl font-bold text-gray-900 mb-4 flex items-center gap-2">
                <Star className="h-5 w-5 text-blue-600" />
                Phân Phối Đánh Giá
              </h2>
              <ResponsiveContainer width="100%" height={300}>
                <BarChart data={reviewRatingData}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="name" />
                  <YAxis />
                  <Tooltip />
                  <Legend />
                  <Bar
                    dataKey="value"
                    name="Số lượng"
                    fill={COLORS.warning}
                    radius={[8, 8, 0, 0]}
                  >
                    {reviewRatingData.map((entry, index) => (
                      <Cell
                        key={`cell-${index}`}
                        fill={
                          entry.rating === 5
                            ? COLORS.success
                            : entry.rating === 4
                            ? COLORS.primary
                            : entry.rating === 3
                            ? COLORS.warning
                            : COLORS.danger
                        }
                      />
                    ))}
                  </Bar>
                </BarChart>
              </ResponsiveContainer>
            </div>
          )}

          {/* Payment by Vendor */}
          {statistics?.payments?.countByVendor &&
            Object.keys(statistics.payments.countByVendor).length > 0 && (
              <div className="bg-white rounded-xl shadow-lg p-6 border border-gray-200">
                <h2 className="text-xl font-bold text-gray-900 mb-4 flex items-center gap-2">
                  <CreditCard className="h-5 w-5 text-blue-600" />
                  Thanh Toán Theo Nhà Cung Cấp
                </h2>
                <ResponsiveContainer width="100%" height={300}>
                  <BarChart
                    data={Object.entries(statistics.payments.countByVendor).map(
                      ([key, value]) => ({
                        name: key.toUpperCase(),
                        value,
                      })
                    )}
                  >
                    <CartesianGrid strokeDasharray="3 3" />
                    <XAxis dataKey="name" />
                    <YAxis />
                    <Tooltip />
                    <Legend />
                    <Bar
                      dataKey="value"
                      name="Số lượng"
                      fill={COLORS.info}
                      radius={[8, 8, 0, 0]}
                    />
                  </BarChart>
                </ResponsiveContainer>
              </div>
            )}
        </div>

        {/* Summary Cards */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div className="bg-gradient-to-br from-blue-500 to-blue-600 rounded-xl shadow-lg p-6 text-white">
            <div className="flex items-center justify-between mb-4">
              <Calendar className="h-8 w-8" />
              <span className="text-2xl font-bold">
                {statistics?.appointments?.activeAppointments || 0}
              </span>
            </div>
            <h3 className="text-lg font-semibold mb-1">Lịch Hẹn Đang Hoạt Động</h3>
            <p className="text-blue-100 text-sm">
              {statistics?.appointments?.pendingAppointments || 0} chờ xác nhận
            </p>
          </div>

          <div className="bg-gradient-to-br from-green-500 to-green-600 rounded-xl shadow-lg p-6 text-white">
            <div className="flex items-center justify-between mb-4">
              <CheckCircle2 className="h-8 w-8" />
              <span className="text-2xl font-bold">
                {statistics?.appointments?.completedAppointments || 0}
              </span>
            </div>
            <h3 className="text-lg font-semibold mb-1">Lịch Hẹn Đã Hoàn Thành</h3>
            <p className="text-green-100 text-sm">
              {((statistics?.appointments?.completedAppointments || 0) /
                (statistics?.appointments?.totalCount || 1)) *
                100}%
              hoàn thành
            </p>
          </div>

          <div className="bg-gradient-to-br from-purple-500 to-purple-600 rounded-xl shadow-lg p-6 text-white">
            <div className="flex items-center justify-between mb-4">
              <AlertCircle className="h-8 w-8" />
              <span className="text-2xl font-bold">
                {statistics?.appointments?.paymentPendingAppointments || 0}
              </span>
            </div>
            <h3 className="text-lg font-semibold mb-1">Chờ Thanh Toán</h3>
            <p className="text-purple-100 text-sm">
              Cần xử lý thanh toán
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;