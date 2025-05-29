import AppointmentForm from '../components/AppointmentForm';

const Appointment = () => {
  return (
    <main>
      <section className="bg-primary-700 py-16">
        <div className="container mx-auto px-4">
          <div className="max-w-3xl">
            <h1 className="text-4xl font-bold text-white mb-6">Book an Appointment</h1>
            <p className="text-gray-200 text-lg">
              Schedule a consultation with our experienced legal team to discuss your specific needs
              and find the right solutions for your legal matters.
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
            <h3 className="text-xl font-bold text-gray-900 mb-4">What to Expect</h3>
            
            <div className="bg-white rounded-lg shadow-md p-6">
              <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                <div className="text-center">
                  <div className="h-12 w-12 bg-primary-100 text-primary-700 rounded-full flex items-center justify-center mx-auto mb-4">
                    <span className="text-xl font-bold">1</span>
                  </div>
                  <h4 className="font-medium text-gray-900 mb-2">Initial Consultation</h4>
                  <p className="text-gray-600 text-sm">
                    Discuss your legal needs with an attorney who specializes in your area of concern.
                  </p>
                </div>
                
                <div className="text-center">
                  <div className="h-12 w-12 bg-primary-100 text-primary-700 rounded-full flex items-center justify-center mx-auto mb-4">
                    <span className="text-xl font-bold">2</span>
                  </div>
                  <h4 className="font-medium text-gray-900 mb-2">Case Assessment</h4>
                  <p className="text-gray-600 text-sm">
                    Receive a comprehensive evaluation of your case and potential legal strategies.
                  </p>
                </div>
                
                <div className="text-center">
                  <div className="h-12 w-12 bg-primary-100 text-primary-700 rounded-full flex items-center justify-center mx-auto mb-4">
                    <span className="text-xl font-bold">3</span>
                  </div>
                  <h4 className="font-medium text-gray-900 mb-2">Custom Solution</h4>
                  <p className="text-gray-600 text-sm">
                    Get a personalized plan tailored to your specific legal needs and objectives.
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