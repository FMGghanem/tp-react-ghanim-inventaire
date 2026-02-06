import React from "react";

export default function AdminHome() {
  return (
    <div className="container">
      <div className="card">
        <h1 style={{ marginTop: 0 }}>Admin Dashboard</h1>
        <p className="muted">Gestion produits / stock â€” <strong>Ghanem Bouchmel</strong></p>
        <ul>
          <li>Ajouter / Modifier / Supprimer produit</li>
          <li>Ajuster le stock</li>
        </ul>
      </div>
    </div>
  );
}