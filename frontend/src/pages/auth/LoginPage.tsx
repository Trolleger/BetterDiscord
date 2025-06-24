import { useEffect, useState } from "react";
import { GoogleLoginButton } from "../../components/auth/GoogleLoginButton";
import { pingBackend } from "../../features/auth/authAPI";

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:4000';

export function LoginPage() {
    const [msg, setMsg] = useState("Loading...");

    useEffect(() => {
        // Add your side-effect here if needed
    }, []);

    return (
        <div>
            <h1>Login Page</h1>
            <GoogleLoginButton apiBaseUrl={`${API_BASE_URL}/auth/google/callback`} />
            <p>Backend status: {msg}</p>
        </div>
    );
}