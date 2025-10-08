import React, { useState, useEffect } from 'react';
import { format, addDays } from 'date-fns';
import { services } from '../../data/services';
import api from '../../config/axios';
import ProgressBar from './ProgressBar.jsx';
import Step1ServiceLawyer from './Step1ServiceLawyer';
import Step2DateTime from './Step2DateTime';
import Step3Notes from './Step3Notes';
import AppointmentSuccess from './AppointmentSuccess';

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

  const getStartTime = (timeRange: string) => timeRange.split("~")[0].trim();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (validateStep(3)) {
      setIsSubmitting(true);

      const userId = user?.id || user?.userId || 0;
      const lawyerId = formData.lawyer;
      // Lấy giờ bắt đầu từ time range
      const startTime = getStartTime(formData.time);
      const scheduledAt =
        formData.date && formData.time
          ? new Date(`${formData.date}T${startTime}:00`).toISOString()
          : null;
      const slot = timeToSlot[formData.time];
      const note = formData.notes;
      const selectedService = services.find(s => s.id === formData.service);
      const spec = selectedSpec || selectedService?.title || '';
      const servicesArr = selectedService ? [selectedService.title] : [];

      try {
        await api.appointment.post('/api/Appointment/CREATE', {
          userId,
          lawyerId,
          scheduledAt,
          slot: String(slot), // slot là string
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

  const timeToSlot: { [key: string]: number } = {
    "08:00 ~ 10:00": 1,
    "10:00 ~ 12:00": 2,
    "13:00 ~ 15:00": 3,
    "15:00 ~ 17:00": 4,
  };

  const slotToTimes: { [key: number]: string[] } = {
    1: ["08:00 ~ 10:00"],
    2: ["10:00 ~ 12:00"],
    3: ["13:00 ~ 15:00"],
    4: ["15:00 ~ 17:00"],
  };

  const getAvailableTimes = () => {
    if (!formData.date) return [];
    const dateObj = new Date(formData.date);
    const dayName = dayIndexToName[dateObj.getDay()];
    let times = workSlots
      .filter(slot => slot.dayOfWeek === dayName && slot.isActive)
      .flatMap(slot => slotToTimes[slot.slot] || []);

    // Nếu là hôm nay, lọc bỏ các slot đã qua
    const today = new Date();
    const isToday =
      dateObj.getFullYear() === today.getFullYear() &&
      dateObj.getMonth() === today.getMonth() &&
      dateObj.getDate() === today.getDate();

    if (isToday) {
      const nowMinutes = today.getHours() * 60 + today.getMinutes();
      times = times.filter(timeRange => {
        const start = timeRange.split("~")[0].trim(); // "08:00"
        const [h, m] = start.split(":").map(Number);
        const slotMinutes = h * 60 + m;
        return slotMinutes > nowMinutes;
      });
    }

    return times;
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
      <AppointmentSuccess
        selectedLawyer={selectedLawyer}
        user={user}
        selectedService={selectedService}
        formData={formData}
        setStep={setStep}
        setSubmitSuccess={setSubmitSuccess}
        setFormData={setFormData}
      />
    );
  }

  return (
    <div className="bg-white rounded-lg shadow-md overflow-hidden">
      <ProgressBar step={step} />
      <form onSubmit={handleSubmit} className="p-6">
        {step === 1 && (
          <Step1ServiceLawyer
            formData={formData}
            updateFormData={updateFormData}
            errors={errors}
            services={services}
            selectedService={selectedService}
            selectedLawyer={selectedLawyer}
            lawyers={lawyers}
            specs={specs}
            selectedSpec={selectedSpec}
            setSelectedSpec={setSelectedSpec}
            filteredLawyers={filteredLawyers}
            nextStep={nextStep}
          />
        )}
        {step === 2 && (
          <Step2DateTime
            formData={formData}
            updateFormData={updateFormData}
            errors={errors}
            getAvailableTimes={getAvailableTimes}
            selectedService={selectedService}
            selectedLawyer={selectedLawyer}
            prevStep={prevStep}
            nextStep={nextStep}
          />
        )}
        {step === 3 && (
          <Step3Notes
            formData={formData}
            updateFormData={updateFormData}
            user={user}
            selectedService={selectedService}
            selectedLawyer={selectedLawyer}
            workSlots={workSlots}
            prevStep={prevStep}
            isSubmitting={isSubmitting}
          />
        )}
      </form>
    </div>
  );
};

export default AppointmentForm;