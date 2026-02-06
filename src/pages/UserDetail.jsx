import React from "react";
import { useNavigate, useParams } from "react-router-dom";

export default function UserDetail() {
  const { id } = useParams();
  const nav = useNavigate();

  return (
    <div className="container">
      <div className="card">
        <h1 style={{ marginTop: 0 }}>DÃ©tails utilisateur</h1>
        <p className="muted">Nom: <strong>Ghanem Bouchmel</strong></p>
        <p>Identifiant: <strong>{id}</strong></p>
        <button onClick={() => nav(-1)}>Retour</button>
      </div>
    </div>
  );
}
