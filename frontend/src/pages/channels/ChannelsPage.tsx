import { useParams } from 'react-router-dom';
import { useAuth } from '../../features/auth/auth';
import DOMPurify from 'dompurify';
import { useEffect } from 'react';
// @ts-ignore
import { socket, channel } from '../../helpers/socket/socket.js';

declare global {
  interface Window {
    socket: typeof socket;
    channel: typeof channel;
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
    window.socket = socket;
    window.channel = channel;
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

        <div id="messages" role="log" aria-live="polite"></div>
        <input id="chat-input" type="text"></input>
      </main>
    </div>
  );
}
// DO NOT REMOVE THIS TODO.
// TODO: Make chat into a component