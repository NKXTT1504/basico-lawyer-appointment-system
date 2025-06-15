import React, { useEffect, useState } from "react";
import { User, Mail, Shield, MapPin } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import api from '../../config/axios';

const AdminProfile = () => {
  const navigate = useNavigate();
  const [formData, setFormData] = useState({
    id: 0,
    fullName: '',
    email: '',
    phoneNumber: '',
    img: '',
  });
  const [updating, setUpdating] = useState(false);
  const [success, setSuccess] = useState('');
  const [error, setError] = useState('');
  const user = JSON.parse(localStorage.getItem("user"));
  const userId = user?.id;

  // 🎯 Fetch API khi load trang
  useEffect(() => {
    const fetchProfile = async () => {
      try {
        const res = await api.auth.get(`/api/UserWithLawyerProfile/${userId}`);
        // Nếu API trả về { fullName, email, phone } như chuẩn:
        setFormData({
          fullName: user.fullName || '',
          email: user.email || '',
          phoneNumber: user.phoneNumber || '',
          img: user.img || ''
        });

      } catch (err) {
        console.error('Lỗi khi load dữ liệu admin:', err);
        setError('Không thể tải thông tin admin. Vui lòng thử lại sau.');
      }
    };

    fetchProfile();
  }, []);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: value,
    }));
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    setUpdating(true);
    setError('');
    setSuccess('');

    // Call API để update (tùy bạn thêm sau)
    setTimeout(() => {
      setUpdating(false);
      setSuccess('Cập nhật thông tin thành công!');
    }, 1000);
  };

  return (
    <main className="min-h-screen bg-gray-50 py-16 pt-28">
      <div className="container mx-auto px-4">
        <div className="max-w-3xl mx-auto">
          <div className="bg-white rounded-lg shadow-md overflow-hidden">
            <div className="bg-primary-700 px-6 py-4 flex items-center gap-4">
              <img
                alt="Ảnh Admin"
                className="w-20 h-20 rounded-full border-4 border-white object-cover"
              />
              <h1 className="text-2xl font-bold text-white">Hi, {formData.fullName}</h1>
            </div>

            {error && (
              <div className="bg-red-50 border-l-4 border-red-400 p-4 m-6">
                <div className="flex">
                  <div className="flex-shrink-0">
                    <svg className="h-5 w-5 text-red-400" viewBox="0 0 20 20" fill="currentColor">
                      <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clipRule="evenodd" />
                    </svg>
                  </div>
                  <div className="ml-3">
                    <p className="text-sm text-red-700">{error}</p>
                  </div>
                </div>
              </div>
            )}

            {success && (
              <div className="bg-green-50 border-l-4 border-green-400 p-4 m-6">
                <div className="flex">
                  <div className="flex-shrink-0">
                    <svg className="h-5 w-5 text-green-400" viewBox="0 0 20 20" fill="currentColor">
                      <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
                    </svg>
                  </div>
                  <div className="ml-3">
                    <p className="text-sm text-green-700">{success}</p>
                  </div>
                </div>
              </div>
            )}

            <form onSubmit={handleSubmit} className="p-6">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div className="input-group">
                  <label htmlFor="fullName" className="block text-sm font-medium text-gray-700">Họ và tên</label>
                  <div className="mt-1 relative rounded-md shadow-sm">
                    <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                      <User className="h-5 w-5 text-gray-400" />
                    </div>
                    <input
                      type="text"
                      id="fullName"
                      name="fullName"
                      value={formData.fullName}
                      onChange={handleChange}
                      className="pl-10 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500"
                      placeholder="Tên quản trị viên"
                    />
                  </div>
                </div>

                <div className="input-group">
                  <label htmlFor="email" className="block text-sm font-medium text-gray-700">Email</label>
                  <div className="mt-1 relative rounded-md shadow-sm">
                    <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                      <Mail className="h-5 w-5 text-gray-400" />
                    </div>
                    <input
                      type="email"
                      id="email"
                      name="email"
                      value={formData.email}
                      disabled
                      className="pl-10 block w-full rounded-md border-gray-300 bg-gray-50 shadow-sm cursor-not-allowed"
                    />
                  </div>
                  <p className="mt-1 text-sm text-gray-500">Email không thể thay đổi</p>
                </div>

                <div className="input-group">
                  <label htmlFor="phoneNumber" className="block text-sm font-medium text-gray-700">Số điện thoại</label>
                  <div className="mt-1 relative rounded-md shadow-sm">
                    <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                      <MapPin className="h-5 w-5 text-gray-400" />
                    </div>
                    <input
                      type="text"
                      id="phoneNumber"
                      name="phoneNumber"
                      value={formData.phoneNumber}
                      onChange={handleChange}
                      className="pl-10 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500"
                      placeholder="Số điện thoại"
                    />
                  </div>
                </div>
              </div>

              <div className="mt-8 flex justify-end">
                <button
                  type="submit"
                  disabled={updating}
                  className="inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-primary-700 hover:bg-primary-800 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500 disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  {updating ? (
                    <>
                      <svg className="animate-spin -ml-1 mr-2 h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                        <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                        <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                      </svg>
                      Đang cập nhật...
                    </>
                  ) : (
                    'Lưu thay đổi'
                  )}
                </button>
              </div>
            </form>
          </div>

          <div className="mt-8 bg-white rounded-lg shadow-md overflow-hidden">
            <div className="bg-primary-700 px-6 py-4">
              <h2 className="text-2xl font-bold text-white">Bảo mật</h2>
            </div>
            <div className="p-6">
              <div className="flex items-center justify-between">
                <div>
                  <h3 className="text-lg font-medium text-gray-900">Đổi mật khẩu</h3>
                  <p className="text-gray-500">Cập nhật mật khẩu để bảo vệ tài khoản của bạn</p>
                </div>
                <button
                  onClick={() => navigate('/change-password')}
                  className="inline-flex items-center px-4 py-2 border border-gray-300 shadow-sm text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500"
                >
                  Đổi mật khẩu
                </button>
              </div>
            </div>
          </div>

          {/* You can add more admin-specific sections here if needed */}
        </div>
      </div>
    </main>
  );
};

export default AdminProfile;