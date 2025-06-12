import React, { useEffect, useState } from "react";
import api from "../config/axios";
import { ChevronLeft, ChevronRight } from "lucide-react";

const PAGE_SIZE = 5;

// Hàm dịch role sang tiếng Việt, không phân biệt hoa thường
const translateRole = (role) => {
    if (!role) return "Không xác định";
    const normalized = role.toLowerCase();
    switch (normalized) {
        case "customer":
            return "Khách hàng";
        case "admin":
            return "Quản trị viên";
        case "lawyer":
            return "Luật sư";
        default:
            return role;
    }
};

const ManageAccount = () => {
    const [allAccounts, setAllAccounts] = useState([]);
    const [page, setPage] = useState(1);
    const [loading, setLoading] = useState(false);
    const [roleFilter, setRoleFilter] = useState("");
    const [searchTerm, setSearchTerm] = useState("");

    // Fetch all accounts (không phân trang BE)
    const fetchAccounts = async () => {
        setLoading(true);
        try {
            const res = await api.auth.get("/api/UserWithLawyerProfile");
            console.log("Response:", res.data);
            setAllAccounts(Array.isArray(res.data.result) ? res.data.result : []);
        } catch (err) {
            console.error("Fetch error:", err);
            setAllAccounts([]);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchAccounts();
    }, []);

    // Lọc theo role và search term
    const filteredAccounts = allAccounts.filter(acc => {
        const roleMatch = roleFilter ? acc.user.role?.toLowerCase() === roleFilter : true;
        const searchMatch = searchTerm
            ? acc.user.fullName?.toLowerCase().includes(searchTerm.toLowerCase()) ||
              acc.user.email?.toLowerCase().includes(searchTerm.toLowerCase())
            : true;
        return roleMatch && searchMatch;
    });

    const total = filteredAccounts.length;
    const totalPages = Math.max(1, Math.ceil(total / PAGE_SIZE));
    const currentAccounts = filteredAccounts.slice((page - 1) * PAGE_SIZE, page * PAGE_SIZE);

    return (
        <main className="min-h-screen bg-gray-50 py-10 pt-28">
            <div className="container mx-auto px-4">
                <div className="bg-white rounded-lg shadow-md p-6">
                    <h1 className="text-4xl text-center font-bold mb-10 text-primary-900">
                        QUẢN LÍ TÀI KHOẢN
                    </h1>

                    {/* Thanh lọc và tìm kiếm */}
                    <div className="mb-6 flex flex-col md:flex-row items-center justify-center gap-4">
                        {/* Lọc role */}
                        <div className="flex items-center gap-2">
                            <label className="text-sm font-semibold">VAI TRÒ:</label>
                            <select
                                className="border px-3 py-2 rounded"
                                value={roleFilter}
                                onChange={(e) => {
                                    setRoleFilter(e.target.value);
                                    setPage(1); // Reset về trang 1 khi lọc
                                }}
                            >
                                <option value="">Tất cả</option>
                                <option value="customer">Khách hàng</option>
                                <option value="admin">Quản trị viên</option>
                                <option value="lawyer">Luật sư</option>
                            </select>
                        </div>

                        {/* Ô tìm kiếm */}
                        <div className="flex items-center gap-2">
                            <label className="text-sm font-semibold">TÌM KIẾM:</label>
                            <input
                                type="text"
                                placeholder="Tên hoặc Email..."
                                className="border px-3 py-2 rounded w-64"
                                value={searchTerm}
                                onChange={(e) => {
                                    setSearchTerm(e.target.value);
                                    setPage(1); // Reset về trang 1 khi search
                                }}
                            />
                        </div>
                    </div>

                    {/* Bảng dữ liệu */}
                    {loading ? (
                        <div className="text-center py-10">Đang tải dữ liệu...</div>
                    ) : (
                        <>
                            <div className="overflow-x-auto">
                                <table className="min-w-full divide-y divide-gray-200">
                                    <thead className="bg-primary-100">
                                        <tr>
                                            <th className="px-4 py-2 text-left">STT</th>
                                            <th className="px-4 py-2 text-left">Tên</th>
                                            <th className="px-4 py-2 text-left">Email</th>
                                            <th className="px-4 py-2 text-left">Số điện thoại</th>
                                            <th className="px-4 py-2 text-left">Vai trò</th>
                                            <th className="px-4 py-2 text-left">Trạng thái</th>
                                            <th className="px-4 py-2 text-left">Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody className="bg-white divide-y divide-gray-200">
                                        {currentAccounts.length === 0 ? (
                                            <tr>
                                                <td colSpan={7} className="text-center py-8 text-gray-500">
                                                    Không có tài khoản nào.
                                                </td>
                                            </tr>
                                        ) : (
                                            currentAccounts.map((acc, idx) => (
                                                <tr key={acc.user.id}>
                                                    <td className="px-4 py-2">{(page - 1) * PAGE_SIZE + idx + 1}</td>
                                                    <td className="px-4 py-2">{acc.user.fullName || "N/A"}</td>
                                                    <td className="px-4 py-2">{acc.user.email}</td>
                                                    <td className="px-4 py-2">{acc.user.phoneNumber || "Chưa cập nhật"}</td>
                                                    <td className="px-4 py-2">{translateRole(acc.user.role)}</td>
                                                    <td className="px-4 py-2">
                                                        {acc.user.isActive ? (
                                                            <span className="px-2 py-1 rounded bg-green-100 text-green-700 text-xs font-semibold">Hoạt động</span>
                                                        ) : (
                                                            <span className="px-2 py-1 rounded bg-red-100 text-red-700 text-xs font-semibold">Khóa</span>
                                                        )}
                                                    </td>
                                                    <td className="px-4 py-2">
                                                        <button className="text-red-600 hover:underline">
                                                            {acc.user.isActive ? "Khóa" : "Mở khóa"}
                                                        </button>
                                                    </td>
                                                </tr>
                                            ))
                                        )}
                                    </tbody>
                                </table>
                            </div>

                            {/* Phân trang */}
                            <div className="flex justify-center items-center mt-6 gap-4">
                                <button
                                    onClick={() => setPage((p) => Math.max(1, p - 1))}
                                    disabled={page === 1}
                                    className="p-2 rounded border bg-white hover:bg-gray-100 disabled:opacity-50"
                                >
                                    <ChevronLeft className="w-4 h-4" />
                                </button>
                                <span className="text-sm font-medium">
                                    Trang {page} / {totalPages}
                                </span>
                                <button
                                    onClick={() => setPage((p) => Math.min(totalPages, p + 1))}
                                    disabled={page === totalPages}
                                    className="p-2 rounded border bg-white hover:bg-gray-100 disabled:opacity-50"
                                >
                                    <ChevronRight className="w-4 h-4" />
                                </button>
                            </div>
                        </>
                    )}
                </div>
            </div>
        </main>
    );
};

export default ManageAccount;
