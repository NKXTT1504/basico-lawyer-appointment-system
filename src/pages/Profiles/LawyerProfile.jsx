import React, { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import api from '../../config/axios';
import { Dialog, Transition } from '@headlessui/react';
import { Fragment } from 'react';
import { getDownloadURL, ref, uploadBytes } from "firebase/storage";
import { storage } from "../../config/firebase";

const LawyerProfile = () => {
  const navigate = useNavigate();
  const [formData, setFormData] = useState({});
  const [loading, setLoading] = useState(true);
  const [updating, setUpdating] = useState(false);
  const [success, setSuccess] = useState("");
  const [showSuccess, setShowSuccess] = useState(false);
  const [error, setError] = useState("");
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editableData, setEditableData] = useState({});
  const user = JSON.parse(localStorage.getItem("user"));
  const userId = user?.id;
  const [isAvatarModalOpen, setIsAvatarModalOpen] = useState(false);
  const [selectedFile, setSelectedFile] = useState(null);
  const [previewUrl, setPreviewUrl] = useState(null);

  const handleAvatarClick = () => {
    setIsAvatarModalOpen(true);
  };

  const handleFileChange = (event) => {
    try {
      const file = event.target.files[0];
      if (file) {
        setSelectedFile(file);
        const objectUrl = URL.createObjectURL(file);
        setPreviewUrl(objectUrl);

        // Cleanup function to revoke the object URL when it's no longer needed
        return () => URL.revokeObjectURL(objectUrl);
      }
    } catch (error) {
      console.error("Error handling file change:", error);
      setError("Có lỗi xảy ra khi chọn file. Vui lòng thử lại.");
    }
  };

  const handleAvatarUpload = async () => {
  if (!selectedFile) return;

  try {
    const storageRef = ref(storage, `avatars/${userId}/${selectedFile.name}`);
    const snapshot = await uploadBytes(storageRef, selectedFile);
    const downloadURL = await getDownloadURL(snapshot.ref);

    // Cập nhật database
    await api.auth.put(`/api/UserWithLawyerProfile/${userId}`, {
      user: {
        fullName: formData.fullName,
        email: formData.email,
        phoneNumber: formData.phoneNumber,
        isActive: true
      },
      lawyerProfile: {
        ...formData,
        img: downloadURL,
        userId: userId
      }
    });

    // Cập nhật UI
    setFormData(prev => ({ ...prev, img: downloadURL }));
    setIsAvatarModalOpen(false);
    setSuccess("Avatar đã được cập nhật thành công!");
  } catch (error) {
    console.error("Error uploading file: ", error);
    setError("Đã xảy ra lỗi khi tải lên avatar. Vui lòng thử lại.");
  }
};


  const customStyles = {
    content: {
      top: '50%',
      left: '50%',
      right: 'auto',
      bottom: 'auto',
      marginRight: '-50%',
      transform: 'translate(-50%, -50%)',
      maxWidth: '500px',
      width: '90%',
    },
    overlay: {
backgroundColor: 'rgba(0, 0, 0, 0.75)'
    }
  };
  useEffect(() => {
    const fetchProfile = async () => {
      setLoading(true);
      try {
        const res = await api.auth.get(`/api/UserWithLawyerProfile/${userId}`);
        const data = res.data.result;
        setFormData({
          ...data.lawyerProfile,
          ...data.user,
          spec: Array.isArray(data.lawyerProfile.spec)
            ? data.lawyerProfile.spec
            : (data.lawyerProfile.spec
              ? data.lawyerProfile.spec.split(",").map((s) => s.trim())
              : []),
          role: data.user.role,
        });
        setEditableData({
          fullName: data.user.fullName,
          email: data.user.email,
          phoneNumber: data.user.phoneNumber,
          description: data.lawyerProfile.description,
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
    setEditableData(prev => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setUpdating(true);
    setError("");
    setSuccess("");

    try {
      const updateData = {
        fullName: editableData.fullName,
        email: editableData.email,
        phoneNumber: editableData.phoneNumber,
        role: formData.role, // Giữ nguyên role hiện tại
        isActive: true // Giả sử người dùng luôn active
      };

      await api.auth.put(`/api/Auth/update/${userId}`, updateData);
      setSuccess("Cập nhật thông tin thành công!");
      setTimeout(() => {
        setShowSuccess(false);
        setSuccess('');
      }, 5000);
      setFormData(prev => ({ ...prev, ...editableData }));
      setIsModalOpen(false);
    } catch (err) {
      setError("Lỗi khi cập nhật thông tin.");
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
      <div className="container mx-auto px-4 max-w-3xl">
        <div className="bg-white rounded-lg shadow-md overflow-hidden">
          <div className="bg-primary-700 px-6 py-4 flex items-center gap-4">
            <img
              src={formData.img || "/placeholder.png"}
              alt="Lawyer Avatar"
              className="w-20 h-20 rounded-full border-4 border-white object-cover"
              onClick={handleAvatarClick}
            />
            <h1 className="text-2xl font-bold text-white">Thông tin <span className="font-extrabold">luật sư</span></h1>
</div>

          {error && <div className="bg-red-50 border-l-4 border-red-400 p-4 m-6 font-bold text-base">{error}</div>}
          {success && <div className="bg-green-50 border-l-4 border-green-400 p-4 m-6 font-bold text-base">{success}</div>}

          <div className="p-6 grid grid-cols-1 md:grid-cols-2 gap-6">
            <InfoItem label="Họ và tên" value={formData.fullName} />
            <InfoItem label="Email" value={formData.email} />
            <InfoItem label="Số điện thoại" value={formData.phoneNumber} />
            <InfoItem label="Bio" value={formData.bio} />
            <InfoItem label="Chuyên môn" value={Array.isArray(formData.spec) ? formData.spec.join(", ") : formData.spec} />
            <InfoItem label="Số giấy phép" value={formData.licenseNum} />
            <InfoItem label="Số năm kinh nghiệm" value={formData.expYears} />
            <InfoItem label="Mô tả" value={formData.description} />
            <InfoItem label="Đánh giá" value={formData.rating} />
            <InfoItem label="Giá/giờ (VNĐ)" value={formData.pricePerHour} />
            <InfoItem label="Ngày làm việc" value={formData.dayOfWeek} />
            <InfoItem label="Giờ làm việc" value={formData.workTime} />

            <div className="md:col-span-2 flex justify-end mt-4">
              <button
                onClick={() => setIsModalOpen(true)}
                className="px-4 py-2 bg-primary-700 text-white rounded-md hover:bg-primary-800 font-bold text-base"
              >
                Thay đổi
              </button>
            </div>
          </div>
        </div>
      </div>

      {/* Avatar Upload Modal */}
      <Transition appear show={isAvatarModalOpen} as={Fragment}>
        <Dialog as="div" className="relative z-10" onClose={() => setIsAvatarModalOpen(false)}>
          <Transition.Child
            as={Fragment}
            enter="ease-out duration-300"
            enterFrom="opacity-0"
            enterTo="opacity-100"
            leave="ease-in duration-200"
            leaveFrom="opacity-100"
            leaveTo="opacity-0"
          >
            <div className="fixed inset-0 bg-black bg-opacity-25" />
          </Transition.Child>

          <div className="fixed inset-0 overflow-y-auto">
            <div className="flex min-h-full items-center justify-center p-4 text-center">
              <Transition.Child
                as={Fragment}
                enter="ease-out duration-300"
                enterFrom="opacity-0 scale-95"
                enterTo="opacity-100 scale-100"
                leave="ease-in duration-200"
                leaveFrom="opacity-100 scale-100"
                leaveTo="opacity-0 scale-95"
              >
                <Dialog.Panel className="w-full max-w-md transform overflow-hidden rounded-2xl bg-white p-6 text-left align-middle shadow-xl transition-all">
                  <Dialog.Title
                    as="h3"
className="text-lg font-medium leading-6 text-gray-900 mb-4"
                  >
                    Cập nhật Avatar
                  </Dialog.Title>
                  <div className="mt-2">
                    <input
                      type="file"
                      accept="image/*"
                      onChange={handleFileChange}
                      className="mb-4"
                    />
                    {previewUrl && (
                      <img
                        src={previewUrl}
                        alt="Preview"
                        className="w-32 h-32 object-cover rounded-full mx-auto mb-4"
                      />
                    )}
                  </div>
                  <div className="mt-4 flex justify-end">
                    <button
                      type="button"
                      className="mr-2 px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 rounded-md hover:bg-gray-200 focus:outline-none focus-visible:ring-2 focus-visible:ring-offset-2 focus-visible:ring-blue-500"
                      onClick={() => setIsAvatarModalOpen(false)}
                    >
                      Hủy
                    </button>
                    <button
                      type="button"
                      className="px-4 py-2 text-sm font-medium text-white bg-blue-600 rounded-md hover:bg-blue-700 focus:outline-none focus-visible:ring-2 focus-visible:ring-offset-2 focus-visible:ring-blue-500"
                      onClick={handleAvatarUpload}
                    >
                      Tải lên
                    </button>
                  </div>
                </Dialog.Panel>
              </Transition.Child>
            </div>
          </div>
        </Dialog>
      </Transition>

      <Transition appear show={isModalOpen} as={Fragment}>
        <Dialog as="div" className="relative z-10" onClose={() => setIsModalOpen(false)}>
          <Transition.Child
            as={Fragment}
            enter="ease-out duration-300"
            enterFrom="opacity-0"
            enterTo="opacity-100"
            leave="ease-in duration-200"
            leaveFrom="opacity-100"
            leaveTo="opacity-0"
          >
            <div className="fixed inset-0 bg-black bg-opacity-25" />
          </Transition.Child>

          <div className="fixed inset-0 overflow-y-auto">
            <div className="flex min-h-full items-center justify-center p-4 text-center">
              <Transition.Child
                as={Fragment}
                enter="ease-out duration-300"
                enterFrom="opacity-0 scale-95"
                enterTo="opacity-100 scale-100"
                leave="ease-in duration-200"
                leaveFrom="opacity-100 scale-100"
                leaveTo="opacity-0 scale-95"
              >
                <Dialog.Panel className="w-full max-w-md transform overflow-hidden rounded-2xl bg-white p-6 text-left align-middle shadow-xl transition-all">
<Dialog.Title
                    as="h3"
                    className="text-lg font-medium leading-6 text-gray-900"
                  >
                    Chỉnh sửa thông tin
                  </Dialog.Title>
                  <form onSubmit={handleSubmit}>
                    <div className="mb-4 mt-4">
                      <label className="block text-sm font-medium text-gray-700">Họ và tên</label>
                      <input
                        type="text"
                        name="fullName"
                        value={editableData.fullName}
                        onChange={handleChange}
                        className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50"
                      />
                    </div>
                    <div className="mb-4">
                      <label className="block text-sm font-medium text-gray-700">Email</label>
                      <input
                        type="email"
                        name="email"
                        value={editableData.email}
                        onChange={handleChange}
                        className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50"
                      />
                    </div>
                    <div className="mb-4">
                      <label className="block text-sm font-medium text-gray-700">Số điện thoại</label>
                      <input
                        type="text"
                        name="phoneNumber"
                        value={editableData.phoneNumber}
                        onChange={handleChange}
                        className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50"
                      />
                    </div>
                    <div className="mb-4">
                      <label className="block text-sm font-medium text-gray-700">Mô tả</label>
                      <textarea
                        name="description"
                        value={editableData.description}
                        onChange={handleChange}
                        rows="3"
                        className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-300 focus:ring focus:ring-indigo-200 focus:ring-opacity-50"
                      />
                    </div>
                    <div className="flex justify-end">
                      <button
                        type="button"
                        onClick={() => setIsModalOpen(false)}
                        className="mr-2 px-4 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
                      >
Hủy
                      </button>
                      <button
                        type="submit"
                        disabled={updating}
                        className="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
                      >
                        {updating ? "Đang cập nhật..." : "Lưu thay đổi"}
                      </button>
                    </div>
                  </form>
                </Dialog.Panel>
              </Transition.Child>
            </div>
          </div>
        </Dialog>
      </Transition>
    </main>
  );
};

const InfoItem = ({ label, value }) => (
  <div>
    <label className="block text-sm font-medium text-gray-700">{label}</label>
    <p className="mt-1 block w-full rounded-md border-gray-300 shadow-sm bg-gray-50 p-2">{value}</p>
  </div>
);

export default LawyerProfile;