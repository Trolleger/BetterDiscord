  import React, { useEffect, useState, useRef } from 'react';
  // @ts-ignore
  import { connectSocket } from '../../features/chat/socket/user_socket';

  interface Message {
    body: string;
    timestamp: string;
  }

  export function Chat() {
    const messagesEndRef = useRef<HTMLDivElement>(null);
    const channelRef = useRef<any>(null);
    const [messages, setMessages] = useState<Message[]>([]);
    const [input, setInput] = useState('');

    useEffect(() => {
      const initSocket = async () => {
        const jwtAccessToken = localStorage.getItem('access_token');
        const socket = await connectSocket(jwtAccessToken);
        
        const channel = socket.channel("room:lobby", {});
        
        interface ChannelJoinOkResponse {
          // Add any properties provided by the "ok" response if needed
        }
        interface ChannelJoinErrorResponse {
          // Add any properties provided by the "error" response if needed
          message?: string;
        }
        
        channel.join()
          .receive("ok", (response: ChannelJoinOkResponse): void => console.log("Joined lobby"))
          .receive("error", (err: ChannelJoinErrorResponse): void => console.error("Unable to join lobby", err));
        
        channel.on("new_msg", (payload: { body: string }) => {
          setMessages(prev => [...prev, { body: payload.body, timestamp: new Date().toLocaleTimeString() }]);
        });
        
        channelRef.current = channel;
      };

      initSocket();

      return () => {
        if (channelRef.current) {
          channelRef.current.leave();
        }
      };
    }, []);

    useEffect(() => {
      messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
    }, [messages]);

    const send = () => {
      if (input.trim() && channelRef.current) {
        channelRef.current.push("new_msg", { body: input.trim() });
        setInput('');
      }
    };

    return (
      <div>
        <div style={{ height: 400, overflowY: 'auto', border: '1px solid #ccc', padding: 10, backgroundColor: '#f9f9f9' }}>
          {messages.map((msg, i) => <p key={i}>[{msg.timestamp}] {msg.body}</p>)}
          <div ref={messagesEndRef} />
        </div>
        <input
          type="text"
          value={input}
          onChange={e => setInput(e.target.value)}
          onKeyDown={e => e.key === 'Enter' && send()}
          placeholder="Type a message..."
          style={{ width: '100%', padding: 8, marginTop: 8 }}
        />
        <button onClick={send} disabled={!input.trim()} style={{ marginTop: 8 }}>Send</button>
      </div>
    );
  }