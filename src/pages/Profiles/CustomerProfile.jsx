import React, { useState, useEffect } from 'react';
import { User, Mail, Phone, Calendar, MapPin, Shield } from 'lucide-react';
import api from '../../config/axios';
import { useNavigate } from 'react-router-dom';
import { toast } from 'react-toastify';

const CustomerProfile = () => {
    const navigate = useNavigate();
    const [loading, setLoading] = useState(true);
    const [updating, setUpdating] = useState(false);
    const [showSuccess, setShowSuccess] = useState(false);
    const [userData, setUserData] = useState(null);
    const [formData, setFormData] = useState({
        fullName: '',
        email: '',
        phoneNumber: ''
    });
    const [error, setError] = useState('');
    const [success, setSuccess] = useState('');

    const fetchUserData = async (userId) => {
        setLoading(true);
        try {
            console.log('Fetching user data for userId:', userId);
            const response = await api.auth.get(`/api/User/${userId}`);
            console.log('API response:', response);

            if (response.data && response.data.result) {
                const userData = response.data.result;
                setUserData(userData);
                setFormData({
                    fullName: userData.fullName || '',
                    email: userData.email || '',
                    phoneNumber: userData.phoneNumber || '',
                });
                return response.data
            } else {
                throw new Error(response.data.message || 'Failed to load user data');
            }
        } catch (error) {
            console.error('Error fetching user data:', error);
            setError(error.message || 'Failed to load profile data');
            toast.error('Failed to load profile data. Please try again.');
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        const loadUserData = async () => {
            const userStr = localStorage.getItem('user');
            if (!userStr) {
                setError('User information not found');
                setLoading(false);
                return;
            }

            const user = JSON.parse(userStr);
            const userId = user.id;

            if (!userId) {
                setError('User ID not found');
                setLoading(false);
                return;
            }

            const result = await fetchUserData(userId);
            console.log('Fetch result:', result);
            if (result && result.result) {
                setSuccess('Profile loaded successfully');
                setShowSuccess(true);
                setTimeout(() => {
                    setShowSuccess(false);
                    setSuccess('');
                }, 5000);
            } else {
                setError(result.message || 'Failed to load profile data');
            }
            setLoading(false);
        };

        loadUserData();
    }, []);

    const handleChange = (e) => {
        const { name, value } = e.target;
        setFormData(prev => ({
            ...prev,
            [name]: value
        }));
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setError('');
        setSuccess('');
        setUpdating(true);

        try {
            const userStr = localStorage.getItem('user');
            if (!userStr) {
                throw new Error('User information not found');
            }

            const user = JSON.parse(userStr);
            const userId = user.id;

            if (!userId) {
                throw new Error('User ID not found');
            }

            const updateData = {
                id: userId,
                fullName: formData.fullName,
                email: formData.email,
                password: formData.password,
                phoneNumber: formData.phoneNumber,
                role: user.role || 'Customer',
                isActive: true
            };

            // Update user data
            const response = await api.auth.put(`/api/User/${userId}`, updateData);

            if (response.data && response.data.isSuccess) {
                setSuccess('Profile updated successfully!');
                setShowSuccess(true);
                setTimeout(() => {
                    setShowSuccess(false);
                    setSuccess('');
                }, 5000);

                // Update local storage with new user data
                const updatedUser = { ...user, ...updateData };
                localStorage.setItem('user', JSON.stringify(updatedUser));
            } else {
                throw new Error(response.data.message || 'Failed to update profile');
            }
        } catch (error) {
            console.error('Error updating profile:', error);
            setError(error.message || 'An error occurred while updating your profile');
            toast.error('Failed to update profile. Please try again.');
        } finally {
            setUpdating(false);
        }
    };

    if (loading) {
        return (
            <div className="min-h-screen bg-gray-50 flex items-center justify-center">
                <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-primary-700"></div>
            </div>
        );
    }

    return (
        <main className="min-h-screen bg-gray-50 py-16 pt-28">
            <div className="container mx-auto px-4">
                <div className="max-w-3xl mx-auto">
                    <div className="bg-white rounded-lg shadow-md overflow-hidden">
                        <div className="bg-primary-700 px-6 py-4">
                            <h1 className="text-2xl font-bold text-white">Thông tin cá nhân</h1>
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
                            <div className="grid grid-cols-1 gap-6">
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
                                            placeholder="Nguyễn Văn A"
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
                                            <Phone className="h-5 w-5 text-gray-400" />
                                        </div>
                                        <input
                                            type="tel"
                                            id="phoneNumber"
                                            name="phoneNumber"
                                            value={formData.phoneNumber}
                                            onChange={handleChange}
                                            className="pl-10 block w-full rounded-md border-gray-300 shadow-sm focus:border-primary-500 focus:ring-primary-500"
                                            placeholder="0123456789"
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
                                <button
                                    onClick={() => navigate('/change-password')}
                                    className="inline-flex items-center px-4 py-2 ml-4 border border-gray-300 shadow-sm text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500"
                                >
                                    Đổi mật khẩu
                                </button>
                            </div>
                        </form>
                    </div>

                    <div className="mt-8 bg-white rounded-lg shadow-md overflow-hidden">
                        <div className="bg-primary-700 px-6 py-4">
                            <h2 className="text-2xl font-bold text-white">Lịch sử cuộc hẹn</h2>
                        </div>

                        <div className="p-6">
                            <div className="flex flex-col">
                                <div className="-my-2 overflow-x-auto sm:-mx-6 lg:-mx-8">
                                    <div className="py-2 align-middle inline-block min-w-full sm:px-6 lg:px-8">
                                        <div className="shadow overflow-hidden border-b border-gray-200 sm:rounded-lg">
                                            <table className="min-w-full divide-y divide-gray-200">
                                                <thead className="bg-gray-50">
                                                    <tr>
                                                        <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                                            Luật sư
                                                        </th>
                                                        <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                                            Ngày
                                                        </th>
                                                        <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                                            Trạng thái
                                                        </th>
                                                        <th scope="col" className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                                                            Hành động
                                                        </th>
                                                    </tr>
                                                </thead>
                                                <tbody className="bg-white divide-y divide-gray-200">
                                                    {/* Placeholder for appointment history - will be implemented later */}
                                                    <tr>
                                                        <td colSpan="4" className="px-6 py-4 text-center text-sm text-gray-500">
                                                            Chưa có cuộc hẹn nào
                                                        </td>
                                                    </tr>
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div className="mt-4 flex justify-center">
                                <button
                                    onClick={() => navigate('/appointment')}
                                    className="inline-flex items-center px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-primary-700 hover:bg-primary-800 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500"
                                >
                                    Đặt lịch hẹn mới
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    );
};

export default CustomerProfile;