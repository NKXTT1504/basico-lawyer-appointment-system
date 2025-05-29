export interface Lawyer {
  id: string;
  name: string;
  photo: string;
  specialization: string[];
  experience: number;
  education: string;
  description: string;
  languages: string[];
  rating: number;
  reviewCount: number;
}

export interface Service {
  id: string;
  title: string;
  icon: string;
  description: string;
  price: string;
  duration: string;
  category: string;
}

export interface Testimonial {
  id: string;
  name: string;
  position: string;
  photo: string;
  content: string;
  rating: number;
}

export interface Appointment {
  id: string;
  service: string;
  lawyer: string;
  date: string;
  time: string;
  clientName: string;
  clientEmail: string;
  clientPhone: string;
  status: 'pending' | 'confirmed' | 'completed' | 'cancelled';
  notes: string;
}

export interface User {
  id: string;
  name: string;
  email: string;
  phone: string;
  appointments: Appointment[];
}