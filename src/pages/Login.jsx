import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext.jsx";

export default function Login() {
  const { login } = useAuth();
  const nav = useNavigate();
  const [username, setUsername] = useState("ghanem");
  const [password, setPassword] = useState("azerty");
  const [error, setError] = useState("");

  const onSubmit = (e) => {
    e.preventDefault();
    const res = login(username, password);
    if (res.ok) nav("/");
    else setError(res.message || "Erreur login");
  };

  return (
    <div className="container" style={{ paddingTop: 40 }}>
      <div className="card" style={{ maxWidth: 560, margin: "0 auto" }}>
        <h1 style={{ marginTop: 0 }}>Connexion</h1>
        <p className="muted">
          Projet E-Shop â€” <strong>Ghanem Bouchmel</strong>
        </p>

        <form onSubmit={onSubmit} className="grid">
          <label className="grid">
            <span>Login</span>
            <input value={username} onChange={(e) => setUsername(e.target.value)} placeholder="ghanem / ghanem2" />
          </label>

          <label className="grid">
            <span>Mot de passe</span>
            <input value={password} onChange={(e) => setPassword(e.target.value)} type="password" placeholder="azerty" />
          </label>

          {error && <div className="card" style={{ borderColor: "#ffb3b3", background: "#fff5f5" }}>{error}</div>}

          <button className="btnDark" type="submit">Se connecter</button>

          <div className="muted" style={{ fontSize: 13 }}>
            Admin: <code>ghanem</code> / <code>azerty</code> â€” Client: <code>ghanem2</code> / <code>azerty</code>
          </div>
        </form>
      </div>
    </div>
  );
}