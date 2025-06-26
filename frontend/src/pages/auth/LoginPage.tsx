import { useState } from "react";
import { useNavigate } from "react-router-dom";
import axios from "axios";

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL;

export function LoginPage() {
  const [emailOrUsername, setEmailOrUsername] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    setLoading(true);

    try {
      const res = await axios.post(`${API_BASE_URL}/api/login`, {
        user: { login: emailOrUsername, password }
      });
      
      const token = res.data.access_token;
      localStorage.setItem("access_token", token);
      
      navigate("/app");
    } catch (err: any) {
      console.log("Login error:", err);
      let errorMessage = "Login failed";
      
      if (err.response?.data?.error) {
        errorMessage = err.response.data.error;
      } else if (err.response?.status === 422) {
        errorMessage = "Invalid email/username or password";
      } else if (err.response?.status === 401) {
        errorMessage = "Invalid credentials";
      }
      
      setError(errorMessage);
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleLogin}>
      <h1>Login</h1>
      {error && <p style={{ color: "red" }}>{error}</p>}
      
      <input
        type="text"
        name="email-or-username" // Prevents browser autocomplete confusion
        placeholder="Email or Username"
        value={emailOrUsername}
        onChange={(e) => setEmailOrUsername(e.target.value)}
        autoComplete="username" // Standard autocomplete hint
        required
      />
      
      <input
        type="password"
        name="password"
        placeholder="Password"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
        autoComplete="current-password"
        required
      />
      
      <button type="submit" disabled={loading}>
        {loading ? "Logging in..." : "Login"}
      </button>
    </form>
  );
}