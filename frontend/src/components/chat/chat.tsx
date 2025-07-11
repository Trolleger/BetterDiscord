import React, { useEffect, useState, useRef } from 'react';
import DOMPurify from 'dompurify';
// @ts-ignore
import { connectSocket } from '../../features/chat/socket/user_socket';

interface Message {
  body: string;
  timestamp: string;
  stylingEnabled: boolean;
}

const ALLOWED_STYLES = ['color', 'font-weight', 'background-color', 'text-decoration', 'font-style'];

export function Chat() {
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const containerRef = useRef<HTMLDivElement>(null);
  const channelRef = useRef<any>(null);
  const socketRef = useRef<any>(null);
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState('');
  const [allowStyling, setAllowStyling] = useState(false);
  const [alertMessage, setAlertMessage] = useState<string | null>(null);

  // Auto-dismiss alerts after 3 seconds
  useEffect(() => {
    if (!alertMessage) return;
    const timer = setTimeout(() => setAlertMessage(null), 3000);
    return () => clearTimeout(timer);
  }, [alertMessage]);

  // Socket initialization (unchanged)
  useEffect(() => {
    let isMounted = true;
    const initSocket = async () => {
      if (socketRef.current) return;
      const socket = await connectSocket(localStorage.getItem('access_token'));
      if (!socket || !isMounted) return;

      const channel = socket.channel("room:lobby", {});
      channel.on("new_msg", (payload: { body: string }) => {
        setMessages(prev => [...prev, {
          body: payload.body,
          timestamp: new Date().toLocaleTimeString(),
          stylingEnabled: allowStyling
        }]);
      });

      channelRef.current = channel;
      socketRef.current = socket;
    };

    initSocket();
    return () => {
      isMounted = false;
      if (channelRef.current) channelRef.current.leave();
      if (socketRef.current) socketRef.current.disconnect();
    };
  }, [allowStyling]);

  // Auto-scroll
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages]);

  const sendMessage = () => {
    if (!input.trim() || !channelRef.current) return;

    // Detect blocked styles BEFORE sanitization
    const blockedStyles: string[] = [];
    if (allowStyling) {
      const temp = document.createElement('div');
      temp.innerHTML = input.trim();
      
      temp.querySelectorAll('[style]').forEach(el => {
        (el.getAttribute('style') || '')
          .split(';')
          .map(decl => decl.trim())
          .filter(Boolean)
          .forEach(decl => {
            const prop = decl.split(':')[0].trim().toLowerCase();
            if (!ALLOWED_STYLES.includes(prop)) {
              blockedStyles.push(prop);
            }
          });
      });

      if (blockedStyles.length) {
        setAlertMessage(`Blocked styles: ${[...new Set(blockedStyles)].join(', ')}`);
      }
    }

    const newMessage = {
      body: allowStyling ? DOMPurify.sanitize(input.trim()) : input.trim(),
      timestamp: new Date().toLocaleTimeString(),
      stylingEnabled: allowStyling
    };

    setMessages(prev => [...prev, newMessage]);
    channelRef.current.push("new_msg", { body: newMessage.body });
    setInput('');
  };

  return (
    <div style={{ maxWidth: 600, margin: '0 auto', padding: 16 }}>
      <div
        ref={containerRef}
        style={{ 
          height: 400,
          overflowY: 'auto',
          border: '1px solid #ddd',
          borderRadius: 8,
          padding: 12,
          marginBottom: 12,
          backgroundColor: '#fafafa'
        }}
      >
        {messages.map((msg, i) => (
          <div key={i} style={{ marginBottom: 8 }}>
            {msg.stylingEnabled ? (
              <span dangerouslySetInnerHTML={{ __html: msg.body }} />
            ) : (
              <span style={{ whiteSpace: 'pre-wrap' }}>{msg.body}</span>
            )}
            <small style={{ display: 'block', color: '#666', marginTop: 4 }}>
              {msg.timestamp}
            </small>
          </div>
        ))}
        <div ref={messagesEndRef} />
      </div>

      {alertMessage && (
        <div style={{ 
          marginTop: 8, 
          padding: 8, 
          background: '#fee', 
          border: '1px solid #f99', 
          borderRadius: 4, 
          fontWeight: 'bold' 
        }}>
          {alertMessage}
        </div>
      )}

      <div style={{ display: 'flex', gap: 8 }}>
        <input
          type="text"
          value={input}
          onChange={(e) => setInput(e.target.value)}
          onKeyDown={(e) => e.key === 'Enter' && sendMessage()}
          placeholder="Type a message..."
          style={{ flex: 1, padding: 8, borderRadius: 4, border: '1px solid #ddd' }}
          autoFocus
        />
        <button
          onClick={sendMessage}
          disabled={!input.trim()}
          style={{ padding: '8px 16px', borderRadius: 4, border: 'none' }}
        >
          Send
        </button>
      </div>

      <button
        onClick={() => setAllowStyling(!allowStyling)}
        style={{
          display: 'block',
          marginTop: 12,
          padding: '8px 16px',
          background: allowStyling ? '#4CAF50' : '#f44336',
          color: 'white',
          border: 'none',
          borderRadius: 4,
          width: '100%'
        }}
      >
        {allowStyling ? 'Styled Mode (ON)' : 'Plain Mode (OFF)'}
      </button>
    </div>
  );
}