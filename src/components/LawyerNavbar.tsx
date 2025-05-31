import React, { useState, useEffect } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { Menu, X, Scale } from 'lucide-react';

const LawyerNavbar: React.FC = () => {
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const [isScrolled, setIsScrolled] = useState(false);
  const location = useLocation();

  useEffect(() => {
    const handleScroll = () => {
      if (window.scrollY > 20) {
        setIsScrolled(true);
      } else {
        setIsScrolled(false);
      }
    };

    window.addEventListener('scroll', handleScroll);
    return () => {
      window.removeEventListener('scroll', handleScroll);
    };
  }, []);

  useEffect(() => {
    // Close mobile menu when route changes
    setIsMenuOpen(false);
  }, [location.pathname]);

  const toggleMenu = () => {
    setIsMenuOpen(!isMenuOpen);
  };

  const navItems = [
    { name: 'Quản lí lịch hẹn', path: '/manageappointment' },
    { name: 'Ca làm', path: '/lawyershift' },
    { name: 'Tài khoản', path: '/lawyerprofile' },
  ];

  return (
    <nav className={`fixed top-0 left-0 w-full z-50 transition-all duration-300 bg-primary-900 ${isScrolled ? 'bg-primary shadow-md' : 'bg-primary'}`}>
      <div className="container mx-auto px-4 text-white">
        <div className="flex justify-between items-center h-20">
          <Link to="/" className="flex items-center space-x-2">
            <Scale className={`h-8 w-8`} />
            <span className={`font-serif text-xl font-bold`}>BASICO</span>
          </Link>

          {/* Desktop Navigation */}
          <div className="hidden md:flex items-center space-x-8">
            {navItems.map((item) => (
              <Link 
                key={item.name} 
                to={item.path}
                className={`font-medium transition-colors`}
              >
                {item.name}
              </Link>
            ))}
            {/* <Link to="/appointment" className="btn-primary">
              Book Appointment
            </Link> */}
          </div>

          {/* Mobile Menu Button */}
          <button 
            onClick={toggleMenu}
            className="md:hidden focus:outline-none"
            aria-label="Toggle menu"
          >
            {isMenuOpen ? (
              <X className={`h-6 w-6`} />
            ) : (
              <Menu className={`h-6 w-6`} />
            )}
          </button>
        </div>

        {/* Mobile Menu */}
        <div 
          className={`md:hidden transition-all duration-300 ease-in-out overflow-hidden ${
            isMenuOpen ? 'max-h-96 py-4' : 'max-h-0 py-0'
          }`}
        >
          <div className="flex flex-col space-y-4 bg-white rounded-lg p-4 shadow-lg">
            {navItems.map((item) => (
              <Link 
                key={item.name} 
                to={item.path}
                className="text-gray-700 hover:text-primary-700 font-medium px-4 py-2 hover:bg-gray-50 rounded-md"
              >
                {item.name}
              </Link>
            ))}
            <Link 
              to="/appointment" 
              className="btn-primary w-full justify-center"
            >
              Book Appointment
            </Link>
          </div>
        </div>
      </div>
    </nav>
  );
};

export default LawyerNavbar;