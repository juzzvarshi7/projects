// client/src/api.js
import axios from 'axios';
const API = axios.create({ baseURL: window._env?.API_BASE || 'http://localhost:3001' });
export default API;
