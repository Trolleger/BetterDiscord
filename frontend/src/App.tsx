import { BrowserRouter as Router, Routes, Route, Navigate, useNavigate } from 'react-router-dom';
import { AuthProvider, ProtectedRoute } from './features/auth/auth';
import { LoginPage } from './pages/auth/LoginPage';
import { RegisterPage } from './pages/auth/RegisterPage';
import { ChannelsPage } from './pages/channels/ChannelsPage';
import { LandingPage } from './pages/LandingPage/LandingPage';
import { setNavigateFunction } from './features/auth/api';
import { useEffect } from 'react';

function AppRoutes() {
  const navigate = useNavigate();
  
  useEffect(() => {
    setNavigateFunction(navigate);
  }, [navigate]);

  return (
    <Routes>
      <Route path="/" element={<LandingPage />} />
      <Route path="/login" element={<LoginPage />} />
      <Route path="/register" element={<RegisterPage />} />
      <Route path="/app" element={<Navigate to="/channels/@me" replace />} />
      <Route path="/channels" element={<Navigate to="/channels/@me" replace />} />
      <Route
        path="/channels/*"
        element={
          <ProtectedRoute>
            <ChannelsPage />
          </ProtectedRoute>
        }
      />
    </Routes>
  );
}

function App() {
  return (
    <AuthProvider>
      <Router>
        <AppRoutes />
      </Router>
    </AuthProvider>
  );
}

export default App;