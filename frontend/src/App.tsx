import { BrowserRouter, Routes, Route } from "react-router-dom";
import { LoginPage } from "./pages/auth/LoginPage";
import { RegisterPage } from "./pages/auth/RegisterPage";

function HomePage() {
  return (
    <div>
      <h1>Welcome to Better Discord</h1>
      <a href="/login">Go to Login</a>
      <br></br>
      <a href="/register">Go to register</a>
    </div>
  );
}

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login"  element={<LoginPage />} />
        <Route path="/register" element={<RegisterPage />} />
        <Route path="/" element={<HomePage />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;