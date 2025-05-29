import axios from 'axios';

const API_URLS = {
  AUTH: 'https://localhost:7071/',
  // Thêm các service khác nếu cần
};

const createAxiosInstance = (baseURL) => {
  const instance = axios.create({ baseURL });

  instance.interceptors.request.use(
    (config) => {
      const token = localStorage.getItem('token');
      if (token) {
        config.headers.Authorization = `Bearer ${token}`;
      }
      return config;
    },
    (error) => Promise.reject(error)
  );

  instance.interceptors.response.use(
    (response) => response,
    async (error) => {
      if (error.response?.status === 401) {
        // Xử lý lỗi xác thực ở đây (ví dụ: đăng xuất người dùng)
      }
      return Promise.reject(error);
    }
  );

  return instance;
};

export const authApi = createAxiosInstance(API_URLS.AUTH);

export default {
  auth: authApi,
};