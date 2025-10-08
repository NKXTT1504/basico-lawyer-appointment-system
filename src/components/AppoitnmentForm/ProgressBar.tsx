import React from "react";

const ProgressBar = ({ step }: { step: number }) => (
  <div className="bg-gray-50 p-4">
    <div className="flex justify-between items-center">
      {['Dịch vụ & Luật sư', 'Ngày & Giờ', 'Ghi chú'].map((title, index) => {
        const stepNum = index + 1;
        return (
          <div key={title} className="flex flex-col items-center flex-1">
            <div className={`h-2 ${index === 0 ? 'hidden' : 'block'} w-full ${step > index ? 'bg-primary-600' : 'bg-gray-200'}`}></div>
            <div className={`
              flex items-center justify-center h-10 w-10 rounded-full 
              ${step > stepNum ? 'bg-primary-600 text-white' : step === stepNum ? 'bg-primary-600 text-white' : 'bg-gray-200 text-gray-600'}
              border-4 ${step >= stepNum ? 'border-primary-100' : 'border-gray-50'}
              transition-all duration-500
            `}>
              {step > stepNum ? '✓' : stepNum}
            </div>
            <span className="text-xs sm:text-sm font-medium mt-2 text-center hidden sm:block">{title}</span>
          </div>
        );
      })}
    </div>
  </div>
);

export default ProgressBar;