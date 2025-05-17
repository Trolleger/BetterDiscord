const API_URL = "http://backend:4000"; // Docker service name

export async function pingBackend() {
  const res = await fetch(`${API_URL}/api/status`);
  return res.json();
}
