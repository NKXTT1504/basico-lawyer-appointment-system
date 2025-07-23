// src/components/ProtectedRoute.jsx
import React from 'react';
import { Navigate, Outlet } from 'react-router-dom';

const ProtectedRoute = ({ allowedRoles }) => {
  const user = JSON.parse(localStorage.getItem('user'));
  const userRole = user?.role;

  if (!user) {
    // Nếu chưa đăng nhập, chuyển hướng đến trang đăng nhập
    return <Navigate to="/login" replace />;
  }

  if (allowedRoles.includes(userRole)) {
    // Nếu role của user nằm trong danh sách được phép, cho phép truy cập
    return <Outlet />;
  } else {
    // Nếu không có quyền, chuyển hướng đến trang không có quyền truy cập
    return <Navigate to="/unauthorized" replace />;
  }
};

export default ProtectedRoute;