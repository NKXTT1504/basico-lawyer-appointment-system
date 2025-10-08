import { useState, useRef, useEffect } from "react";
import api from '../config/axios';
import {
  Scale
} from "lucide-react";

// Hàm hỗ trợ render link và xuống dòng
const renderMessage = (text) => {
  return text.split('\n').map((line, i, arr) => (
    <span key={i}>
      {line.split(/(\bhttps?:\/\/[^\s]+)/g).map((part, j) =>
        part.startsWith('http') ? (
          <a
            key={j}
            href={part}
            target="_blank"
            rel="noopener noreferrer"
            className="text-primary-700 underline hover:text-primary-800"
          >
            {part}
          </a>
        ) : (
          part
        )
      )}
      {i < arr.length - 1 && <br />}
    </span>
  ));
};

const ChatBox = () => {
  const [open, setOpen] = useState(false);
  const [messages, setMessages] = useState([
    { 
      from: "bot", 
      text: "Xin chào! Mình là trợ lý tư vấn pháp lý của hệ thống BASICO. Bạn cần hỗ trợ gì?", 
      timestamp: new Date() 
    }
  ]);
  const [input, setInput] = useState("");
  const [userId] = useState(() => localStorage.getItem("userId") || "guest");
  const [isLoading, setIsLoading] = useState(false);
  const messagesEndRef = useRef(null);

  useEffect(() => {
    if (open && messagesEndRef.current) {
      messagesEndRef.current.scrollIntoView({ behavior: "smooth", block: "nearest" });
    }
  }, [messages, open]);

  const handleSend = async () => {
    if (!input.trim()) return;
    
    const userMessage = { 
      from: "user", 
      text: input, 
      timestamp: new Date() 
    };
    setMessages(prev => [...prev, userMessage]);
    setInput("");
    setIsLoading(true);

    try {
      const res = await api.ai.post("/api/chat", {
        userId,
        message: input
      });
      const botMessage = {
        from: "bot",
        text: res.data.answer || "Xin lỗi, tôi chưa hiểu câu hỏi của bạn.",
        timestamp: new Date()
      };
      setMessages(prev => [...prev, botMessage]);
    } catch (err) {
      setMessages(prev => [
        ...prev,
        { 
          from: "bot", 
          text: "Có lỗi xảy ra. Vui lòng thử lại sau ít phút.", 
          timestamp: new Date() 
        }
      ]);
    } finally {
      setIsLoading(false);
    }
  };

  const formatTime = (date) => {
    return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
  };

  return (
    <>
      {/* Chat Icon */}
      <button
        className="fixed bottom-6 right-6 z-50 bg-gradient-to-r from-primary-700 to-primary-800 text-white rounded-full shadow-lg w-14 h-14 flex items-center justify-center hover:from-primary-800 hover:to-primary-900 transition-all duration-300 transform hover:scale-110 focus:outline-none ring-4 ring-primary-300 ring-opacity-50"
        onClick={() => setOpen(o => !o)}
        aria-label="Mở chat hỗ trợ"
      >
        <svg width="24" height="24" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-5l-5 5v-5z" />
        </svg>
      </button>

      {/* Chat Window */}
      {open && (
        <div className="fixed bottom-24 right-6 z-50 w-80 md:w-96 bg-white rounded-2xl shadow-2xl flex flex-col border border-gray-200 overflow-hidden animate-fade-in-up">
          {/* Header */}
          <div className="px-5 py-4 bg-gradient-to-r from-primary-700 to-primary-800 text-white flex justify-between items-center">
            <div className="flex items-center gap-2">
              <div className="w-8 h-8 rounded-full bg-white bg-opacity-20 flex items-center justify-center">
                <Scale className="h-5 w-5" />
              </div>
              <span className="font-bold text-white">BASICO AI</span>
            </div>
            <button
              onClick={() => setOpen(false)}
              className="text-white hover:text-gray-200 transition p-1 rounded-full hover:bg-black hover:bg-opacity-10"
              aria-label="Đóng chat"
            >
              <svg width="20" height="20" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>

          {/* Messages */}
          <div className="flex-1 px-4 py-4 overflow-y-auto bg-gray-50" style={{ maxHeight: 340 }}>
            {messages.map((msg, idx) => (
              <div
                key={idx}
                className={`flex mb-4 ${msg.from === "user" ? "justify-end" : "justify-start"}`}
              >
                {msg.from === "bot" && (
                  <div className="w-9 h-9 rounded-full bg-primary-700 flex items-center justify-center text-white text-sm mr-2 flex-shrink-0 border-2 border-white shadow-sm">
                    B
                  </div>
                )}
                <div className={`max-w-xs md:max-w-md px-4 py-3 rounded-2xl text-sm relative ${msg.from === "user" ? "bg-primary-100 text-primary-900 rounded-tr-none" : "bg-white text-gray-800 border border-gray-200 rounded-tl-none shadow-sm"}`}
                     style={{ whiteSpace: "pre-wrap", wordBreak: "break-word" }}
                >
                  {renderMessage(msg.text)}
                  <div className={`text-xs mt-1 opacity-70 ${msg.from === "user" ? "text-right text-primary-800" : "text-left text-gray-500"}`}>
                    {formatTime(msg.timestamp)}
                  </div>
                </div>
                {msg.from === "user" && (
                  <div className="w-9 h-9 rounded-full bg-primary-700 flex items-center justify-center text-white text-sm ml-2 flex-shrink-0 border-2 border-white shadow-sm">
                    U
                  </div>
                )}
              </div>
            ))}
            
            {isLoading && (
              <div className="flex justify-start mb-4">
                <div className="w-9 h-9 rounded-full bg-primary-700 flex items-center justify-center text-white text-sm mr-2 flex-shrink-0 border-2 border-white shadow-sm">
                  B
                </div>
                <div className="px-4 py-3 bg-white rounded-2xl rounded-tl-none border border-gray-200 shadow-sm">
                  <div className="flex space-x-1">
                    <div className="w-2 h-2 bg-primary-700 rounded-full animate-bounce"></div>
                    <div className="w-2 h-2 bg-primary-700 rounded-full animate-bounce" style={{ animationDelay: '0.2s' }}></div>
                    <div className="w-2 h-2 bg-primary-700 rounded-full animate-bounce" style={{ animationDelay: '0.4s' }}></div>
                  </div>
                </div>
              </div>
            )}
            <div ref={messagesEndRef} />
          </div>

          {/* Input */}
          <div className="px-4 py-3 bg-white border-t">
            <div className="flex gap-2">
              <input
                type="text"
                className="flex-1 border border-gray-300 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent transition"
                placeholder="Nhập câu hỏi của bạn..."
                value={input}
                onChange={e => setInput(e.target.value)}
                onKeyDown={e => e.key === "Enter" && !isLoading && handleSend()}
                disabled={isLoading}
              />
              <button
                className={`px-5 py-2.5 rounded-xl font-medium text-white transition-all duration-200 ${
                  isLoading || !input.trim()
                    ? "bg-gray-400 cursor-not-allowed"
                    : "bg-gradient-to-r from-primary-700 to-primary-800 hover:from-primary-800 hover:to-primary-900 shadow-md hover:shadow-lg"
                }`}
                onClick={handleSend}
                disabled={isLoading || !input.trim()}
                aria-label="Gửi tin nhắn"
              >
                <svg width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 19l9 2-9-18-9 18 9-2zm0 0v-8" />
                </svg>
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Animation styles */}
      <style>{`
        @keyframes fade-in-up {
          from {
            opacity: 0;
            transform: translateY(20px);
          }
          to {
            opacity: 1;
            transform: translateY(0);
          }
        }
        .animate-fade-in-up {
          animation: fade-in-up 0.3s ease-out;
        }
      `}</style>
    </>
  );
};

export default ChatBox;