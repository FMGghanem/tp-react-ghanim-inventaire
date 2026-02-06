import React from "react";
import { useDispatch, useSelector } from "react-redux";
import { clearCart, decreaseQty, removeFromCart, selectCartItems, selectCartTotal } from "../features/cart/cartSlice";

export default function Cart() {
  const items = useSelector(selectCartItems);
  const total = useSelector(selectCartTotal);
  const dispatch = useDispatch();

  return (
    <div className="container">
      <div className="card">
        <h1 style={{ marginTop: 0 }}>Panier</h1>
        <p className="muted">Ghanem Bouchmel</p>

        <div className="row">
          <strong>Total:</strong> {total} DT
          <button className="btn" onClick={() => dispatch(clearCart())}>Vider</button>
        </div>
      </div>

      <div className="card" style={{ marginTop: 12 }}>
        <table className="table">
          <thead>
            <tr>
              <th>Produit</th>
              <th>Prix</th>
              <th>QtÃ©</th>
              <th>Sous-total</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {items.map((i) => (
              <tr key={i.id}>
                <td>{i.title}</td>
                <td>{i.price} DT</td>
                <td>{i.quantity}</td>
                <td>{i.price * i.quantity} DT</td>
                <td className="row">
                  <button className="btn" onClick={() => dispatch(decreaseQty(i.id))}>-</button>
                  <button className="btn" onClick={() => dispatch(removeFromCart(i.id))}>Supprimer</button>
                </td>
              </tr>
            ))}
            {items.length === 0 && (
              <tr><td colSpan="5" className="muted">Panier vide.</td></tr>
            )}
          </tbody>
        </table>
      </div>

      <div className="card" style={{ marginTop: 12 }}>
        <p className="muted">
          (Simple) Pour une vraie commande, on ajouterait un slice "orders" + paiement.
        </p>
      </div>
    </div>
  );
}