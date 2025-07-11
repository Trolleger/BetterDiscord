import React, { useEffect, useState, useRef } from 'react';
import DOMPurify from 'dompurify';
// @ts-ignore
import { connectSocket } from '../../features/chat/socket/user_socket';

interface Message {
  body: string;
  timestamp: string;
}

const allowedStyles = ['color', 'font-weight', 'background-color', 'text-decoration', 'font-style'];

export function Chat() {
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const containerRef = useRef<HTMLDivElement>(null);
  const channelRef = useRef<any>(null);
  const socketRef = useRef<any>(null);
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState('');
  const [allowStyling, setAllowStyling] = useState(false);
  const [blockedWarning, setBlockedWarning] = useState<string | null>(null);
  const blockedItems = useRef<string[]>([]);

  // Setup DOMPurify hook with style whitelist
  useEffect(() => {
    const uponSanitizeAttribute = (node: any) => {
      if (node.attrName === 'style') {
        const style = node.attrValue;
        const declarations = style.split(';').map((s: string) => s.trim()).filter(Boolean);
        
        const filtered = declarations.filter((decl: string) => {
          const prop = decl.split(':')[0].trim().toLowerCase();
          const isAllowed = allowedStyles.includes(prop);
          if (!isAllowed) blockedItems.current.push(prop);
          return isAllowed;
        });

        if (filtered.length > 0) {
          node.attrValue = filtered.join('; ') + ';';
        } else {
          node.removeAttribute('style');
        }
      }
    };

    const uponSanitizeElement = (node: any) => {
      if (node.tagName === 'SCRIPT') {
        blockedItems.current.push(`<${node.tagName.toLowerCase()}>`);
      }
    };

    DOMPurify.addHook('uponSanitizeAttribute', uponSanitizeAttribute);
    DOMPurify.addHook('uponSanitizeElement', uponSanitizeElement);

    return () => {
      DOMPurify.removeHook('uponSanitizeAttribute');
      DOMPurify.removeHook('uponSanitizeElement');
    };
  }, []);

  useEffect(() => {
    let isMounted = true;

    const initSocket = async () => {
      if (socketRef.current) return;
      const jwtAccessToken = localStorage.getItem('access_token');
      const socket = await connectSocket(jwtAccessToken);
      if (!socket) return;

      socketRef.current = socket;
      const channel = socket.channel("room:lobby", {});

      channel.join()
        .receive("ok", () => console.log("Joined lobby"))
        .receive("error", (err: any) => console.error("Unable to join lobby", err));

      channel.on("new_msg", (payload: { body: string }) => {
        if (!isMounted) return;
        setMessages(prev => [...prev, { 
          body: payload.body, 
          timestamp: new Date().toLocaleTimeString() 
        }]);
      });

      channelRef.current = channel;
    };

    initSocket();

    return () => {
      isMounted = false;
      if (channelRef.current) {
        channelRef.current.leave();
        channelRef.current = null;
      }
      if (socketRef.current) {
        socketRef.current.disconnect();
        socketRef.current = null;
      }
    };
  }, []);

  useEffect(() => {
    const container = containerRef.current;
    if (!container) return;

    const isNearBottom = container.scrollHeight - container.scrollTop - container.clientHeight < 50;
    if (isNearBottom) {
      messagesEndRef.current?.scrollIntoView({ behavior: "auto" });
    }
  }, [messages]);

  const send = () => {
    if (!input.trim() || !channelRef.current) return;

    blockedItems.current = [];
    const messageToSend = allowStyling ? DOMPurify.sanitize(input.trim()) : input.trim();

    // Only send through socket - the response will add it to messages
    channelRef.current.push("new_msg", { body: messageToSend });
    setInput('');

    // Show warning if anything was blocked
    if (blockedItems.current.length > 0) {
      setBlockedWarning(`These [${blockedItems.current.join(', ')}] were blocked, rest was sent.`);
      setTimeout(() => setBlockedWarning(null), 5000);
    }
  };

  const renderMessage = (msg: Message) => {
    if (allowStyling) {
      return (
        <span dangerouslySetInnerHTML={{ __html: DOMPurify.sanitize(msg.body) }} />
      );
    } else {
      return <span>{msg.body}</span>;
    }
  };

  return (
    <div>
      <div
        ref={containerRef}
        style={{ height: 400, overflowY: 'auto', border: '1px solid #ccc', padding: 10, backgroundColor: '#f9f9f9' }}
      >
        {messages.map((msg, i) => (
          <p key={i} style={{ margin: '4px 0' }}>
            {renderMessage(msg)}
            <small style={{ color: '#666', marginLeft: '8px' }}>{msg.timestamp}</small>
          </p>
        ))}
        <div ref={messagesEndRef} />
      </div>

      <div style={{ marginTop: 8 }}>
        <input
          type="text"
          value={input}
          onChange={e => setInput(e.target.value)}
          onKeyDown={e => e.key === 'Enter' && send()}
          placeholder="Type a message..."
          style={{ width: '100%', padding: 8 }}
        />
        <div style={{ display: 'flex', gap: 8, marginTop: 8 }}>
          <button 
            onClick={send} 
            disabled={!input.trim()} 
            style={{ flex: 1, padding: 8 }}
          >
            Send
          </button>
          <button
            onClick={() => setAllowStyling(!allowStyling)}
            style={{
              padding: 8,
              background: allowStyling ? '#4CAF50' : '#f44336',
              color: 'white',
              border: 'none',
              borderRadius: 4
            }}
          >
            {allowStyling ? 'Styled' : 'Plain'}
          </button>
        </div>
      </div>

      {blockedWarning && (
        <div style={{
          position: 'fixed',
          bottom: 20,
          left: '50%',
          transform: 'translateX(-50%)',
          background: '#ff6b6b',
          color: 'white',
          padding: '8px 16px',
          borderRadius: 4,
          boxShadow: '0 2px 10px rgba(0,0,0,0.2)',
          zIndex: 1000
        }}>
          {blockedWarning}
        </div>
      )}
    </div>
  );
}