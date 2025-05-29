import { Service } from '../types';
import { BookOpen, Building, FileText, Home, Scale, Shield, Users, Briefcase } from 'lucide-react';

export const services: Service[] = [
  {
    id: "1",
    title: "Corporate Law",
    icon: "Building",
    description: "Expert guidance on business formation, governance, compliance, and corporate transactions to help your business thrive while staying legally protected.",
    price: "$200-$350",
    duration: "60 min",
    category: "Business"
  },
  {
    id: "2",
    title: "Intellectual Property",
    icon: "Shield",
    description: "Protect your innovations, creative works, and brand identity through patents, trademarks, copyrights, and trade secrets management.",
    price: "$250-$400",
    duration: "60 min",
    category: "Business"
  },
  {
    id: "3",
    title: "Family Law",
    icon: "Users",
    description: "Compassionate legal guidance for divorce, child custody, adoption, and other family matters during life's most challenging transitions.",
    price: "$180-$300",
    duration: "90 min",
    category: "Personal"
  },
  {
    id: "4",
    title: "Real Estate Law",
    icon: "Home",
    description: "Comprehensive legal services for property transactions, tenant disputes, zoning issues, and real estate development projects.",
    price: "$200-$350",
    duration: "60 min",
    category: "Property"
  },
  {
    id: "5",
    title: "Criminal Defense",
    icon: "Scale",
    description: "Strategic defense representation for those facing criminal charges, from minor offenses to complex federal cases.",
    price: "$300-$500",
    duration: "120 min",
    category: "Personal"
  },
  {
    id: "6",
    title: "Contract Review",
    icon: "FileText",
    description: "Thorough analysis and revision of contracts to protect your interests and ensure favorable terms before signing any agreement.",
    price: "$150-$250",
    duration: "45 min",
    category: "Business"
  },
  {
    id: "7",
    title: "Estate Planning",
    icon: "BookOpen",
    description: "Create comprehensive wills, trusts, and estate plans to protect your assets and ensure your wishes are carried out.",
    price: "$200-$350",
    duration: "90 min",
    category: "Personal"
  },
  {
    id: "8",
    title: "Employment Law",
    icon: "Briefcase",
    description: "Legal counsel on workplace issues, including discrimination, harassment, wrongful termination, and employment contracts.",
    price: "$200-$350",
    duration: "60 min",
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
  { id: 'all', name: 'All Services' },
  { id: 'business', name: 'Business' },
  { id: 'personal', name: 'Personal' },
  { id: 'property', name: 'Property' }
];