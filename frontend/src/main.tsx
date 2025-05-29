import React from 'react';
import ReactDOM from 'react-dom/client';

import MediasoupClient from './components/MediaSoup/MediasoupClient';
import { GoogleLoginButton } from './components/auth/GoogleLoginButton';

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <GoogleLoginButton />
    <MediasoupClient />
  </React.StrictMode>
);
