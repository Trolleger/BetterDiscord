import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider, ProtectedRoute } from './features/auth/auth';
import { LoginPage } from './pages/auth/LoginPage';
import { RegisterPage } from './pages/auth/RegisterPage';
import { ChannelsPage } from './pages/channels/ChannelsPage';
import { LandingPage } from './pages/LandingPage/LandingPage';

function App() {
  return (
    <AuthProvider>
      <Router>
        <Routes>
          <Route path="/" element={<LandingPage />} />
          <Route path="/login" element={<LoginPage />} />
          <Route path="/register" element={<RegisterPage />} />

          {/* Redirect /app to @me */}
          <Route path="/app" element={<Navigate to="/channels/@me" replace />} />

          {/* Protected channel routes */}
          <Route
            path="/channels/:id"
            element={
              <ProtectedRoute>
                <ChannelsPage />
              </ProtectedRoute>
            }
          />
        </Routes>
      </Router>
    </AuthProvider>
  );
}

export default App;
