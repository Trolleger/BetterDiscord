import { useAuth } from '../../features/auth/auth';
import { Chat } from '../../components/chat/chat';

export function ChannelsPage() {
  const { user, logout } = useAuth();

  return (
    <div style={{ padding: 20 }}>
      <header style={{ display: 'flex', justifyContent: 'space-between' }}>
        <h1>Better Discord</h1>
        <div>
          Hello, {user?.username}
          <button onClick={logout} style={{ marginLeft: 10 }}>Logout</button>
        </div>
      </header>
      <hr />
      <Chat />
    </div>
  );
}

// TODO: Later extract chat UI + logic into its own component for cleaner code
// TODO: Add chat history
