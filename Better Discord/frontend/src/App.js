import { jsx as _jsx } from "react/jsx-runtime";
import { useEffect, useState } from "react";
import { pingBackend } from "./api";
function App() {
    const [msg, setMsg] = useState("");
    useEffect(() => {
        pingBackend().then((data) => {
            if (data.message)
                setMsg(data.message);
            else
                setMsg(JSON.stringify(data));
        });
    }, []);
    return (_jsx("div", { className: "p-6 text-white bg-black min-h-screen" }));
}
export default App;
