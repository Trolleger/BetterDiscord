import { BrowserRouter, Routes, Route, Link } from "react-router-dom";
import { LoginPage } from "./pages/auth/LoginPage";
import { RegisterPage } from "./pages/auth/RegisterPage";
import { MainPage } from "./pages/app/MainPage"; // Your main app page after login

function HomePage() {
  return (
    <div>
      <h1>Welcome to Better Discord</h1>
      <Link to="/login">Go to Login</Link>
      <br />
      <Link to="/register">Go to Register</Link>
    </div>
  );
}

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<HomePage />} />
        <Route path="/login" element={<LoginPage />} />
        <Route path="/register" element={<RegisterPage />} />
        <Route path="/app" element={<MainPage />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;