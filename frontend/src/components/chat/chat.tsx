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
 // Refs and state
 const messagesEndRef = useRef<HTMLDivElement>(null);
 const containerRef = useRef<HTMLDivElement>(null);
 const channelRef = useRef<any>(null);
 const socketRef = useRef<any>(null);
 const [messages, setMessages] = useState<Message[]>([]);
 const [input, setInput] = useState('');
 const [allowStyling, setAllowStyling] = useState(false);
 const [alertMessage, setAlertMessage] = useState<string | null>(null);

 // 2. AUTO-DISMISS ALERTS
 useEffect(() => {
   if (alertMessage) {
     const timer = setTimeout(() => setAlertMessage(null), 3000);
     return () => clearTimeout(timer);
   }
 }, [alertMessage]);

 // 3. SOCKET LOGIC (UNCHANGED)
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
     channelRef.current?.leave();
     socketRef.current?.disconnect();
   };
 }, [allowStyling]);

 // 4. MESSAGE SENDING WITH STYLE BLOCKING
 const sendMessage = () => {
   if (!input.trim() || !channelRef.current) return;

   let clean = input.trim();
   
   if (allowStyling) {
     const blocked: string[] = [];
     const temp = document.createElement('div');
     temp.innerHTML = input.trim();
     
     temp.querySelectorAll('[style]').forEach(el => {
       const styleAttr = el.getAttribute('style') || '';
       const allowedStyles: string[] = [];
       
       styleAttr.split(';').forEach(decl => {
         const [prop, value] = decl.split(':').map(s => s.trim());
         if (prop && value) {
           if (ALLOWED_STYLES.includes(prop.toLowerCase())) {
             allowedStyles.push(decl);
           } else {
             blocked.push(prop.toLowerCase());
           }
         }
       });
       
       el.setAttribute('style', allowedStyles.join(';'));
     });
     
     clean = temp.innerHTML;
     
     if (blocked.length) {
       setAlertMessage(`Blocked styles: ${[...new Set(blocked)].join(', ')}`);
     }
   }

   // Send message
   setMessages(prev => [...prev, {
     body: clean,
     timestamp: new Date().toLocaleTimeString(),
     stylingEnabled: allowStyling
   }]);
   channelRef.current.push("new_msg", { body: clean });
   setInput('');
 };

 // 5. RENDER
 return (
   <div style={{ maxWidth: 600, margin: '0 auto', padding: 16 }}>
     <div
       ref={containerRef}
       style={{ height: 400, overflowY: 'auto', border: '1px solid #ddd', padding: 10 }}
     >
       {messages.map((msg, i) => (
         <div key={i}>
           {msg.stylingEnabled ? (
             <span dangerouslySetInnerHTML={{ __html: msg.body }} />
           ) : (
             <span>{msg.body}</span>
           )}
         </div>
       ))}
       <div ref={messagesEndRef} />
     </div>

     {alertMessage && (
       <div style={{ background: '#fee', padding: 8, margin: '8px 0' }}>
         {alertMessage}
       </div>
     )}

     <input
       type="text"
       value={input}
       onChange={(e) => setInput(e.target.value)}
       onKeyDown={(e) => e.key === 'Enter' && sendMessage()}
       style={{ width: '100%', padding: 8 }}
     />

     <button
       onClick={() => setAllowStyling(!allowStyling)}
       style={{
         display: 'block',
         marginTop: 8,
         padding: 8,
         background: allowStyling ? '#4CAF50' : '#f44336',
         color: 'white'
       }}
     >
       {allowStyling ? 'Styled Mode' : 'Plain Mode'}
     </button>
   </div>
 );
}