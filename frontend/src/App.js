import React, { useEffect, useState } from "react";

function App() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    // Use relative URL for API calls (will be proxied by nginx)
    const apiUrl = process.env.REACT_APP_API_URL || "/api";
    
    fetch(apiUrl)
      .then((res) => {
        if (!res.ok) {
          throw new Error(`HTTP error! status: ${res.status}`);
        }
        return res.json();
      })
      .then((data) => {
        setData(data);
        setLoading(false);
      })
      .catch((err) => {
        console.error("Error fetching data:", err);
        setError(err.message);
        setLoading(false);
      });
  }, []);

  if (loading) {
    return (
      <div style={styles.container}>
        <div style={styles.card}>
          <h2 style={styles.loading}>Loading...</h2>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div style={styles.container}>
        <div style={styles.card}>
          <h2 style={styles.error}>Error: {error}</h2>
        </div>
      </div>
    );
  }

  return (
    <div style={styles.container}>
      <div style={styles.card}>
        <h1 style={styles.title}>DevOps Assessment</h1>
        <h2 style={styles.subtitle}>Full-Stack Application</h2>
        <div style={styles.divider}></div>
        <h3 style={styles.dataTitle}>Response from Backend:</h3>
        <pre style={styles.pre}>{JSON.stringify(data, null, 2)}</pre>
        <div style={styles.info}>
          <p>Frontend: React.js</p>
          <p>Backend: Node.js + Express</p>
          <p>Monitoring: Prometheus + Grafana</p>
        </div>
      </div>
    </div>
  );
}

const styles = {
  container: {
    minHeight: "100vh",
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    background: "linear-gradient(135deg, #667eea 0%, #764ba2 100%)",
    padding: "20px",
  },
  card: {
    background: "white",
    borderRadius: "16px",
    padding: "40px",
    boxShadow: "0 20px 60px rgba(0, 0, 0, 0.3)",
    maxWidth: "500px",
    width: "100%",
    textAlign: "center",
  },
  title: {
    margin: "0 0 8px 0",
    color: "#333",
    fontSize: "28px",
    fontWeight: "700",
  },
  subtitle: {
    margin: "0",
    color: "#666",
    fontSize: "16px",
    fontWeight: "400",
  },
  divider: {
    height: "2px",
    background: "linear-gradient(90deg, #667eea, #764ba2)",
    margin: "24px 0",
    borderRadius: "2px",
  },
  dataTitle: {
    color: "#444",
    fontSize: "18px",
    marginBottom: "16px",
  },
  pre: {
    background: "#f5f5f5",
    padding: "16px",
    borderRadius: "8px",
    textAlign: "left",
    overflow: "auto",
    fontSize: "14px",
    color: "#333",
  },
  info: {
    marginTop: "24px",
    padding: "16px",
    background: "#f0f4ff",
    borderRadius: "8px",
    textAlign: "left",
    fontSize: "14px",
    color: "#555",
  },
  loading: {
    color: "#667eea",
  },
  error: {
    color: "#e53e3e",
  },
};

export default App;
