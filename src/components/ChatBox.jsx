import { useState, useRef, useEffect } from "react";
import api from '../config/axios';
import {
  Copy,
  Share2,
  ThumbsUp,
  ThumbsDown,
  Send,
  X,
  MessageCircle,
  Bot,
  User
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
            className="text-primary-600 underline hover:text-primary-700 transition-colors"
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
      timestamp: new Date(),
      id: Date.now()
    }
  ]);
  const [input, setInput] = useState("");
  const [userId] = useState(() => localStorage.getItem("userId") || "guest");
  const [isLoading, setIsLoading] = useState(false);
  const [feedback, setFeedback] = useState({});
  const messagesEndRef = useRef(null);
  const messagesContainerRef = useRef(null);

  // Auto scroll to bottom khi có tin nhắn mới
  useEffect(() => {
    if (messagesContainerRef.current) {
      const container = messagesContainerRef.current;
      container.scrollTop = container.scrollHeight;
    }
  }, [messages, isLoading]);

  const handleSend = async () => {
    if (!input.trim()) return;
    
    const userMessage = { 
      from: "user", 
      text: input, 
      timestamp: new Date(),
      id: Date.now()
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
        timestamp: new Date(),
        id: Date.now() + 1
      };
      setMessages(prev => [...prev, botMessage]);
    } catch (err) {
      const errorMessage = {
        from: "bot", 
        text: "Có lỗi xảy ra. Vui lòng thử lại sau ít phút.", 
        timestamp: new Date(),
        id: Date.now() + 1
      };
      setMessages(prev => [...prev, errorMessage]);
    } finally {
      setIsLoading(false);
    }
  };

  const handleCopy = async (text) => {
    try {
      await navigator.clipboard.writeText(text);
      // Có thể thêm toast notification ở đây
    } catch (err) {
      console.error("Lỗi khi sao chép: ", err);
    }
  };

  const handleShare = async (text) => {
    if (navigator.share) {
      try {
        await navigator.share({
          title: 'BASICO AI Chat',
          text: text
        });
      } catch (err) {
        console.error("Lỗi khi chia sẻ: ", err);
      }
    } else {
      handleCopy(text);
    }
  };

  const handleFeedback = (messageId, type) => {
    setFeedback(prev => ({
      ...prev,
      [messageId]: type
    }));
  };

  const formatTime = (date) => {
    return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
  };

  const SuggestedQuestions = () => {
    const questions = [
      "Giới thiệu về hệ thống BASICO",
      "Có bao nhiêu luật sư ở BASICO?",
      "Các dịch vụ của BASICO là gì?",
      "Phổ biến về luật doanh nghiệp?"
    ];

    return (
      <div className="px-4 py-3 bg-gradient-to-r from-blue-50 to-indigo-50 border-t border-gray-200">
        <p className="text-xs text-gray-600 mb-2 font-medium">Câu hỏi gợi ý:</p>
        <div className="flex flex-wrap gap-2">
          {questions.map((question, index) => (
            <button
              key={index}
              onClick={() => setInput(question)}
              className="text-xs bg-white text-gray-700 px-3 py-1.5 rounded-lg border border-gray-200 hover:border-primary-300 hover:text-primary-700 transition-all duration-200 shadow-sm hover:shadow flex-1 min-w-[calc(50%-4px)]"
            >
              {question}
            </button>
          ))}
        </div>
      </div>
    );
  };

  return (
    <>
      {/* Floating Chat Button */}
      <button
        className={`fixed bottom-6 right-6 z-50 bg-gradient-to-r from-primary-600 to-primary-700 text-white rounded-full shadow-2xl w-14 h-14 flex items-center justify-center hover:from-primary-700 hover:to-primary-800 transition-all duration-300 transform hover:scale-110 focus:outline-none ring-4 ring-primary-200 ${
          open ? 'scale-0 opacity-0' : 'scale-100 opacity-100'
        }`}
        onClick={() => setOpen(true)}
        aria-label="Mở chat hỗ trợ"
      >
        <div className="relative">
          <MessageCircle className="w-6 h-6" />
          {messages.length > 1 && (
            <span className="absolute -top-1 -right-1 bg-red-500 text-white text-xs rounded-full w-4 h-4 flex items-center justify-center animate-pulse">
              {messages.length - 1}
            </span>
          )}
        </div>
      </button>

      {/* Chat Window */}
      {open && (
        <div className="fixed bottom-24 right-6 z-50 w-80 md:w-96 bg-white rounded-2xl shadow-2xl flex flex-col border border-gray-200 overflow-hidden animate-fade-in-up max-h-[80vh]">
          {/* Header */}
          <div className="px-5 py-4 bg-gradient-to-r from-primary-600 to-primary-700 text-white flex justify-between items-center flex-shrink-0">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-full bg-white bg-opacity-20 flex items-center justify-center">
                <Bot className="h-5 w-5" />
              </div>
              <div>
                <span className="font-bold text-white block">BASICO AI</span>
                <span className="text-primary-100 text-xs block">Trợ lý pháp lý thông minh</span>
              </div>
            </div>
            <button
              onClick={() => setOpen(false)}
              className="text-white hover:text-gray-200 transition p-2 rounded-full hover:bg-white hover:bg-opacity-10"
              aria-label="Đóng chat"
            >
              <X className="w-5 h-5" />
            </button>
          </div>

          {/* Messages Container với scroll bar tùy chỉnh */}
          <div 
            ref={messagesContainerRef}
            className="flex-1 overflow-y-auto px-4 py-4 bg-gradient-to-b from-gray-50 to-blue-50"
            style={{ 
              maxHeight: 'calc(80vh - 200px)',
              minHeight: '200px'
            }}
          >
            <div className="space-y-4">
              {messages.map((msg) => (
                <div
                  key={msg.id}
                  className={`flex ${msg.from === "user" ? "justify-end" : "justify-start"}`}
                >
                  {msg.from === "bot" && (
                    <div className="w-8 h-8 rounded-full bg-gradient-to-r from-primary-600 to-primary-700 flex items-center justify-center text-white text-sm mr-3 flex-shrink-0 border-2 border-white shadow">
                      <Bot className="w-4 h-4" />
                    </div>
                  )}
                  
                  <div className={`max-w-[75%] group relative ${
                    msg.from === "user" ? "order-2" : "order-1"
                  }`}>
                    <div 
                      className={`px-4 py-3 rounded-2xl text-sm relative ${
                        msg.from === "user" 
                          ? "bg-gradient-to-r from-primary-500 to-primary-600 text-white rounded-br-none shadow-lg" 
                          : "bg-white text-gray-800 border border-gray-200 rounded-bl-none shadow-lg"
                      }`}
                      style={{ whiteSpace: "pre-wrap", wordBreak: "break-word" }}
                    >
                      {renderMessage(msg.text)}
                      <div className={`text-xs mt-2 ${
                        msg.from === "user" ? "text-primary-100 text-right" : "text-gray-500 text-left"
                      }`}>
                        {formatTime(msg.timestamp)}
                      </div>
                    </div>

                    {/* Action Buttons for Bot Messages */}
                    {msg.from === "bot" && (
                      <div className="absolute -right-10 top-1/2 transform -translate-y-1/2 opacity-0 group-hover:opacity-100 transition-opacity duration-200 flex flex-col gap-1">
                        <button
                          onClick={() => handleCopy(msg.text)}
                          className="p-2 bg-white border border-gray-200 rounded-lg shadow-sm hover:bg-gray-50 transition-colors"
                          title="Sao chép"
                        >
                          <Copy className="w-3 h-3 text-gray-600" />
                        </button>
                        <button
                          onClick={() => handleShare(msg.text)}
                          className="p-2 bg-white border border-gray-200 rounded-lg shadow-sm hover:bg-gray-50 transition-colors"
                          title="Chia sẻ"
                        >
                          <Share2 className="w-3 h-3 text-gray-600" />
                        </button>
                      </div>
                    )}

                    {/* Feedback Buttons for Bot Messages */}
                    {msg.from === "bot" && (
                      <div className="flex gap-2 mt-2 justify-end">
                        <button
                          onClick={() => handleFeedback(msg.id, 'like')}
                          className={`p-1 rounded transition-colors ${
                            feedback[msg.id] === 'like' 
                              ? 'text-green-600 bg-green-50' 
                              : 'text-gray-400 hover:text-green-600 hover:bg-green-50'
                          }`}
                          title="Hữu ích"
                        >
                          <ThumbsUp className="w-3 h-3" />
                        </button>
                        <button
                          onClick={() => handleFeedback(msg.id, 'dislike')}
                          className={`p-1 rounded transition-colors ${
                            feedback[msg.id] === 'dislike' 
                              ? 'text-red-600 bg-red-50' 
                              : 'text-gray-400 hover:text-red-600 hover:bg-red-50'
                          }`}
                          title="Không hữu ích"
                        >
                          <ThumbsDown className="w-3 h-3" />
                        </button>
                      </div>
                    )}
                  </div>
                  
                  {msg.from === "user" && (
                    <div className="w-8 h-8 rounded-full bg-gradient-to-r from-primary-600 to-primary-700 flex items-center justify-center text-white text-sm ml-3 flex-shrink-0 border-2 border-white shadow order-1">
                      <User className="w-4 h-4" />
                    </div>
                  )}
                </div>
              ))}
              
              {/* Loading Indicator */}
              {isLoading && (
                <div className="flex justify-start">
                  <div className="w-8 h-8 rounded-full bg-gradient-to-r from-primary-600 to-primary-700 flex items-center justify-center text-white text-sm mr-3 flex-shrink-0 border-2 border-white shadow">
                    <Bot className="w-4 h-4" />
                  </div>
                  <div className="px-4 py-3 bg-white rounded-2xl rounded-bl-none border border-gray-200 shadow-lg">
                    <div className="flex space-x-1">
                      <div className="w-2 h-2 bg-primary-600 rounded-full animate-bounce"></div>
                      <div className="w-2 h-2 bg-primary-600 rounded-full animate-bounce" style={{ animationDelay: '0.2s' }}></div>
                      <div className="w-2 h-2 bg-primary-600 rounded-full animate-bounce" style={{ animationDelay: '0.4s' }}></div>
                    </div>
                  </div>
                </div>
              )}
              <div ref={messagesEndRef} />
            </div>
          </div>

          {/* Suggested Questions */}
          <SuggestedQuestions />

          {/* Input Area */}
          <div className="px-4 py-3 bg-white border-t border-gray-200 flex-shrink-0">
            <div className="flex gap-2">
              <div className="flex-1 relative">
                <input
                  type="text"
                  className="w-full border border-gray-300 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-primary-500 focus:border-transparent transition bg-white pr-10"
                  placeholder="Nhập câu hỏi pháp lý của bạn..."
                  value={input}
                  onChange={e => setInput(e.target.value)}
                  onKeyDown={e => e.key === "Enter" && !isLoading && handleSend()}
                  disabled={isLoading}
                />
                {input && (
                  <button
                    onClick={() => setInput("")}
                    className="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600 transition-colors"
                  >
                    <X className="w-4 h-4" />
                  </button>
                )}
              </div>
              <button
                className={`px-4 py-2.5 rounded-xl font-medium text-white transition-all duration-200 shadow-lg flex items-center justify-center ${
                  isLoading || !input.trim()
                    ? "bg-gray-400 cursor-not-allowed"
                    : "bg-gradient-to-r from-primary-600 to-primary-700 hover:from-primary-700 hover:to-primary-800 hover:shadow-xl"
                }`}
                onClick={handleSend}
                disabled={isLoading || !input.trim()}
                aria-label="Gửi tin nhắn"
              >
                <Send className="w-4 h-4" />
              </button>
            </div>
            <p className="text-xs text-gray-500 text-center mt-2">
              BASICO AI có thể đưa ra các câu trả lời không chính xác. Hãy kiểm tra lại thông tin quan trọng.
            </p>
          </div>
        </div>
      )}

      {/* Custom Scrollbar Styles */}
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

        /* Custom scrollbar */
        .overflow-y-auto::-webkit-scrollbar {
          width: 6px;
        }
        
        .overflow-y-auto::-webkit-scrollbar-track {
          background: #f1f5f9;
          border-radius: 3px;
        }
        
        .overflow-y-auto::-webkit-scrollbar-thumb {
          background: #cbd5e1;
          border-radius: 3px;
        }
        
        .overflow-y-auto::-webkit-scrollbar-thumb:hover {
          background: #94a3b8;
        }
      `}</style>
    </>
  );
};

export default ChatBox;