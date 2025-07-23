import { useEffect, useState } from "react";
import api from "../../../config/axios";
import uploadFile from "../../../utils/file";

const FormManagement = () => {
    const [forms, setForms] = useState([]);
    const [loading, setLoading] = useState(true);
    const [editingForm, setEditingForm] = useState(null);
    const [formData, setFormData] = useState({ name: "", description: "", file: null });
    const [activeTab, setActiveTab] = useState("list");

    const [currentPage, setCurrentPage] = useState(1);
    const itemsPerPage = 5;
    const totalPages = Math.ceil(forms.length / itemsPerPage);
    const paginatedForms = forms.slice((currentPage - 1) * itemsPerPage, currentPage * itemsPerPage);

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

    useEffect(() => {
        fetchForms();
    }, []);

    useEffect(() => {
        if (editingForm) {
            setActiveTab("create");
            setFormData({ name: editingForm.name, description: editingForm.description, file: null });
        }
    }, [editingForm]);

    const handleChange = (e) => {
        const { name, value, files } = e.target;
        if (name === "file") {
            setFormData({ ...formData, file: files[0] });
        } else {
            setFormData({ ...formData, [name]: value });
        }
    };

    const handleSubmit = async (e) => {
        e.preventDefault();

        try {
            let filePath = editingForm?.filePath || "";
            if (formData.file) {
                filePath = await uploadFile(formData.file);
            }

            const payload = {
                name: formData.name,
                description: formData.description,
                filePath,
            };

            if (editingForm) {
                await api.auth.put(`/api/Form/${editingForm.id}`, payload);
            } else {
                await api.auth.post("/api/Form", payload);
            }

            setFormData({ name: "", description: "", file: null });
            setEditingForm(null);
            fetchForms();
            setActiveTab("list");
        } catch (err) {
            console.error(err);
            alert("Có lỗi xảy ra!");
        }
    };

    const handleDelete = async (id) => {
        if (!window.confirm("Bạn có chắc chắn muốn xóa form này?")) return;
        try {
            await api.auth.delete(`/api/Form/${id}`);
            fetchForms();
        } catch {
            alert("Xóa thất bại!");
        }
    };

    const handleEdit = (form) => {
        setEditingForm(form);
    };

    const handleCancelEdit = () => {
        setEditingForm(null);
        setFormData({ name: "", description: "", file: null });
    };

    return (
        <div className="max-w-4xl mx-auto p-6 text-center">
            <h1 className="text-4xl font-bold mt-10 mb-10">QUẢN LÍ FORM</h1>
            <div className="flex justify-center gap-4 mb-4">
                <button
                    onClick={() => { setActiveTab("list"); setEditingForm(null); handleCancelEdit(); }}
                    className={`px-4 py-2 rounded ${activeTab === "list" ? "bg-primary-800 text-white" : "bg-gray-200 text-black"}`}
                >
                    Danh sách form
                </button>
                <button
                    onClick={() => { setActiveTab("create"); setEditingForm(null); handleCancelEdit(); }}
                    className={`px-4 py-2 rounded ${activeTab === "create" ? "bg-primary-800 text-white" : "bg-gray-200 text-black"}`}
                >
                    {editingForm ? `Chỉnh sửa form` : "Tạo form mới"}
                </button>
            </div>

            {activeTab === "create" && (
                <form onSubmit={handleSubmit} className="bg-white rounded shadow p-4 mb-8">
                    <div className="mb-3 text-left">
                        <label className="block font-medium mb-1">Tên form</label>
                        <input
                            type="text"
                            name="name"
                            value={formData.name}
                            onChange={handleChange}
                            required
                            className="border rounded px-3 py-2 w-full"
                        />
                    </div>
                    <div className="mb-3 text-left">
                        <label className="block font-medium mb-1">Mô tả</label>
                        <input
                            type="text"
                            name="description"
                            value={formData.description}
                            onChange={handleChange}
                            required
                            className="border rounded px-3 py-2 w-full"
                        />
                    </div>
                    <div className="mb-3 text-left">
                        <label className="block font-medium mb-1">Tải file</label>
                        <input
                            type="file"
                            name="file"
                            onChange={handleChange}
                            className="border rounded px-3 py-2 w-full"
                        />
                    </div>
                    <div className="flex gap-3 justify-center">
                        <button type="submit" className="px-4 py-2 bg-primary-800 text-white rounded">
                            {editingForm ? "Cập nhật" : "Thêm mới"}
                        </button>
                        {editingForm && (
                            <button
                                type="button"
                                onClick={handleCancelEdit}
                                className="px-4 py-2 bg-gray-300 rounded"
                            >
                                Hủy
                            </button>
                        )}
                    </div>
                </form>
            )}

            {activeTab === "list" && (
                <div className="bg-white rounded shadow p-4">
                    {loading ? (
                        <div className="text-gray-500">Đang tải...</div>
                    ) : paginatedForms.length === 0 ? (
                        <div className="text-gray-500">Chưa có form nào.</div>
                    ) : (
                        <>
                            <table className="min-w-full divide-y divide-gray-200 text-center">
                                <thead className="bg-gray-100">
                                    <tr>
                                        <th className="px-4 py-2">STT</th>
                                        <th className="px-4 py-2">Tên form</th>
                                        <th className="px-4 py-2">Mô tả</th>
                                        <th className="px-4 py-2">File</th>
                                        <th className="px-4 py-2">Thao tác</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {paginatedForms.map((form, index) => (
                                        <tr key={form.id} className="border-b">
                                            <td className="px-4 py-2">
                                                {(currentPage - 1) * itemsPerPage + index + 1}
                                            </td>
                                            <td className="px-4 py-2">{form.name}</td>
                                            <td className="px-4 py-2">{form.description}</td>
                                            <td className="px-4 py-2">
                                                {form.filePath ? (
                                                    <a
                                                        href={form.filePath}
                                                        download
                                                        target="_blank"
                                                        rel="noopener noreferrer"
                                                        className="text-primary-900 underline"
                                                    >
                                                        Tải về
                                                    </a>
                                                ) : (
                                                    "Không có file"
                                                )}
                                            </td>
                                            <td className="px-4 py-2">
                                                <button
                                                    onClick={() => handleEdit(form)}
                                                    className="px-3 py-1 bg-yellow-600 text-white rounded mr-2"
                                                >
                                                    Sửa
                                                </button>
                                                <button
                                                    onClick={() => handleDelete(form.id)}
                                                    className="px-3 py-1 bg-red-600 text-white rounded"
                                                >
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
        </div>
    );
};

export default FormManagement;
