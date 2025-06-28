import { useState, useCallback } from "react";
import { useNavigate, Navigate } from "react-router-dom";
import { useAuth } from "../../features/auth/auth";
import api from "../../features/auth/api";

export function LoginPage() {
  const [emailOrUsername, setEmailOrUsername] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();
  const { login, isAuthenticated } = useAuth();

  // Prevent navigation if already authenticated and avoid re-render loops
  if (isAuthenticated) {
    return <Navigate to="/channels/@me" replace />;
  }

  // Use useCallback to prevent unnecessary re-renders
  const onEmailOrUsernameChange = useCallback((e: React.ChangeEvent<HTMLInputElement>) => {
    setEmailOrUsername(e.target.value);
    // Only clear error if there actually is one
    if (error) setError("");
  }, [error]);

  const onPasswordChange = useCallback((e: React.ChangeEvent<HTMLInputElement>) => {
    setPassword(e.target.value);
    // Only clear error if there actually is one
    if (error) setError("");
  }, [error]);

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();
    
    // Prevent multiple submissions
    if (loading) return;
    
    setLoading(true);
    setError(""); // Clear any existing errors
    
    try {
      const res = await api.post("/api/login", {
        user: { login: emailOrUsername, password },
      });
      
      await login(res.data.access_token);
      
      // Use replace to prevent back navigation to login
      navigate("/channels/@me", { replace: true });
    } catch (err: any) {
      // Ensure we're still on the login page before setting error
      if (err.response?.status === 422 || err.response?.status === 401) {
        setError("Invalid email/username or password");
      } else if (err.response?.data?.error) {
        setError(err.response.data.error);
      } else {
        setError("Login failed. Please try again.");
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <div>
      <form onSubmit={handleLogin}>
        <h1>Login</h1>
        {error && (
          <div style={{ 
            color: "red", 
            marginBottom: "10px",
            padding: "8px",
            backgroundColor: "#ffeaea",
            border: "1px solid #ffcaca",
            borderRadius: "4px"
          }}>
            {error}
          </div>
        )}
        <input
          type="text"
          placeholder="Email or Username"
          value={emailOrUsername}
          onChange={onEmailOrUsernameChange}
          required
          disabled={loading}
          autoComplete="username"
        />
        <input
          type="password"
          placeholder="Password"
          value={password}
          onChange={onPasswordChange}
          required
          disabled={loading}
          autoComplete="current-password"
        />
        <button type="submit" disabled={loading || !emailOrUsername.trim() || !password.trim()}>
          {loading ? "Logging in..." : "Login"}
        </button>
      </form>
    </div>
  );
}