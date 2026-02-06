import React, { useMemo, useState } from "react";
import { useDispatch, useSelector } from "react-redux";
import { addProduct, deleteProduct, selectInventoryProducts, updateProduct } from "../features/inventory/inventorySlice";

export default function Inventory() {
  const products = useSelector(selectInventoryProducts);
  const dispatch = useDispatch();

  const [form, setForm] = useState({ name: "", quantity: 0, price: 0 });
  const [editId, setEditId] = useState(null);

  const totalValue = useMemo(() => {
    return products.reduce((sum, p) => sum + Number(p.quantity) * Number(p.price), 0);
  }, [products]);

  const onSubmit = (e) => {
    e.preventDefault();
    const payload = {
      id: editId ?? Date.now(),
      name: form.name.trim(),
      quantity: Number(form.quantity),
      price: Number(form.price),
    };
    if (!payload.name) return;

    if (editId) dispatch(updateProduct(payload));
    else dispatch(addProduct(payload));

    setForm({ name: "", quantity: 0, price: 0 });
    setEditId(null);
  };

  const startEdit = (p) => {
    setEditId(p.id);
    setForm({ name: p.name, quantity: p.quantity, price: p.price });
  };

  return (
    <div className="container">
      <div className="grid">
        <div className="card">
          <h1 style={{ marginTop: 0 }}>Gestion d'inventaire (Redux Toolkit)</h1>
          <p className="muted">CRUD + calcul valeur totale.</p>
          <p className="muted">Nom : <strong>Ghanem Bouchmel</strong></p>

          <div className="card">
            <strong>Valeur totale stock:</strong> {totalValue} DT
          </div>

          <form onSubmit={onSubmit} className="row" style={{ marginTop: 12 }}>
            <input placeholder="Nom produit" value={form.name} onChange={(e) => setForm((f) => ({ ...f, name: e.target.value }))} />
            <input type="number" placeholder="QuantitÃ©" value={form.quantity} onChange={(e) => setForm((f) => ({ ...f, quantity: e.target.value }))} />
            <input type="number" placeholder="Prix" value={form.price} onChange={(e) => setForm((f) => ({ ...f, price: e.target.value }))} />
            <button style={{ padding: "8px 12px" }}>{editId ? "Mettre Ã  jour" : "Ajouter"}</button>
            {editId && (
              <button type="button" onClick={() => { setEditId(null); setForm({ name: "", quantity: 0, price: 0 }); }}>
                Annuler
              </button>
            )}
          </form>
        </div>

        <div className="card">
          <h2 style={{ marginTop: 0 }}>Liste des produits</h2>
          <table className="table">
            <thead>
              <tr>
                <th>Nom</th>
                <th>QuantitÃ©</th>
                <th>Prix</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {products.map((p) => (
                <tr key={p.id}>
                  <td>{p.name}</td>
                  <td>{p.quantity}</td>
                  <td>{p.price} DT</td>
                  <td className="row">
                    <button onClick={() => startEdit(p)}>Modifier</button>
                    <button onClick={() => dispatch(deleteProduct({ id: p.id }))}>Supprimer</button>
                  </td>
                </tr>
              ))}
              {products.length === 0 && (
                <tr><td colSpan="4" className="muted">Aucun produit.</td></tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
