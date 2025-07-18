import { useEffect, useState } from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';

// Components
import Navbar from './components/Layout/Navbar';
import Footer from './components/Layout/Footer';

// Pages
import Home from './pages/Interface/Customer/Home';
import Services from './pages/Interface/Customer/Services';
import ServiceDetails from './pages/Interface/Customer/ServiceDetails';
import Lawyers from './pages/Interface/Customer/Lawyers';
import LawyerDetails from './pages/Interface/Customer/LawyerDetails';
import About from './pages/Interface/Customer/About';
import Contact from './pages/Interface/Customer/Contact';
import Appointment from './pages/Interface/Customer/Appointment';
import Login from './pages/Authentication/Login';
import Register from './pages/Authentication/Register';
import ManageAppointment from './pages/Interface/Lawyer/ManageAppointment';
import LawyerShift from './pages/Interface/Lawyer/LawyerShift';
import LawyerProfile from './pages/Profiles/LawyerProfile';
import AdminProfile from './pages/Profiles/AdminProfile';
import Profile from './pages/Profiles/CustomerProfile'; 
import ManageAccount from './pages/ManageAccount'; 
import ManageLawyer from './pages/Interface/Admin/LawyerManagement'; 
import CustomerAppointment from './pages/Interface/Customer/CustomerAppointment';

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
         <Navbar />
        <div className="pt-20 flex-grow">
          <Routes>
            <Route path="/" element={<Home />} />
            <Route path="/services" element={<Services />} />
            <Route path="/services/:id" element={<ServiceDetails />} />
            <Route path="/lawyers" element={<Lawyers />} />
            <Route path="/lawyers/:slug" element={<LawyerDetails />} />
            <Route path="/about" element={<About />} />
            <Route path="/contact" element={<Contact />} />
            <Route path="/appointment" element={<Appointment />} />
            <Route path="/login" element={<Login setRole={setRole} />} />
            <Route path="/register" element={<Register />} />
            <Route path="/manageappointment" element={<ManageAppointment />} />
            <Route path="/lawyershift" element={<LawyerShift />} />
            <Route path="/lawyerprofile" element={<LawyerProfile />} />
            <Route path="/customerprofile" element={<Profile />} />
            <Route path="/adminprofile" element={<AdminProfile />} />
            <Route path="/manageaccount" element={<ManageAccount />} />
            <Route path="/lawyermanagement" element={<ManageLawyer />} />
            <Route path="/appointments" element={<CustomerAppointment />} />
          </Routes>
        </div>
        <Footer />
      </div>
    </Router>
  );
}

export default App;
