import { useParams, Link } from 'react-router-dom';
import { lawyers } from '../../../data/lawyers';
import { Star, Calendar, ArrowLeft } from 'lucide-react';

const LawyerDetails = () => {
  const { id } = useParams();
  const lawyer = lawyers.find(l => l.id === id);

  if (!lawyer) {
    return (
      <div className="container mx-auto px-4 py-16 text-center">
        <h2 className="text-2xl font-bold text-gray-900 mb-4">Attorney Not Found</h2>
        <p className="text-gray-600 mb-6">The attorney you're looking for doesn't exist or has been removed.</p>
        <Link to="/lawyers" className="btn-primary">
          View All Attorneys
        </Link>
      </div>
    );
  }

  return (
    <main>
      <section className="bg-primary-700 py-16">
        <div className="container mx-auto px-4">
          <Link to="/lawyers" className="inline-flex items-center text-white hover:text-accent-300 mb-6 transition-colors">
            <ArrowLeft className="h-5 w-5 mr-2" />
            <span>Back to All Attorneys</span>
          </Link>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8 items-center">
            <div>
              <div className="relative overflow-hidden rounded-lg shadow-lg h-96 max-w-sm mx-auto">
                <img 
                  src={lawyer.photo} 
                  alt={`Attorney ${lawyer.name}`} 
                  className="w-full h-full object-cover object-center"
                />
              </div>
            </div>
            <div className="md:col-span-2 text-white">
              <h1 className="text-4xl font-bold text-white mb-2">{lawyer.name}</h1>
              
              <div className="flex flex-wrap gap-2 mb-4">
                {lawyer.specialization.map((spec, index) => (
                  <span key={index} className="badge bg-accent-300 text-primary-800 font-medium">
                    {spec}
                  </span>
                ))}
              </div>
              
              <div className="flex items-center mb-4">
                <div className="flex items-center">
                  <Star className="h-5 w-5 text-yellow-400 fill-current" />
                  <span className="ml-1 font-medium">{lawyer.rating}</span>
                </div>
                <span className="text-gray-300 text-sm ml-2">({lawyer.reviewCount} reviews)</span>
              </div>
              
              <p className="text-gray-200 mb-6 text-lg">{lawyer.description}</p>
              
              <Link 
                to={`/appointment?lawyer=${lawyer.id}`} 
                className="btn bg-accent-300 text-primary-800 hover:bg-accent-400 font-medium inline-flex items-center"
              >
                <Calendar className="mr-2 h-5 w-5" />
                <span>Schedule Consultation</span>
              </Link>
            </div>
          </div>
        </div>
      </section>

      <section className="py-16">
        <div className="container mx-auto px-4">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            <div className="md:col-span-2">
              <h2 className="text-2xl font-bold text-gray-900 mb-6">About {lawyer.name}</h2>
              
              <div className="prose max-w-none">
                <p className="mb-4">
                  With {lawyer.experience} years of experience in {lawyer.specialization.join(' and ')}, 
                  {lawyer.name} has established a reputation for excellence and dedication to client success. 
                </p>
                <p className="mb-4">
                  Their approach combines deep legal knowledge with a commitment to understanding each client's 
                  unique circumstances and goals. This client-centered philosophy has resulted in numerous favorable 
                  outcomes and long-lasting client relationships.
                </p>
                <p>
                  {lawyer.name} is known for their thorough preparation, strategic thinking, and 
                  exceptional advocacy skills both in and out of the courtroom.
                </p>
              </div>
              
              <div className="mt-8">
                <h3 className="text-xl font-medium text-gray-900 mb-4">Areas of Expertise</h3>
                <ul className="grid grid-cols-1 sm:grid-cols-2 gap-y-2 gap-x-4">
                  {lawyer.specialization.map((spec, index) => (
                    <li key={index} className="flex items-center">
                      <svg className="h-5 w-5 text-primary-600 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                      </svg>
                      {spec}
                    </li>
                  ))}
                  <li className="flex items-center">
                    <svg className="h-5 w-5 text-primary-600 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                    </svg>
                    Case Analysis & Strategy
                  </li>
                  <li className="flex items-center">
                    <svg className="h-5 w-5 text-primary-600 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                    </svg>
                    Client Advocacy
                  </li>
                  <li className="flex items-center">
                    <svg className="h-5 w-5 text-primary-600 mr-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                    </svg>
                    Negotiation
                  </li>
                </ul>
              </div>
            </div>
            
            <div>
              <div className="bg-gray-50 rounded-lg p-6 shadow-md">
                <h3 className="text-xl font-medium text-gray-900 mb-4">Attorney Profile</h3>
                
                <div className="space-y-4">
                  <div>
                    <h4 className="text-sm font-medium text-gray-500">Education</h4>
                    <p className="text-gray-900">{lawyer.education}</p>
                  </div>
                  
                  <div>
                    <h4 className="text-sm font-medium text-gray-500">Experience</h4>
                    <p className="text-gray-900">{lawyer.experience} years</p>
                  </div>
                  
                  <div>
                    <h4 className="text-sm font-medium text-gray-500">Languages</h4>
                    <p className="text-gray-900">{lawyer.languages.join(', ')}</p>
                  </div>
                  
                  <div>
                    <h4 className="text-sm font-medium text-gray-500">Contact</h4>
                    <a href="mailto:contact@legalconsult.com" className="text-primary-700 hover:text-primary-800">
                      contact@legalconsult.com
                    </a>
                  </div>
                </div>
                
                <div className="mt-8">
                  <Link 
                    to={`/appointment?lawyer=${lawyer.id}`}
                    className="btn-primary w-full justify-center"
                  >
                    Book Appointment
                  </Link>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>
    </main>
  );
};

export default LawyerDetails;