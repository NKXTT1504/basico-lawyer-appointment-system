import { useState, useEffect } from "react";
import { Link, useLocation, useNavigate } from "react-router-dom";
import { Menu, X, Scale, User } from "lucide-react";

const Navbar = () => {
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const [isScrolled, setIsScrolled] = useState(false);
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [userRole, setUserRole] = useState(null);
  const location = useLocation();
  const navigate = useNavigate();

  useEffect(() => {
    const handleScroll = () => {
      setIsScrolled(window.scrollY > 20);
    };

    const checkLoginStatus = () => {
      const token = localStorage.getItem("token");
      const role = localStorage.getItem("role");
      setIsLoggedIn(!!token);
      setUserRole(role);
    };

    window.addEventListener("scroll", handleScroll);
    window.addEventListener("storage", checkLoginStatus);
    checkLoginStatus();

    return () => {
      window.removeEventListener("scroll", handleScroll);
      window.removeEventListener("storage", checkLoginStatus);
    };
  }, []);

  useEffect(() => {
    setIsMenuOpen(false);
  }, [location.pathname]);

  const toggleMenu = () => {
    setIsMenuOpen(!isMenuOpen);
  };

  const handleLogout = () => {
    localStorage.removeItem("token");
    localStorage.removeItem("role");
    localStorage.removeItem("user");
    setIsLoggedIn(false);
    setUserRole(null);
    navigate("/");
  };

  const getProfileLink = () => {
    switch(userRole) {
      case 'Customer':
        return '/customerprofile';
      case 'Lawyer':
        return '/lawyerprofile';
      case 'Admin':
        return '/admin/dashboard';
      default:
        return '/customerprofile';
    }
  };

  const navItems = [
    { name: "Trang chủ", path: "/" },
    { name: "Dịch vụ", path: "/services" },
    { name: "Luật sư", path: "/lawyers" },
    { name: "Giới thiệu", path: "/about" },
    { name: "Liên hệ", path: "/contact" },
  ];

  return (
    <nav
      className={`fixed top-0 left-0 w-full z-50 ${
        isScrolled ? "bg-white shadow-md" : "bg-white"
      }`}
    >
      <div className="container mx-auto px-4">
        <div className="flex justify-between items-center h-20">
          <Link to="/" className="flex items-center space-x-2">
            <Scale className="h-8 w-8" style={{ color: "#1e3353" }} />
            <span className={`font-serif text-xl font-bold`}>BASICO</span>
          </Link>

          {/* Desktop Navigation */}
          <div className="hidden md:flex items-center space-x-8">
            {navItems.map((item) => (
              <Link
                key={item.name}
                to={item.path}
                className="font-medium"
                style={{ color: "#1e3353" }}
              >
                {item.name}
              </Link>
            ))}
            {isLoggedIn ? (
              <div className="flex items-center space-x-4">
                <Link to={getProfileLink()} className="btn-primary">
                  <User className="h-5 w-5 mr-2" />
                  Profile
                </Link>
                <button onClick={handleLogout} className="btn-outline">
                  Đăng xuất
                </button>
              </div>
            ) : (
              <div className="flex items-center space-x-4">
                <Link to="/login" className="btn-outline">
                  Đăng nhập
                </Link>
                <Link to="/register" className="btn-primary">
                  Đăng Ký
                </Link>
              </div>
            )}
          </div>

          {/* Mobile Menu Button */}
          <button
            onClick={toggleMenu}
            className="md:hidden focus:outline-none"
            aria-label="Toggle menu"
          >
            {isMenuOpen ? (
              <X className="h-6 w-6" style={{ color: "#1e3353" }} />
            ) : (
              <Menu className="h-6 w-6" style={{ color: "#1e3353" }} />
            )}
          </button>
        </div>

        {/* Mobile Menu */}
        <div
          className={`md:hidden transition-all duration-300 ease-in-out overflow-hidden ${
            isMenuOpen ? "max-h-96 py-4" : "max-h-0 py-0"
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
            {isLoggedIn ? (
              <>
                <Link
                  to={getProfileLink()}
                  className="btn-primary w-full justify-center"
                >
                  <User className="h-5 w-5 mr-2" />
                  Profile
                </Link>
                <button
                  onClick={handleLogout}
                  className="btn-outline w-full justify-center"
                >
                  Đăng xuất
                </button>
              </>
            ) : (
              <>
                <Link
                  to="/login"
                  className="btn-outline w-full justify-center"
                >
                  Đăng nhập
                </Link>
                <Link
                  to="/register"
                  className="btn-primary w-full justify-center"
                >
                  Đăng Ký
                </Link>
              </>
            )}
          </div>
        </div>
      </div>
    </nav>
  );
};

export default Navbar;