import { useState } from "react";
import { useNavigate } from "react-router-dom";
import axios from "axios";

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL

export function RegisterPage() {
    const [email, setEmail] = useState("");
    const [username, setUsername] = useState("");
    const [password, setPassword] = useState("");
    const [error, setError] = useState("");
    const [loading, setLoading] = useState(false);
    const navigate = useNavigate();
    
    // Setting states and vars
    const handleRegister = async (e: React.FormEvent) => {
        // E Is short for event
        e.preventDefault();
        // Preventing reload of page when doing the form
        setError("");
        setLoading(true);
        // Set's a blank state for when user is doing the log
        
        // Sends registration data to backend and waits for response
        try {
            await axios.post(`${API_BASE_URL}/api/users`, {
                email,
                username,
                password,
            })
            alert("Registered successfully! Please log in.");
            navigate("/login");
            // If it works right it just alerts the user the login worked and navigates to login
        } catch (err: any) {
            console.log("Full error:", err);
            console.log("Error response:", err.response?.data);
            
            // Handle different types of errors from the backend
            let errorMessage = "Registration failed";
            
            if (err.response?.data?.errors) {
                // Handle validation errors from your fallback controller
                const errors = err.response.data.errors;
                const errorMessages = Object.entries(errors).map(([field, messages]) => 
                    `${field}: ${Array.isArray(messages) ? messages.join(', ') : messages}`
                );
                errorMessage = errorMessages.join('; ');
            } else if (err.response?.data?.error) {
                errorMessage = err.response.data.error;
            }
            
            setError(errorMessage);
            // If there is any error just returns the error
        } finally {
            setLoading(false);
        }
    }
    
    return (
        // All the code for the form
        <form onSubmit={handleRegister}>
            <h1>Register</h1>
            {error && <p style={{ color: "red" }}>{error}</p>}
            {/* If there is an error it will put it here with some styling */}
            
            {/* (e.target.value) is grabbing what the user typed into an input field. */}
            {/* In other words // onChange handlers update React state with input values */}
            <input
                type="email"
                placeholder="Email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
            />
            <input
                type="text"
                placeholder="Username"
                value={username}
                onChange={(e) => setUsername(e.target.value)}
                required
            />
            <input
                type="password"
                placeholder="Password (min 8 chars)"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
            />
            <button type="submit" disabled={loading}>
                {loading ? "Registering..." : "Register"}
            </button>
            {/* A button which is disabled while loading, while it is loading it says Registering and once it's done it switches back to register */}
            {/* So once you press submit it sends all those values in and the axios post from above takes it and sends it to the backend */}
        </form>
    );
}