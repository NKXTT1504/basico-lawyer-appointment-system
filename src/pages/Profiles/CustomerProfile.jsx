import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { User, Mail, Phone, Calendar } from 'lucide-react';
import api from '../../config/axios';

const Profile = () => {
    const navigate = useNavigate();
    const [loading, setLoading] = useState(true);
    const [updating, setUpdating] = useState(false);
    const [formData, setFormData] = useState({
        name: '',
        email: '',
        phone: '',
        dateOfBirth: '',
        address: ''
    });
    const [error, setError] = useState('');
    const [success, setSuccess] = useState('');

useEffect(() => {
  const getProfile = async () => {
    try {
      const userId = localStorage.getItem('userId');
      if (!userId) {
        throw new Error('User ID not found');
      }

      const response = await api.auth.get(`/api/Auth/update/${userId}`);
      const profileData = response.data;
      
      setFormData({
        name: profileData.fullName || '',
        email: profileData.email || '',
        phone: profileData.phoneNumber || '',
        // Note: dateOfBirth and address are not provided by the API
      });
    } catch (error) {
      console.error('Error loading profile:', error.message);
      setError('Failed to load profile data. Please try again.');
    } finally {
      setLoading(false);
    }
  };
  getProfile();
}, []);

    const handleChange = (e) => {
        setFormData(prev => ({
            ...prev,
            [e.target.name]: e.target.value
        }));
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setError('');
        setSuccess('');
        setUpdating(true);

        try {
            const userId = localStorage.getItem('userId'); // Assuming you store the user's ID in localStorag
            if (!userId) {
                throw new Error('User ID not found');
            }
            await api.auth.put('/api/Auth/update/${userId}', {
                fullName: formData.name,
                email: formData.email,
                phoneNumber: formData.phone,
                role: "Customer", // Assuming the role is always CUSTOMER for this profile
                isActive: true // Assuming you want to keep the user active
            });

            setSuccess('Profile updated successfully!');
        } catch (error) {
            setError(error.response?.data?.message || 'An error occurred while updating your profile');
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
        <main className="min-h-screen bg-gray-50 py-16">
            <div className="container mx-auto px-4">
                <div className="max-w-3xl mx-auto">
                    <div className="bg-white rounded-lg shadow-md overflow-hidden">
                        <div className="bg-primary-700 px-6 py-4">
                            <h1 className="text-2xl font-bold text-white">Profile Settings</h1>
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
                                    <label htmlFor="name" className="input-label">Full Name</label>
                                    <div className="relative">
                                        <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                            <User className="h-5 w-5 text-gray-400" />
                                        </div>
                                        <input
                                            type="text"
                                            id="name"
                                            name="name"
                                            value={formData.name}
                                            onChange={handleChange}
                                            className="pl-10 w-full"
                                            placeholder="John Doe"
                                        />
                                    </div>
                                </div>

                                <div className="input-group">
                                    <label htmlFor="email" className="input-label">Email Address</label>
                                    <div className="relative">
                                        <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                            <Mail className="h-5 w-5 text-gray-400" />
                                        </div>
                                        <input
                                            type="email"
                                            id="email"
                                            name="email"
                                            value={formData.email}
                                            disabled
                                            className="pl-10 w-full bg-gray-50 cursor-not-allowed"
                                        />
                                    </div>
                                    <p className="text-sm text-gray-500 mt-1">Email cannot be changed</p>
                                </div>

                                <div className="input-group">
                                    <label htmlFor="phone" className="input-label">Phone Number</label>
                                    <div className="relative">
                                        <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                            <Phone className="h-5 w-5 text-gray-400" />
                                        </div>
                                        <input
                                            type="tel"
                                            id="phone"
                                            name="phone"
                                            value={formData.phone}
                                            onChange={handleChange}
                                            className="pl-10 w-full"
                                            placeholder="(123) 456-7890"
                                        />
                                    </div>
                                </div>

                                <div className="input-group">
                                    <label htmlFor="dateOfBirth" className="input-label">Date of Birth</label>
                                    <div className="relative">
                                        <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                                            <Calendar className="h-5 w-5 text-gray-400" />
                                        </div>
                                        <input
                                            type="date"
                                            id="dateOfBirth"
                                            name="dateOfBirth"
                                            value={formData.dateOfBirth}
                                            onChange={handleChange}
                                            className="pl-10 w-full"
                                        />
                                    </div>
                                </div>

                                <div className="md:col-span-2">
                                    <div className="input-group">
                                        <label htmlFor="address" className="input-label">Address</label>
                                        <input
                                            type="text"
                                            id="address"
                                            name="address"
                                            value={formData.address}
                                            onChange={handleChange}
                                            className="w-full"
                                            placeholder="123 Main St, City, State, ZIP"
                                        />
                                    </div>
                                </div>
                            </div>

                            <div className="mt-6 flex justify-end">
                                <button
                                    type="submit"
                                    disabled={updating}
                                    className="btn-primary"
                                >
                                    {updating ? (
                                        <>
                                            <svg className="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                                                <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                                                <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                                            </svg>
                                            Updating...
                                        </>
                                    ) : (
                                        'Save Changes'
                                    )}
                                </button>
                            </div>
                        </form>
                    </div>

                    <div className="mt-8 bg-white rounded-lg shadow-md overflow-hidden">
                        <div className="bg-primary-700 px-6 py-4">
                            <h2 className="text-2xl font-bold text-white">Security Settings</h2>
                        </div>

                        <div className="p-6">
                            <div className="flex items-center justify-between">
                                <div>
                                    <h3 className="text-lg font-medium text-gray-900">Change Password</h3>
                                    <p className="text-gray-500">Update your password to keep your account secure</p>
                                </div>
                                <button
                                    onClick={() => navigate('/change-password')}
                                    className="btn-outline"
                                >
                                    Change Password
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    );
};

export default Profile;