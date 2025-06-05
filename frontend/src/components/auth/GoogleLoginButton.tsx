import React from 'react';

interface GoogleLoginButtonProps {
  apiBaseUrl: string;
}

export const GoogleLoginButton: React.FC<GoogleLoginButtonProps> = ({ apiBaseUrl }) => {
  const handleGoogleLogin = () => {
    // Fixed: Call the REQUEST endpoint, not the callback
    window.location.href = `http://localhost:4000/auth/google`;
  };

  return (
    <button onClick={handleGoogleLogin} className="google-login-btn">
      Login with Google
    </button>
  );
};