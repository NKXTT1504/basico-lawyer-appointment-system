import { useEffect, useState } from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';

// Components
import Navbar from './components/Navbar';
import LawyerNavbar from './components/LawyerNavbar';
import Footer from './components/Footer';

// Pages
import Home from './pages/Home';
import Services from './pages/Services';
import ServiceDetails from './pages/ServiceDetails';
import Lawyers from './pages/Lawyers';
import LawyerDetails from './pages/LawyerDetails';
import About from './pages/About';
import Contact from './pages/Contact';
import Appointment from './pages/Appointment';
import Login from './pages/Login';
import Register from './pages/Register';
import ManageAppointment from './pages/ManageAppointment';
import LawyerShift from './pages/LawyerShift';
import LawyerProfile from './pages/LawyerProfile';

function App() {
  const [role, setRole] = useState(localStorage.getItem("role"));

  useEffect(() => {
    const handleStorageChange = () => {
      setRole(localStorage.getItem("role"));
    };

    window.addEventListener("storage", handleStorageChange);
    return () => window.removeEventListener("storage", handleStorageChange);
  }, []);
  return (
    <Router>
      <div className="min-h-screen flex flex-col">
        {role === "Lawyer" ? <LawyerNavbar /> : <Navbar />}
        <div className="pt-20 flex-grow">
          <Routes>
            <Route path="/" element={<Home />} />
            <Route path="/services" element={<Services />} />
            <Route path="/services/:id" element={<ServiceDetails />} />
            <Route path="/lawyers" element={<Lawyers />} />
            <Route path="/lawyers/:id" element={<LawyerDetails />} />
            <Route path="/about" element={<About />} />
            <Route path="/contact" element={<Contact />} />
            <Route path="/appointment" element={<Appointment />} />
            <Route path="/login" element={<Login />} />
            <Route path="/register" element={<Register />} />
            <Route path="/manageappointment" element={<ManageAppointment />} />
            <Route path="/lawyershift" element={<LawyerShift />} />
            <Route path="/lawyerprofile" element={<LawyerProfile />} />
          </Routes>
        </div>
        <Footer />
      </div>
    </Router>
  );
}

export default App;
