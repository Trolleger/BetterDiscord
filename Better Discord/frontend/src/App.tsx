import { useEffect, useState } from "react";
import { pingBackend } from "./api";

function App() {
  const [msg, setMsg] = useState("");

  useEffect(() => {
    pingBackend().then((data) => {
      if (data.message) setMsg(data.message);
      else setMsg(JSON.stringify(data));
    });
  }, []);

  return (
    <div className="p-6 text-white bg-black min-h-screen">

    </div>
  );
}

export default App;
