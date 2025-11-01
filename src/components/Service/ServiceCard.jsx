import { Link } from 'react-router-dom';
import { getIconComponent, slugify } from '../../data/services';

const ServiceCard = ({ service }) => {
  // fallback mapping from practiceArea.code -> icon name (used by getIconComponent)
  const practiceToIconName = {
    MARRIAGE: 'Users',
    BUSINESS: 'Briefcase',
    INSURANCE: 'Shield',
    CONTRACT: 'FileText',
    LABOR: 'Users',
    CONSTRUCTION: 'Home',
  };

  const iconName =
    service.icon ||
    (service.practiceArea && practiceToIconName[(service.practiceArea.code || '').toString().toUpperCase()]) ||
    'FileText';

  const IconComponent = getIconComponent(iconName);

  // build slug from title/name
  const slug = slugify(service.title || service.name || String(service.id));

  return (
    <Link to={`/services/${slug}`} className="block group">
      <div className="bg-white rounded-2xl p-6 shadow-sm border border-gray-100 hover:shadow-lg transition-all duration-300 h-full transform group-hover:-translate-y-1">
        <div className="flex items-start gap-4">
          <div className="flex-shrink-0 p-3 bg-primary-50 rounded-xl group-hover:bg-primary-100 transition-colors">
            {IconComponent && <IconComponent className="h-6 w-6 text-primary-700" />}
          </div>

          <div className="min-w-0">
            <h3 className="text-lg font-semibold text-gray-900 mb-2 group-hover:text-primary-700 transition-colors line-clamp-2">
              {service.title || service.name}
            </h3>

            <p className="text-gray-600 text-sm leading-relaxed line-clamp-3">
              {service.description}
            </p>
          </div>
        </div>
      </div>
    </Link>
  );
};

export default ServiceCard;