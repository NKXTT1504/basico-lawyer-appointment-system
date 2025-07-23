import { useEffect, useState } from "react";
import api from "../../../config/axios";

const initialForm = {
  id: null,
  lawyerId: "",
  title: "",
  qualificationType: "",
  description: "",
  issuedDate: "",
  issuedBy: "",
  documentUrl: "",
  isPublic: true,
  isVerified: false,
};

const ManageDiploma = () => {
  const user = JSON.parse(localStorage.getItem("user") || "{}");
  const lawyerId = user?.id;
  const [diplomas, setDiplomas] = useState([]);
  const [loading, setLoading] = useState(true);
  const [activeTab, setActiveTab] = useState("list");
  const [form, setForm] = useState(initialForm);
  const [editingId, setEditingId] = useState(null);

  const [currentPage, setCurrentPage] = useState(1);
  const itemsPerPage = 5;
  const indexOfLastItem = currentPage * itemsPerPage;
  const indexOfFirstItem = indexOfLastItem - itemsPerPage;
  const currentDiplomas = diplomas.slice(indexOfFirstItem, indexOfLastItem);
  const totalPages = Math.ceil(diplomas.length / itemsPerPage);
  const paginate = (page) => setCurrentPage(page);

  const fetchDiplomas = async () => {
    setLoading(true);
    try {
      const res = await api.lawyer.get(`/api/LawyerDiploma/lawyer/${lawyerId}`);
      setDiplomas(Array.isArray(res.data.result) ? res.data.result : []);
    } catch {
      setDiplomas([]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (lawyerId) fetchDiplomas();
  }, [lawyerId]);

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;

    if ((name === "isPublic" || name === "isVerified") && form[name] !== checked) {
      const confirmMsg =
        name === "isPublic"
          ? checked
            ? "Bạn có chắc muốn công khai bằng cấp này?"
            : "Bạn có chắc muốn ẩn bằng cấp này?"
          : checked
            ? "Xác nhận đã xác thực bằng cấp này?"
            : "Gỡ xác thực bằng cấp?";
      if (!window.confirm(confirmMsg)) return;
    }

    setForm((prev) => ({
      ...prev,
      [name]: type === "checkbox" ? checked : value,
    }));
  };

  const handleEdit = (diploma) => {
    setForm({
      ...diploma,
      issuedDate: diploma.issuedDate?.slice(0, 10) || "",
    });
    setEditingId(diploma.id);
    setActiveTab("form");
  };

  const handleDelete = async (id) => {
    if (!window.confirm("Bạn có chắc chắn muốn xóa bằng cấp này?")) return;
    try {
      await api.lawyer.delete(`/api/LawyerDiploma/${id}`);
      fetchDiplomas();
    } catch {
      alert("Xóa thất bại!");
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      if (editingId) {
        await api.lawyer.put(`/api/LawyerDiploma/${editingId}`, { ...form, lawyerId });
      } else {
        await api.lawyer.post(`/api/LawyerDiploma/lawyer/${lawyerId}`, { ...form, lawyerId });
      }
      setForm(initialForm);
      setEditingId(null);
      setActiveTab("list");
      fetchDiplomas();
    } catch {
      alert("Lưu thất bại!");
    }
  };

  const handleCancel = () => {
    setForm(initialForm);
    setEditingId(null);
    setActiveTab("list");
  };

  return (
    <div className="max-w-5xl mx-auto p-6">
      <h1 className="text-4xl font-bold mb-10 mt-10 text-primary-900 text-center">QUẢN LÍ BẰNG CẤP</h1>

      <div className="flex justify-center gap-4 mb-6">
        <button
          className={`px-4 py-2 rounded ${activeTab === "list" ? "bg-primary-700 text-white" : "bg-gray-200"}`}
          onClick={() => {
            setActiveTab("list");
            setForm(initialForm);
            setEditingId(null);
          }}
        >
          Danh sách bằng cấp
        </button>
        <button
          className={`px-4 py-2 rounded ${activeTab === "form" ? "bg-primary-700 text-white" : "bg-gray-200"}`}
          onClick={() => {
            setActiveTab("form");
            setForm(initialForm);
            setEditingId(null);
          }}
        >
          {editingId ? "Sửa bằng cấp" : "Thêm bằng cấp"}
        </button>
      </div>

      {activeTab === "list" && (
        <div className="bg-white rounded shadow p-4">
          {loading ? (
            <div className="text-gray-500 text-center">Đang tải...</div>
          ) : diplomas.length === 0 ? (
            <div className="text-gray-500 text-center">Chưa có bằng cấp nào.</div>
          ) : (
            <>
              <table className="min-w-full divide-y divide-gray-200 text-center">
                <thead className="bg-gray-100">
                  <tr>
                    <th className="px-2 py-2">Tên</th>
                    <th className="px-2 py-2">Loại</th>
                    <th className="px-2 py-2">Ngày cấp</th>
                    <th className="px-2 py-2">Nơi cấp</th>
                    <th className="px-2 py-2">Công khai</th>
                    <th className="px-2 py-2">Xác thực</th>
                    <th className="px-2 py-2">Tệp</th>
                    <th className="px-2 py-2">Thao tác</th>
                  </tr>
                </thead>
                <tbody>
                  {currentDiplomas.map((d) => (
                    <tr key={d.id} className="border-b">
                      <td className="px-2 py-2">{d.title}</td>
                      <td className="px-2 py-2">{d.qualificationType}</td>
                      <td className="px-2 py-2">{d.issuedDate?.slice(0, 10)}</td>
                      <td className="px-2 py-2">{d.issuedBy}</td>
                      <td className="px-2 py-2">{d.isPublic ? "✔️" : "❌"}</td>
                      <td className="px-2 py-2">{d.isVerified ? "✔️" : "❌"}</td>
                      <td className="px-2 py-2">
                        {d.documentUrl ? (
                          <a
                            href={d.documentUrl}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="text-blue-600 underline"
                          >
                            Xem file
                          </a>
                        ) : (
                          <span className="text-gray-400">Không có</span>
                        )}
                      </td>
                      <td className="px-2 py-2">
                        <button onClick={() => handleEdit(d)} className="px-2 py-1 bg-yellow-500 text-white rounded mr-2">
                          Sửa
                        </button>
                        <button onClick={() => handleDelete(d.id)} className="px-2 py-1 bg-red-500 text-white rounded">
                          Xóa
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>

              {totalPages > 1 && (
                <div className="flex justify-center items-center gap-4 mt-6">
                  <button
                    onClick={() => setCurrentPage((p) => Math.max(1, p - 1))}
                    disabled={currentPage === 1}
                    className="p-2 rounded border bg-white hover:bg-gray-100 disabled:opacity-50"
                  >
                    &larr;
                  </button>
                  <span className="text-sm font-medium">
                    Trang {currentPage} / {totalPages}
                  </span>
                  <button
                    onClick={() => setCurrentPage((p) => Math.min(totalPages, p + 1))}
                    disabled={currentPage === totalPages}
                    className="p-2 rounded border bg-white hover:bg-gray-100 disabled:opacity-50"
                  >
                    &rarr;
                  </button>
                </div>
              )}
            </>
          )}
        </div>
      )}

      {activeTab === "form" && (
        <div className="flex justify-center">
          <form onSubmit={handleSubmit} className="bg-white rounded shadow p-4 max-w-2xl w-full">
            <div className="mb-3">
              <label className="block font-medium mb-1">Tên bằng cấp</label>
              <input type="text" name="title" value={form.title} onChange={handleChange} required className="border rounded px-3 py-2 w-full" />
            </div>
            <div className="mb-3">
              <label className="block font-medium mb-1">Loại bằng cấp</label>
              <input type="text" name="qualificationType" value={form.qualificationType} onChange={handleChange} required className="border rounded px-3 py-2 w-full" />
            </div>
            <div className="mb-3">
              <label className="block font-medium mb-1">Mô tả</label>
              <textarea name="description" value={form.description} onChange={handleChange} className="border rounded px-3 py-2 w-full" />
            </div>
            <div className="mb-3">
              <label className="block font-medium mb-1">Ngày cấp</label>
              <input type="date" name="issuedDate" value={form.issuedDate} onChange={handleChange} required className="border rounded px-3 py-2 w-full" />
            </div>
            <div className="mb-3">
              <label className="block font-medium mb-1">Nơi cấp</label>
              <input type="text" name="issuedBy" value={form.issuedBy} onChange={handleChange} required className="border rounded px-3 py-2 w-full" />
            </div>
            <div className="mb-3">
              <label className="block font-medium mb-1">Đường dẫn file (URL)</label>
              <input type="text" name="documentUrl" value={form.documentUrl} onChange={handleChange} className="border rounded px-3 py-2 w-full" placeholder="https://..." />
            </div>
            <div className="mb-3 flex gap-6">
              <label className="flex items-center gap-2">
                <input type="checkbox" name="isPublic" checked={form.isPublic} onChange={handleChange} />
                Công khai
              </label>
              <label className="flex items-center gap-2">
                <input type="checkbox" name="isVerified" checked={form.isVerified} onChange={handleChange} />
                Đã xác thực
              </label>
            </div>
            <div className="flex gap-3">
              <button type="submit" className="px-4 py-2 bg-primary-700 text-white rounded">
                {editingId ? "Cập nhật" : "Thêm mới"}
              </button>
              <button type="button" onClick={handleCancel} className="px-4 py-2 bg-gray-300 rounded">
                Hủy
              </button>
            </div>
          </form>
        </div>
      )}
    </div>
  );
};

export default ManageDiploma;
