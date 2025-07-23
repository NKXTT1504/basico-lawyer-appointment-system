import { BrowserRouter as Router, Route, Routes } from 'react-router-dom';
import { useState, useEffect } from 'react';

// Components
import Navbar from './components/Layout/Navbar';
import Footer from './components/Layout/Footer';
import ProtectedRoute from './components/ProtectedRoute';

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
import CustomerProfile from './pages/Profiles/CustomerProfile';
import ManageAccount from './pages/Interface/Admin/ManageAccount';
import ManageLawyer from './pages/Interface/Admin/LawyerManagement';
import CustomerAppointment from './pages/Interface/Customer/CustomerAppointment';
import ReviewManagement from './pages/Interface/Admin/ReviewManagement';
import Dashboard from './pages/Interface/Admin/Dashboard';
import FormManagement from './pages/Interface/Admin/FormManagement';
import Form from './pages/Interface/Customer/Form'
import FormDetails from './pages/Interface/Customer/FormDetails';
import ManageDiploma from './pages/Interface/Lawyer/ManageDiploma';
import Unauthorized from './pages/Authentication/Unauthorized';
import ForgotPassword from './pages/Authentication/ForgotPassword';
import ChangePassword from './pages/Authentication/ChangePassword';
import AppointmentManagement from './pages/Interface/Admin/AppointmentManagement';

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

            <Route path="/login" element={<Login />} />
            <Route path="/unauthorized" element={<Unauthorized />} />

            {/* Routes cho Admin */}
            <Route element={<ProtectedRoute allowedRoles={['Admin']} />}>
              {/* Thêm các route khác của admin ở đây */}
              <Route path="/adminprofile" element={<AdminProfile />} />
              <Route path="/reviewmanagement" element={<ReviewManagement />} />
              <Route path="/dashboard" element={<Dashboard />} />
              <Route path="/appointmentmanagement" element={<AppointmentManagement />} />
              <Route path="/lawyermanagement" element={<ManageLawyer />} />
              <Route path="/manageaccount" element={<ManageAccount />} />
              <Route path="/formmanagement" element={<FormManagement />} />
              <Route path="/change-password" element={<ChangePassword />} />

            </Route>

            {/* Routes cho Lawyer */}
            <Route element={<ProtectedRoute allowedRoles={['Lawyer']} />}>
              {/* Thêm các route khác của lawyer ở đây */}
              <Route path="/lawyerprofile" element={<LawyerProfile />} />
              <Route path="/lawyershift" element={<LawyerShift />} />
              <Route path="/manageappointment" element={<ManageAppointment />} />
              <Route path="/manage-diploma" element={<ManageDiploma />} />
            </Route>

            {/* Routes cho Customer */}
            <Route element={<ProtectedRoute allowedRoles={['Customer']} />}>
              {/* Thêm các route khác của customer ở đây */}
              <Route path="/appointment" element={<Appointment />} />
              <Route path="/history-appointments" element={<CustomerAppointment />} />
              <Route path="/customer-profile" element={<CustomerProfile />} />
              <Route path="/change-password" element={<ChangePassword />} />


            </Route>

            {/* Public routes */}
            <Route path="/" element={<Home />} />
            {/* Thêm các route công khai khác ở đây */}
            <Route path="/services" element={<Services />} />
            <Route path="/services/:id" element={<ServiceDetails />} />
            <Route path="/lawyers" element={<Lawyers />} />
            <Route path="/lawyers/:slug" element={<LawyerDetails />} />
            <Route path="/about" element={<About />} />
            <Route path="/contact" element={<Contact />} />
            <Route path="/login" element={<Login setRole={setRole} />} />
            <Route path="/register" element={<Register />} />
            <Route path="/form" element={<Form />} />
            <Route path="/forms/:id" element={<FormDetails />} />
            <Route path="/forgot-password" element={<ForgotPassword />} />
          </Routes>
        </div>
        <Footer />
      </div >
    </Router >
  );
};

export default App;