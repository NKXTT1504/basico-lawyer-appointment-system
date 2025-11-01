import { useState, useEffect } from "react";
import { Link, useLocation, useNavigate } from "react-router-dom";
import { useSelector, useDispatch } from "react-redux";
import { logout } from "../../redux/features/userSlice";
import { Menu, X, Scale, User } from "lucide-react";


const Navbar = () => {
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const [isScrolled, setIsScrolled] = useState(false);
  const location = useLocation();
  const navigate = useNavigate();
  const dispatch = useDispatch();
  const [openDropdowns, setOpenDropdowns] = useState({});

  const toggleDropdown = (name) => {
    setOpenDropdowns(prev => ({
      ...prev,
      [name]: !prev[name]
    }));
  };

  const user = useSelector((state) => state.user);
  const isLoggedIn = !!user?.token;
  const userRole = user?.user?.role || null;

  useEffect(() => {
    const handleScroll = () => {
      setIsScrolled(window.scrollY > 20);
    };
    window.addEventListener("scroll", handleScroll);
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  useEffect(() => {
    setIsMenuOpen(false);
  }, [location.pathname]);

  const toggleMenu = () => setIsMenuOpen(!isMenuOpen);

  const handleLogout = () => {
    localStorage.clear(); // Xóa hết storage
    sessionStorage.clear(); // Xóa hết session storage
    dispatch(logout());
    navigate("/");
  };

  const getProfileLink = () => {
    switch (userRole) {
      case "Customer":
        return "/customer-profile";
      case "Lawyer":
        return "/lawyerprofile";
      case "Admin":
        return "/adminprofile";
      default:
        return "/";
    }
  };

  const commonNavItems = [
    { name: "Trang chủ", path: "/" },
    { name: "Dịch vụ", path: "/services" },
    { name: "Luật sư", path: "/lawyers" },
    { name: "Văn bản", path: "/form" },
    { name: "Giới thiệu", path: "/about" },
    { name: "Liên hệ", path: "/contact" },
  ];

  const customerNavItems = [
    { name: "Trang chủ", path: "/" },
    { name: "Dịch vụ", path: "/services" },
    { name: "Luật sư", path: "/lawyers" },
    { name: "Văn bản", path: "/form" },
    { name: "Giới thiệu", path: "/about" },
    { name: "Liên hệ", path: "/contact" },

  ];

  const lawyerNavItems = [
    { name: "Quản lí lịch hẹn", path: "/manageappointment" },
    { name: "Ca làm", path: "/lawyershift" },
    { name: "Quản lí bằng cấp", path: "/manage-diploma" },
  ];

  const adminNavItems = [
    { name: "Thống kê", path: "/dashboard" },
    {
      name: "Quản lý",
      children: [
        { name: "Tài khoản", path: "/manageaccount" },
        { name: "Luật sư", path: "/lawyermanagement" },
        { name: "Lịch hẹn", path: "/appointmentmanagement" },
        { name: "Đánh giá", path: "/reviewmanagement" },
        { name: "Form", path: "/formmanagement" },
        { name: "Thanh toán", path: "/paymentmanagement" },
      ]
    }
  ];

  let navItems = commonNavItems;
  if (userRole === "Lawyer") {
    navItems = [...lawyerNavItems];
  } else if (userRole === "Admin") {
    navItems = [...adminNavItems];
  }

  // Định nghĩa màu sắc tùy vào role
  const isRoleWithDarkNavbar = userRole === "Lawyer" || userRole === "Admin";
  const navbarBgClass = isRoleWithDarkNavbar ? "bg-primary-900" : "bg-white";
  const textColor = isRoleWithDarkNavbar ? "text-white" : "text-primary-900";
  const iconColor = isRoleWithDarkNavbar ? "#fff" : "#1e3353";

  useEffect(() => {
    const closeDropdowns = (e) => {
      if (!e.target.closest('.dropdown-container')) {
        setOpenDropdowns({});
      }
    };

    document.addEventListener('click', closeDropdowns);

    return () => document.removeEventListener('click', closeDropdowns);
  }, []);

  return (
    <nav
      className={`fixed top-0 left-0 w-full z-50 transition-all duration-300 ${navbarBgClass} ${isScrolled && !isRoleWithDarkNavbar ? "shadow-md" : ""
        }`}
    >
      <div className="container mx-auto px-4">
        <div className="flex justify-between items-center h-20">
          <Link to="/" className="flex items-center space-x-2">
            <Scale className="h-8 w-8" style={{ color: iconColor }} />
            <span className={`font-serif text-xl font-bold ${textColor}`}>
              BASICO
            </span>
          </Link>

          {/* Desktop Navigation */}
          <div className="hidden md:flex items-center space-x-8">
            {navItems.map((item) => (
              <div key={item.name} className="relative dropdown-container">
                {item.children ? (
                  <>
                    <button
                      onClick={() => toggleDropdown(item.name)}
                      className={`font-medium ${textColor} flex items-center`}
                    >
                      {item.name}
                      <svg className="w-4 h-4 ml-1" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                      </svg>
                    </button>
                    {openDropdowns[item.name] && (
                      <div className="absolute left-0 mt-2 w-28 rounded-md shadow-lg bg-white ring-1 ring-black ring-opacity-5">
                        <div className="py-1 whitespace-nowrap" role="menu" aria-orientation="vertical" aria-labelledby="options-menu">
                          {item.children.map((child) => (
                            <Link
                              key={child.name}
                              to={child.path}
                              className="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                              role="menuitem"
                            >
                              {child.name}
                            </Link>
                          ))}
                        </div>
                      </div>
                    )}
                  </>
                ) : (
                  <Link
                    to={item.path}
                    className={`font-medium ${textColor}`}
                  >
                    {item.name}
                  </Link>
                )}
              </div>
            ))}
            <div className="flex-grow"></div>
            {isLoggedIn ? (
              <div className="flex items-center space-x-4">
                <div className="relative dropdown-container">
                  <button
                    onClick={() => toggleDropdown('account')}
                    className={`btn-primary ${isRoleWithDarkNavbar ? "bg-white text-primary-900 hover:bg-gray-200" : ""}`}
                  >
                    <User className="h-5 w-5 mr-2" />
                    Tài khoản
                  </button>
                  {openDropdowns['account'] && (
                    <div className="absolute mt-2 w-40 bg-white rounded-md shadow-lg z-10">
                      <Link
                        to={getProfileLink()}
                        className="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                      >
                        Cài đặt
                      </Link>
                      {userRole === "Customer" && (
                        <>
                          <Link
                            to="/history-appointments"
                            className="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                          >
                            Cuộc hẹn
                          </Link>
                          <Link
                            to="/customer-payment"
                            className="flex items-center px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 transition-colors"
                          >
                            Lịch sử thanh toán
                          </Link>
                        </>
                      )}
                      <button
                        onClick={handleLogout}
                        className="block w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 hover:rounded-md"
                      >
                        Đăng xuất
                      </button>
                    </div>
                  )}
                </div>
              </div>
            ) : (
              <div className="flex items-center space-x-4">
                <Link
                  to="/register"
                  className={`btn-outline ${isRoleWithDarkNavbar ? "border-white text-white hover:bg-primary-800" : ""}`}
                >
                  Đăng ký
                </Link>
                <Link
                  to="/login"
                  className={`btn-primary ${isRoleWithDarkNavbar ? "bg-white text-primary-900 hover:bg-gray-200" : ""}`}
                >
                  Đăng nhập
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
              <X className="h-6 w-6" style={{ color: iconColor }} />
            ) : (
              <Menu className="h-6 w-6" style={{ color: iconColor }} />
            )}
          </button>
        </div>

        {/* Mobile Menu */}
        <div
          className={`md:hidden transition-all duration-300 ease-in-out overflow-hidden ${isMenuOpen ? "max-h-96 py-4" : "max-h-0 py-0"
            }`}
        >
          <div
            className={`flex flex-col space-y-4 rounded-lg p-4 shadow-lg ${isRoleWithDarkNavbar ? "bg-primary-900" : "bg-white"
              }`}
          >
            {navItems.map((item) => (
              <div key={item.name}>
                {item.children ? (
                  <>
                    <button
                      onClick={() => toggleDropdown(item.name)}
                      className={`font-medium w-full text-left px-4 py-2 rounded-md ${isRoleWithDarkNavbar
                        ? "text-white hover:bg-primary-800"
                        : "text-gray-700 hover:bg-gray-50"
                        }`}
                    >
                      {item.name}
                    </button>
                    {openDropdowns[item.name] && (
                      <div className="pl-4">
                        {item.children.map((child) => (
                          <Link
                            key={child.name}
                            to={child.path}
                            className={`block px-4 py-2 text-sm rounded-md ${isRoleWithDarkNavbar
                              ? "text-white hover:bg-primary-800"
                              : "text-gray-700 hover:bg-gray-50"
                              }`}
                          >
                            {child.name}
                          </Link>
                        ))}
                      </div>
                    )}
                  </>
                ) : (
                  <Link
                    to={item.path}
                    className={`font-medium block px-4 py-2 rounded-md ${isRoleWithDarkNavbar
                      ? "text-white hover:bg-primary-800"
                      : "text-gray-700 hover:bg-gray-50"
                      }`}
                  >
                    {item.name}
                  </Link>
                )}
              </div>
            ))}

            {isLoggedIn ? (
              <>
                <Link
                  to={getProfileLink()}
                  className={`btn-primary w-full justify-center ${isRoleWithDarkNavbar
                    ? "bg-white text-primary-900 hover:bg-gray-200"
                    : ""
                    }`}
                >
                  <User className="h-5 w-5 mr-2" />
                  Tài khoản
                </Link>
                <button
                  onClick={handleLogout}
                  className={`btn-outline w-full justify-center ${isRoleWithDarkNavbar
                    ? "border-white text-white hover:bg-primary-800"
                    : ""
                    }`}
                >
                  Đăng xuất
                </button>
              </>
            ) : (
              <>
                <Link
                  to="/login"
                  className={`btn-outline w-full justify-center ${isRoleWithDarkNavbar
                    ? "border-white text-white hover:bg-primary-800"
                    : ""
                    }`}
                >
                  Đăng nhập
                </Link>
                <Link
                  to="/register"
                  className={`btn-primary w-full justify-center ${isRoleWithDarkNavbar
                    ? "bg-white text-primary-900 hover:bg-gray-200"
                    : ""
                    }`}
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
