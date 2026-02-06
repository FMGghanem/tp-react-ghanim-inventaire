import React from "react";
import { Link } from "react-router-dom";

export default function NotFound() {
  return (
    <div className="container">
      <div className="card">
        <h1 style={{ marginTop: 0 }}>404</h1>
        <p className="muted">Page introuvable â€” Ghanem Bouchmel</p>
        <Link to="/" className="btn">Retour accueil</Link>
      </div>
    </div>
  );
}