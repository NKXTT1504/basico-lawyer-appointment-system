import { useParams, Link } from 'react-router-dom';
import { services, getIconComponent } from '../data/services';
import { ArrowLeft, Check } from 'lucide-react';

const ServiceDetails = () => {
  const { id } = useParams();
  const service = services.find(s => s.id === id);

  if (!service) {
    return (
      <div className="container mx-auto px-4 py-16 text-center">
        <h2 className="text-2xl font-bold text-gray-900 mb-4">Service Not Found</h2>
        <p className="text-gray-600 mb-6">The service you're looking for doesn't exist or has been removed.</p>
        <Link to="/services" className="btn-primary">
          View All Services
        </Link>
      </div>
    );
  }

  const IconComponent = getIconComponent(service.icon);

  // Service benefits specific to each service
  const benefits = [
    'Expert legal advice tailored to your specific situation',
    'Clear communication throughout the process',
    'Strategic approach to achieve optimal outcomes',
    'Transparent pricing with no hidden fees',
    'Ongoing support and guidance'
  ];

  // Service process steps
  const processSteps = [
    {
      title: 'Initial Consultation',
      description: 'Meet with our expert attorney to discuss your specific needs and goals.'
    },
    {
      title: 'Case Analysis',
      description: 'Your attorney will thoroughly analyze your case and develop a strategic approach.'
    },
    {
      title: 'Implementation',
      description: 'We execute the legal strategy, keeping you informed at every step.'
    },
    {
      title: 'Resolution',
      description: 'Achieve the best possible outcome with our dedicated support.'
    }
  ];

  return (
    <main>
      <section className="bg-primary-700 py-16">
        <div className="container mx-auto px-4">
          <Link to="/services" className="inline-flex items-center text-white hover:text-accent-300 mb-6 transition-colors">
            <ArrowLeft className="h-5 w-5 mr-2" />
            <span>Back to All Services</span>
          </Link>
          
          <div className="flex items-center mb-6">
            <div className="p-4 bg-white rounded-lg mr-4">
              <IconComponent className="h-8 w-8 text-primary-700" />
            </div>
            <h1 className="text-4xl font-bold text-white">{service.title}</h1>
          </div>
          
          <div className="max-w-3xl text-white">
            <p className="text-xl text-gray-200 mb-6">{service.description}</p>
            
            <div className="flex flex-wrap gap-6">
              <div>
                <span className="block text-gray-300 text-sm">Price Range</span>
                <span className="text-lg font-medium text-white">{service.price}</span>
              </div>
              
              <div>
                <span className="block text-gray-300 text-sm">Duration</span>
                <span className="text-lg font-medium text-white">{service.duration}</span>
              </div>
              
              <div>
                <span className="block text-gray-300 text-sm">Category</span>
                <span className="text-lg font-medium text-white">{service.category}</span>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section className="py-16">
        <div className="container mx-auto px-4">
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-12">
            <div className="lg:col-span-2">
              <h2 className="text-3xl font-bold text-gray-900 mb-6">Service Overview</h2>
              
              <div className="prose max-w-none mb-12">
                <p className="mb-4">
                  Our {service.title.toLowerCase()} service provides comprehensive legal assistance to help you 
                  navigate complex legal matters with confidence and peace of mind. Whether you're 
                  facing a challenging legal issue or seeking proactive legal advice, our experienced 
                  attorneys are here to guide you every step of the way.
                </p>
                
                <p className="mb-4">
                  With years of specialized experience in {service.title.toLowerCase()}, our legal team has 
                  successfully handled numerous cases across a wide range of scenarios and complexities. 
                  We understand that each case is unique, which is why we take the time to understand your 
                  specific situation and develop tailored strategies to achieve the best possible outcomes.
                </p>
                
                <p>
                  Our approach combines deep legal expertise with a client-centered focus, ensuring that 
                  you receive both exceptional legal representation and compassionate support throughout 
                  the process. We're committed to providing clear communication, transparent pricing, 
                  and dedicated advocacy for your legal needs.
                </p>
              </div>
              
              <div className="mb-12">
                <h3 className="text-2xl font-bold text-gray-900 mb-6">Our Process</h3>
                
                <div className="space-y-6">
                  {processSteps.map((step, index) => (
                    <div key={index} className="flex">
                      <div className="flex-shrink-0">
                        <div className="flex items-center justify-center h-10 w-10 rounded-full bg-primary-100 text-primary-700 font-bold">
                          {index + 1}
                        </div>
                      </div>
                      <div className="ml-4">
                        <h4 className="text-lg font-medium text-gray-900">{step.title}</h4>
                        <p className="text-gray-600">{step.description}</p>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
              
              <div>
                <h3 className="text-2xl font-bold text-gray-900 mb-6">Why Choose Our Services</h3>
                
                <ul className="space-y-4">
                  {benefits.map((benefit, index) => (
                    <li key={index} className="flex items-start">
                      <Check className="h-6 w-6 text-green-500 mr-2 flex-shrink-0" />
                      <span className="text-gray-700">{benefit}</span>
                    </li>
                  ))}
                </ul>
              </div>
            </div>
            
            <div>
              <div className="bg-gray-50 rounded-lg p-6 shadow-md sticky top-24">
                <h3 className="text-xl font-bold text-gray-900 mb-4">Ready to Get Started?</h3>
                <p className="text-gray-600 mb-6">
                  Book a consultation with one of our expert attorneys specializing in {service.title.toLowerCase()} 
                  to discuss your specific needs and explore how we can help.
                </p>
                
                <Link 
                  to={`/appointment?service=${service.id}`}
                  className="btn-primary w-full justify-center mb-4"
                >
                  Schedule Consultation
                </Link>
                
                <Link 
                  to="/contact"
                  className="btn-outline w-full justify-center"
                >
                  Contact Us
                </Link>
                
                <div className="mt-6 pt-6 border-t border-gray-200">
                  <h4 className="font-medium text-gray-900 mb-3">Need More Information?</h4>
                  <p className="text-gray-600 text-sm mb-4">
                    Call us for a quick consultation or to ask any questions about our services.
                  </p>
                  <a 
                    href="tel:+12125551234" 
                    className="block text-center py-2 text-primary-700 font-medium hover:text-primary-800"
                  >
                    +1 (212) 555-1234
                  </a>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section className="py-16 bg-gray-50">
        <div className="container mx-auto px-4 text-center">
          <h2 className="text-3xl font-bold text-gray-900 mb-6">Explore Other Services</h2>
          <p className="text-gray-600 max-w-3xl mx-auto mb-10">
            Discover our comprehensive range of legal services designed to address all your legal needs.
          </p>
          
          <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
            {services
              .filter(s => s.id !== service.id)
              .slice(0, 4)
              .map(s => {
                const ServiceIcon = getIconComponent(s.icon);
                return (
                  <Link 
                    key={s.id}
                    to={`/services/${s.id}`}
                    className="bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow text-center"
                  >
                    <div className="p-3 bg-primary-50 rounded-full w-14 h-14 flex items-center justify-center mx-auto mb-4">
                      <ServiceIcon className="h-7 w-7 text-primary-700" />
                    </div>
                    <h3 className="font-medium text-gray-900">{s.title}</h3>
                  </Link>
                );
              })}
          </div>
        </div>
      </section>
    </main>
  );
};

export default ServiceDetails;