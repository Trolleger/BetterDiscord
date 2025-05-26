import React from "react";

export const GoogleLoginButton = () => {
  return (
    <a
      href="http://localhost:4000/auth/google"
      style={{
        display: "inline-block",
        padding: "10px 20px",
        backgroundColor: "#4285F4",
        color: "white",
        borderRadius: 4,
        textDecoration: "none",
        fontWeight: "bold",
        fontFamily: "Arial, sans-serif",
        cursor: "pointer",
      }}
    >
      Login with Google
    </a>
  );
};
