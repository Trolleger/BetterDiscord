import { useParams } from 'react-router-dom';
import { useAuth } from '../../features/auth/auth';

export function ChannelsPage() {
  const { user, logout } = useAuth();
  const { id } = useParams(); // will be "@me" or a server ID

  return (
    <div>
      <header style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <h1>Better Discord</h1>
        <div>
          <span>Hello, {user?.username}!</span>
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
        {/* Render based on channel id */}
        {id === '@me' ? (
          <p>You're in your DMs.</p>
        ) : (
          <p>You're viewing server: {id}</p>
        )}
      </main>
    </div>
  );
}
