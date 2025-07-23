import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import api from "../../../config/axios";

const PAGE_SIZE = 8;

const Form = () => {
  const [forms, setForms] = useState([]);
  const [loading, setLoading] = useState(true);
  const [currentPage, setCurrentPage] = useState(1);

  useEffect(() => {
    const fetchForms = async () => {
      setLoading(true);
      try {
        const res = await api.auth.get("/api/Form");
        setForms(Array.isArray(res.data) ? res.data : []);
      } catch {
        setForms([]);
      } finally {
        setLoading(false);
      }
    };
    fetchForms();
  }, []);

  const totalPages = Math.ceil(forms.length / PAGE_SIZE);
  const paginatedForms = forms.slice((currentPage - 1) * PAGE_SIZE, currentPage * PAGE_SIZE);

  return (
    <main>
          <section className="bg-primary-700 py-16">
        <div className="container mx-auto px-4">
          <div className="max-w-3xl">
            <h1 className="text-4xl font-bold text-white mb-4">Kho văn bản mẫu</h1>
            <p className="text-gray-200 text-lg">
              Các văn bản pháp lý mẫu giúp bạn dễ dàng soạn thảo và sử dụng trong các tình huống pháp lý khác nhau.
            </p>
          </div>
        </div>
      </section>

      <div className="max-w-5xl mx-auto mt-10 px-4 mb-10">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {loading ? (
            <div className="col-span-full text-center text-gray-500">Đang tải...</div>
          ) : paginatedForms.length === 0 ? (
            <div className="col-span-full text-center text-gray-500">Không có văn bản nào.</div>
          ) : (
            paginatedForms.map((form) => (
              <div key={form.id} className="bg-white rounded-xl shadow-md p-6 hover:shadow-lg transition">
                <h2 className="text-xl font-bold text-primary-700 mb-2">
                  <Link to={`/forms/${form.id}`} className="hover:underline">
                    {form.name}
                  </Link>
                </h2>
                <p className="text-gray-600 mb-4 line-clamp-3">{form.description || 'Không có mô tả.'}</p>
                <div className="flex justify-between text-sm text-gray-500">
                  {form.filePath ? (
                    <a
                      href={form.filePath}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="text-blue-600 hover:underline"
                    >
                      Xem file
                    </a>
                  ) : (
                    <span className="text-red-400">Không có file</span>
                  )}
                </div>
              </div>
            ))
          )}
        </div>

        {totalPages > 1 && (
          <div className="flex justify-center items-center gap-4 mt-10">
            <button
              onClick={() => setCurrentPage((p) => Math.max(1, p - 1))}
              disabled={currentPage === 1}
              className="p-2 rounded border bg-white hover:bg-gray-100 disabled:opacity-50"
            >
              &larr;
            </button>
            <span className="text-sm font-medium">Trang {currentPage} / {totalPages}</span>
            <button
              onClick={() => setCurrentPage((p) => Math.min(totalPages, p + 1))}
              disabled={currentPage === totalPages}
              className="p-2 rounded border bg-white hover:bg-gray-100 disabled:opacity-50"
            >
              &rarr;
            </button>
          </div>
        )}
      </div>
    </main>
  );
};

export default Form;