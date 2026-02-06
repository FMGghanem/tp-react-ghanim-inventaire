import React from "react";
import { Link } from "react-router-dom";

const FAKE = [
  { id: "1", name: "Alice", email: "alice@example.com" },
  { id: "2", name: "Bob", email: "bob@example.com" },
  { id: "3", name: "Charlie", email: "charlie@example.com" },
];

export default function Users() {
  return (
    <div className="container">
      <div className="card">
        <h1 style={{ marginTop: 0 }}>Users (Route Params)</h1>
        <p className="muted">Nom: <strong>Ghanem Bouchmel</strong></p>
        <ul className="grid">
          {FAKE.map((u) => (
            <li key={u.id}>
              <Link to={/users/} style={{ textDecoration: "underline" }}>{u.name}</Link>
              <div className="muted" style={{ fontSize: 12 }}>{u.email}</div>
            </li>
          ))}
        </ul>
      </div>
    </div>
  );
}
