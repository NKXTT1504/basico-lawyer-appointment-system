import { Star } from 'lucide-react';


const TestimonialCard = ({ testimonial }) => {
  return (
    <div className="bg-white p-6 rounded-lg shadow-md hover:shadow-lg transition-shadow">
      <div className="flex items-center mb-4">
        {/* Rating Stars */}
        <div className="flex mr-2">
          {[...Array(5)].map((_, i) => (
            <Star 
              key={i} 
              className={`h-4 w-4 ${i < testimonial.rating ? 'text-yellow-500 fill-current' : 'text-gray-300'}`} 
            />
          ))}
        </div>
      </div>
      
      <p className="text-gray-600 mb-6 italic">"{testimonial.content}"</p>
      
      <div className="flex items-center">
        <img 
          src={testimonial.photo} 
          alt={testimonial.name} 
          className="h-12 w-12 rounded-full object-cover mr-4"
        />
        <div>
          <h4 className="font-medium text-gray-900">{testimonial.name}</h4>
          <p className="text-sm text-gray-500">{testimonial.position}</p>
        </div>
      </div>
    </div>
  );
};

export default TestimonialCard;