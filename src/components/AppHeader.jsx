import React from "react";
import { NavLink, useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext.jsx";
import { useTheme } from "../context/ThemeContext.jsx";
import { useSelector } from "react-redux";
import { selectCartCount } from "../features/cart/cartSlice";

function Nav({ to, children }) {
  return (
    <NavLink
      to={to}
      end
      className={({ isActive }) => "nav " + (isActive ? "navActive" : "")}
    >
      {children}
    </NavLink>
  );
}

export default function AppHeader() {
  const { user, logout } = useAuth();
  const { theme, toggleTheme } = useTheme();
  const cartCount = useSelector(selectCartCount);
  const nav = useNavigate();

  return (
    <header className="header">
      <div className="banner">
        <div className="container row space">
          <div className="row">
            <strong style={{ fontSize: 16 }}>E-Shop Demo</strong>
            <span className="badge">Ghanem Bouchmel</span>
            {user && <span className="badge">RÃ´le: {user.role}</span>}
            <span className="badge">ThÃ¨me: {theme}</span>
          </div>
          <div className="row">
            <button className="btn" onClick={toggleTheme}>Changer thÃ¨me</button>
            {user && (
              <button
                className="btnDark"
                onClick={() => {
                  logout();
                  nav("/login");
                }}
              >
                Logout
              </button>
            )}
          </div>
        </div>
      </div>

      {user && (
        <div className="container row" style={{ paddingTop: 10, paddingBottom: 10 }}>
          <nav className="row">
            <Nav to="/">Accueil</Nav>
            <Nav to="/cart">Panier ({cartCount})</Nav>
            <Nav to="/orders">Mes commandes</Nav>
            {user.role === "admin" && (
              <>
                <Nav to="/admin">Admin</Nav>
                <Nav to="/admin/products">Produits</Nav>
              </>
            )}
          </nav>
        </div>
      )}
    </header>
  );
}