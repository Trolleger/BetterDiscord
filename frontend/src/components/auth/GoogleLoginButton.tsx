import React from 'react';

export const GoogleLoginButton: React.FC = () => {
  const handleGoogleLogin = () => {
    window.location.href = `${import.meta.env.VITE_API_BASE_URL}/auth/google`;
  };

  return (
    <button onClick={handleGoogleLogin} className="google-login-btn">
      Login with Google
    </button>
  );
};
