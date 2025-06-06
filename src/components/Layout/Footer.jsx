import { Link } from "react-router-dom";
import {
  Scale,
  Mail,
  Phone,
  MapPin,
  Facebook,
  Twitter,
  Linkedin,
  Instagram,
} from "lucide-react";

const Footer = () => {
  return (
    <footer className="bg-primary-900 text-white">
      <div className="container mx-auto pt-16 pb-8">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-8">
          {/* Logo and Description */}
          <div className="space-y-4">
            <Link to="/" className="flex items-center space-x-2">
              <Scale className="h-8 w-8 text-accent-300" />
              <span className="font-serif text-xl font-bold text-white">
                Basico
              </span>
            </Link>
            <p className="text-gray-300 mt-4">
              Dịch vụ pháp lý chuyên nghiệp phù hợp với nhu cầu của bạn. Đội ngũ
              luật sư giàu kinh nghiệm của chúng tôi cam kết cung cấp tư vấn
              pháp lý và đại diện pháp lý xuất sắc.
            </p>
            <div className="flex space-x-4 pt-4">
              <a
                href="#"
                className="text-gray-300 hover:text-accent-300 transition-colors"
                aria-label="Facebook"
              >
                <Facebook size={20} />
              </a>
              <a
                href="#"
                className="text-gray-300 hover:text-accent-300 transition-colors"
                aria-label="Twitter"
              >
                <Twitter size={20} />
              </a>
              <a
                href="#"
                className="text-gray-300 hover:text-accent-300 transition-colors"
                aria-label="LinkedIn"
              >
                <Linkedin size={20} />
              </a>
              <a
                href="#"
                className="text-gray-300 hover:text-accent-300 transition-colors"
                aria-label="Instagram"
              >
                <Instagram size={20} />
              </a>
            </div>
          </div>

          {/* Quick Links */}
          <div className="space-y-4">
            <h3 className="text-lg font-medium text-white font-serif">
              Truy cập nhanh
            </h3>
            <ul className="space-y-2">
              {Object.entries({
                "Dịch vụ": "/services",
                "Luật sư": "/lawyers",
                "Giới thiệu": "/about",
                "Liên hệ": "/contact",
              }).map(([name, path]) => (
                <li key={name}>
                  <Link
                    to={path}
                    className="text-gray-300 hover:text-accent-300 transition-colors"
                  >
                    {name}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          {/* Practice Areas */}
          <div className="space-y-4">
            <h3 className="text-lg font-medium text-white font-serif">
              Lĩnh Vực Hoạt Động
            </h3>
            <ul className="space-y-2">
              {[
                "Luật Doanh Nghiệp",
                "Luật Gia Đình",
                "Luật Bất Động Sản",
                "Sở Hữu Trí Tuệ",
                "Bào Chữa Hình Sự",
                "Lập Kế Hoạch Di Sản",
              ].map((item) => (
                <li key={item}>
                  <Link
                    to={`/services#${item.toLowerCase().replace(" ", "-")}`}
                    className="text-gray-300 hover:text-accent-300 transition-colors"
                  >
                    {item}
                  </Link>
                </li>
              ))}
            </ul>
          </div>

          {/* Contact Information */}
          <div className="space-y-4">
            <h3 className="text-lg font-medium text-white font-serif">
              Thông Tin Liên Hệ
            </h3>
            <ul className="space-y-4">
              <li className="flex items-start space-x-3">
                <MapPin className="h-5 w-5 text-accent-300 mt-0.5" />
                <span className="text-gray-300">
                  123 Basico, Suite 789
                  <br />
                  New York, NY 10001
                </span>
              </li>
              <li className="flex items-center space-x-3">
                <Phone className="h-5 w-5 text-accent-300" />
                <a
                  href="tel:+12125551234"
                  className="text-gray-300 hover:text-accent-300 transition-colors"
                >
                  +1 (212) 555-1234
                </a>
              </li>
              <li className="flex items-center space-x-3">
                <Mail className="h-5 w-5 text-accent-300" />
                <a
                  href="mailto:info@legalconsult.com"
                  className="text-gray-300 hover:text-accent-300 transition-colors"
                >
                  info@basico.com
                </a>
              </li>
            </ul>
          </div>
        </div>

        <hr className="border-gray-700 my-8" />

        <div className="flex flex-col md:flex-row justify-between items-center text-gray-400 text-sm">
          <p>© {new Date().getFullYear()} Basico. All rights reserved.</p>
          <div className="flex space-x-4 mt-4 md:mt-0">
            <Link
              to="/privacy-policy"
              className="hover:text-accent-300 transition-colors"
            >
              Privacy Policy
            </Link>
            <Link
              to="/terms-of-service"
              className="hover:text-accent-300 transition-colors"
            >
              Terms of Service
            </Link>
          </div>
        </div>
      </div>
    </footer>
  );
};

export default Footer;