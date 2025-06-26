import { message } from 'antd';
import AppointmentForm from '../../../components/AppointmentForm';
import { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useRef } from 'react';


const Appointment = () => {
  const navigate = useNavigate();
  const hasShowMessage = useRef(false);

  useEffect(() => {
    const token = localStorage.getItem('token');
    if(!token && !hasShowMessage.current) {
      message.warning('Vui lòng đăng nhập để đặt lịch hẹn.');
      navigate('/login');
      hasShowMessage.current = true;
    }
  }, [navigate]);

  return (
    <main>
      <section className="bg-primary-700 py-16">
        <div className="container mx-auto px-4">
          <div className="max-w-3xl">
            <h1 className="text-4xl font-bold text-white mb-6">Đặt Lịch Hẹn</h1>
            <p className="text-gray-200 text-lg">
              Hãy đặt lịch tư vấn với đội ngũ luật sư giàu kinh nghiệm của chúng tôi để thảo luận về nhu cầu cụ thể
              và tìm ra giải pháp phù hợp cho các vấn đề pháp lý của bạn.
            </p>
          </div>
        </div>
      </section>

      <section className="py-16 bg-gray-50">
        <div className="container mx-auto px-4">
          <div className="max-w-4xl mx-auto">
            <AppointmentForm />
          </div>
          
          <div className="max-w-4xl mx-auto mt-12">
            <h3 className="text-xl font-bold text-gray-900 mb-4">Bạn Sẽ Nhận Được Gì</h3>
            
            <div className="bg-white rounded-lg shadow-md p-6">
              <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                <div className="text-center">
                  <div className="h-12 w-12 bg-primary-100 text-primary-700 rounded-full flex items-center justify-center mx-auto mb-4">
                    <span className="text-xl font-bold">1</span>
                  </div>
                  <h4 className="font-medium text-gray-900 mb-2">Tư Vấn Ban Đầu</h4>
                  <p className="text-gray-600 text-sm">
                    Thảo luận nhu cầu pháp lý của bạn với luật sư chuyên môn trong lĩnh vực liên quan.
                  </p>
                </div>
                
                <div className="text-center">
                  <div className="h-12 w-12 bg-primary-100 text-primary-700 rounded-full flex items-center justify-center mx-auto mb-4">
                    <span className="text-xl font-bold">2</span>
                  </div>
                  <h4 className="font-medium text-gray-900 mb-2">Đánh Giá Hồ Sơ</h4>
                  <p className="text-gray-600 text-sm">
                    Nhận đánh giá toàn diện về vụ việc của bạn và các chiến lược pháp lý khả thi.
                  </p>
                </div>
                
                <div className="text-center">
                  <div className="h-12 w-12 bg-primary-100 text-primary-700 rounded-full flex items-center justify-center mx-auto mb-4">
                    <span className="text-xl font-bold">3</span>
                  </div>
                  <h4 className="font-medium text-gray-900 mb-2">Giải Pháp Cá Nhân Hóa</h4>
                  <p className="text-gray-600 text-sm">
                    Nhận được kế hoạch cá nhân hóa phù hợp với nhu cầu và mục tiêu pháp lý cụ thể của bạn.
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>
    </main>
  );
};

export default Appointment;
