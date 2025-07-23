// src/pages/Unauthorized.jsx
import React from 'react';
import { Link } from 'react-router-dom';

const Unauthorized = () => {
  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-md w-full space-y-8">
        <div>
          <h2 className="mt-6 text-center text-3xl font-extrabold text-gray-900">
            Không có quyền truy cập
          </h2>
          <p className="mt-2 text-center text-sm text-gray-600">
            Bạn không có quyền truy cập vào trang này.
          </p>
        </div>
        <div className="mt-8 space-y-6">
          <Link
            to="/"
            className="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-primary-600 hover:bg-primary-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500"
          >
            Quay về trang chủ
          </Link>
        </div>
      </div>
    </div>
  );
};

export default Unauthorized;