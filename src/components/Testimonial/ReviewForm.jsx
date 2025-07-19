import { useState } from "react";
import { Star } from "lucide-react";
import api from "../../config/axios";

const StarRating = ({ value, onChange }) => (
  <div className="flex items-center gap-1 mb-2">
    {[1, 2, 3, 4, 5].map((star) => (
      <button
        key={star}
        type="button"
        className="focus:outline-none"
        onClick={() => onChange(star)}
      >
        <Star
          className={`h-6 w-6 ${star <= value ? "text-yellow-400 fill-yellow-400" : "text-gray-300"}`}
          fill={star <= value ? "#facc15" : "none"}
        />
      </button>
    ))}
  </div>
);

const ReviewForm = ({ lawyerId, onSuccess }) => {
  const [rating, setRating] = useState(0);
  const [comment, setComment] = useState("");
  const [loading, setLoading] = useState(false);
  const [err, setErr] = useState("");
  const [success, setSuccess] = useState(false);

  const user = JSON.parse(localStorage.getItem("user") || "{}");
  const userId = user?.id || user?.userId || 0;
  const isCustomer = user?.role === "Customer";

  const handleSubmit = async (e) => {
    e.preventDefault();
    setErr("");
     if (!isCustomer) {
      setErr("Vui lòng đăng nhập vào tài khoản để đánh giá!");
      return;
    }
    if (!comment.trim()) {
      setErr("Vui lòng nhập nội dung đánh giá.");
      return;
    }
    setLoading(true);
    try {
      await api.auth.post("/api/Review", {
        lawyerId,
        userId,
        rating,
        comment,
      });
      setComment("");
      setRating(5);
      setSuccess(true);
      if (onSuccess) onSuccess();
      setTimeout(() => setSuccess(false), 4000);
    } catch {
      setErr("Gửi đánh giá thất bại. Vui lòng thử lại.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="relative">
      {/* ✅ Animated success message */}
      {success && (
        <div className="absolute inset-x-0 -top-24 z-10 flex justify-center">
          <div className="flex items-center gap-3 bg-green-100 border border-green-300 text-green-800 px-6 py-3 rounded-xl shadow-lg animate-fade-bounce">
            <img
              src="https://cdn-icons-png.flaticon.com/512/190/190411.png"
              alt="Success"
              className="w-6 h-6 animate-scale-pop"
            />
            <span className="font-medium">Đánh giá của bạn đã được gửi thành công!</span>
          </div>
        </div>
      )}

      <form
        onSubmit={handleSubmit}
        className="bg-white rounded-xl shadow p-6 mt-8 border border-gray-100 max-w-xl mx-auto relative"
      >
        <h3 className="text-2xl font-semibold mb-3 text-primary-900">Đánh giá luật sư</h3>

        <StarRating value={rating} onChange={setRating} />

        <textarea
          className="w-full border rounded-lg p-3 mb-3 focus:ring-2 focus:ring-primary-300 transition"
          rows={3}
          placeholder="Nhận xét của bạn về luật sư..."
          value={comment}
          onChange={(e) => setComment(e.target.value)}
          required
        />

        {err && <div className="text-red-600 mb-2 text-sm">{err}</div>}

        <button
          type="submit"
          className="bg-primary-700 text-white px-6 py-2 rounded-lg font-semibold hover:bg-primary-800 transition disabled:opacity-60"
          disabled={loading}
        >
          {loading ? "Đang gửi..." : "Gửi đánh giá"}
        </button>
      </form>
    </div>
  );
};

export default ReviewForm;
