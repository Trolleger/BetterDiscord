import React from 'react';
import ReactDOM from 'react-dom/client';

import MediasoupClient from './components/MediaSoup/MediasoupClient';
import { GoogleLoginButton } from './components/auth/GoogleLoginButton';

// Use the backend service URL - this will be accessible from the browser
const API_BASE_URL = 'http://localhost:4000';

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <GoogleLoginButton apiBaseUrl={API_BASE_URL} />
    <MediasoupClient />
  </React.StrictMode>
);