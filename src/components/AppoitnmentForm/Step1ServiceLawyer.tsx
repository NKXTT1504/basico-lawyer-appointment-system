import React from 'react';
import { Star } from 'lucide-react';

// Add explicit types for props
interface Step1ServiceLawyerProps {
  formData: {
    service?: string;
    lawyer?: string;
    [key: string]: any;
  };
  updateFormData: (field: string, value: string) => void;
  errors: Record<string, string>;
  services: any[];
  selectedService: any;
  selectedLawyer: any;
  lawyers: any[];
  specs: string[];
  selectedSpec: string;
  setSelectedSpec: (spec: string) => void;
  filteredLawyers: any[];
  nextStep: () => void;
}

const Step1ServiceLawyer: React.FC<Step1ServiceLawyerProps> = ({
  formData,
  updateFormData,
  errors,
  services,
  selectedService,
  selectedLawyer,
  lawyers,
  specs,
  selectedSpec,
  setSelectedSpec,
  filteredLawyers,
  nextStep
}) => (
  <div className="animate-fade-in">
    <h2 className="text-2xl font-bold text-gray-900 mb-6">Chọn dịch vụ & luật sư</h2>
    <div className="mb-6">
      <label className="block text-gray-700 font-medium mb-2">Chọn dịch vụ</label>
      <select
        className="w-full border-gray-300 rounded-md shadow-sm focus:border-primary-500 focus:ring-primary-500"
        value={formData.service}
        onChange={(e) => updateFormData('service', e.target.value)}
      >
        <option value="">Chọn dịch vụ pháp lý...</option>
        {services.map((service) => (
          <option key={service.id} value={service.id}>
            {service.title} - {service.price}
          </option>
        ))}
      </select>
      {errors.service && <p className="text-red-500 text-sm mt-1">{errors.service}</p>}
    </div>
    <div className="mb-4">
      <label className="block mb-2 font-semibold">Chọn lĩnh vực</label>
      <select
        value={selectedSpec}
        onChange={e => {
          setSelectedSpec(e.target.value);
          updateFormData("lawyer", ""); // reset chọn luật sư khi đổi lĩnh vực
        }}
        className="w-full border-gray-300 rounded-md shadow-sm mb-4"
      >
        <option value="">-- Chọn lĩnh vực --</option>
        {specs.map(spec => (
          <option key={spec} value={spec}>{spec}</option>
        ))}
      </select>
    </div>

    {selectedSpec && (
      <div className="mb-4">
        <label className="block mb-2 font-semibold">Chọn luật sư</label>
        <select
          value={formData.lawyer}
          onChange={e => updateFormData("lawyer", e.target.value)}
          className="w-full border-gray-300 rounded-md shadow-sm"
        >
          <option value="">Chọn luật sư...</option>
          {filteredLawyers.map(lawyer => (
            <option key={lawyer.lawyerProfile.id} value={lawyer.lawyerProfile.id}>
              {lawyer.user.fullName}
            </option>
          ))}
        </select>
      </div>
    )}
    {/* Thông tin dịch vụ đã chọn */}
    {selectedService && (
      <div className="mb-6 p-4 bg-gray-50 rounded-lg">
        <h3 className="font-medium text-gray-900 mb-2">Chi tiết dịch vụ:</h3>
        <p className="text-gray-600 mb-2">{selectedService.description}</p>
        <div className="flex flex-wrap gap-x-4 text-sm">
          <p><span className="font-medium">Giá:</span> {selectedService.price}</p>
          <p><span className="font-medium">Thời lượng:</span> {selectedService.duration}</p>
        </div>
      </div>
    )}
    {/* Thông tin luật sư đã chọn */}
    {selectedLawyer && (
      <div className="mb-6 p-4 bg-gray-50 rounded-lg">
        <div className="flex items-center">
          <img
            src={selectedLawyer.lawyerProfile.img}
            alt={selectedLawyer.user.fullName}
            className="h-16 w-16 rounded-full object-cover mr-4"
          />
          <div>
            <h3 className="font-medium text-gray-900">{selectedLawyer.fullName}</h3>
            <p className="text-gray-600">{selectedLawyer.lawyerProfile.expYears} năm kinh nghiệm</p>
            <p className="text-gray-600">
              Lĩnh vực: {
                typeof selectedLawyer?.lawyerProfile?.spec === 'string'
                  ? selectedLawyer.lawyerProfile.spec
                  : Array.isArray(selectedLawyer?.lawyerProfile?.spec)
                    ? selectedLawyer.lawyerProfile.spec.join(', ')
                    : 'Chưa cập nhật'
              }
            </p>
            <div className="flex items-center mt-1">
              <Star className="h-4 w-4 text-yellow-500 fill-current" />
              <span className="ml-1 text-gray-700">{selectedLawyer.lawyerProfile.rating}</span>
              <span className="text-gray-500 text-sm ml-1">({selectedLawyer.reviewCount} đánh giá)</span>
            </div>
          </div>
        </div>
      </div>
    )}
    <div className="flex justify-end">
      <button
        type="button"
        onClick={nextStep}
        className="btn-primary"
      >
        Tiếp tục
      </button>
    </div>
  </div>
);

export default Step1ServiceLawyer;