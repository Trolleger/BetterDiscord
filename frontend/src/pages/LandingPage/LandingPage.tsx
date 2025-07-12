import { useNavigate } from "react-router-dom";

export function LandingPage() {
  const navigate = useNavigate();
  
  return (
    <div>
      <h1>Welcome to ChatApp</h1>
      <button onClick={() => navigate("/login")}>Login</button>
      <button onClick={() => navigate("/register")}>Register</button>
    </div>
  );
}