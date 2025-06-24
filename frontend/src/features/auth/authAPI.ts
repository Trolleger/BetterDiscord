const API_URL = import.meta.env.VITE_API_BASE_URL

export async function pingBackend() {
  try {
    const res = await fetch(`${API_URL}/api/status`);
    return await res.json();
  } catch (e) {
    return { error: "Backend not reachable" };
  }
}
