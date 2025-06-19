import React, { useState, useEffect } from 'react';
import { format } from 'date-fns';
import { services } from '../data/services';
import { Star, Calendar, Clock } from 'lucide-react';
import api from '../config/axios';

const AppointmentForm = ({
  initialService = '',
  initialLawyer = ''
}) => {
  const [step, setStep] = useState(1);
  const [formData, setFormData] = useState({
    service: initialService,
    lawyer: initialLawyer,
    date: '',
    time: '',
    notes: ''
  });
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submitSuccess, setSubmitSuccess] = useState(false);
  const [lawyers, setLawyers] = useState<any[]>([]);
  const [workSlots, setWorkSlots] = useState<any[]>([]);
  const [selectedSpec, setSelectedSpec] = useState<string>('');

  const availableTimes = [
    '08:00', '09:00', '10:00', '11:00', '13:00', '14:00', '15:00', '16:00'
  ];

  const specs = [
    "Dân sự",
    "Hợp đồng",
    "Hình sự",
    "Tố tụng",
    "Đất đai",
    "Bất động sản",
    "Doanh nghiệp",
    "Hôn nhân",
    "Ly hôn",
    "Nuôi con"
  ];

  // Lấy thông tin user từ localStorage
  const getUser = () => {
    const userStr = localStorage.getItem('user');
    if (userStr) {
      try {
        const user = JSON.parse(userStr);
        return user;
      } catch {
        return {};
      }
    }
    return {};
  };
  const user = getUser();


  useEffect(() => {
    const fetchLawyers = async () => {
      try {
        const res = await api.auth.get('/api/UserWithLawyerProfile/only-lawyers');
        console.log("Lawyers API:", res.data);
        setLawyers(res.data.result || res.data);
      } catch {
        setLawyers([]);
      }
    };
    fetchLawyers();
  }, []);

  useEffect(() => {
    if (!formData.lawyer) {
      setWorkSlots([]);
      return;
    }
    const fetchSlots = async () => {
      try {
        const res = await api.lawyer.get(`/api/lawyers/${formData.lawyer}/workslots`);
        setWorkSlots(res.data.result || res.data);
      } catch {
        setWorkSlots([]);
      }
    };
    fetchSlots();
  }, [formData.lawyer]);

  const updateFormData = (field: string, value: string) => {
    setFormData(prev => ({ ...prev, [field]: value }));
    if (errors[field]) {
      setErrors(prev => {
        const newErrors = { ...prev };
        delete newErrors[field];
        return newErrors;
      });
    }
  };

  const validateStep = (stepNum: number) => {
    const newErrors: Record<string, string> = {};

    if (stepNum === 1) {
      if (!formData.service) newErrors.service = 'Vui lòng chọn dịch vụ';
      if (!formData.lawyer) newErrors.lawyer = 'Vui lòng chọn luật sư';
    } else if (stepNum === 2) {
      if (!formData.date) newErrors.date = 'Vui lòng chọn ngày';
      if (!formData.time) newErrors.time = 'Vui lòng chọn giờ';
    }
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const nextStep = () => {
    if (validateStep(step)) {
      setStep(step + 1);
      window.scrollTo(0, 0);
    }
  };

  const prevStep = () => {
    setStep(step - 1);
    window.scrollTo(0, 0);
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (validateStep(3)) {
      setIsSubmitting(true);

      // Chuẩn bị dữ liệu gửi API
      const userId = user?.id || user?.userId || 0;
      const lawyerId = formData.lawyer;
      const scheduledAt = formData.date && formData.time
        ? new Date(`${formData.date}T${formData.time}:00`).toISOString()
        : null;
      const slot = formData.time;
      const note = formData.notes;
      const selectedService = services.find(s => s.id === formData.service);
      const spec = selectedSpec || selectedService?.title || '';
      const servicesArr = selectedService ? [selectedService.title] : [];

      try {
        await api.appointment.post('/api/Appointment/CREATE', {
          userId,
          lawyerId,
          scheduledAt,
          slot,
          note,
          spec,
          services: servicesArr
        });
        setIsSubmitting(false);
        setSubmitSuccess(true);
      } catch (error) {
        setIsSubmitting(false);
        setErrors({ api: "Đặt lịch thất bại. Vui lòng thử lại!" });
      }
    }
  };

  const selectedService = services.find(s => s.id === formData.service);
  const selectedLawyer = lawyers.find(
    l => String(l.lawyerProfile.id) === String(formData.lawyer)
  );

  const dayIndexToName = [
    "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"
  ];

  const slotToTimes: { [key: string]: string[] } = {
    1: ["8:00", "9:00"],
    2: ["10:00", "11:00"],
    3: ["13:00", "14:00"],
    4: ["15:00", "16:00"],
  };

  const getAvailableTimes = () => {
    if (!formData.date) return [];
    const dateObj = new Date(formData.date);
    const dayName = dayIndexToName[dateObj.getDay()];
    return workSlots
      .filter(slot => slot.dayOfWeek === dayName && slot.isActive)
      .flatMap(slot => slotToTimes[slot.slot] || []);
  };

  const filteredLawyers = selectedSpec
    ? lawyers.filter(lawyer => {
        const spec = lawyer.lawyerProfile?.spec;
        if (typeof spec === "string") {
          return spec.split(",").map((s: string) => s.trim()).includes(selectedSpec);
        }
        if (Array.isArray(spec)) {
          return spec.map((s: string) => s.trim()).includes(selectedSpec);
        }
        return false;
      })
    : [];

  if (submitSuccess) {
    return (
      <div className="bg-white p-8 rounded-lg shadow-md animate-fade-in">
        <div className="text-center">
          <div className="inline-flex items-center justify-center h-16 w-16 rounded-full bg-green-100 text-green-600 mb-6">
            <svg className="h-8 w-8" fill="currentColor" viewBox="0 0 20 20">
              <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
            </svg>
          </div>
          <h2 className="text-2xl font-bold text-gray-900 mb-2">Đặt lịch thành công!</h2>
          <p className="text-gray-600 mb-6">
            Cảm ơn bạn đã đặt lịch. Chúng tôi đã gửi email xác nhận tới {user?.email}.
          </p>
          <div className="bg-gray-50 rounded-lg p-6 mb-6 text-left">
            <h3 className="text-lg font-medium text-gray-900 mb-4">Chi tiết lịch hẹn:</h3>
            <div className="space-y-3">
              <p><span className="font-medium">Dịch vụ:</span> {selectedService?.title}</p>
              <p><span className="font-medium">Luật sư:</span> {selectedLawyer?.user.fullName}</p>
              <p><span className="font-medium">Ngày:</span> {format(new Date(formData.date), 'dd/MM/yyyy')}</p>
              <p><span className="font-medium">Giờ:</span> {formData.time}</p>
            </div>
          </div>
          <div className="flex flex-col sm:flex-row justify-center gap-4">
            <a href="/" className="btn-primary">
              Về trang chủ
            </a>
            <button
              onClick={() => {
                setStep(1);
                setSubmitSuccess(false);
                setFormData({
                  service: '',
                  lawyer: '',
                  date: '',
                  time: '',
                  notes: ''
                });
              }}
              className="btn-outline"
            >
              Đặt lịch mới
            </button>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="bg-white rounded-lg shadow-md overflow-hidden">
      {/* Progress Bar */}
      <div className="bg-gray-50 p-4">
        <div className="flex justify-between items-center">
          {['Dịch vụ & Luật sư', 'Ngày & Giờ', 'Ghi chú'].map((title, index) => {
            const stepNum = index + 1;
            return (
              <div key={title} className="flex flex-col items-center flex-1">
                <div className={`h-2 ${index === 0 ? 'hidden' : 'block'} w-full ${step > index ? 'bg-primary-600' : 'bg-gray-200'}`}></div>
                <div className={`
                  flex items-center justify-center h-10 w-10 rounded-full 
                  ${step > stepNum ? 'bg-primary-600 text-white' : step === stepNum ? 'bg-primary-600 text-white' : 'bg-gray-200 text-gray-600'}
                  border-4 ${step >= stepNum ? 'border-primary-100' : 'border-gray-50'}
                  transition-all duration-500
                `}>
                  {step > stepNum ? '✓' : stepNum}
                </div>
                <span className="text-xs sm:text-sm font-medium mt-2 text-center hidden sm:block">{title}</span>
              </div>
            );
          })}
        </div>
      </div>

      <form onSubmit={handleSubmit} className="p-6">
        {/* Bước 1: Chọn dịch vụ & luật sư */}
        {step === 1 && (
          <div className="animate-fade-in">
            <h2 className="text-2xl font-bold text-gray-900 mb-6">Chọn dịch vụ & luật sư</h2>
            <div className="mb-6">
              <label className="block text-gray-700 font-medium mb-2">Chọn dịch vụ</label>
              <select
                className="w-full border-gray-300 rounded-md shadow-sm focus:border-primary-500 focus:ring-primary-500"
                value={formData.service}
                onChange={(e) => updateFormData('service', e.target.value)}
              >
                <option value="">Chọn dịch vụ pháp lý...</option>
                {services.map((service) => (
                  <option key={service.id} value={service.id}>
                    {service.title} - {service.price}
                  </option>
                ))}
              </select>
              {errors.service && <p className="text-red-500 text-sm mt-1">{errors.service}</p>}
            </div>
            <div className="mb-4">
              <label className="block mb-2 font-semibold">Chọn lĩnh vực</label>
              <select
                value={selectedSpec}
                onChange={e => {
                  setSelectedSpec(e.target.value);
                  updateFormData("lawyer", ""); // reset chọn luật sư khi đổi lĩnh vực
                }}
                className="w-full border-gray-300 rounded-md shadow-sm mb-4"
              >
                <option value="">-- Chọn lĩnh vực --</option>
                {specs.map(spec => (
                  <option key={spec} value={spec}>{spec}</option>
                ))}
              </select>
            </div>

            {selectedSpec && (
              <div className="mb-4">
                <label className="block mb-2 font-semibold">Chọn luật sư</label>
                <select
                  value={formData.lawyer}
                  onChange={e => updateFormData("lawyer", e.target.value)}
                  className="w-full border-gray-300 rounded-md shadow-sm"
                >
                  <option value="">Chọn luật sư...</option>
                  {filteredLawyers.map(lawyer => (
                    <option key={lawyer.lawyerProfile.id} value={lawyer.lawyerProfile.id}>
                      {lawyer.user.fullName}
                    </option>
                  ))}
                </select>
              </div>
            )}
            {/* Thông tin dịch vụ đã chọn */}
            {selectedService && (
              <div className="mb-6 p-4 bg-gray-50 rounded-lg">
                <h3 className="font-medium text-gray-900 mb-2">Chi tiết dịch vụ:</h3>
                <p className="text-gray-600 mb-2">{selectedService.description}</p>
                <div className="flex flex-wrap gap-x-4 text-sm">
                  <p><span className="font-medium">Giá:</span> {selectedService.price}</p>
                  <p><span className="font-medium">Thời lượng:</span> {selectedService.duration}</p>
                </div>
              </div>
            )}
            {/* Thông tin luật sư đã chọn */}
            {selectedLawyer && (
              <div className="mb-6 p-4 bg-gray-50 rounded-lg">
                <div className="flex items-center">
                  <img
                    src={selectedLawyer.lawyerProfile.img}
                    alt={selectedLawyer.user.fullName}
                    className="h-16 w-16 rounded-full object-cover mr-4"
                  />
                  <div>
                    <h3 className="font-medium text-gray-900">{selectedLawyer.fullName}</h3>
                    <p className="text-gray-600">{selectedLawyer.lawyerProfile.expYears} năm kinh nghiệm</p>
                    <p className="text-gray-600">
                      Lĩnh vực: {
                        typeof selectedLawyer?.lawyerProfile?.spec === 'string'
                          ? selectedLawyer.lawyerProfile.spec
                          : Array.isArray(selectedLawyer?.lawyerProfile?.spec)
                            ? selectedLawyer.lawyerProfile.spec.join(', ')
                            : 'Chưa cập nhật'
                      }
                    </p>
                    <div className="flex items-center mt-1">
                      <Star className="h-4 w-4 text-yellow-500 fill-current" />
                      <span className="ml-1 text-gray-700">{selectedLawyer.lawyerProfile.rating}</span>
                      <span className="text-gray-500 text-sm ml-1">({selectedLawyer.reviewCount} đánh giá)</span>
                    </div>
                  </div>
                </div>
              </div>
            )}
            <div className="flex justify-end">
              <button
                type="button"
                onClick={nextStep}
                className="btn-primary"
              >
                Tiếp tục
              </button>
            </div>
          </div>
        )}

        {/* Bước 2: Chọn ngày & giờ */}
        {step === 2 && (
          <div className="animate-fade-in">
            <h2 className="text-2xl font-bold text-gray-900 mb-6">Chọn ngày & giờ</h2>
            <div className="mb-6">
              <label className="block text-gray-700 font-medium mb-2 flex items-center">
                <Calendar className="h-5 w-5 mr-2 text-primary-600" />
                Chọn ngày
              </label>
              <input
                type="date"
                className="w-full border-gray-300 rounded-md shadow-sm focus:border-primary-500 focus:ring-primary-500"
                value={formData.date}
                onChange={(e) => updateFormData('date', e.target.value)}
                min={format(new Date(), 'yyyy-MM-dd')}
              />
              {errors.date && <p className="text-red-500 text-sm mt-1">{errors.date}</p>}
            </div>
            <div className="mb-6">
              <label className="block text-gray-700 font-medium mb-2 flex items-center">
                <Clock className="h-5 w-5 mr-2 text-primary-600" />
                Chọn giờ
              </label>
              {getAvailableTimes().length === 0 ? (
                <p className="text-gray-500">Luật sư không làm việc ngày này.</p>
              ) : (
                <div className="grid grid-cols-3 gap-2">
                  {getAvailableTimes().map(time => (
                    <button
                      key={time}
                      type="button"
                      className={`py-2 px-4 rounded-md text-center transition-colors ${
                        formData.time === time
                          ? "bg-primary-600 text-white"
                          : "bg-gray-100 text-gray-700 hover:bg-gray-200"
                      }`}
                      onClick={() => updateFormData("time", time)}
                    >
                      {time}
                    </button>
                  ))}
                </div>
              )}
              {errors.time && <p className="text-red-500 text-sm mt-1">{errors.time}</p>}
            </div>
            <div className="mb-6 p-4 bg-gray-50 rounded-lg">
              <h3 className="font-medium text-gray-900 mb-2">Tóm tắt lịch hẹn:</h3>
              <p><span className="font-medium">Dịch vụ:</span> {selectedService?.title}</p>
              <p><span className="font-medium">Luật sư:</span> {selectedLawyer?.user.fullName}</p>
              {formData.date && <p>
                <span className="font-medium">Ngày:</span> {format(new Date(formData.date), 'dd/MM/yyyy')}
              </p>}
              {formData.time && <p><span className="font-medium">Giờ:</span> {formData.time}</p>}
            </div>
            <div className="flex justify-between">
              <button
                type="button"
                onClick={prevStep}
                className="btn-outline"
              >
                Quay lại
              </button>
              <button
                type="button"
                onClick={nextStep}
                className="btn-primary"
              >
                Tiếp tục
              </button>
            </div>
          </div>
        )}

        {/* Bước 3: Ghi chú */}
        {step === 3 && (
          <div className="animate-fade-in">
            <h2 className="text-2xl font-bold text-gray-900 mb-6">Ghi chú thêm</h2>
            <div className="mb-6">
              <label className="input-label" htmlFor="notes">Ghi chú (không bắt buộc)</label>
              <textarea
                id="notes"
                className="w-full h-32"
                value={formData.notes}
                onChange={(e) => updateFormData('notes', e.target.value)}
                placeholder="Bạn có thể ghi chú thêm về vấn đề pháp lý hoặc yêu cầu đặc biệt..."
              ></textarea>
            </div>
            <div className="mb-6 p-4 bg-gray-50 rounded-lg">
              <h3 className="font-medium text-gray-900 mb-2">Thông tin lịch hẹn:</h3>
              <p><span className="font-medium">Khách hàng:</span> {user?.fullName || user?.name || 'Ẩn danh'}</p>
              <p><span className="font-medium">Email:</span> {user?.email}</p>
              <p><span className="font-medium">Số điện thoại:</span> {user?.phoneNumber || user?.phone}</p>
              <p><span className="font-medium">Dịch vụ:</span> {selectedService?.title}</p>
              <p><span className="font-medium">Luật sư:</span> {selectedLawyer?.user.fullName}</p>
              {formData.date && <p>
                <span className="font-medium">Ngày:</span> {format(new Date(formData.date), 'dd/MM/yyyy')}
              </p>}
              {formData.time && <p><span className="font-medium">Giờ:</span> {formData.time}</p>}
              <p>
                {(() => {
                  const slot = workSlots.find(s => String(s.id) === formData.time);
                  return slot ? `${slot.dayOfWeek} - Slot ${slot.slot}` : "";
                })()}
              </p>
            </div>
            <div className="flex justify-between mt-6">
              <button
                type="button"
                onClick={prevStep}
                className="btn-outline"
              >
                Quay lại
              </button>
              <button
                type="submit"
                className="btn-primary"
                disabled={isSubmitting}
              >
                {isSubmitting ? (
                  <>
                    <svg className="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                      <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                      <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                    Đang xử lý...
                  </>
                ) : (
                  'Xác nhận đặt lịch'
                )}
              </button>
            </div>
          </div>
        )}
      </form>
    </div>
  );
};

export default AppointmentForm;