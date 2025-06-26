import { Service } from '../types';
import { BookOpen, Building, FileText, Home, Scale, Shield, Users, Briefcase } from 'lucide-react';

export const services: Service[] = [
  {
    id: "1",
    title: "Luật Doanh Nghiệp",
    icon: "Building",
    description: "Tư vấn chuyên sâu về thành lập doanh nghiệp, quản trị, tuân thủ pháp luật và giao dịch để giúp doanh nghiệp phát triển bền vững.",
    price: "$200-$350",
    duration: "60 phút",
    category: "Business"
  },
  {
    id: "2",
    title: "Sở Hữu Trí Tuệ",
    icon: "Shield",
    description: "Bảo vệ sáng chế, tác phẩm sáng tạo và thương hiệu của bạn thông qua bằng sáng chế, nhãn hiệu, bản quyền và bí mật thương mại.",
    price: "$250-$400",
    duration: "60 phút",
    category: "Business"
  },
  {
    id: "3",
    title: "Luật Gia Đình",
    icon: "Users",
    description: "Tư vấn pháp lý tận tâm về ly hôn, quyền nuôi con, nhận con nuôi và các vấn đề gia đình khác trong thời điểm khó khăn.",
    price: "$180-$300",
    duration: "90 phút",
    category: "Personal"
  },
  {
    id: "4",
    title: "Luật Bất Động Sản",
    icon: "Home",
    description: "Dịch vụ pháp lý toàn diện về giao dịch bất động sản, tranh chấp thuê nhà, quy hoạch và các dự án phát triển bất động sản.",
    price: "$200-$350",
    duration: "60 phút",
    category: "Property"
  },
  {
    id: "5",
    title: "Bào Chữa Hình Sự",
    icon: "Scale",
    description: "Đại diện bào chữa chiến lược cho những người bị buộc tội, từ vi phạm nhẹ đến các vụ án hình sự phức tạp cấp liên bang.",
    price: "$300-$500",
    duration: "120 phút",
    category: "Personal"
  },
  {
    id: "6",
    title: "Xem Xét Hợp Đồng",
    icon: "FileText",
    description: "Phân tích kỹ lưỡng và chỉnh sửa hợp đồng để bảo vệ quyền lợi của bạn và đảm bảo điều khoản có lợi trước khi ký kết.",
    price: "$150-$250",
    duration: "45 phút",
    category: "Business"
  },
  {
    id: "7",
    title: "Lập Kế Hoạch Di Sản",
    icon: "BookOpen",
    description: "Lập di chúc, quỹ tín thác và kế hoạch tài sản để bảo vệ tài sản và đảm bảo mong muốn của bạn được thực hiện.",
    price: "$200-$350",
    duration: "90 phút",
    category: "Personal"
  },
  {
    id: "8",
    title: "Luật Lao Động",
    icon: "Briefcase",
    description: "Tư vấn pháp lý về các vấn đề tại nơi làm việc như phân biệt đối xử, quấy rối, sa thải sai luật và hợp đồng lao động.",
    price: "$200-$350",
    duration: "60 phút",
    category: "Business"
  }
];

export const getIconComponent = (iconName: string) => {
  switch (iconName) {
    case 'Building': return Building;
    case 'Shield': return Shield;
    case 'Users': return Users;
    case 'Home': return Home;
    case 'Scale': return Scale;
    case 'FileText': return FileText;
    case 'BookOpen': return BookOpen;
    case 'Briefcase': return Briefcase;
    default: return FileText;
  }
};

export const serviceCategories = [
  { id: 'all', name: 'Tất cả Dịch vụ' },
  { id: 'business', name: 'Doanh nghiệp' },
  { id: 'personal', name: 'Cá nhân' },
  { id: 'property', name: 'Bất động sản' }
];
