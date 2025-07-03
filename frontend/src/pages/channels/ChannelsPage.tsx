import { useParams } from 'react-router-dom';
import { useAuth } from '../../features/auth/auth';
import DOMPurify from 'dompurify';
import { useEffect } from 'react';
// @ts-ignore
import socket from '../../helpers/socket/socket.js';

// Extend Window interface so TS knows about window.socket
declare global {
  interface Window {
    socket: typeof socket;
  }
}

export function ChannelsPage() {
  const { user, logout } = useAuth();
  const { '*': wildcardId } = useParams();

  const sanitizedUsername = user?.username ? DOMPurify.sanitize(user.username) : '';
  const sanitizedId = wildcardId ? DOMPurify.sanitize(wildcardId) : '';

  useEffect(() => {
    console.log('Socket connected:', socket.isConnected());
    console.log('Socket state:', socket.connectionState());
    window.socket = socket;  // No TS error now
  }, []);

  return (
    <div>
      <header style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <h1>Better Discord</h1>
        <div>
          <span>Hello, {sanitizedUsername}!</span>
          <button
            onClick={logout}
            style={{ marginLeft: '10px', padding: '5px 10px' }}
          >
            Logout
          </button>
        </div>
      </header>
      <hr />
      <main>
        {sanitizedId === '@me' ? (
          <p>You're in your DMs.</p>
        ) : (
          <p>You're viewing server: {sanitizedId}</p>
        )}
      </main>
    </div>
  );
}
