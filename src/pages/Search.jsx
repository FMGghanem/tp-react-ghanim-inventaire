import React, { useMemo } from "react";
import { useSearchParams } from "react-router-dom";

export default function Search() {
  const [params, setParams] = useSearchParams();

  const q = params.get("q") || "";
  const sort = params.get("sort") || "asc";

  const results = useMemo(() => {
    const base = ["react", "redux", "router", "hooks", "vite", "jsx", "lazy"];
    const filtered = base.filter((x) => x.includes(q.toLowerCase()));
    const sorted = [...filtered].sort();
    return sort === "desc" ? sorted.reverse() : sorted;
  }, [q, sort]);

  return (
    <div className="container">
      <div className="card">
        <h1 style={{ marginTop: 0 }}>Search (Query Params)</h1>
        <p className="muted">Nom: <strong>Ghanem Bouchmel</strong></p>

        <div className="row">
          <input value={q} onChange={(e) => setParams({ q: e.target.value, sort })} placeholder="q=..." />
          <select value={sort} onChange={(e) => setParams({ q, sort: e.target.value })}>
            <option value="asc">asc</option>
            <option value="desc">desc</option>
          </select>
        </div>

        <div style={{ marginTop: 12 }}>
          <strong>URL actuelle:</strong> <span className="muted">/search?q={q}&sort={sort}</span>
        </div>

        <ul>
          {results.map((r) => <li key={r}>{r}</li>)}
          {results.length === 0 && <li className="muted">Aucun rÃ©sultat.</li>}
        </ul>
      </div>
    </div>
  );
}
