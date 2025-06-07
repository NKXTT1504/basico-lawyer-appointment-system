import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useSelector, useDispatch } from 'react-redux';
import { User, Mail, Phone, Calendar, MapPin, Award, Briefcase } from 'lucide-react';
import { logout } from '../redux/features/userSlice';
import api from '../config/axios';
import { toast } from 'react-hot-toast';

const ProfileTemplate = ({ userType }) => {
  const user = useSelector((store) => store.user);
  const navigate = useNavigate();
  const dispatch = useDispatch();
  
  const [loading, setLoading] = useState(true);
  const [updating, setUpdating] = useState(false);
  const [formData, setFormData] = useState({});
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  // Define API endpoints based on user type
  const apiEndpoints = {
    customer: {
      get: '/api/User',
      update: '/api/User'
    },
    lawyer: {
      get: '/api/UserWithLawyerProfile',
      update: '/api/UserWithLawyerProfile'
    }
  };

  // Define fields based on user type
  const getFields = () => {
    const commonFields = [
      { name: 'fullName', label: 'Họ và tên', type: 'text', icon: <User className="h-5 w-5 text-gray-400" />, placeholder: 'Nguyễn Văn A' },
      { name: 'email', label: 'Email', type: 'email', icon: <Mail className="h-5 w-5 text-gray-400" />, placeholder: 'example@email.com', disabled: true },
      { name: 'phoneNumber', label: 'Số điện thoại', type: 'tel', icon: <Phone className="h-5 w-5 text-gray-400" />, placeholder: '0123456789' },
    ];

    if (userType === 'lawyer') {
      return [
        ...commonFields,
        { name: 'experience', label: 'Kinh nghiệm (năm)', type: 'number', icon: <Calendar className="h-5 w-5 text-gray-400" />, placeholder: '5' },
        { name: 'specialization', label: 'Chuyên môn', type: 'text', icon: <Award className="h-5 w-5 text-gray-400" />, placeholder: 'Luật dân sự, Luật hình sự' },
        { name: 'licenseNum', label: 'Số giấy phép', type: 'text', icon: <Briefcase className="h-5 w-5 text-gray-400" />, placeholder: 'LS12345' },
        { name: 'address', label: 'Địa chỉ văn phòng', type: 'text', icon: <MapPin className="h-5 w-5 text-gray-400" />, placeholder: 'Số 123, Đường ABC, Quận XYZ, TP. Hồ Chí Minh' },
      ];
    }
    
    return commonFields;
  };

  useEffect(() => {
    const fetchUserData = async () => {
      try {
        setLoading(true);
        const userId = user?.id || localStorage.getItem('userId');
        
        if (!userId) {
          throw new Error('User ID not found');
        }

        const endpoint = userType === 'lawyer' 
          ? `${apiEndpoints.lawyer.get}/${userId}` 
          : `${apiEndpoints.customer.get}/${userId}`;
        
        const response = await api.auth.get(endpoint);
        
        if (response.data) {
          // Handle different response structures
          const userData = response.data.result || response.data;
          
          // Map API response to form fields
          const mappedData = {
            fullName: userData.fullName || userData.name || '',
            email: userData.email || '',
            phoneNumber: userData.phoneNumber || userData.phone || '',
          };
          
          // Add lawyer-specific fields if available
          if (userType === 'lawyer' && userData.lawyerProfile) {
            mappedData.experience = userData.lawyerProfile.experience || '';
            mappedData.specialization = userData.lawyerProfile.specialization || '';
            mappedData.licenseNum = userData.lawyerProfile.licenseNum || '';
            mappedData.address = userData.lawyerProfile.address || '';
          }
          
          setFormData(mappedData);
        }
      } catch (error) {
        console.error('Error fetching user data:', error);
        setError('Không thể tải thông tin người dùng. Vui lòng thử lại sau.');
      } finally {
        setLoading(false);
      }
    };

    fetchUserData();
  }, [user, userType]);

  const handleLogout = () => {
    dispatch(logout());
    navigate("/");
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData({ ...formData, [name]: value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setSuccess('');
    setUpdating(true);

    try {
      const userId = user?.id || localStorage.getItem('userId');
      
      if (!userId) {
        throw new Error('User ID not found');
      }

      const endpoint = userType === 'lawyer' 
        ? `${apiEndpoints.lawyer.update}/${userId}` 
        : `${apiEndpoints.customer.update}/${userId}`;
      
      // Prepare data based on user type
      const updateData = {
        fullName: formData.fullName,
        email: formData.email,
        phoneNumber: formData.phoneNumber,
        role: userType === 'lawyer' ? 'Lawyer' : 'Customer',
        isActive: true
      };
      
      // Add lawyer-specific data if needed
      if (userType === 'lawyer') {
        updateData.lawyerProfile = {
          experience: formData.experience,
          specialization: formData.specialization,
          licenseNum: formData.licenseNum,
          address: formData.address
        };
      }
      
      const response = await api.auth.put(endpoint, updateData);
      
      if (response.status === 200) {
        setSuccess('Cập nhật thông tin thành công!');
        toast.success("Cập nhật thông tin thành công.");
      } else {
        throw new Error('Không thể cập nhật thông tin.');
      }
    } catch (error) {
      console.error('Error updating profile:', error);
      setError(error.response?.data?.message || 'Không thể cập nhật thông tin. Vui lòng thử lại sau.');
      toast.error("Không thể cập nhật thông tin.");
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

  const fields = getFields();

  return (
    <main className="min-h-screen bg-gray-50 py-16">
      <div className="container mx-auto px-4">
        <div className="max-w-3xl mx-auto">
          <div className="bg-white rounded-lg shadow-md overflow-hidden">
            <div className="bg-primary-700 px-6 py-4">
              <h1 className="text-2xl font-bold text-white">Thông tin của bạn</h1>
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
                {fields.map((field) => (
                  <div key={field.name} className="input-group">
                    <label htmlFor={field.name} className="input-label">{field.label}</label>
                    <div className="relative">
                      <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                        {field.icon}
                      </div>
                      <input
                        type={field.type}
                        id={field.name}
                        name={field.name}
                        value={formData[field.name] || ''}
                        onChange={handleChange}
                        className="pl-10 w-full"
                        placeholder={field.placeholder}
                        disabled={field.disabled}
                      />
                    </div>
                    {field.helpText && <p className="text-sm text-gray-500 mt-1">{field.helpText}</p>}
                  </div>
                ))}
              </div>

              <div className="mt-6 flex justify-end">
                <button
                  type="submit"
                  disabled={updating}
                  className="btn-primary"
                >
                  {updating ? 'Đang cập nhật...' : 'Lưu thay đổi'}
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
                  className="btn-outline"
                >
                  Đổi mật khẩu
                </button>
              </div>
              
              <div className="mt-6 pt-6 border-t border-gray-200">
                <div className="flex items-center justify-between">
                  <div>
                    <h3 className="text-lg font-medium text-gray-900">Đăng xuất</h3>
                    <p className="text-gray-500">Đăng xuất khỏi tài khoản của bạn</p>
                  </div>
                  <button
                    onClick={handleLogout}
                    className="btn-outline bg-red-50 text-red-600 hover:bg-red-100"
                  >
                    Đăng xuất
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </main>
  );
};

export default ProfileTemplate;