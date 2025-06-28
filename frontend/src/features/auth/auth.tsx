import { createContext, useContext, useState, useEffect, ReactNode, useCallback, useMemo } from "react";
import { Navigate } from "react-router-dom";
import api from "./api";

interface User {
  id: string;
  email: string;
  username: string;
  // Add other user properties as needed
}

interface AuthContextType {
  user: User | null;
  loading: boolean;
  login: (token: string) => Promise<void>;
  logout: () => void;
  isAuthenticated: boolean;
  error: string | null;
  clearError: () => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const clearError = useCallback(() => {
    setError(null);
  }, []);

  const checkAuth = useCallback(async () => {
    const token = localStorage.getItem("access_token");
    if (!token) {
      setLoading(false);
      return;
    }

    try {
      const response = await api.get("/api/profile");
      setUser(response.data.user);
      setError(null);
    } catch (err: any) {
      console.warn("Auth check failed:", err.message);
      localStorage.removeItem("access_token");
      setUser(null);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    checkAuth();
  }, [checkAuth]);

  const login = useCallback(async (token: string) => {
    setLoading(true);
    setError(null);
    
    try {
      localStorage.setItem("access_token", token);
      const response = await api.get("/api/profile");
      setUser(response.data.user);
    } catch (error: any) {
      localStorage.removeItem("access_token");
      setUser(null);
      setError("Failed to authenticate user");
      throw error;
    } finally {
      setLoading(false);
    }
  }, []);

  const logout = useCallback(() => {
    setLoading(true);
    localStorage.removeItem("access_token");
    setUser(null);
    setError(null);
    
    api.delete("/api/logout").catch((err) => {
      console.warn("Logout API call failed:", err.message);
    }).finally(() => {
      setLoading(false);
    });
  }, []);

  // MEMOIZE THE CONTEXT VALUE - this was the missing piece!
  const contextValue = useMemo(() => ({
    user,
    loading,
    login,
    logout,
    isAuthenticated: !!user && !loading,
    error,
    clearError,
  }), [user, loading, login, logout, error, clearError]);

  return (
    <AuthContext.Provider value={contextValue}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error("useAuth must be used within AuthProvider");
  }
  return context;
}

export function ProtectedRoute({ children }: { children: ReactNode }) {
  const { isAuthenticated, loading } = useAuth();
  
  if (loading) {
    return (
      <div style={{ 
        display: 'flex', 
        justifyContent: 'center', 
        alignItems: 'center', 
        height: '100vh' 
      }}>
        Loading...
      </div>
    );
  }
  
  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }
  
  return <>{children}</>;
}