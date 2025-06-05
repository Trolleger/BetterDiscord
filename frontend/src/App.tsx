import { useEffect, useState } from "react";
import { GoogleLoginButton } from "./components/auth/GoogleLoginButton";
import { pingBackend } from "./api";

function App() {
  const [msg, setMsg] = useState("");

  useEffect(() => {
    pingBackend().then((data) => {
      if (data.message) {
        setMsg(data.message);
      } else if (data && Object.keys(data).length > 0) {
        setMsg(JSON.stringify(data));
      } else {
        setMsg(""); // no message, no curly braces
      }
    }).catch(() => {
      setMsg("Failed to contact backend");
    });
  }, []);

  return (
    <div className="p-6 text-white bg-black min-h-screen flex flex-col items-center justify-center">
      <div className="mb-4">
        <GoogleLoginButton apiBaseUrl="http://localhost:4000/auth/google/callback" />
      </div>
      <p className="mt-4 text-center">{msg}</p>
    </div>
  );
}

export default App;
