import { useState } from 'react';
import { lawyers } from '../../../data/lawyers';
import LawyerCard from '../components/LawyerCard';

const Lawyers = () => {
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedSpecialization, setSelectedSpecialization] = useState('all');
  
  // Extract all unique specializations from lawyers
  const allSpecializations = Array.from(
    new Set(lawyers.flatMap(lawyer => lawyer.specialization))
  ).sort();
  
  // Filter lawyers based on search and specialization
  const filteredLawyers = lawyers.filter(lawyer => {
    const matchesSearch = 
      lawyer.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
      lawyer.description.toLowerCase().includes(searchTerm.toLowerCase());
    
    const matchesSpecialization = 
      selectedSpecialization === 'all' || 
      lawyer.specialization.some(spec => 
        spec.toLowerCase() === selectedSpecialization.toLowerCase()
      );
    
    return matchesSearch && matchesSpecialization;
  });

  return (
    <main>
      <section className="bg-primary-700 py-16">
        <div className="container mx-auto px-4">
          <div className="max-w-3xl">
            <h1 className="text-4xl font-bold text-white mb-6">Our Expert Attorneys</h1>
            <p className="text-gray-200 text-lg">
              Meet our team of experienced legal professionals dedicated to providing
              exceptional service and expertise in their respective practice areas.
            </p>
          </div>
        </div>
      </section>

      <section className="py-16">
        <div className="container mx-auto px-4">
          <div className="bg-white rounded-lg shadow-md p-6 mb-10">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {/* Search Input */}
              <div>
                <label htmlFor="search" className="block text-sm font-medium text-gray-700 mb-2">
                  Search Attorneys
                </label>
                <input
                  type="text"
                  id="search"
                  className="w-full"
                  placeholder="Search by name or keyword..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                />
              </div>
              
              {/* Specialization Filter */}
              <div>
                <label htmlFor="specialization" className="block text-sm font-medium text-gray-700 mb-2">
                  Filter by Specialization
                </label>
                <select
                  id="specialization"
                  className="w-full"
                  value={selectedSpecialization}
                  onChange={(e) => setSelectedSpecialization(e.target.value)}
                >
                  <option value="all">All Specializations</option>
                  {allSpecializations.map(spec => (
                    <option key={spec} value={spec}>{spec}</option>
                  ))}
                </select>
              </div>
            </div>
          </div>

          {filteredLawyers.length > 0 ? (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
              {filteredLawyers.map(lawyer => (
                <LawyerCard key={lawyer.id} lawyer={lawyer} />
              ))}
            </div>
          ) : (
            <div className="text-center py-12">
              <h3 className="text-xl font-medium text-gray-900 mb-2">No attorneys found</h3>
              <p className="text-gray-600">
                Try adjusting your search criteria or browse all attorneys by clearing filters.
              </p>
              <button
                onClick={() => {
                  setSearchTerm('');
                  setSelectedSpecialization('all');
                }}
                className="mt-4 btn-outline"
              >
                Clear All Filters
              </button>
            </div>
          )}
        </div>
      </section>
    </main>
  );
};

export default Lawyers;