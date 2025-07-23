import { useState } from 'react';
import { Mail, Phone, MapPin, Clock } from 'lucide-react';

const ContactSection = () => {
  const [formData, setFormData] = useState({
    name: "",
    email: "",
    phone: "",
    subject: "",
    message: "",
  });
  const [errors, setErrors] = useState({});
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [submitSuccess, setSubmitSuccess] = useState(false);

  const handleChange = (e) => {
    const { id, value } = e.target;
    setFormData(prev => ({ ...prev, [id]: value }));

    // Clear error for this field
    if (errors[id]) {
      setErrors(prev => {
        const newErrors = { ...prev };
        delete newErrors[id];
        return newErrors;
      });
    }
  };

  const validateForm = () => {
    const newErrors = {};

    if (!formData.name.trim()) newErrors.name = "Yêu cầu nhập";
    if (!formData.email.trim()) newErrors.email = "Yêu cầu nhập";
    else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(formData.email)) {
      newErrors.email = "Hãy nhập mail hợp lệ";
    }
    if (!formData.message.trim()) newErrors.message = "Yêu cầu nhập";

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = (e) => {
    e.preventDefault();

    if (validateForm()) {
      setIsSubmitting(true);

      // Simulate API call with timeout
      setTimeout(() => {
        console.log('Contact form submitted:', formData);
        setIsSubmitting(false);
        setSubmitSuccess(true);
        setFormData({
          name: '',
          email: '',
          phone: '',
          subject: '',
          message: ''
        });
      }, 1500);
    }
  };

  return (
    <section className="py-16 bg-white" id="contact">
      <div className="container mx-auto px-4">
        <div className="text-center max-w-3xl mx-auto mb-12">
          <h2 className="text-3xl font-bold text-gray-900 mb-4">Liên hệ chúng tôi</h2>
          <p className="text-gray-600">
            Bạn có thắc mắc hoặc muốn thảo luận về nhu cầu pháp lý của mình? Hãy liên hệ với đội ngũ luật sư giàu kinh nghiệm của chúng tôi.          </p>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 max-w-6xl mx-auto">
          {/* Contact Information */}
          <div>
            <h3 className="text-2xl font-bold text-gray-900 mb-6">Kết nối với chúng tôi</h3>

            <div className="space-y-6">
              <div className="flex items-start">
                <MapPin className="h-6 w-6 text-primary-700 mt-1 flex-shrink-0" />
                <div className="ml-4">
                  <h4 className="font-medium text-gray-900">Văn phòng</h4>
                  <p className="text-gray-600">
                    123 Legal Avenue, Suite 789<br />
                    New York, NY 10001
                  </p>
                </div>
              </div>

              <div className="flex items-start">
                <Phone className="h-6 w-6 text-primary-700 mt-1 flex-shrink-0" />
                <div className="ml-4">
                  <h4 className="font-medium text-gray-900">Điện thoại</h4>
                  <p className="text-gray-600">
                    <a href="tel:+12125551234" className="hover:text-primary-700 transition-colors">+1 (212) 555-1234</a>
                  </p>
                </div>
              </div>

              <div className="flex items-start">
                <Mail className="h-6 w-6 text-primary-700 mt-1 flex-shrink-0" />
                <div className="ml-4">
                  <h4 className="font-medium text-gray-900">Email</h4>
                  <p className="text-gray-600">
                    <a href="mailto:info@legalconsult.com" className="hover:text-primary-700 transition-colors">info@legalconsult.com</a>
                  </p>
                </div>
              </div>

              <div className="flex items-start">
                <Clock className="h-6 w-6 text-primary-700 mt-1 flex-shrink-0" />
                <div className="ml-4">
                  <h4 className="font-medium text-gray-900">Giờ làm việc</h4>
                  <p className="text-gray-600">
                    Thứ Hai - Thứ Sáu: 9:00 AM - 6:00 PM<br />
                    Thứ Bảy: 10:00 AM - 2:00 PM<br />
                    Chủ Nhật: Nghỉ
                  </p>
                </div>
              </div>
            </div>

            {/* Map */}
            <div className="mt-8 h-64 bg-gray-200 rounded-lg overflow-hidden">
              <iframe
                src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d387193.3059353029!2d-74.25986548248684!3d40.69714941932609!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x89c24fa5d33f083b%3A0xc80b8f06e177fe62!2sNew%20York%2C%20NY%2C%20USA!5e0!3m2!1sen!2sca!4v1655903584025!5m2!1sen!2sca"
                width="100%"
                height="100%"
                style={{ border: 0 }}
                allowFullScreen
                loading="lazy"
                referrerPolicy="no-referrer-when-downgrade"
                title="Office Location"
              ></iframe>
            </div>
          </div>

          {/* Contact Form */}
          <div>
            <h3 className="text-2xl font-bold text-gray-900 mb-6">Gửi tin nhắn cho chúng tôi</h3>

            {submitSuccess ? (
              <div className="bg-green-50 border-l-4 border-green-400 p-4 mb-6">
                <div className="flex items-center">
                  <div className="flex-shrink-0">
                    <svg className="h-5 w-5 text-green-400" viewBox="0 0 20 20" fill="currentColor">
                      <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
                    </svg>
                  </div>
                  <div className="ml-3">
                    <p className="text-sm text-green-700">
                      Cảm ơn bạn đã liên hệ! Chúng tôi sẽ sớm phản hồi bạn.
                    </p>
                  </div>
                </div>
              </div>
            ) : (
              <form onSubmit={handleSubmit} className="space-y-6">
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div className="input-group">
                    <label htmlFor="name" className="input-label">Họ và tên</label>
                    <input
                      type="text"
                      id="name"
                      value={formData.name}
                      onChange={handleChange}
                      className="w-full"
                      placeholder="John Doe"
                    />
                    {errors.name && <p className="text-red-500 text-sm">{errors.name}</p>}
                  </div>

                  <div className="input-group">
                    <label htmlFor="email" className="input-label">Email</label>
                    <input
                      type="email"
                      id="email"
                      value={formData.email}
                      onChange={handleChange}
                      className="w-full"
                      placeholder="john.doe@example.com"
                    />
                    {errors.email && <p className="text-red-500 text-sm">{errors.email}</p>}
                  </div>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                  <div className="input-group">
                    <label htmlFor="phone" className="input-label">Điện thoại</label>
                    <input
                      type="tel"
                      id="phone"
                      value={formData.phone}
                      onChange={handleChange}
                      className="w-full"
                      placeholder="(123) 456-7890"
                    />
                  </div>

                  <div className="input-group">
                    <label htmlFor="subject" className="input-label">Vấn đề</label>
                    <select
                      id="subject"
                      value={formData.subject}
                      onChange={handleChange}
                      className="w-full"
                    >
                      <option value="">Vấn đề...</option>
                      <option value="Appointment">Lên lịch hẹn</option>
                      <option value="Consultation">Tư vấn ban đầu</option>
                      <option value="Inquiry">Điều tra chung</option>
                      <option value="Other">Khác</option>
                    </select>
                  </div>
                </div>

                <div className="input-group">
                  <label htmlFor="message" className="input-label">Lời nhắn</label>
                  <textarea
                    id="message"
                    rows={6}
                    value={formData.message}
                    onChange={handleChange}
                    className="w-full"
                    placeholder="Please describe how we can assist you..."
                  ></textarea>
                  {errors.message && <p className="text-red-500 text-sm">{errors.message}</p>}
                </div>

                <button
                  type="submit"
                  className="btn-primary w-full"
                  disabled={isSubmitting}
                >
                  {isSubmitting ? (
                    <>
                      <svg className="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                        <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                        <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                      </svg>
                      Đang gửi...
                    </>
                  ) : (
                    'Gửi yêu cầu'
                  )}
                </button>
              </form>
            )}
          </div>
        </div>
      </div>
    </section>
  );
};

export default ContactSection;