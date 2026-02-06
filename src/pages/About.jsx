import React from "react";

export default function About() {
  return (
    <div className="container">
      <div className="card">
        <h1 style={{ marginTop: 0 }}>About (Lazy Loaded)</h1>
        <p className="muted">Cette page est chargÃ©e en lazy via React.lazy + Suspense.</p>
        <p>Nom: <strong>Ghanem Bouchmel</strong></p>
      </div>
    </div>
  );
}
