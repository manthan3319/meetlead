import axios from 'axios';
import Cookies from 'js-cookie';

const _resolveBaseURL = () => {
  if (process.env.NEXT_PUBLIC_API_URL) return process.env.NEXT_PUBLIC_API_URL;
  const host = typeof window !== 'undefined' ? window.location.hostname : 'localhost';
  return `http://${host}:5000/api`;
};

export const api = axios.create({
  baseURL: _resolveBaseURL(),
  timeout: 20000,
});

api.interceptors.request.use((config) => {
  const token = Cookies.get('ml_token');
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

api.interceptors.response.use(
  (r) => r,
  (err) => {
    if (err.response?.status === 401 && typeof window !== 'undefined') {
      Cookies.remove('ml_token');
      Cookies.remove('ml_user');
      if (!window.location.pathname.startsWith('/login')) window.location.href = '/login';
    }
    return Promise.reject(err);
  }
);

export const setAuth = (token: string, user: any) => {
  Cookies.set('ml_token', token, { expires: 30 });
  Cookies.set('ml_user', JSON.stringify(user), { expires: 30 });
};

export const clearAuth = () => {
  Cookies.remove('ml_token');
  Cookies.remove('ml_user');
};

export const getUser = (): any | null => {
  try {
    const u = Cookies.get('ml_user');
    return u ? JSON.parse(u) : null;
  } catch {
    return null;
  }
};
