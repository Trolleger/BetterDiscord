import React from 'react';

interface GoogleLoginButtonProps {
  apiBaseUrl: string;
}

export const GoogleLoginButton: React.FC<GoogleLoginButtonProps> = ({ apiBaseUrl }) => {
  const handleGoogleLogin = () => {
    // Redirect to the backend's Google OAuth endpoint
    window.location.href = `${apiBaseUrl}/auth/google`;
  };

  return (
    <button onClick={handleGoogleLogin} className="google-login-btn">
      Login with Google
    </button>
  );
};