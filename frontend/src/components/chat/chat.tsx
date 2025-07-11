import React, { useEffect, useState, useRef } from 'react';
import DOMPurify from 'dompurify';
// @ts-ignore
import { connectSocket } from '../../features/chat/socket/user_socket';

interface Message {
  body: string;
  timestamp: string;
  stylingEnabled: boolean;
}

const allowedStyles = ['color', 'font-weight', 'background-color', 'text-decoration', 'font-style'];

export function Chat() {
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const containerRef = useRef<HTMLDivElement>(null);
  const channelRef = useRef<any>(null);
  const socketRef = useRef<any>(null);
  const alertTimeout = useRef<NodeJS.Timeout | null>(null);
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState('');
  const [allowStyling, setAllowStyling] = useState(false);
  const [blockedWarning, setBlockedWarning] = useState<string | null>(null);

  // Enhanced DOMPurify config
  useEffect(() => {
    const hooks = {
      uponSanitizeAttribute: (node: any) => {
        if (node.attrName === 'style') {
          const blocked: string[] = [];
          const sanitized = node.attrValue.split(';')
            .filter((decl: string) => {
              const [prop] = decl.split(':').map(s => s.trim().toLowerCase());
              const allowed = allowedStyles.includes(prop);
              if (!allowed && prop) blocked.push(prop);
              return allowed;
            })
            .join('; ');
          
          node.attrValue = sanitized || null;
          if (blocked.length) {
            setBlockedWarning(`Blocked styles: ${blocked.join(', ')}`);
            setTimeout(() => setBlockedWarning(null), 3000);
          }
        }
      }
    };

    DOMPurify.addHook('uponSanitizeAttribute', hooks.uponSanitizeAttribute);
    return () => { DOMPurify.removeHook('uponSanitizeAttribute'); };
  }, []);

  // Socket setup (unchanged from your original)
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
      if (channelRef.current) channelRef.current.leave();
      if (socketRef.current) socketRef.current.disconnect();
    };
  }, [allowStyling]);

  const sendMessage = () => {
    if (!input.trim() || !channelRef.current) return;

    const newMessage = {
      body: input.trim(),
      timestamp: new Date().toLocaleTimeString(),
      stylingEnabled: allowStyling
    };

    setMessages(prev => [...prev, newMessage]);
    channelRef.current.push("new_msg", { body: allowStyling 
      ? DOMPurify.sanitize(input.trim())
      : input.trim()
    });
    setInput('');
  };

  return (
    <div>
      <div ref={containerRef} style={{ height: 400, overflowY: 'auto', border: '1px solid #ccc', padding: 10 }}>
        {messages.map((msg, i) => (
          <p key={i}>
            {msg.stylingEnabled ? (
              <span dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(msg.body) }} />
            ) : (
              <span>{msg.body}</span>
            )}
          </p>
        ))}
        <div ref={messagesEndRef} />
      </div>

      <input
        type="text"
        value={input}
        onChange={(e) => setInput(e.target.value)}
        onKeyDown={(e) => e.key === 'Enter' && sendMessage()}
        placeholder="Type a message..."
        style={{ width: '100%', padding: 8, marginTop: 8 }}
      />

      <button 
        onClick={() => setAllowStyling(!allowStyling)}
        style={{ 
          background: allowStyling ? '#4CAF50' : '#f44336',
          color: 'white',
          padding: '8px 16px',
          marginTop: 8
        }}
      >
        {allowStyling ? 'Styled Mode' : 'Plain Mode'}
      </button>

      {blockedWarning && (
        <div style={{
          position: 'fixed',
          bottom: 20,
          left: '50%',
          transform: 'translateX(-50%)',
          background: '#ff4444',
          color: 'white',
          padding: '8px 16px',
          borderRadius: 4
        }}>
          {blockedWarning}
        </div>
      )}
    </div>
  );
}