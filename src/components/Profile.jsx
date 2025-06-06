import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { User, Mail, Phone, Calendar } from 'lucide-react';
const ProfileTemplate = ({ path, pathapi }) => {
  const user = useSelector((store) => store.user);
  const navigate = useNavigate();
  const [loading, setLoading] = useState(true);
  const [updating, setUpdating] = useState(false);
  const [formData, setFormData] = useState({});
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  console.log(user);

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
      const response = await api.put(`${pathapi}/${user.id}`);
      if (response.status === 200) {
        setIsEditing(false);
        toast.success("Cập nhật thông tin thành công.");
      } else {
        console.error("Error updating user info:", response);
        toast.error("Không thể cập nhật thông tin.");
      }
    } catch (error) {
      setError(error.message || "Không thể cập nhật thông tin.");
    } finally {
      setUpdating(false);
    }
  };

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
                <p className="text-sm text-red-700">{error}</p>
              </div>
            )}

            {success && (
              <div className="bg-green-50 border-l-4 border-green-400 p-4 m-6">
                <p className="text-sm text-green-700">{success}</p>
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

export default ProfileTemplate;