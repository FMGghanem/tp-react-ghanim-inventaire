import React, { useMemo, useState } from "react";
import { useDispatch, useSelector } from "react-redux";
import { adminAddProduct, adminAdjustStock, adminDeleteProduct, adminUpdateProduct, selectAllProducts } from "../../features/products/productsSlice";

export default function AdminProducts() {
  const items = useSelector(selectAllProducts);
  const dispatch = useDispatch();

  const [editId, setEditId] = useState(null);
  const [form, setForm] = useState({ title: "", price: 0, category: "PC", stock: 0, description: "", image: "" });

  const categories = useMemo(() => ["PC", "TÃ©lÃ©phone", "Accessoires"], []);

  const reset = () => {
    setEditId(null);
    setForm({ title: "", price: 0, category: "PC", stock: 0, description: "", image: "" });
  };

  const submit = (e) => {
    e.preventDefault();
    const payload = {
      id: editId ?? Date.now(),
      title: form.title.trim(),
      price: Number(form.price),
      category: form.category,
      stock: Number(form.stock),
      description: form.description.trim() || "Produit ajoutÃ© par admin.",
      image: form.image.trim() || "https://via.placeholder.com/420x260?text=Produit",
    };
    if (!payload.title) return;

    if (editId) dispatch(adminUpdateProduct(payload));
    else dispatch(adminAddProduct(payload));

    reset();
  };

  const startEdit = (p) => {
    setEditId(p.id);
    setForm({ title: p.title, price: p.price, category: p.category, stock: p.stock, description: p.description, image: p.image });
  };

  return (
    <div className="container">
      <div className="card">
        <h1 style={{ marginTop: 0 }}>Admin â€¢ Produits</h1>
        <p className="muted">CRUD Admin â€” Ghanem Bouchmel</p>

        <form className="grid" onSubmit={submit} style={{ marginTop: 10 }}>
          <div className="grid2">
            <label className="grid">
              <span>Titre</span>
              <input value={form.title} onChange={(e) => setForm((f) => ({ ...f, title: e.target.value }))} />
            </label>

            <label className="grid">
              <span>CatÃ©gorie</span>
              <select value={form.category} onChange={(e) => setForm((f) => ({ ...f, category: e.target.value }))}>
                {categories.map((c) => <option key={c} value={c}>{c}</option>)}
              </select>
            </label>
          </div>

          <div className="grid2">
            <label className="grid">
              <span>Prix (DT)</span>
              <input type="number" value={form.price} onChange={(e) => setForm((f) => ({ ...f, price: e.target.value }))} />
            </label>

            <label className="grid">
              <span>Stock</span>
              <input type="number" value={form.stock} onChange={(e) => setForm((f) => ({ ...f, stock: e.target.value }))} />
            </label>
          </div>

          <label className="grid">
            <span>Image URL (optionnel)</span>
            <input value={form.image} onChange={(e) => setForm((f) => ({ ...f, image: e.target.value }))} />
          </label>

          <label className="grid">
            <span>Description</span>
            <input value={form.description} onChange={(e) => setForm((f) => ({ ...f, description: e.target.value }))} />
          </label>

          <div className="row">
            <button className="btnDark" type="submit">{editId ? "Mettre Ã  jour" : "Ajouter"}</button>
            {editId && <button className="btn" type="button" onClick={reset}>Annuler</button>}
          </div>
        </form>
      </div>

      <div className="card" style={{ marginTop: 12 }}>
        <table className="table">
          <thead>
            <tr>
              <th>Produit</th>
              <th>Cat.</th>
              <th>Prix</th>
              <th>Stock</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {items.map((p) => (
              <tr key={p.id}>
                <td>{p.title}</td>
                <td>{p.category}</td>
                <td>{p.price} DT</td>
                <td>{p.stock}</td>
                <td className="row">
                  <button className="btn" onClick={() => startEdit(p)}>Modifier</button>
                  <button className="btn" onClick={() => dispatch(adminDeleteProduct(p.id))}>Supprimer</button>
                  <button className="btn" onClick={() => dispatch(adminAdjustStock({ id: p.id, delta: +1 }))}>+Stock</button>
                  <button className="btn" onClick={() => dispatch(adminAdjustStock({ id: p.id, delta: -1 }))}>-Stock</button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}