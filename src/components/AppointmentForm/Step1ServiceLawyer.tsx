import React, { useMemo, useState, useEffect } from 'react';
import { Star, X, CheckCircle, Trash2, MapPin, DollarSign } from 'lucide-react';
import PaymentInform from './PaymentInform';
import api from '../../config/axios';

interface Step1ServiceLawyerProps {
  formData: {
    service: string[];
    lawyer?: string;
    [key: string]: any;
  };
  updateFormData: (field: string, value: any) => void;
  errors: Record<string, string>;
  services: any[];
  selectedServices: any[];
  selectedLawyer: any;
  lawyers: any[];
  practiceAreas: { id: any; code: string; name: string; description?: string }[];
  selectedPracticeArea: string;
  setSelectedPracticeArea: (code: string) => void;
  filteredLawyers: any[];
  nextStep: () => void;
  lawyerDetails: {[key: string]: any};
  setLawyerDetails: (details: {[key: string]: any}) => void;
}

const Step1ServiceLawyer: React.FC<Step1ServiceLawyerProps> = ({
  formData,
  updateFormData,
  errors,
  services,
  selectedServices,
  selectedLawyer,
  lawyers,
  practiceAreas,
  selectedPracticeArea,
  setSelectedPracticeArea,
  filteredLawyers,
  nextStep,
  lawyerDetails,
  setLawyerDetails
}) => {
  const [depositConfirmed, setDepositConfirmed] = useState(false);
  const [lawyerRatings, setLawyerRatings] = useState<{[key: string]: number}>({});
  const [lawyerReviewCounts, setLawyerReviewCounts] = useState<{[key: string]: number}>({});

  // Fetch user details, ratings và review counts for lawyers
  useEffect(() => {
    const fetchLawyerDetails = async () => {
      const details: {[key: string]: any} = {};
      const ratings: {[key: string]: number} = {};
      const reviewCounts: {[key: string]: number} = {};
      
      for (const lawyer of lawyers) {
        try {
          const lawyerId = lawyer.lawyerProfile?.id || lawyer.id;
          const userId = lawyer.userId || lawyer.user?.id;
          
          // Fetch user details
          if (userId) {
            const userRes = await api.auth.get(`/api/User/${userId}`);
            if (userRes.data && userRes.data.isSuccess) {
              details[lawyerId] = userRes.data.result;
            }
          }
          
          // Fetch average rating
          try {
            const ratingRes = await api.auth.get(`/api/Review/lawyer/${lawyerId}/average-rating`);
            if (ratingRes.data !== null && ratingRes.data !== undefined) {
              ratings[lawyerId] = parseFloat(ratingRes.data) || 0;
            }
          } catch (error) {
            console.error(`Error fetching rating for lawyer ${lawyerId}:`, error);
            ratings[lawyerId] = 0;
          }
          
          // Fetch review count
          try {
            const reviewsRes = await api.auth.get(`/api/Review/lawyer/${lawyerId}`);
            if (reviewsRes.data && Array.isArray(reviewsRes.data)) {
              reviewCounts[lawyerId] = reviewsRes.data.length;
            } else {
              reviewCounts[lawyerId] = 0;
            }
          } catch (error) {
            console.error(`Error fetching reviews for lawyer ${lawyerId}:`, error);
            reviewCounts[lawyerId] = 0;
          }
          
        } catch (error) {
          console.error(`Error fetching details for lawyer ${lawyer.id}:`, error);
        }
      }
      
      setLawyerDetails(details);
      setLawyerRatings(ratings);
      setLawyerReviewCounts(reviewCounts);
    };

    if (lawyers.length > 0) {
      fetchLawyerDetails();
    }
  }, [lawyers, setLawyerDetails]);

  const toggleService = (id: string) => {
    const current: string[] = Array.isArray(formData.service) ? formData.service : [];
    const next = current.includes(id) ? current.filter(s => s !== id) : [...current, id];
    updateFormData('service', next);
    if (next.length < 2) setDepositConfirmed(false);
  };

  const selectAllServices = () => {
    const filteredIds = filteredServices.map(s => String(s.id));
    const current: string[] = Array.isArray(formData.service) ? formData.service : [];
    
    const newSelection = [...new Set([...current, ...filteredIds])];
    updateFormData('service', newSelection);
    
    if (newSelection.length >= 2) {
      setDepositConfirmed(false);
    }
  };

  const deselectAllServices = () => {
    updateFormData('service', []);
    setDepositConfirmed(false);
  };

  const removeOneService = () => {
    const current: string[] = Array.isArray(formData.service) ? formData.service : [];
    if (current.length > 0) {
      const newSelection = current.slice(0, -1);
      updateFormData('service', newSelection);
    }
    setDepositConfirmed(false);
  };

  // Filter services by selectedPracticeArea
  const filteredServices = useMemo(() => {
    if (!selectedPracticeArea) return services || [];
    const code = (selectedPracticeArea || '').toString().toLowerCase();
    return (services || []).filter((svc: any) => {
      return (svc.practiceArea?.code || svc.practiceArea?.name || '').toString().toLowerCase() === code;
    });
  }, [services, selectedPracticeArea]);

  // Filter lawyers based on selected practice area
  const displayLawyers = useMemo(() => {
    if (!selectedPracticeArea) {
      return lawyers;
    }
    return lawyers.filter((lawyer: any) => {
      const pas = lawyer.practiceAreas || [];
      return pas.some((pa: any) => 
        (pa.code || '').toString().toLowerCase() === selectedPracticeArea.toString().toLowerCase()
      );
    });
  }, [lawyers, selectedPracticeArea]);

  const selectedIds: string[] = Array.isArray(formData.service) ? formData.service : [];

  // Check which services in current filtered view are selected
  const selectedInCurrentView = useMemo(() => {
    const filteredIds = filteredServices.map(s => String(s.id));
    return selectedIds.filter(id => filteredIds.includes(id));
  }, [selectedIds, filteredServices]);

  // Check if all services in current view are selected
  const allInViewSelected = filteredServices.length > 0 && 
    selectedInCurrentView.length === filteredServices.length;

  const depositRequired = selectedServices.length >= 2;
  const showPaymentInform = depositRequired && !depositConfirmed;

  // Get lawyer full name from user details
  const getLawyerFullName = (lawyer: any) => {
    const lawyerId = lawyer.lawyerProfile?.id || lawyer.id;
    const userDetail = lawyerDetails[lawyerId];
    return userDetail?.fullName || lawyer.user?.fullName || lawyer.fullName || 'Chưa cập nhật';
  };

  // Get lawyer image
  const getLawyerImage = (lawyer: any) => {
    return lawyer.lawyerProfile?.img || lawyer.img || '/images/default-avatar.png';
  };

  // Get lawyer rating
  const getLawyerRating = (lawyer: any) => {
    const lawyerId = lawyer.lawyerProfile?.id || lawyer.id;
    return lawyerRatings[lawyerId] || lawyer.lawyerProfile?.rating || lawyer.rating || 0;
  };

  // Get lawyer review count
  const getLawyerReviewCount = (lawyer: any) => {
    const lawyerId = lawyer.lawyerProfile?.id || lawyer.id;
    return lawyerReviewCounts[lawyerId] || lawyer.reviewCount || 0;
  };

  // Format price
  const formatPrice = (price: number) => {
    return new Intl.NumberFormat('vi-VN', {
      style: 'currency',
      currency: 'VND'
    }).format(price);
  };

  return (
    <div className="animate-fade-in">
      <h2 className="text-2xl font-bold text-gray-900 mb-8">Chọn Dịch Vụ & Luật Sư</h2>

      {/* Lĩnh vực filter */}
      <div className="mb-8">
        <label className="block text-sm font-semibold text-gray-700 mb-3">Lọc theo lĩnh vực</label>
        <select
          value={selectedPracticeArea || ''}
          onChange={e => {
            setSelectedPracticeArea(e.target.value);
            updateFormData("lawyer", "");
          }}
          className="w-full px-4 py-3 border border-gray-300 rounded-lg shadow-sm focus:ring-2 focus:ring-primary-500 focus:border-primary-500 transition-colors"
        >
          <option value="">Tất cả lĩnh vực</option>
          {practiceAreas.map(pa => (
            <option key={pa.code ?? pa.id} value={pa.code}>{pa.name}</option>
          ))}
        </select>
      </div>

      {/* Dịch vụ đã chọn section */}
      {selectedServices.length > 0 && (
        <div className="mb-8 p-6 bg-gradient-to-r from-primary-50 to-blue-50 border border-primary-200 rounded-xl shadow-sm">
          <div className="flex items-center justify-between mb-4">
            <div className="flex items-center">
              <CheckCircle className="h-6 w-6 text-primary-600 mr-3" />
              <div>
                <h3 className="font-semibold text-gray-900 text-lg">Dịch Vụ Đã Chọn</h3>
                <p className="text-sm text-gray-600">{selectedServices.length} dịch vụ được chọn</p>
              </div>
            </div>
            <button
              onClick={deselectAllServices}
              className="p-3 text-red-500 hover:text-red-700 hover:bg-red-50 rounded-lg transition-colors"
              title="Xóa tất cả dịch vụ"
            >
              <Trash2 className="h-5 w-5" />
            </button>
          </div>
          <div className="grid gap-3 max-h-48 overflow-y-auto pr-2">
            {selectedServices.map((svc: any) => (
              <div key={svc.id} className="flex items-center justify-between p-3 bg-white rounded-lg border border-gray-200 shadow-xs">
                <div className="flex items-center">
                  <button
                    onClick={() => toggleService(String(svc.id))}
                    className="p-1 text-red-400 hover:text-red-600 hover:bg-red-50 rounded-full transition-colors mr-3"
                  >
                    <X className="h-4 w-4" />
                  </button>
                  <div>
                    <span className="font-medium text-gray-900 block">{svc.title || svc.name}</span>
                    <span className="text-xs text-gray-500">{svc.practiceArea?.name || svc.category}</span>
                  </div>
                </div>
                <span className="font-semibold text-primary-600 text-sm bg-primary-50 px-2 py-1 rounded">
                  {svc.price}
                </span>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* Danh sách dịch vụ */}
      <div className="mb-8">
        <div className="flex items-center justify-between mb-4">
          <label className="block text-sm font-semibold text-gray-700">Chọn Dịch Vụ</label>
          {filteredServices.length > 0 && (
            <div className="flex gap-3">
              {!allInViewSelected && (
                <button
                  onClick={selectAllServices}
                  className="px-6 py-2.5 rounded-lg font-semibold text-white bg-primary-600 hover:bg-primary-700 shadow-sm hover:shadow-md transition-all"
                >
                  Chọn tất cả
                </button>
              )}
              {allInViewSelected && selectedServices.length > 0 && (
                <button
                  onClick={deselectAllServices}
                  className="p-3 text-red-500 hover:text-red-700 hover:bg-red-50 rounded-lg transition-colors"
                  title="Bỏ chọn tất cả"
                >
                  <Trash2 className="h-5 w-5" />
                </button>
              )}
            </div>
          )}
        </div>

        <div className="border border-gray-200 rounded-xl overflow-hidden bg-white shadow-sm">
          <div className="max-h-80 overflow-y-auto">
            {filteredServices.length === 0 ? (
              <div className="text-center text-gray-500 py-8">
                <div className="text-gray-400 mb-2">📋</div>
                {selectedPracticeArea ? 'Không có dịch vụ nào trong lĩnh vực này' : 'Không có dịch vụ nào'}
              </div>
            ) : (
              <div className="divide-y divide-gray-100">
                {filteredServices.map(s => (
                  <label 
                    key={s.id} 
                    className={`flex items-start p-4 cursor-pointer transition-all hover:bg-gray-50 ${
                      selectedIds.includes(String(s.id)) ? 'bg-primary-25 border-l-4 border-l-primary-500' : ''
                    }`}
                  >
                    <div className="flex items-start flex-1 min-w-0">
                      <div className="flex items-center h-5 mt-0.5">
                        <input
                          type="checkbox"
                          value={String(s.id)}
                          checked={selectedIds.includes(String(s.id))}
                          onChange={() => toggleService(String(s.id))}
                          className="h-4 w-4 text-primary-600 border-gray-300 rounded focus:ring-primary-500"
                        />
                      </div>
                      <div className="ml-3 flex-1 min-w-0">
                        <div className="flex justify-between items-start">
                          <span className={`font-medium block ${
                            selectedIds.includes(String(s.id)) ? 'text-primary-900' : 'text-gray-900'
                          }`}>
                            {s.title || s.name}
                          </span>
                          <span className="text-sm font-semibold text-primary-600 bg-primary-50 px-2 py-1 rounded ml-2 whitespace-nowrap">
                            {s.price}
                          </span>
                        </div>
                        <p className="text-sm text-gray-600 mt-1 line-clamp-2">{s.description}</p>
                        {s.practiceArea?.name && (
                          <span className="inline-block mt-2 text-xs text-gray-500 bg-gray-100 px-2 py-1 rounded">
                            {s.practiceArea.name}
                          </span>
                        )}
                      </div>
                    </div>
                  </label>
                ))}
              </div>
            )}
          </div>
        </div>

        {errors.service && (
          <p className="text-red-500 text-sm mt-2 flex items-center">
            ⚠️ {errors.service}
          </p>
        )}

        <PaymentInform
          open={showPaymentInform}
          count={selectedServices.length}
          onConfirm={() => setDepositConfirmed(true)}
          onCancel={() => setDepositConfirmed(false)}
          onRemoveOneService={removeOneService}
        />
      </div>

      {/* Chọn luật sư */}
      <div className="mb-8">
        <label className="block text-sm font-semibold text-gray-700 mb-3">Chọn Luật Sư</label>
        <select
          value={formData.lawyer}
          onChange={e => updateFormData("lawyer", e.target.value)}
          className="w-full px-4 py-3 border border-gray-300 rounded-lg shadow-sm focus:ring-2 focus:ring-primary-500 focus:border-primary-500 transition-colors"
        >
          <option value="">Chọn luật sư...</option>
          {displayLawyers.map(lawyer => {
            const lawyerId = lawyer.lawyerProfile?.id || lawyer.id;
            return (
              <option key={lawyerId} value={lawyerId}>
                {getLawyerFullName(lawyer)} 
              </option>
            );
          })}
        </select>
        {errors.lawyer && (
          <p className="text-red-500 text-sm mt-2 flex items-center">
            ⚠️ {errors.lawyer}
          </p>
        )}
      </div>

      {/* Thông tin luật sư đã chọn */}
      {selectedLawyer && (
        <div className="mb-8 p-6 bg-white border border-gray-200 rounded-xl shadow-sm">
          <div className="flex items-start">
            <img
              src={getLawyerImage(selectedLawyer)}
              alt={getLawyerFullName(selectedLawyer)}
              className="h-16 w-16 rounded-full object-cover mr-4 border-2 border-primary-200"
            />
            <div className="flex-1">
              <div className="flex justify-between items-start mb-2">
                <h3 className="font-semibold text-gray-900 text-lg">{getLawyerFullName(selectedLawyer)}</h3>
                <div className="flex items-center bg-yellow-50 px-2 py-1 rounded">
                  <Star className="h-4 w-4 text-yellow-500 fill-current" />
                  <span className="ml-1 text-sm font-medium text-gray-700">
                    {getLawyerRating(selectedLawyer).toFixed(1)}
                  </span>
                </div>
              </div>
              
              <p className="text-gray-600 mb-2">
                {selectedLawyer.lawyerProfile?.expYears ?? selectedLawyer.expYears ?? 0} năm kinh nghiệm
              </p>

              {/* Địa điểm */}
              <div className="flex items-center text-gray-600 mb-2">
                <MapPin className="h-4 w-4 text-gray-400 mr-2" />
                <span className="text-sm">
                  {selectedLawyer.lawyerProfile?.description || selectedLawyer.description || 'Chưa cập nhật địa điểm'}
                </span>
              </div>

              {/* Giá theo giờ */}
              <div className="flex items-center text-gray-600 mb-3">
                <DollarSign className="h-4 w-4 text-gray-400 mr-2" />
                <span className="text-sm font-medium text-primary-600">
                  {formatPrice(selectedLawyer.lawyerProfile?.pricePerHour || selectedLawyer.pricePerHour || 0)}/giờ
                </span>
              </div>

              <p className="text-gray-600 text-sm mb-3">
                <span className="font-medium">Lĩnh vực: </span>
                {selectedLawyer.practiceAreas && selectedLawyer.practiceAreas.length > 0
                  ? selectedLawyer.practiceAreas.map((pa: any) => pa.name).join(', ')
                  : 'Chưa cập nhật'}
              </p>
              
              <div className="flex items-center text-sm text-gray-500">
                <span>👥 {getLawyerReviewCount(selectedLawyer)} đánh giá</span>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Next button */}
      <div className="flex justify-end pt-6 border-t border-gray-200">
        <button
          type="button"
          onClick={() => nextStep()}
          disabled={
            !selectedServices.length ||
            !formData.lawyer ||
            (depositRequired && !depositConfirmed)
          }
          className={`px-8 py-3 rounded-lg font-semibold text-white transition-all ${
            (!selectedServices.length || !formData.lawyer || (depositRequired && !depositConfirmed))
              ? 'bg-gray-300 cursor-not-allowed'
              : 'bg-primary-600 hover:bg-primary-700 shadow-sm hover:shadow-md'
          }`}
        >
          Tiếp Theo
        </button>
      </div>
    </div>
  );
};

export default Step1ServiceLawyer;