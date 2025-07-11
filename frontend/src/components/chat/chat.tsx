import React, { useEffect, useState, useRef } from 'react';
import remarkBreaks from 'remark-breaks';
import ReactMarkdown from 'react-markdown';
// @ts-ignore
import { connectSocket } from '../../features/chat/socket/user_socket';

interface Message {
  body: string;
  timestamp: string;
}

export function Chat() {
  // Refs and state
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const containerRef = useRef<HTMLDivElement>(null);
  const channelRef = useRef<any>(null);
  const socketRef = useRef<any>(null);
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState('');

  // Socket logic
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

  // Auto-scroll to bottom
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  const sendMessage = () => {
    if (!input.trim() || !channelRef.current) return;

    channelRef.current.push("new_msg", { body: input.trim() });
    setInput('');
  };

  const handleKeyDown = (e: React.KeyboardEvent<HTMLTextAreaElement>) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      sendMessage();
    }
  };

  return (
    <div style={{ maxWidth: 600, margin: '0 auto', padding: 16 }}>
      <div
        ref={containerRef}
        style={{
          height: 400,
          overflowY: 'auto',
          border: '1px solid #ddd',
          padding: 10,
          backgroundColor: '#f9f9f9'
        }}
      >
        {messages.map((msg, i) => (
          <div key={i} style={{ marginBottom: 12 }}>
            <div style={{
              lineHeight: 1.4,
              fontSize: 14
            }}>
              <ReactMarkdown
                remarkPlugins={[remarkBreaks]}
                components={{
                  p: ({ children }) => <span>{children}</span>,
                  code: ({ children }) => (
                    <code style={{
                      backgroundColor: '#f4f4f4',
                      padding: '2px 4px',
                      borderRadius: '3px',
                      fontFamily: 'monospace'
                    }}>
                      {children}
                    </code>
                  ),
                  pre: ({ children }) => (
                    <pre style={{
                      backgroundColor: '#f4f4f4',
                      padding: '8px',
                      borderRadius: '4px',
                      overflow: 'auto',
                      margin: '4px 0'
                    }}>
                      {children}
                    </pre>
                  )
                }}
              >
                {msg.body}
              </ReactMarkdown>

            </div>
            <div style={{ fontSize: 12, color: '#666', marginTop: 4 }}>
              {msg.timestamp}
            </div>
          </div>
        ))}
        <div ref={messagesEndRef} />
      </div>

      <div style={{ marginTop: 8, fontSize: 12, color: '#666' }}>
        Supports full markdown: **bold**, *italic*, `code`, ```code blocks```, links, lists, etc.
      </div>

      <textarea
        value={input}
        onChange={(e) => setInput(e.target.value)}
        onKeyDown={handleKeyDown}
        placeholder="Type markdown... (Shift+Enter for new line)"
        style={{
          width: '100%',
          padding: 8,
          marginTop: 4,
          minHeight: 80,
          resize: 'vertical',
          fontFamily: 'inherit'
        }}
      />

      <button
        onClick={sendMessage}
        disabled={!input.trim()}
        style={{
          marginTop: 8,
          padding: 8,
          backgroundColor: input.trim() ? '#4CAF50' : '#ccc',
          color: 'white',
          border: 'none',
          borderRadius: 4
        }}
      >
        Send
      </button>
    </div>
  );
}