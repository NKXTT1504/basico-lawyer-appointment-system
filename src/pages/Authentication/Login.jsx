import { useState, useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { Mail, Lock, ArrowRight, Scale } from 'lucide-react';
import { useDispatch } from "react-redux";
import api from '../../config/axios';
import { login } from "../../redux/features/userSlice";
import { googleProvider, auth } from "../../config/firebase";
import { getAuth, GoogleAuthProvider, signInWithPopup, signInWithRedirect, getRedirectResult } from "firebase/auth";

const Login = () => {
  const navigate = useNavigate();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [rememberMe, setRememberMe] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [isGoogleLoading, setIsGoogleLoading] = useState(false);

  const dispatch = useDispatch(); // Store data to redux

  useEffect(() => {
    const rememberedEmail = localStorage.getItem('rememberedEmail');
    if (rememberedEmail) {
      setEmail(rememberedEmail);
      setRememberMe(true);
    }
  }, []);

  useEffect(() => {
    const auth = getAuth();
    getRedirectResult(auth)
      .then((result) => {
        console.log("Google redirect result:", result);
        if (result && result.user) {
          handleGoogleLoginSuccess(result.user);
        } else {
          console.log("No user returned from Google redirect.");
        }
      })
      .catch((error) => {
        setError(error.message);
        setIsGoogleLoading(false);
        console.log("Google login error:", error);
      });
  }, []);

const handleLogin = async (e) => {
    e.preventDefault();
    setIsLoading(true);
    setError('');
    try {
      const response = await api.auth.post("/api/Auth/login", { email, password });
      const { token, tokenExpiration, user } = response.data;
      const role = user.role;
      console.log("Đăng nhập role:", role);
      dispatch(login(response.data));

      //     // 👉 Kiểm tra tài khoản bị khóa
    if (user.isActive === false || user.isActive === 0) {
      setError("Tài khoản của bạn đã bị khóa.");
      return;
    }
      localStorage.setItem("token", token);
      localStorage.setItem("tokenExpiration", tokenExpiration);
      localStorage.setItem("role", role);

      if (user) {
        localStorage.setItem('user', JSON.stringify(user));
      }

      if (rememberMe) {
        localStorage.setItem('rememberedEmail', email);
      } else {
        localStorage.removeItem('rememberedEmail');
      }

      const redirectPath = sessionStorage.getItem("redirectPath") || "/";
      sessionStorage.removeItem("redirectPath");

      switch (role) {
        case 'Customer':
          navigate('/');
          break;
        case 'Lawyer':
          navigate('/manageappointment');
          break;
        case 'Admin':
          navigate('/dashboard');
          break;
        default:
          navigate('/');
      }
    } catch (err) {
      setError(err.response?.data?.message || 'An error occurred during login');
    } finally {
      setIsLoading(false);
    }
  };


  const handleGoogleLogin = async () => {
  setIsGoogleLoading(true);
  try {
    const response = await api.auth.get("/api/Auth/google-login");
    const { url } = response.data;

    // 👉 Mở popup
    const width = 500;
    const height = 600;
    const left = window.screenX + (window.innerWidth - width) / 2;
    const top = window.screenY + (window.innerHeight - height) / 2;

    const popup = window.open(
      url,
      "GoogleLogin",
      `width=${width},height=${height},left=${left},top=${top}`
    );

    if (!popup) {
      throw new Error("Không thể mở cửa sổ đăng nhập Google.");
    }

    // Đợi response từ popup (dùng postMessage)
    window.addEventListener("message", async (event) => {
      if (event.origin !== window.location.origin) return;

      const { idToken } = event.data;

      if (idToken) {
        // Gửi ID token về backend để login
        const loginRes = await api.auth.post("/api/Auth/google-callback", {
          idToken,
        });

        const { token, tokenExpiration, user } = loginRes.data;
        dispatch(login(loginRes.data));
        localStorage.setItem("token", token);
        localStorage.setItem("tokenExpiration", tokenExpiration);
        localStorage.setItem("user", JSON.stringify(user));
        localStorage.setItem("role", user.role);

        switch (user.role) {
          case "Customer":
            navigate("/");
            break;
          case "Lawyer":
            navigate("/manageappointment");
            break;
          case "Admin":
            navigate("/dashboard");
            break;
          default:
            navigate("/");
        }
      }

      popup.close();
    });
  } catch (error) {
    setError("Lỗi khi đăng nhập bằng Google");
    console.error("Google login error:", error);
  } finally {
    setIsGoogleLoading(false);
  }
};

  
  const handleGoogleLoginSuccess = async (user) => {
    try {
      const idToken = await user.getIdToken();
      console.log("Google idToken:", idToken);
      const response = await api.auth.post("/api/Auth/google-callback", { idToken });
      console.log("Backend login response:", response.data);
      const { token, tokenExpiration, user: userData } = response.data;
      const role = userData.role;
      dispatch(login(response.data));
      localStorage.setItem("token", token);
      localStorage.setItem("tokenExpiration", tokenExpiration);
      localStorage.setItem("role", role);
      localStorage.setItem("user", JSON.stringify(userData));
      // Điều hướng theo role
      switch (role) {
        case 'Customer':
          navigate('/');
          break;
        case 'Lawyer':
          navigate('/manageappointment');
          break;
        case 'Admin':
          navigate('/dashboard');
          break;
        default:
          navigate('/');
      }
    } catch (err) {
      setError(err.response?.data?.message || 'Đăng nhập Google thất bại');
      console.log("Google login backend error:", err);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 flex flex-col justify-center py-16 sm:px-6 lg:px-8">
      <div className="sm:mx-auto sm:w-full sm:max-w-lg">
        <Link to="/" className="flex items-center justify-center gap-3">
          <Scale className="h-16 w-16 text-primary-700" />
          <span className="text-4xl font-bold text-primary-700 font-serif">Basico</span>
        </Link>
        <h2 className="mt-8 text-center text-5xl font-bold text-gray-900">
          Đăng nhập tài khoản
        </h2>
        <p className="mt-3 text-center text-base text-gray-600">
          Hoặc{' '}
          <Link to="/register" className="font-medium text-primary-700 hover:text-primary-800">
            tạo mới tài khoản
          </Link>
        </p>
      </div>

      <div className="mt-12 sm:mx-auto sm:w-full sm:max-w-xl">
        <div className="bg-white py-12 px-8 shadow-xl sm:rounded-lg sm:px-16">
          {error && (
            <div className="mb-5 bg-red-50 border-l-4 border-red-400 p-5">
              <div className="flex">
                <div className="flex-shrink-0">
                  <svg className="h-6 w-6 text-red-400" viewBox="0 0 20 20" fill="currentColor">
                    <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clipRule="evenodd" />
                  </svg>
                </div>
                <div className="ml-3">
                  <p className="text-base text-red-700">{error}</p>
                </div>
              </div>
            </div>
          )}

          <form className="space-y-7" onSubmit={handleLogin}>
            <div>
              <label htmlFor="email" className="block text-lg font-medium text-gray-700">
                Email
              </label>
              <div className="mt-2 relative rounded-md shadow-sm">
                <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                  <Mail className="h-6 w-6 text-gray-400" />
                </div>
                <input
                  id="email"
                  name="email"
                  type="email"
                  autoComplete="email"
                  required
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  className="pl-12 block w-full py-3 text-lg"
                  placeholder="you@example.com"
                />
              </div>
            </div>

            <div>
              <label htmlFor="password" className="block text-lg font-medium text-gray-700">
                Mật khẩu
              </label>
              <div className="mt-2 relative rounded-md shadow-sm">
                <div className="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                  <Lock className="h-6 w-6 text-gray-400" />
                </div>
                <input
                  id="password"
                  name="password"
                  type="password"
                  autoComplete="current-password"
                  required
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="pl-12 block w-full py-3 text-lg"
                  placeholder="••••••••"
                />
              </div>
            </div>

            <div className="flex items-center justify-between">
              <div className="flex items-center">
                <input
                  id="remember-me"
                  name="remember-me"
                  type="checkbox"
                  checked={rememberMe}
                  onChange={(e) => setRememberMe(e.target.checked)}
                  className="h-5 w-5 text-primary-700 focus:ring-primary-500 border-gray-300 rounded"
                />
                <label htmlFor="remember-me" className="ml-2 block text-base text-gray-900">
                  Ghi nhớ đăng nhập
                </label>
              </div>

              <div className="text-base">
                <Link to="/forgot-password" className="font-medium text-primary-700 hover:text-primary-800">
                  Quên mật khẩu
                </Link>
              </div>
            </div>

            <div>
              <button
                type="submit"
                disabled={isLoading}
                className="btn-primary w-full justify-center py-4 text-lg font-medium"
              >
                {isLoading ? (
                  <>
                    <svg className="animate-spin -ml-1 mr-3 h-6 w-6 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                      <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                      <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                    <span className="text-lg">Đang đăng nhập...</span>
                  </>
                ) : (
                  <>
                    <span className="text-lg">Đăng nhập</span>
                    <ArrowRight className="ml-2 h-6 w-6" />
                  </>
                )}
              </button>
            </div>

            <div className="relative">
              <div className="absolute inset-0 flex items-center">
                <div className="w-full border-t border-gray-300"></div>
              </div>
              <div className="relative flex justify-center text-sm">
                <span className="px-2 bg-white text-gray-500 text-base">Hoặc đăng nhập với</span>
              </div>
            </div>

            <div>
              <button
                type="button"
                onClick={handleGoogleLogin}
                disabled={isGoogleLoading}
                className="w-full flex justify-center items-center py-3 px-4 border border-gray-300 rounded-md shadow-sm bg-white text-lg font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary-500"
              >
                {isGoogleLoading ? (
                  <>
                    <svg className="animate-spin -ml-1 mr-3 h-5 w-5 text-gray-700" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                      <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                      <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                    </svg>
                    <span>Đang xử lý...</span>
                  </>
                ) : (
                  <>
                    <svg className="h-6 w-6 mr-2" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">
                      <path fill="#FFC107" d="M43.611,20.083H42V20H24v8h11.303c-1.649,4.657-6.08,8-11.303,8c-6.627,0-12-5.373-12-12c0-6.627,5.373-12,12-12c3.059,0,5.842,1.154,7.961,3.039l5.657-5.657C34.046,6.053,29.268,4,24,4C12.955,4,4,12.955,4,24c0,11.045,8.955,20,20,20c11.045,0,20-8.955,20-20C44,22.659,43.862,21.35,43.611,20.083z" />
                      <path fill="#FF3D00" d="M6.306,14.691l6.571,4.819C14.655,15.108,18.961,12,24,12c3.059,0,5.842,1.154,7.961,3.039l5.657-5.657C34.046,6.053,29.268,4,24,4C16.318,4,9.656,8.337,6.306,14.691z" />
                      <path fill="#4CAF50" d="M24,44c5.166,0,9.86-1.977,13.409-5.192l-6.19-5.238C29.211,35.091,26.715,36,24,36c-5.202,0-9.619-3.317-11.283-7.946l-6.522,5.025C9.505,39.556,16.227,44,24,44z" />
                      <path fill="#1976D2" d="M43.611,20.083H42V20H24v8h11.303c-0.792,2.237-2.231,4.166-4.087,5.571c0.001-0.001,0.002-0.001,0.003-0.002l6.19,5.238C36.971,39.205,44,34,44,24C44,22.659,43.862,21.35,43.611,20.083z" />
                    </svg>
                    <span>Đăng nhập với Google</span>
                  </>
                )}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
};

export default Login;