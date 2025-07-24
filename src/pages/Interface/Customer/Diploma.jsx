import { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import api from "../../../config/axios";

// Hàm slugify giống như bạn dùng ở LawyerDetails
const slugify = (str) =>
    str
        .normalize("NFD")
        .replace(/[\u0300-\u036f]/g, "")
        .replace(/[^a-zA-Z0-9 ]/g, "")
        .replace(/\s+/g, "-")
        .toLowerCase();

const ITEMS_PER_PAGE = 5;

const Diploma = () => {
    const { slug } = useParams();
    const [lawyerId, setLawyerId] = useState(null);
    const [diplomas, setDiplomas] = useState([]);
    const [loading, setLoading] = useState(true);
    const [currentPage, setCurrentPage] = useState(1);

    // Lấy lawyerId từ slug bằng cách fetch toàn bộ danh sách luật sư
    useEffect(() => {
        const fetchLawyerId = async () => {
            setLoading(true);
            try {
                const res = await api.auth.get("/api/UserWithLawyerProfile/only-lawyers");
                const list = Array.isArray(res.data.result) ? res.data.result : [];
                const found = list.find(lawyer => {
                    const generatedSlug = slugify(lawyer.user.fullName);
                    return generatedSlug === slug;
                    
                });
                setLawyerId(found?.user.id || null);
            } catch {
                setLawyerId(null);
            } finally {
                setLoading(false);
            }
        };
        if (slug) fetchLawyerId();
    }, [slug]);

    // Lấy bằng cấp khi có lawyerId
    useEffect(() => {
        const fetchDiplomas = async () => {
            setLoading(true);
            try {
                const res = await api.lawyer.get(`/api/LawyerDiploma/lawyer/${lawyerId}`);
                const all = Array.isArray(res.data.result) ? res.data.result : [];
                setDiplomas(all.filter(d => d.isPublic && d.isVerified));
            } catch {
                setDiplomas([]);
            } finally {
                setLoading(false);
            }
        };
        if (lawyerId) fetchDiplomas();
    }, [lawyerId]);

    // Phân trang
    const totalPages = Math.ceil(diplomas.length / ITEMS_PER_PAGE);
    const currentDiplomas = diplomas.slice(
        (currentPage - 1) * ITEMS_PER_PAGE,
        currentPage * ITEMS_PER_PAGE
    );

    return (
        <div className="max-w-7xl mx-auto p-6">
            <h1 className="text-3xl font-bold mb-8 text-primary-900 text-center">Bằng cấp của luật sư</h1>
            <div className="bg-white rounded shadow p-4 overflow-x-auto">
                {loading ? (
                    <div className="text-gray-500 text-center py-8">Đang tải...</div>
                ) : currentDiplomas.length === 0 ? (
                    <div className="text-gray-500 text-center py-8">Luật sư chưa công khai bằng cấp nào.</div>
                ) : (
                   <table className="min-w-full divide-y divide-gray-200 text-center table-auto">
                        <thead className="bg-gray-100">
                            <tr>
                                <th className="px-2 py-2">Tên bằng cấp</th>
                                <th className="px-2 py-2">Loại</th>
                                <th className="px-2 py-2">Ngày cấp</th>
                                <th className="px-2 py-2">Nơi cấp</th>
                                <th className="px-2 py-2">Mô tả</th>
                                <th className="px-2 py-2">Tệp</th>
                            </tr>
                        </thead>
                        <tbody>
                            {currentDiplomas.map((d) => (
                                <tr key={d.id} className="border-b">
                                    <td className="px-2 py-2 font-semibold">{d.title}</td>
                                    <td className="px-2 py-2">{d.qualificationType}</td>
                                    <td className="px-2 py-2">{d.issuedDate?.slice(0, 10)}</td>
                                    <td className="px-2 py-2">{d.issuedBy}</td>
                                    <td className="px-2 py-2">{d.description}</td>
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
                                </tr>
                            ))}
                        </tbody>
                    </table>
                )}
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
            </div>
        </div>
    );
};

export default Diploma;