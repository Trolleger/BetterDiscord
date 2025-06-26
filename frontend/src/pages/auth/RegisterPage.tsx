import { useState } from "react";
import { useNavigate } from "react-router-dom";
import axios from "axios";

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL;

export function RegisterPage() {
  const [email, setEmail] = useState("");
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

  const handleRegister = async (e: React.FormEvent) => {
    e.preventDefault();
    setError("");
    setLoading(true);

    try {
      // Your backend expects user object, and endpoint is /api/register
      await axios.post(`${API_BASE_URL}/api/register`, {
        user: {
          email,
          username,
          password,
        }
      });
      
      alert("Registered successfully! Please log in.");
      navigate("/login");
    } catch (err: any) {
      console.log("Registration error:", err);
      let errorMessage = "Registration failed";

      if (err.response?.status === 422 && err.response?.data?.errors) {
        // Handle Ecto changeset errors from FallbackController
        const errors = err.response.data.errors;
        const errorMessages = Object.entries(errors).map(([field, messages]) =>
          `${field}: ${Array.isArray(messages) ? messages.join(', ') : messages}`
        );
        errorMessage = errorMessages.join('; ');
      } else if (err.response?.data?.error) {
        errorMessage = err.response.data.error;
      } else if (err.response?.status === 422) {
        errorMessage = "Please check your input and try again";
      }

      setError(errorMessage);
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleRegister}>
      <h1>Register</h1>
      {error && <p style={{ color: "red" }}>{error}</p>}

      <input
        type="email"
        placeholder="Email"
        value={email}
        onChange={(e) => setEmail(e.target.value)}
        required
      />
      
      <input
        type="text"
        placeholder="Username (3-30 chars)"
        value={username}
        onChange={(e) => setUsername(e.target.value)}
        required
        minLength={3}
        maxLength={30}
      />
      
      <input
        type="password"
        placeholder="Password (min 8 chars)"
        value={password}
        onChange={(e) => setPassword(e.target.value)}
        required
        minLength={8}
      />
      
      <button type="submit" disabled={loading}>
        {loading ? "Registering..." : "Register"}
      </button>
    </form>
  );
}