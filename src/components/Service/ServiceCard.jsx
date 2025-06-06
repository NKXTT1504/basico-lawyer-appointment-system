import { Link } from 'react-router-dom';
import { getIconComponent } from '../../data/services';
import { ArrowRight } from 'lucide-react';

const ServiceCard = ({ service }) => {
  const IconComponent = getIconComponent(service.icon);

  return (
    <div className="card group h-full flex flex-col transition-all duration-300 hover:border-l-4 hover:border-l-primary-700">
      <div className="p-6 flex-1 flex flex-col">
        <div className="p-3 bg-primary-50 rounded-lg w-14 h-14 flex items-center justify-center mb-4 group-hover:bg-primary-100 transition-colors">
          <IconComponent className="h-7 w-7 text-primary-700" />
        </div>
        
        <h3 className="text-xl font-medium text-gray-900 mb-3">{service.title}</h3>
        
        <p className="text-gray-600 mb-4 flex-grow">{service.description}</p>
        
        <div className="flex flex-wrap gap-2 mb-4">
          <span className="text-sm font-medium text-gray-700">
            <span className="font-bold">Giá:</span> {service.price}
          </span>
          <br/>
          <span className="text-sm font-medium text-gray-700">
            <span className="font-bold">Thời lượng:</span> {service.duration}
          </span>
        </div>
        
        <Link 
          to={`/services/${service.id}`}
          className="group mt-auto inline-flex items-center text-primary-700 font-medium hover:text-primary-800"
        >
          <span>Tìm hiểu thêm</span>
          <ArrowRight className="ml-2 h-4 w-4 transform group-hover:translate-x-1 transition-transform" />
        </Link>
      </div>
    </div>
  );
};

export default ServiceCard;