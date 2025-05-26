const API_URL = "http://localhost:4000";

export async function pingBackend() {
  try {
    const res = await fetch(`${API_URL}/api/status`);
    return await res.json();
  } catch (e) {
    return { error: "Backend not reachable" };
  }
}