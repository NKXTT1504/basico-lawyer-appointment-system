import React, { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import api from '../../config/axios';

const defaultFormData = {
  id: 0,
  bio: "",
  spec: [],
  licenseNum: "",
  expYears: 0,
  description: "",
  rating: 0,
  pricePerHour: 0,
  img: "",
  dayOfWeek: "",
  workTime: "",
  fullName: "",
  email: "",
  phoneNumber: ""
};

const LawyerProfile = () => {
  const navigate = useNavigate();
  const [formData, setFormData] = useState(defaultFormData);

  const [loading, setLoading] = useState(true);
  const [updating, setUpdating] = useState(false);
  const [success, setSuccess] = useState("");
  const [error, setError] = useState("");
  const user = JSON.parse(localStorage.getItem("user"));
  const userId = user?.id;

  // Lấy thông tin user + lawyer profile chỉ qua 1 API
  useEffect(() => {
    const fetchProfile = async () => {
      setLoading(true);
      try {
        const res = await api.auth.get(`/api/UserWithLawyerProfile/${userId}`);
        console.log("API response:", res.data);
        // Nếu response là { result: {...} } thì lấy res.data.result
        const data = res.data.result;

        setFormData({
          ...defaultFormData,
          ...data.lawyerProfile,
          ...data.user,
          spec: Array.isArray(data.lawyerProfile.spec)
            ? data.lawyerProfile.spec
            : (data.lawyerProfile.spec
              ? data.lawyerProfile.spec.split(",").map((s) => s.trim())
              : []),
        });
      } catch (err) {
        setError("Không thể tải thông tin người dùng/luật sư.");
      } finally {
        setLoading(false);
      }
    };
    if (userId) fetchProfile();
    else {
      setError("Không tìm thấy ID người dùng.");
      setLoading(false);
    }
  }, [userId]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: name === "spec"
        ? value.split(",").map((item) => item.trim())
        : ["rating", "expYears", "pricePerHour"].includes(name)
          ? Number(value)
          : value,
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setUpdating(true);
    setError("");
    setSuccess("");

    try {
      // Update thông tin user + lawyer qua API auth
      await api.auth.put(`/api/Auth/update/${userId}`, {
        ...formData,
        spec: Array.isArray(formData.spec) ? formData.spec : (formData.spec ? formData.spec.split(",").map(s => s.trim()) : []),
      });

      setSuccess("Cập nhật thông tin thành công!");
    } catch (err) {
      setError("Lỗi khi cập nhật thông tin.");
    } finally {
      setUpdating(false);
    }
  };

  if (loading) return <p className="text-center mt-10 font-bold text-lg">Đang tải thông tin...</p>;

  return (
    <main className="min-h-screen bg-gray-50 py-16 pt-28">
      <div className="container mx-auto px-4 max-w-3xl">
        <div className="bg-white rounded-lg shadow-md overflow-hidden">
          <div className="bg-primary-700 px-6 py-4 flex items-center gap-4">
            <img
              src={formData.img || "/placeholder.png"}
              alt="Lawyer Avatar"
              className="w-20 h-20 rounded-full border-4 border-white object-cover"
            />
            <h1 className="text-2xl font-bold text-white">Thông tin <span className="font-extrabold">luật sư</span></h1>
          </div>

          {error && <div className="bg-red-50 border-l-4 border-red-400 p-4 m-6 font-bold text-base">{error}</div>}
          {success && <div className="bg-green-50 border-l-4 border-green-400 p-4 m-6 font-bold text-base">{success}</div>}

          <form onSubmit={handleSubmit} className="p-6 grid grid-cols-1 md:grid-cols-2 gap-6">
            {/* User Info */}
            <div>
              <label className="block text-base font-bold text-gray-700">Họ và tên</label>
              <input
                type="text"
                name="fullName"
                value={formData.fullName}
                onChange={handleChange}
                className="block w-full rounded-md border-gray-300 shadow-sm pl-2 font-semibold"
              />
            </div>
            <div>
              <label className="block text-base font-bold text-gray-700">Email</label>
              <input
                type="email"
                name="email"
                value={formData.email}
                onChange={handleChange}
                className="block w-full rounded-md border-gray-300 shadow-sm pl-2 font-semibold"
              />
            </div>
            <div>
              <label className="block text-base font-bold text-gray-700">Số điện thoại</label>
              <input
                type="text"
                name="phoneNumber"
                value={formData.phoneNumber}
                onChange={handleChange}
                className="block w-full rounded-md border-gray-300 shadow-sm pl-2 font-semibold"
              />
            </div>

            {/* Lawyer Info */}
            <div>
              <label className="block text-base font-bold text-gray-700">Bio</label>
              <input
                type="text"
                name="bio"
                value={formData.bio}
                onChange={handleChange}
                className="block w-full rounded-md border-gray-300 shadow-sm pl-2 font-semibold"
              />
            </div>
            <div>
              <label className="block text-base font-bold text-gray-700">Chuyên môn (dùng dấu phẩy)</label>
              <input
                type="text"
                name="spec"
                value={Array.isArray(formData.spec) ? formData.spec.join(", ") : ""}
                onChange={handleChange}
                className="block w-full rounded-md border-gray-300 shadow-sm pl-2 font-semibold"
              />
            </div>
            <div>
              <label className="block text-base font-bold text-gray-700">Số giấy phép</label>
              <input
                type="text"
                name="licenseNum"
                value={formData.licenseNum}
                onChange={handleChange}
                className="block w-full rounded-md border-gray-300 shadow-sm pl-2 font-semibold"
              />
            </div>
            <div>
              <label className="block text-base font-bold text-gray-700">Số năm kinh nghiệm</label>
              <input
                type="number"
                name="expYears"
                value={formData.expYears}
                onChange={handleChange}
                className="block w-full rounded-md border-gray-300 shadow-sm pl-2 font-semibold"
              />
            </div>
            <div className="md:col-span-2">
              <label className="block text-base font-bold text-gray-700">Mô tả</label>
              <textarea
                name="description"
                value={formData.description}
                onChange={handleChange}
                rows="3"
                className="block w-full rounded-md border-gray-300 shadow-sm pl-2 font-semibold"
              />
            </div>
            <div>
              <label className="block text-base font-bold text-gray-700">Đánh giá</label>
              <input
                type="number"
                name="rating"
                value={formData.rating}
                onChange={handleChange}
                className="block w-full rounded-md border-gray-300 shadow-sm pl-2 font-semibold"
              />
            </div>
            <div>
              <label className="block text-base font-bold text-gray-700">Giá/giờ (VNĐ)</label>
              <input
                type="number"
                name="pricePerHour"
                value={formData.pricePerHour}
                onChange={handleChange}
                className="block w-full rounded-md border-gray-300 shadow-sm pl-2 font-semibold"
              />
            </div>
            <div>
              <label className="block text-base font-bold text-gray-700">Ngày làm việc</label>
              <input
                type="text"
                name="dayOfWeek"
                value={formData.dayOfWeek}
                onChange={handleChange}
                className="block w-full rounded-md border-gray-300 shadow-sm pl-2 font-semibold"
              />
            </div>
            <div>
              <label className="block text-base font-bold text-gray-700">Giờ làm việc</label>
              <input
                type="text"
                name="workTime"
                value={formData.workTime}
                onChange={handleChange}
                className="block w-full rounded-md border-gray-300 shadow-sm pl-2 font-semibold"
              />
            </div>

            <div className="md:col-span-2 flex justify-end mt-4">
              <button
                type="submit"
                disabled={updating}
                className="px-4 py-2 bg-primary-700 text-white rounded-md hover:bg-primary-800 disabled:opacity-50 font-bold text-base"
              >
                {updating ? "Đang cập nhật..." : "Lưu thay đổi"}
              </button>
            </div>
          </form>
        </div>

        {/* Security */}
        <div className="mt-8 bg-white rounded-lg shadow-md overflow-hidden">
          <div className="bg-primary-700 px-6 py-4">
            <h2 className="text-2xl font-bold text-white">Bảo mật</h2>
          </div>
          <div className="p-6 flex justify-between items-center">
            <div>
              <h3 className="text-lg font-bold">Đổi mật khẩu</h3>
              <p className="text-gray-500">Cập nhật mật khẩu để bảo vệ tài khoản của bạn</p>
            </div>
            <button
              onClick={() => navigate("/change-password")}
              className="px-4 py-2 bg-gray-100 text-gray-700 rounded-md hover:bg-gray-200 font-bold"
            >
              Đổi mật khẩu
            </button>
          </div>
        </div>
      </div>
    </main>
  );
};

export default LawyerProfile;