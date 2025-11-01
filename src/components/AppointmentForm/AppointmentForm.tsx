import React, { useState, useEffect } from 'react';
import { format, addDays } from 'date-fns';
import api from '../../config/axios';
import ProgressBar from './ProgressBar';
import Step1ServiceLawyer from './Step1ServiceLawyer';
import Step2DateTime from './Step2DateTime';
import Step3Notes from './Step3Notes';
import AppointmentSuccess from './AppointmentSuccess';
import AppointmentSuccessDirect from './AppointmentSuccessDirect';
import { useLocation } from 'react-router-dom';
import { slugify } from '../../data/services';

const AppointmentForm = ({
  initialService = '',
  initialLawyer = ''
}) => {
  const [step, setStep] = useState(1);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submitSuccess, setSubmitSuccess] = useState(false);

  // services fetched from API
  const [services, setServices] = useState<any[]>([]);
  const [practiceAreas, setPracticeAreas] = useState<any[]>([]); // derived from lawyer profiles

  // track incoming slug from query string (if any)
  const location = useLocation();
  const [initialServiceSlug, setInitialServiceSlug] = useState<string>('');

  // replace selectedSpec with selectedPracticeArea (holds practiceArea.code)
  const [selectedPracticeArea, setSelectedPracticeArea] = useState<string>('');

  const [formData, setFormData] = useState({
    service: initialService ? [initialService] : [], // <-- store as string[]
    lawyer: initialLawyer,
    date: '',
    time: '',
    notes: ''
  });
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [lawyers, setLawyers] = useState<any[]>([]);
  const [workSlots, setWorkSlots] = useState<any[]>([]);
  const [selectedSpec, setSelectedSpec] = useState<string>('');
  const [lawyerDetails, setLawyerDetails] = useState<{[key: string]: any}>({});

  const availableTimes = [
    '08:00', '09:00', '10:00', '11:00', '13:00', '14:00', '15:00', '16:00'
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

  // read query param on mount
  useEffect(() => {
    const params = new URLSearchParams(location.search);
    const svc = params.get('service');
    if (svc) setInitialServiceSlug(svc);
  }, [location.search]);

  // fetch services from API on mount
  useEffect(() => {
    let mounted = true;
    (async () => {
      try {
        const res = await api.lawyer.get('/api/Service');
        if (!mounted) return;
        let data: any[] = [];
        if (res) {
          const d = res.data;
          if (Array.isArray(d)) data = d;
          else if (d && Array.isArray(d.result)) data = d.result;
        }
        setServices(Array.isArray(data) ? data : []);
      } catch (err) {
        console.error('Service fetch error:', err);
        setServices([]);
      }
    })();
    return () => {
      mounted = false;
    };
  }, []);

  // fetch lawyer profiles (use the endpoint you provided) and derive practiceAreas
  useEffect(() => {
    let mounted = true;
    (async () => {
      try {
        const res = await api.lawyer.get('/api/Lawyer/GetAllLawyerProfile');
        if (!mounted) return;
        let data: any[] = [];
        if (res) {
          const d = res.data;
          if (Array.isArray(d)) data = d;
          else if (d && Array.isArray(d.result)) data = d.result;
        }
        // data is array of lawyer profiles; set lawyers state
        setLawyers(Array.isArray(data) ? data : []);

        // derive unique practiceAreas across all lawyers
        const map: Record<string, any> = {};
        (Array.isArray(data) ? data : []).forEach((lp: any) => {
          const pas = lp.practiceAreas || [];
          (pas || []).forEach((pa: any) => {
            if (pa && pa.code && !map[pa.code]) map[pa.code] = pa;
          });
        });
        setPracticeAreas(Object.values(map));
      } catch (err) {
        console.error('Lawyer profiles fetch error:', err);
        setLawyers([]);
        setPracticeAreas([]);
      }
    })();
    return () => {
      mounted = false;
    };
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

  const updateFormData = (field: string, value: any) => {
    setFormData(prev => ({ ...prev, [field]: value }));
    if (errors[field]) {
      setErrors(prev => {
        const newErrors = { ...prev };
        delete newErrors[field];
        return newErrors;
      });
    }
  };

  // helper: array of selected service ids (strings)
  const selectedServices: string[] = Array.isArray(formData.service)
    ? formData.service
    : formData.service ? [String(formData.service)] : [];

  // Get all selected services
  const selectedServicesList = selectedServices
    .map(id => services.find(s => String(s.id) === String(id)))
    .filter(Boolean);

  // derive selectedLawyer from loaded lawyers + formData.lawyer
  const selectedLawyer = lawyers.find(l =>
    String(l.lawyerProfile?.id || l.id || l.user?.id || '') === String(formData.lawyer)
  );

  const validateStep = (stepNum: number) => {
    const newErrors: Record<string, string> = {};

    if (stepNum === 1) {
      if (!formData.service || formData.service.length === 0) newErrors.service = 'Vui lòng chọn dịch vụ';
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

  const getStartTime = (timeRange: string) => {
    if (!timeRange) return '';
    if (timeRange.includes('~')) return timeRange.split('~')[0].trim();
    return timeRange.trim();
  };

  const handleCreateAppointment = async (appointmentData: any) => {
  const { formData, selectedServices, selectedLawyer, user } = appointmentData;
  
  const userId = user?.id || user?.userId || 0;
  const lawyerId = formData.lawyer;
  const startTime = getStartTime(formData.time);
  const scheduledAt = formData.date && startTime
    ? new Date(`${formData.date}T${startTime}:00`).toISOString()
    : null;

  const slot = timeToSlot[formData.time] ?? null;
  const note = formData.notes;
  const servicesArr = selectedServices.map(service => service.title || service.name).filter(Boolean);
  const spec = selectedSpec || (selectedServices[0]?.title ?? '');

  try {
    const requestData: any = {
      userId,
      lawyerId,
      scheduledAt,
      slot: slot !== null ? String(slot) : null,
      note,
      spec,
      services: servicesArr
    };

    // Không gửi status, backend tự động set dựa vào số lượng services
    console.log('Creating appointment with data:', requestData);

    const response = await api.appointment.post('/api/Appointment/CREATE', requestData);

    console.log('Appointment creation response:', response.data);

    // Backend trả về { appointmentId, state, message }
    return response.data.appointmentId || response.data.id;
  } catch (error: any) {
    console.error('Appointment creation error:', error);
    throw new Error(error.response?.data?.message || 'Không thể tạo lịch hẹn');
  }
};

  // Hàm xử lý khi đặt lịch thành công không qua thanh toán (1 dịch vụ)
  const handleDirectSuccess = () => {
    setIsSubmitting(false);
    setSubmitSuccess(true);
  };

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

  // filteredLawyers should now match selectedPracticeArea against lawyer.practiceAreas
  const filteredLawyers = selectedPracticeArea
    ? lawyers.filter((lawyer: any) => {
        const pas = lawyer.practiceAreas || [];
        return pas.some((pa: any) => (pa.code || '').toString().toLowerCase() === selectedPracticeArea.toString().toLowerCase());
      })
    : [];

  // after services loaded, if there was a slug in query, resolve it -> select the service
  useEffect(() => {
    if (!initialServiceSlug || services.length === 0) return;

    const matched = services.find(s =>
      slugify(s.name || s.title || String(s.id)) === initialServiceSlug
    );

    if (matched) {
      // preselect the service (store id as string in array)
      setFormData(prev => ({ ...prev, service: [String(matched.id)] }));
      // optionally preselect the practice area filter so user sees the relevant category
      if (matched.practiceArea?.code) {
        setSelectedPracticeArea(matched.practiceArea.code);
      }
    }

    // clear the slug so we only apply once
    setInitialServiceSlug('');
  }, [initialServiceSlug, services]);

if (submitSuccess) {
  // Kiểm tra có cần thanh toán không
  const requiresPayment = selectedServicesList.length >= 2;
  
  if (requiresPayment) {
    // Sử dụng AppointmentSuccess cũ (có payment info)
    return (
      <AppointmentSuccessDirect
        selectedLawyer={selectedLawyer}
        user={user}
        selectedService={selectedServicesList}
        formData={formData}
        setStep={setStep}
        setSubmitSuccess={setSubmitSuccess}
        setFormData={setFormData}
      />
    );
  } else {
    // Sử dụng AppointmentSuccessDirect mới (không thanh toán)
    return (
      <AppointmentSuccessDirect
        selectedLawyer={selectedLawyer}
        user={user}
        selectedService={selectedServicesList}
        formData={formData}
        setStep={setStep}
        setSubmitSuccess={setSubmitSuccess}
        setFormData={setFormData}
      />
    );
  }
}

  return (
    <div className="bg-white rounded-lg shadow-md overflow-hidden">
      <ProgressBar step={step} />
      <form className="p-6">
        {step === 1 && (
          <Step1ServiceLawyer
            formData={formData}
            updateFormData={updateFormData}
            errors={errors}
            services={services}
            selectedServices={selectedServicesList}
            selectedLawyer={selectedLawyer}
            lawyers={lawyers}
            practiceAreas={practiceAreas}
            selectedPracticeArea={selectedPracticeArea}
            setSelectedPracticeArea={setSelectedPracticeArea}
            filteredLawyers={filteredLawyers}
            nextStep={nextStep}
            lawyerDetails={lawyerDetails}
            setLawyerDetails={setLawyerDetails}
          />
        )}
        {step === 2 && (
          <Step2DateTime
            formData={formData}
            updateFormData={updateFormData}
            errors={errors}
            getAvailableTimes={getAvailableTimes}
            selectedServices={selectedServicesList}
            selectedLawyer={selectedLawyer}
            prevStep={prevStep}
            nextStep={nextStep}
            lawyerDetails={lawyerDetails}
          />
        )}
        {step === 3 && (
          <Step3Notes
            formData={formData}
            updateFormData={updateFormData}
            user={user}
            selectedServices={selectedServicesList}
            selectedLawyer={selectedLawyer}
            workSlots={workSlots}
            prevStep={prevStep}
            isSubmitting={isSubmitting}
            lawyerDetails={lawyerDetails}
            onCreateAppointment={handleCreateAppointment}
            onDirectSuccess={handleDirectSuccess}
          />
        )}
      </form>
    </div>
  );
};

export default AppointmentForm;