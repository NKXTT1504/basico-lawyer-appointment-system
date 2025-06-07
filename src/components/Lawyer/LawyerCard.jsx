import { Link } from 'react-router-dom';
import { Star, ArrowRight } from 'lucide-react';

const LawyerCard = ({ lawyer }) => {
  return (
    <div className="card h-full flex flex-col">
      <div className="relative h-64 overflow-hidden">
        <img 
          src={lawyer.photo} 
          alt={`Attorney ${lawyer.name}`} 
          className="w-full h-full object-cover object-center transition-transform duration-500 group-hover:scale-105"
        />
        <div className="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black to-transparent h-24"></div>
      </div>
      
      <div className="p-6 flex-1 flex flex-col">
        <h3 className="text-xl font-medium text-gray-900 mb-1">{lawyer.name}</h3>
        
        <div className="flex flex-wrap gap-2 mb-3">
          {lawyer.specialization.map((spec, index) => (
            <span key={index} className="badge-blue">
              {spec}
            </span>
          ))}
        </div>
        
        <div className="flex items-center mb-3">
          <div className="flex items-center">
            <Star className="h-5 w-5 text-yellow-500 fill-current" />
            <span className="ml-1 font-medium">{lawyer.rating}</span>
          </div>
          <span className="text-gray-500 text-sm ml-2">({lawyer.reviewCount} reviews)</span>
        </div>
        
        <p className="text-gray-600 mb-4 line-clamp-3">{lawyer.description}</p>
        
        <div className="mt-auto">
          <p className="text-sm font-medium text-gray-700 mb-4">
            <span className="font-bold">Experience:</span> {lawyer.experience} years
          </p>
          
          <Link 
            to={`/lawyers/${lawyer.id}`}
            className="group inline-flex items-center text-primary-700 font-medium hover:text-primary-800"
          >
            <span>View profile</span>
            <ArrowRight className="ml-2 h-4 w-4 transform group-hover:translate-x-1 transition-transform" />
          </Link>
        </div>
      </div>
    </div>
  );
};

export default LawyerCard;