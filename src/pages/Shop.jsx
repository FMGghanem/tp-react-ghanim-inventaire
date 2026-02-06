import React, { useMemo, useState } from "react";
import { useDispatch, useSelector } from "react-redux";
import { selectAllProducts } from "../features/products/productsSlice";
import { addToCart } from "../features/cart/cartSlice";

export default function Shop() {
  const all = useSelector(selectAllProducts);
  const dispatch = useDispatch();

  const [q, setQ] = useState("");
  const [cat, setCat] = useState("Tous");

  const categories = useMemo(() => ["Tous", ...Array.from(new Set(all.map((p) => p.category)))], [all]);

  const filtered = useMemo(() => {
    return all.filter((p) => {
      const okQ = p.title.toLowerCase().includes(q.toLowerCase());
      const okC = cat === "Tous" ? true : p.category === cat;
      return okQ && okC;
    });
  }, [all, q, cat]);

  return (
    <div className="container">
      <div className="card">
        <h1 style={{ marginTop: 0 }}>Redux Shop (Catalogue)</h1>
        <p className="muted">Ajout au panier via Redux Toolkit. Nom: <strong>Ghanem Bouchmel</strong></p>

        <div className="row" style={{ marginTop: 8 }}>
          <input placeholder="Rechercher..." value={q} onChange={(e) => setQ(e.target.value)} />
          <select value={cat} onChange={(e) => setCat(e.target.value)}>
            {categories.map((c) => <option key={c} value={c}>{c}</option>)}
          </select>
        </div>
      </div>

      <div className="container" style={{ paddingTop: 12 }}>
        <div className="kpi">
          {filtered.map((p) => (
            <div className="card" key={p.id}>
              <strong>{p.title}</strong>
              <div className="muted">{p.category}</div>
              <div style={{ marginTop: 6 }}><strong>{p.price} DT</strong></div>
              <button style={{ marginTop: 10 }} onClick={() => dispatch(addToCart(p))}>
                Ajouter au panier
              </button>
            </div>
          ))}
          {filtered.length === 0 && <div className="card muted">Aucun rÃ©sultat.</div>}
        </div>
      </div>
    </div>
  );
}
