import React from "react";
import { useParams } from "react-router-dom";
import { useSelector, useDispatch } from "react-redux";
import { selectProductById } from "../features/products/productsSlice";
import { addToCart } from "../features/cart/cartSlice";

export default function ProductDetail() {
  const { id } = useParams();
  const p = useSelector((s) => selectProductById(s, id));
  const dispatch = useDispatch();

  if (!p) {
    return (
      <div className="container">
        <div className="card">
          <h1 style={{ marginTop: 0 }}>Produit introuvable</h1>
        </div>
      </div>
    );
  }

  return (
    <div className="container">
      <div className="card">
        <h1 style={{ marginTop: 0 }}>{p.title}</h1>
        <p className="muted">Ghanem Bouchmel</p>

        <div className="grid2">
          <img src={p.image} alt={p.title} style={{ width: "100%", borderRadius: 12, border: "1px solid #eee" }} />
          <div>
            <div className="badge">{p.category}</div>
            <p style={{ marginTop: 10 }}>{p.description}</p>
            <p><strong>Prix:</strong> {p.price} DT</p>
            <p><strong>Stock:</strong> {p.stock}</p>
            <button className="btnDark" onClick={() => dispatch(addToCart(p))}>Ajouter au panier</button>
          </div>
        </div>
      </div>
    </div>
  );
}