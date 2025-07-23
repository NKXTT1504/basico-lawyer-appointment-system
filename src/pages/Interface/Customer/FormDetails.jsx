// FormDetails.jsx
import { useEffect, useState } from "react";
import { useParams, Link } from "react-router-dom";
import api from "../../../config/axios";

const FormDetails = () => {
  const { id } = useParams();
  const [form, setForm] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchForm = async () => {
      setLoading(true);
      try {
        const res = await api.auth.get(`/api/Form/${id}`);
        setForm(res.data);
      } catch {
        setForm(null);
      } finally {
        setLoading(false);
      }
    };
    fetchForm();
  }, [id]);

  return (
    <main className="min-h-screen pt-24 px-4 bg-gray-50">
      <div className="max-w-3xl mx-auto bg-white p-8 rounded-xl shadow-md">
        {loading ? (
          <div className="text-center text-gray-500">Đang tải chi tiết...</div>
        ) : !form ? (
          <div className="text-center text-red-500">Không tìm thấy văn bản.</div>
        ) : (
          <>
            <h1 className="text-3xl font-bold text-primary-900 mb-4">{form.name}</h1>
            <p className="text-gray-700 mb-6 whitespace-pre-wrap">{form.description || 'Không có mô tả.'}</p>
            {form.filePath ? (
              <div className="mb-4">
                <a
                  href={form.filePath}
                  download
                  target="_blank"
                  rel="noopener noreferrer"
                  className="bg-primary-800 text-white px-4 py-2 rounded hover:bg-primary-700 transition"
                >
                  Tải xuống tài liệu
                </a>
              </div>
            ) : (
              <p className="text-red-400">Không có file đính kèm.</p>
            )}
            <Link
              to="/form"
              className="mt-6 inline-block text-blue-600 hover:underline text-sm"
            >
              &larr; Quay lại danh sách
            </Link>
          </>
        )}
      </div>
    </main>
  );
};

export default FormDetails;
