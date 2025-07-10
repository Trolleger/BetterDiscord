const BACKEND_URL = import.meta.env.VITE_API_BASE_URL || "http://localhost:4000";

export async function fetchSocketToken(accessToken: string): Promise<string | null> {
    // Async, takes in the JWT string, returns string (phoenix token) either null
  try {
    const response = await fetch(`${BACKEND_URL}/api/socket-token`, {
        // Calls the backend api
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${accessToken}`,
        'Content-Type': 'application/json'
      },
      credentials: 'include' // include cookies if needed for refresh flow
    });
    // Makes a GET request it sends the JWT as a Bearer token in the Authorization header , Content type is just for safety, credentials include just includes cookies

    if (!response.ok) {
      console.error('Failed to fetch socket token');
      return null;
    }
    // Just some error checking
    const data = await response.json();
    return data.token;
    // Parses the JSON response and returns the phoenix token field
  } catch (err) {
    console.error('Error fetching socket token:', err);
    return null;
    // Catches any network or unexpected errors and fails gracefully.
  }
}
