import { useParams } from 'react-router-dom';
import { useAuth } from '../../features/auth/auth';
import { useEffect, useState, useRef } from 'react';
// @ts-ignore
import { socket } from '../../helpers/socket/user_socket.js';

interface Message {
  body: string;
  timestamp: string;
}

export function ChannelsPage() {
  const { user, logout } = useAuth();
  const { '*': routeId } = useParams();

  // Reference to the div to scroll messages into view
  const messagesEndRef = useRef<HTMLDivElement>(null);

  // Reference to keep channel instance across renders (important)
  const channelRef = useRef<any>(null);

  // State for messages list
  const [messages, setMessages] = useState<Message[]>([]);

  // State for current input text
  const [input, setInput] = useState('');

  useEffect(() => {
    // Create and join channel only once on mount
    const channel = socket.channel("room:lobby", {});

    interface ChannelJoinOkResponse {
      status: string;
    }

    interface ChannelJoinErrorResponse {
      error: any;
    }

    // Join channel, handle success/error logs
    channel.join()
      .receive("ok", (_response: ChannelJoinOkResponse) => console.log("Joined lobby"))
      .receive("error", (err: ChannelJoinErrorResponse) => console.error("Unable to join lobby", err));

    // Listen for incoming messages on channel and update state
    channel.on("new_msg", (payload: { body: string }) => {
      setMessages(prev => [
        ...prev,
        {
          body: payload.body,
          // Use locale string timestamp for readability
          timestamp: new Date().toLocaleTimeString(),
        }
      ]);
    });

    // Save channel instance in ref so send() can reuse it
    channelRef.current = channel;

    // Cleanup: leave channel on unmount
    return () => {
      channel.leave();
    };
  }, []);

  // Scroll chat window to bottom on new message
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages]);

  // Send message through existing channel, clear input
  const send = () => {
    if (input.trim() && channelRef.current) {
      channelRef.current.push("new_msg", { body: input.trim() });
      setInput('');
    }
  };

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

      <p>{routeId === '@me' ? "You're in your DMs." : `You're viewing server: ${routeId}`}</p>

      <div
        id="messages"
        role="log"
        aria-live="polite"
        style={{
          height: 400,
          overflowY: 'auto',
          border: '1px solid #ccc',
          padding: 10,
          marginBottom: 10,
          backgroundColor: '#f9f9f9'
        }}
      >
        {messages.map((msg, i) => (
          <p key={i}>[{msg.timestamp}] {msg.body}</p>
        ))}
        {/* Invisible div for auto-scrolling to bottom */}
        <div ref={messagesEndRef} />
      </div>

      <div style={{ display: 'flex', gap: 10 }}>
        {/* Input for typing messages */}
        <input
          id="chat-input"
          type="text"
          value={input}
          onChange={e => setInput(e.target.value)}
          onKeyDown={e => e.key === 'Enter' && send()}
          placeholder="Type a message..."
          style={{
            flex: 1,
            padding: 8,
            border: '1px solid #ccc',
            borderRadius: 4
          }}
        />

        {/* Send button, disabled when input empty */}
        <button
          onClick={send}
          style={{
            padding: '8px 16px',
            backgroundColor: input.trim() ? '#007bff' : '#ccc',
            color: 'white',
            border: 'none',
            borderRadius: 4,
            cursor: input.trim() ? 'pointer' : 'not-allowed'
          }}
          disabled={!input.trim()}
        >
          Send
        </button>
      </div>
    </div>
  );
}
// TODO: Later extract chat UI + logic into its own component for cleaner code
// TODO: Add chat history
