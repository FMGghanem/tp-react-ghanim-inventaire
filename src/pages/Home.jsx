import React, { useMemo, useState } from "react";
import { useSelector, useDispatch } from "react-redux";
import { selectAllProducts } from "../features/products/productsSlice";
import { addToCart } from "../features/cart/cartSlice";
import { Link } from "react-router-dom";
import { useTheme } from "../context/ThemeContext.jsx";

export default function Home() {
  const all = useSelector(selectAllProducts);
  const dispatch = useDispatch();
  const { theme } = useTheme();

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
        <h1 style={{ marginTop: 0 }}>Catalogue</h1>
        <p className="muted">E-shop rÃ©aliste avec produits (PC, TÃ©lÃ©phone, Accessoires). â€” <strong>Ghanem Bouchmel</strong></p>

        <div className="row">
          <input placeholder="Rechercher..." value={q} onChange={(e) => setQ(e.target.value)} />
          <select value={cat} onChange={(e) => setCat(e.target.value)}>
            {categories.map((c) => <option key={c} value={c}>{c}</option>)}
          </select>
          <span className="badge">ThÃ¨me: {theme}</span>
        </div>
      </div>

      <div className="gridProducts">
        {filtered.map((p) => (
          <div className="card" key={p.id}>
            <img src={p.image} alt={p.title} style={{ width: "100%", borderRadius: 12, border: "1px solid #eee" }} />
            <div style={{ marginTop: 10 }}>
              <strong>{p.title}</strong>
              <div className="muted">{p.category} â€¢ Stock: {p.stock}</div>
              <div style={{ marginTop: 6 }}><strong>{p.price} DT</strong></div>

              <div className="row" style={{ marginTop: 10 }}>
                <Link className="btn" to={`/p/${p.id}`}>DÃ©tails</Link>
                <button className="btnDark" onClick={() => dispatch(addToCart(p))}>Ajouter</button>
              </div>
            </div>
          </div>
        ))}
        {filtered.length === 0 && <div className="card muted">Aucun rÃ©sultat.</div>}
      </div>
    </div>
  );
}