import React, { useEffect, useState, useRef } from 'react';
import DOMPurify from 'dompurify';
// @ts-ignore
import { connectSocket } from '../../features/chat/socket/user_socket';

interface Message {
  body: string;
  timestamp: string;
}

// Whitelisted CSS properties allowed inside style attributes
const allowedStyles = ['color', 'font-weight', 'background-color', 'text-decoration', 'font-style'];

// Simple function to clean styles
const cleanStyles = (htmlContent: string): string => {
  const tempDiv = document.createElement('div');
  tempDiv.innerHTML = htmlContent;
  
  const styledElements = tempDiv.querySelectorAll('[style]');
  styledElements.forEach(element => {
    const style = element.getAttribute('style') || '';
    const allowedDeclarations = style.split(';')
      .map(s => s.trim())
      .filter(Boolean)
      .filter(decl => {
        const prop = decl.split(':')[0].trim().toLowerCase();
        return allowedStyles.includes(prop);
      });
    
    if (allowedDeclarations.length > 0) {
      element.setAttribute('style', allowedDeclarations.join('; '));
    } else {
      element.removeAttribute('style');
    }
  });
  
  return tempDiv.innerHTML;
};

export function Chat() {
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const containerRef = useRef<HTMLDivElement>(null);
  const channelRef = useRef<any>(null);
  const socketRef = useRef<any>(null);
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState('');
  const [alertMessage, setAlertMessage] = useState<string | null>(null);

  useEffect(() => {
    let isMounted = true;

    const initSocket = async () => {
      if (socketRef.current) return;
      
      const jwtAccessToken = localStorage.getItem('access_token');
      if (!jwtAccessToken) {
        console.error('No access token found');
        return;
      }

      const socket = await connectSocket(jwtAccessToken);
      if (!socket || !isMounted) return;

      socketRef.current = socket;
      const channel = socket.channel("room:lobby", {});

      channel.join()
        .receive("ok", () => console.log("Joined lobby"))
        .receive("error", (err: any) => console.error("Unable to join lobby", err));

      channel.on("new_msg", (payload: { body: string }) => {
        if (!isMounted) return;

        // Clean styles and sanitize
        const cleanedContent = cleanStyles(payload.body);
        const cleanBody = DOMPurify.sanitize(cleanedContent);
        
        setMessages(prev => [...prev, { body: cleanBody, timestamp: new Date().toLocaleTimeString() }]);
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

  // Scroll to bottom when new messages come in
  useEffect(() => {
    const container = containerRef.current;
    if (!container) return;

    const isNearBottom = container.scrollHeight - container.scrollTop - container.clientHeight < 50;
    if (isNearBottom) {
      messagesEndRef.current?.scrollIntoView({ behavior: "auto" });
    }
  }, [messages]);

  // Auto-clear alert after 3 seconds
  useEffect(() => {
    if (!alertMessage) return;
    const timeout = setTimeout(() => setAlertMessage(null), 3000);
    return () => clearTimeout(timeout);
  }, [alertMessage]);

  const send = () => {
    if (input.trim() && channelRef.current) {
      // Check for blocked styles BEFORE sending
      const rejectedStyles: string[] = [];
      
      const tempDiv = document.createElement('div');
      tempDiv.innerHTML = input.trim();
      
      const styledElements = tempDiv.querySelectorAll('[style]');
      styledElements.forEach(element => {
        const style = element.getAttribute('style') || '';
        const declarations = style.split(';').map(s => s.trim()).filter(Boolean);
        
        declarations.forEach(decl => {
          const prop = decl.split(':')[0].trim().toLowerCase();
          if (!allowedStyles.includes(prop)) {
            rejectedStyles.push(prop);
          }
        });
      });

      // Show alert to sender if there are blocked styles
      if (rejectedStyles.length > 0) {
        const uniqueRejected = [...new Set(rejectedStyles)];
        setAlertMessage(`The styles you sent which are blacklisted: ${uniqueRejected.join(', ')}. The rest worked.`);
      }

      // Send the message
      channelRef.current.push("new_msg", { body: input.trim() });
      setInput('');
    }
  };

  return (
    <div>
      <div
        ref={containerRef}
        style={{ height: 400, overflowY: 'auto', border: '1px solid #ccc', padding: 10, backgroundColor: '#f9f9f9' }}
      >
        {messages.map((msg, i) => (
          <p
            key={i}
            dangerouslySetInnerHTML={{ __html: msg.body }}
          />
        ))}
        <div ref={messagesEndRef} />
      </div>

      {alertMessage && (
        <div style={{
          marginTop: 8,
          padding: 8,
          backgroundColor: '#eee',
          color: '#333',
          border: '1px solid #ccc',
          borderRadius: 4,
          fontSize: 14,
          fontWeight: 'bold'
        }}>
          {alertMessage}
        </div>
      )}

      <input
        type="text"
        value={input}
        onChange={e => setInput(e.target.value)}
        onKeyDown={e => e.key === 'Enter' && send()}
        placeholder="Type a message!..."
        style={{ width: '100%', padding: 8, marginTop: 8 }}
      />
      <button onClick={send} disabled={!input.trim()} style={{ marginTop: 8 }}>
        Send
      </button>
    </div>
  );
}