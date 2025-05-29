import React, { useState } from 'react';
import { format } from 'date-fns';
import { services } from '../data/services';
import { lawyers } from '../data/lawyers';
import { Star, Calendar, Clock } from 'lucide-react';


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
    name: '',
    email: '',
    phone: '',
    notes: ''
  });
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submitSuccess, setSubmitSuccess] = useState(false);

  const availableTimes = [
    '09:00', '10:00', '11:00', '13:00', '14:00', '15:00', '16:00'
  ];

  const updateFormData = (field: string, value: string) => {
    setFormData(prev => ({ ...prev, [field]: value }));
    // Clear error for this field
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
      if (!formData.service) newErrors.service = 'Please select a service';
      if (!formData.lawyer) newErrors.lawyer = 'Please select an attorney';
    } else if (stepNum === 2) {
      if (!formData.date) newErrors.date = 'Please select a date';
      if (!formData.time) newErrors.time = 'Please select a time';
    } else if (stepNum === 3) {
      if (!formData.name) newErrors.name = 'Please enter your name';
      if (!formData.email) newErrors.email = 'Please enter your email';
      if (!formData.phone) newErrors.phone = 'Please enter your phone number';
      else if (!/^\d{10}$/.test(formData.phone.replace(/\D/g, ''))) {
        newErrors.phone = 'Please enter a valid phone number';
      }
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

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    if (validateStep(3)) {
      setIsSubmitting(true);
      
      // Simulate API call with timeout
      setTimeout(() => {
        console.log('Form submitted:', formData);
        setIsSubmitting(false);
        setSubmitSuccess(true);
      }, 1500);
    }
  };

  const selectedService = services.find(s => s.id === formData.service);
  const selectedLawyer = lawyers.find(l => l.id === formData.lawyer);

  if (submitSuccess) {
    return (
      <div className="bg-white p-8 rounded-lg shadow-md animate-fade-in">
        <div className="text-center">
          <div className="inline-flex items-center justify-center h-16 w-16 rounded-full bg-green-100 text-green-600 mb-6">
            <svg className="h-8 w-8" fill="currentColor" viewBox="0 0 20 20">
              <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
            </svg>
          </div>
          <h2 className="text-2xl font-bold text-gray-900 mb-2">Appointment Scheduled!</h2>
          <p className="text-gray-600 mb-6">
            Thank you for booking with us. We've sent a confirmation email to {formData.email}.
          </p>
          
          <div className="bg-gray-50 rounded-lg p-6 mb-6 text-left">
            <h3 className="text-lg font-medium text-gray-900 mb-4">Appointment Details:</h3>
            <div className="space-y-3">
              <p><span className="font-medium">Service:</span> {selectedService?.title}</p>
              <p><span className="font-medium">Attorney:</span> {selectedLawyer?.name}</p>
              <p><span className="font-medium">Date:</span> {format(new Date(formData.date), 'MMMM d, yyyy')}</p>
              <p><span className="font-medium">Time:</span> {formData.time}</p>
            </div>
          </div>
          
          <div className="flex flex-col sm:flex-row justify-center gap-4">
            <a href="/" className="btn-primary">
              Return to Home
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
                  name: '',
                  email: '',
                  phone: '',
                  notes: ''
                });
              }}
              className="btn-outline"
            >
              Book Another Appointment
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
          {['Service & Attorney', 'Date & Time', 'Your Information'].map((title, index) => {
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
        {/* Step 1: Service & Attorney Selection */}
        {step === 1 && (
          <div className="animate-fade-in">
            <h2 className="text-2xl font-bold text-gray-900 mb-6">Select Service & Attorney</h2>
            
            <div className="mb-6">
              <label className="block text-gray-700 font-medium mb-2">Select Service</label>
              <select
                className="w-full border-gray-300 rounded-md shadow-sm focus:border-primary-500 focus:ring-primary-500"
                value={formData.service}
                onChange={(e) => updateFormData('service', e.target.value)}
              >
                <option value="">Select a legal service...</option>
                {services.map((service) => (
                  <option key={service.id} value={service.id}>
                    {service.title} - {service.price}
                  </option>
                ))}
              </select>
              {errors.service && <p className="text-red-500 text-sm mt-1">{errors.service}</p>}
            </div>
            
            <div className="mb-6">
              <label className="block text-gray-700 font-medium mb-2">Select Attorney</label>
              <select
                className="w-full border-gray-300 rounded-md shadow-sm focus:border-primary-500 focus:ring-primary-500"
                value={formData.lawyer}
                onChange={(e) => updateFormData('lawyer', e.target.value)}
              >
                <option value="">Select an attorney...</option>
                {lawyers.map((lawyer) => (
                  <option key={lawyer.id} value={lawyer.id}>
                    {lawyer.name} - {lawyer.specialization.join(', ')}
                  </option>
                ))}
              </select>
              {errors.lawyer && <p className="text-red-500 text-sm mt-1">{errors.lawyer}</p>}
            </div>
            
            {/* Selected Service Details */}
            {selectedService && (
              <div className="mb-6 p-4 bg-gray-50 rounded-lg">
                <h3 className="font-medium text-gray-900 mb-2">Service Details:</h3>
                <p className="text-gray-600 mb-2">{selectedService.description}</p>
                <div className="flex flex-wrap gap-x-4 text-sm">
                  <p><span className="font-medium">Price Range:</span> {selectedService.price}</p>
                  <p><span className="font-medium">Duration:</span> {selectedService.duration}</p>
                </div>
              </div>
            )}
            
            {/* Selected Attorney Details */}
            {selectedLawyer && (
              <div className="mb-6 p-4 bg-gray-50 rounded-lg">
                <div className="flex items-center">
                  <img 
                    src={selectedLawyer.photo} 
                    alt={selectedLawyer.name}
                    className="h-16 w-16 rounded-full object-cover mr-4" 
                  />
                  <div>
                    <h3 className="font-medium text-gray-900">{selectedLawyer.name}</h3>
                    <p className="text-gray-600">{selectedLawyer.experience} years of experience</p>
                    <div className="flex items-center mt-1">
                      <Star className="h-4 w-4 text-yellow-500 fill-current" />
                      <span className="ml-1 text-gray-700">{selectedLawyer.rating}</span>
                      <span className="text-gray-500 text-sm ml-1">({selectedLawyer.reviewCount} reviews)</span>
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
                Continue
              </button>
            </div>
          </div>
        )}
        
        {/* Step 2: Date & Time Selection */}
        {step === 2 && (
          <div className="animate-fade-in">
            <h2 className="text-2xl font-bold text-gray-900 mb-6">Select Date & Time</h2>
            
            <div className="mb-6">
              <label className="block text-gray-700 font-medium mb-2 flex items-center">
                <Calendar className="h-5 w-5 mr-2 text-primary-600" />
                Select Date
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
                Select Time
              </label>
              <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
                {availableTimes.map((time) => (
                  <button
                    key={time}
                    type="button"
                    className={`py-2 px-4 rounded-md text-center transition-colors ${
                      formData.time === time 
                        ? 'bg-primary-600 text-white' 
                        : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
                    }`}
                    onClick={() => updateFormData('time', time)}
                  >
                    {time}
                  </button>
                ))}
              </div>
              {errors.time && <p className="text-red-500 text-sm mt-1">{errors.time}</p>}
            </div>
            
            <div className="mb-6 p-4 bg-gray-50 rounded-lg">
              <h3 className="font-medium text-gray-900 mb-2">Appointment Summary:</h3>
              <p><span className="font-medium">Service:</span> {selectedService?.title}</p>
              <p><span className="font-medium">Attorney:</span> {selectedLawyer?.name}</p>
              {formData.date && <p>
                <span className="font-medium">Date:</span> {format(new Date(formData.date), 'MMMM d, yyyy')}
              </p>}
              {formData.time && <p><span className="font-medium">Time:</span> {formData.time}</p>}
            </div>
            
            <div className="flex justify-between">
              <button 
                type="button" 
                onClick={prevStep}
                className="btn-outline"
              >
                Back
              </button>
              <button 
                type="button" 
                onClick={nextStep}
                className="btn-primary"
              >
                Continue
              </button>
            </div>
          </div>
        )}
        
        {/* Step 3: Personal Information */}
        {step === 3 && (
          <div className="animate-fade-in">
            <h2 className="text-2xl font-bold text-gray-900 mb-6">Your Information</h2>
            
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="input-group">
                <label className="input-label" htmlFor="name">Full Name</label>
                <input
                  type="text"
                  id="name"
                  className="w-full"
                  value={formData.name}
                  onChange={(e) => updateFormData('name', e.target.value)}
                  placeholder="John Doe"
                />
                {errors.name && <p className="text-red-500 text-sm">{errors.name}</p>}
              </div>
              
              <div className="input-group">
                <label className="input-label" htmlFor="email">Email Address</label>
                <input
                  type="email"
                  id="email"
                  className="w-full"
                  value={formData.email}
                  onChange={(e) => updateFormData('email', e.target.value)}
                  placeholder="john.doe@example.com"
                />
                {errors.email && <p className="text-red-500 text-sm">{errors.email}</p>}
              </div>
              
              <div className="input-group md:col-span-2">
                <label className="input-label" htmlFor="phone">Phone Number</label>
                <input
                  type="tel"
                  id="phone"
                  className="w-full"
                  value={formData.phone}
                  onChange={(e) => updateFormData('phone', e.target.value)}
                  placeholder="(123) 456-7890"
                />
                {errors.phone && <p className="text-red-500 text-sm">{errors.phone}</p>}
              </div>
              
              <div className="input-group md:col-span-2">
                <label className="input-label" htmlFor="notes">Additional Notes (Optional)</label>
                <textarea
                  id="notes"
                  className="w-full h-32"
                  value={formData.notes}
                  onChange={(e) => updateFormData('notes', e.target.value)}
                  placeholder="Please share any additional information about your legal matter that would help us prepare for your consultation."
                ></textarea>
              </div>
            </div>
            
            <div className="mb-6 mt-8 p-4 bg-gray-50 rounded-lg">
              <h3 className="font-medium text-gray-900 mb-2">Final Appointment Details:</h3>
              <p><span className="font-medium">Service:</span> {selectedService?.title}</p>
              <p><span className="font-medium">Attorney:</span> {selectedLawyer?.name}</p>
              {formData.date && <p>
                <span className="font-medium">Date:</span> {format(new Date(formData.date), 'MMMM d, yyyy')}
              </p>}
              {formData.time && <p><span className="font-medium">Time:</span> {formData.time}</p>}
            </div>
            
            <div className="flex justify-between mt-6">
              <button 
                type="button" 
                onClick={prevStep}
                className="btn-outline"
              >
                Back
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
                    Processing...
                  </>
                ) : (
                  'Confirm Appointment'
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