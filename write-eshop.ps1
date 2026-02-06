$ErrorActionPreference = "Stop"
Set-Location (Get-Location)

function Write-FileNoBom([string]$path, [string]$content) {
  $dir = Split-Path $path -Parent
  if ($dir -and !(Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }

  $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText((Join-Path (Get-Location) $path), $content, $utf8NoBom)
  Write-Host "wrote $path"
}

# Folders
$folders = @(
  "src",
  "src\app",
  "src\components",
  "src\context",
  "src\features\products",
  "src\features\cart",
  "src\pages",
  "src\pages\admin"
)
New-Item -ItemType Directory -Force -Path $folders | Out-Null

# ---------------------------
# Redux store
# ---------------------------
Write-FileNoBom "src/app/store.js" @'
import { configureStore } from "@reduxjs/toolkit";
import productsReducer from "../features/products/productsSlice";
import cartReducer from "../features/cart/cartSlice";

export const store = configureStore({
  reducer: {
    products: productsReducer,
    cart: cartReducer,
  },
});
'@

# ---------------------------
# Auth (2 users, 2 roles)
# ---------------------------
Write-FileNoBom "src/context/AuthContext.jsx" @'
import React, { createContext, useContext, useEffect, useMemo, useState } from "react";

const AuthCtx = createContext(null);

const USERS = [
  { username: "ghanem", password: "azerty", role: "admin", displayName: "Ghanem Bouchmel" },
  { username: "ghanem2", password: "azerty", role: "client", displayName: "Ghanem Bouchmel" },
];

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);

  useEffect(() => {
    const raw = localStorage.getItem("eshop_user");
    if (raw) setUser(JSON.parse(raw));
  }, []);

  const login = (username, password) => {
    const found = USERS.find(
      (u) => u.username === username.trim() && u.password === password
    );
    if (!found) return { ok: false, message: "Identifiants invalides." };

    const safeUser = { username: found.username, role: found.role, displayName: found.displayName };
    setUser(safeUser);
    localStorage.setItem("eshop_user", JSON.stringify(safeUser));
    return { ok: true, user: safeUser };
  };

  const logout = () => {
    setUser(null);
    localStorage.removeItem("eshop_user");
  };

  const value = useMemo(() => ({ user, login, logout }), [user]);
  return <AuthCtx.Provider value={value}>{children}</AuthCtx.Provider>;
}

export function useAuth() {
  return useContext(AuthCtx);
}
'@

# ---------------------------
# Theme
# ---------------------------
Write-FileNoBom "src/context/ThemeContext.jsx" @'
import React, { createContext, useContext, useMemo, useState } from "react";

const ThemeCtx = createContext(null);

export function ThemeProvider({ children }) {
  const [theme, setTheme] = useState("clair");
  const toggleTheme = () => setTheme((t) => (t === "clair" ? "sombre" : "clair"));
  const value = useMemo(() => ({ theme, toggleTheme }), [theme]);
  return <ThemeCtx.Provider value={value}>{children}</ThemeCtx.Provider>;
}

export function useTheme() {
  return useContext(ThemeCtx);
}
'@

# ---------------------------
# Products slice (placeholder items)
# ---------------------------
Write-FileNoBom "src/features/products/productsSlice.js" @'
import { createSlice } from "@reduxjs/toolkit";

const initialState = {
  items: [
    { id: 1, title: "PC Portable Lenovo i5", price: 2499, category: "PC", stock: 7, description: "Portable polyvalent pour travail et études.", image: "https://via.placeholder.com/420x260?text=PC+Lenovo" },
    { id: 2, title: "Téléphone Samsung A54", price: 1299, category: "Téléphone", stock: 12, description: "Bon appareil photo + autonomie.", image: "https://via.placeholder.com/420x260?text=Samsung+A54" },
    { id: 3, title: "iPhone 13 (reconditionné)", price: 1899, category: "Téléphone", stock: 4, description: "Reconditionné, garanti, très bon état.", image: "https://via.placeholder.com/420x260?text=iPhone+13" },
    { id: 4, title: "Casque Bluetooth JBL", price: 199, category: "Accessoires", stock: 20, description: "Son clair, confortable.", image: "https://via.placeholder.com/420x260?text=Casque+JBL" },
    { id: 5, title: "Souris Logitech MX", price: 169, category: "Accessoires", stock: 15, description: "Précision + ergonomie.", image: "https://via.placeholder.com/420x260?text=Souris+Logitech" },
    { id: 6, title: "Écran 27 pouces IPS", price: 699, category: "PC", stock: 6, description: "Confort visuel, parfait pour dev.", image: "https://via.placeholder.com/420x260?text=Ecran+27" },
  ],
};

const productsSlice = createSlice({
  name: "products",
  initialState,
  reducers: {
    adminAddProduct: (state, action) => {
      state.items.unshift(action.payload);
    },
    adminDeleteProduct: (state, action) => {
      const id = action.payload;
      state.items = state.items.filter((p) => p.id !== id);
    },
    adminUpdateProduct: (state, action) => {
      const updated = action.payload;
      const idx = state.items.findIndex((p) => p.id === updated.id);
      if (idx !== -1) state.items[idx] = { ...state.items[idx], ...updated };
    },
    adminAdjustStock: (state, action) => {
      const { id, delta } = action.payload;
      const p = state.items.find((x) => x.id === id);
      if (!p) return;
      p.stock = Math.max(0, Number(p.stock) + Number(delta));
    },
  },
});

export const {
  adminAddProduct,
  adminDeleteProduct,
  adminUpdateProduct,
  adminAdjustStock,
} = productsSlice.actions;

export const selectAllProducts = (state) => state.products.items;
export const selectProductById = (state, id) =>
  state.products.items.find((p) => String(p.id) === String(id));

export default productsSlice.reducer;
'@

# ---------------------------
# Cart slice
# ---------------------------
Write-FileNoBom "src/features/cart/cartSlice.js" @'
import { createSlice } from "@reduxjs/toolkit";

const initialState = {
  items: [], // {id,title,price,quantity}
};

const cartSlice = createSlice({
  name: "cart",
  initialState,
  reducers: {
    addToCart: (state, action) => {
      const p = action.payload;
      const existing = state.items.find((i) => i.id === p.id);
      if (existing) existing.quantity += 1;
      else state.items.push({ id: p.id, title: p.title, price: p.price, quantity: 1 });
    },
    decreaseQty: (state, action) => {
      const id = action.payload;
      const existing = state.items.find((i) => i.id === id);
      if (!existing) return;
      if (existing.quantity > 1) existing.quantity -= 1;
      else state.items = state.items.filter((i) => i.id !== id);
    },
    removeFromCart: (state, action) => {
      const id = action.payload;
      state.items = state.items.filter((i) => i.id !== id);
    },
    clearCart: (state) => {
      state.items = [];
    },
  },
});

export const { addToCart, decreaseQty, removeFromCart, clearCart } = cartSlice.actions;

export const selectCartItems = (state) => state.cart.items;
export const selectCartCount = (state) => state.cart.items.reduce((sum, i) => sum + i.quantity, 0);
export const selectCartTotal = (state) => state.cart.items.reduce((sum, i) => sum + i.price * i.quantity, 0);

export default cartSlice.reducer;
'@

# ---------------------------
# Routing guards
# ---------------------------
Write-FileNoBom "src/components/ProtectedRoute.jsx" @'
import React from "react";
import { Navigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext.jsx";

export default function ProtectedRoute({ children }) {
  const { user } = useAuth();
  if (!user) return <Navigate to="/login" replace />;
  return children;
}
'@

Write-FileNoBom "src/components/RoleRoute.jsx" @'
import React from "react";
import { Navigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext.jsx";

export default function RoleRoute({ allow, children }) {
  const { user } = useAuth();
  if (!user) return <Navigate to="/login" replace />;
  if (!allow.includes(user.role)) return <Navigate to="/" replace />;
  return children;
}
'@

# ---------------------------
# UI Header + Banner
# ---------------------------
Write-FileNoBom "src/components/AppHeader.jsx" @'
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
            {user && <span className="badge">Rôle: {user.role}</span>}
            <span className="badge">Thème: {theme}</span>
          </div>
          <div className="row">
            <button className="btn" onClick={toggleTheme}>Changer thème</button>
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
'@

# ---------------------------
# Pages
# ---------------------------
Write-FileNoBom "src/pages/Login.jsx" @'
import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext.jsx";

export default function Login() {
  const { login } = useAuth();
  const nav = useNavigate();
  const [username, setUsername] = useState("ghanem");
  const [password, setPassword] = useState("azerty");
  const [error, setError] = useState("");

  const onSubmit = (e) => {
    e.preventDefault();
    const res = login(username, password);
    if (res.ok) nav("/");
    else setError(res.message || "Erreur login");
  };

  return (
    <div className="container" style={{ paddingTop: 40 }}>
      <div className="card" style={{ maxWidth: 560, margin: "0 auto" }}>
        <h1 style={{ marginTop: 0 }}>Connexion</h1>
        <p className="muted">
          Projet E-Shop — <strong>Ghanem Bouchmel</strong>
        </p>

        <form onSubmit={onSubmit} className="grid">
          <label className="grid">
            <span>Login</span>
            <input value={username} onChange={(e) => setUsername(e.target.value)} placeholder="ghanem / ghanem2" />
          </label>

          <label className="grid">
            <span>Mot de passe</span>
            <input value={password} onChange={(e) => setPassword(e.target.value)} type="password" placeholder="azerty" />
          </label>

          {error && <div className="card" style={{ borderColor: "#ffb3b3", background: "#fff5f5" }}>{error}</div>}

          <button className="btnDark" type="submit">Se connecter</button>

          <div className="muted" style={{ fontSize: 13 }}>
            Admin: <code>ghanem</code> / <code>azerty</code> — Client: <code>ghanem2</code> / <code>azerty</code>
          </div>
        </form>
      </div>
    </div>
  );
}
'@

Write-FileNoBom "src/pages/Home.jsx" @'
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
        <p className="muted">E-shop réaliste avec produits (PC, Téléphone, Accessoires). — <strong>Ghanem Bouchmel</strong></p>

        <div className="row">
          <input placeholder="Rechercher..." value={q} onChange={(e) => setQ(e.target.value)} />
          <select value={cat} onChange={(e) => setCat(e.target.value)}>
            {categories.map((c) => <option key={c} value={c}>{c}</option>)}
          </select>
          <span className="badge">Thème: {theme}</span>
        </div>
      </div>

      <div className="gridProducts">
        {filtered.map((p) => (
          <div className="card" key={p.id}>
            <img src={p.image} alt={p.title} style={{ width: "100%", borderRadius: 12, border: "1px solid #eee" }} />
            <div style={{ marginTop: 10 }}>
              <strong>{p.title}</strong>
              <div className="muted">{p.category} • Stock: {p.stock}</div>
              <div style={{ marginTop: 6 }}><strong>{p.price} DT</strong></div>

              <div className="row" style={{ marginTop: 10 }}>
                <Link className="btn" to={`/p/${p.id}`}>Détails</Link>
                <button className="btnDark" onClick={() => dispatch(addToCart(p))}>Ajouter</button>
              </div>
            </div>
          </div>
        ))}
        {filtered.length === 0 && <div className="card muted">Aucun résultat.</div>}
      </div>
    </div>
  );
}
'@

Write-FileNoBom "src/pages/ProductDetail.jsx" @'
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
'@

Write-FileNoBom "src/pages/Cart.jsx" @'
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
              <th>Qté</th>
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
'@

Write-FileNoBom "src/pages/Orders.jsx" @'
import React from "react";

export default function Orders() {
  return (
    <div className="container">
      <div className="card">
        <h1 style={{ marginTop: 0 }}>Mes commandes</h1>
        <p className="muted">Placeholder — Ghanem Bouchmel</p>
        <ul>
          <li>CMD-001 — En cours</li>
          <li>CMD-002 — Livrée</li>
        </ul>
      </div>
    </div>
  );
}
'@

Write-FileNoBom "src/pages/admin/AdminHome.jsx" @'
import React from "react";

export default function AdminHome() {
  return (
    <div className="container">
      <div className="card">
        <h1 style={{ marginTop: 0 }}>Admin Dashboard</h1>
        <p className="muted">Gestion produits / stock — <strong>Ghanem Bouchmel</strong></p>
        <ul>
          <li>Ajouter / Modifier / Supprimer produit</li>
          <li>Ajuster le stock</li>
        </ul>
      </div>
    </div>
  );
}
'@

Write-FileNoBom "src/pages/admin/AdminProducts.jsx" @'
import React, { useMemo, useState } from "react";
import { useDispatch, useSelector } from "react-redux";
import { adminAddProduct, adminAdjustStock, adminDeleteProduct, adminUpdateProduct, selectAllProducts } from "../../features/products/productsSlice";

export default function AdminProducts() {
  const items = useSelector(selectAllProducts);
  const dispatch = useDispatch();

  const [editId, setEditId] = useState(null);
  const [form, setForm] = useState({ title: "", price: 0, category: "PC", stock: 0, description: "", image: "" });

  const categories = useMemo(() => ["PC", "Téléphone", "Accessoires"], []);

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
      description: form.description.trim() || "Produit ajouté par admin.",
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
        <h1 style={{ marginTop: 0 }}>Admin • Produits</h1>
        <p className="muted">CRUD Admin — Ghanem Bouchmel</p>

        <form className="grid" onSubmit={submit} style={{ marginTop: 10 }}>
          <div className="grid2">
            <label className="grid">
              <span>Titre</span>
              <input value={form.title} onChange={(e) => setForm((f) => ({ ...f, title: e.target.value }))} />
            </label>

            <label className="grid">
              <span>Catégorie</span>
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
            <button className="btnDark" type="submit">{editId ? "Mettre à jour" : "Ajouter"}</button>
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
'@

Write-FileNoBom "src/pages/NotFound.jsx" @'
import React from "react";
import { Link } from "react-router-dom";

export default function NotFound() {
  return (
    <div className="container">
      <div className="card">
        <h1 style={{ marginTop: 0 }}>404</h1>
        <p className="muted">Page introuvable — Ghanem Bouchmel</p>
        <Link to="/" className="btn">Retour accueil</Link>
      </div>
    </div>
  );
}
'@

# ---------------------------
# App router
# ---------------------------
Write-FileNoBom "src/App.jsx" @'
import React from "react";
import { Navigate, Route, Routes } from "react-router-dom";

import AppHeader from "./components/AppHeader.jsx";
import ProtectedRoute from "./components/ProtectedRoute.jsx";
import RoleRoute from "./components/RoleRoute.jsx";

import Login from "./pages/Login.jsx";
import Home from "./pages/Home.jsx";
import ProductDetail from "./pages/ProductDetail.jsx";
import Cart from "./pages/Cart.jsx";
import Orders from "./pages/Orders.jsx";
import NotFound from "./pages/NotFound.jsx";

import AdminHome from "./pages/admin/AdminHome.jsx";
import AdminProducts from "./pages/admin/AdminProducts.jsx";

function Shell({ children }) {
  return (
    <>
      <AppHeader />
      {children}
      <footer className="container" style={{ paddingBottom: 28 }}>
        <div className="muted" style={{ fontSize: 12 }}>© E-Shop — <strong>Ghanem Bouchmel</strong></div>
      </footer>
    </>
  );
}

export default function App() {
  return (
    <Routes>
      <Route path="/login" element={<Login />} />

      <Route path="/" element={
        <ProtectedRoute>
          <Shell><Home /></Shell>
        </ProtectedRoute>
      } />

      <Route path="/p/:id" element={
        <ProtectedRoute>
          <Shell><ProductDetail /></Shell>
        </ProtectedRoute>
      } />

      <Route path="/cart" element={
        <ProtectedRoute>
          <Shell><Cart /></Shell>
        </ProtectedRoute>
      } />

      <Route path="/orders" element={
        <ProtectedRoute>
          <Shell><Orders /></Shell>
        </ProtectedRoute>
      } />

      <Route path="/admin" element={
        <RoleRoute allow={["admin"]}>
          <Shell><AdminHome /></Shell>
        </RoleRoute>
      } />

      <Route path="/admin/products" element={
        <RoleRoute allow={["admin"]}>
          <Shell><AdminProducts /></Shell>
        </RoleRoute>
      } />

      <Route path="/home" element={<Navigate to="/" replace />} />
      <Route path="*" element={
        <ProtectedRoute>
          <Shell><NotFound /></Shell>
        </ProtectedRoute>
      } />
    </Routes>
  );
}
'@

# ---------------------------
# main.jsx
# ---------------------------
Write-FileNoBom "src/main.jsx" @'
import React from "react";
import ReactDOM from "react-dom/client";
import { BrowserRouter } from "react-router-dom";
import { Provider } from "react-redux";
import { store } from "./app/store";
import { AuthProvider } from "./context/AuthContext.jsx";
import { ThemeProvider } from "./context/ThemeContext.jsx";
import App from "./App.jsx";
import "./index.css";

ReactDOM.createRoot(document.getElementById("root")).render(
  <React.StrictMode>
    <Provider store={store}>
      <AuthProvider>
        <ThemeProvider>
          <BrowserRouter>
            <App />
          </BrowserRouter>
        </ThemeProvider>
      </AuthProvider>
    </Provider>
  </React.StrictMode>
);
'@

# ---------------------------
# CSS
# ---------------------------
Write-FileNoBom "src/index.css" @'
:root { font-family: system-ui, Arial, sans-serif; }
body { margin: 0; background: #f6f7fb; color: #111; }

.container { max-width: 1100px; margin: 0 auto; padding: 16px; }
.card { background: white; border: 1px solid #e9e9ef; border-radius: 14px; padding: 16px; }
.row { display: flex; gap: 10px; align-items: center; flex-wrap: wrap; }
.grid { display: grid; gap: 12px; }
.grid2 { display: grid; gap: 12px; grid-template-columns: repeat(2, minmax(0, 1fr)); }
@media (max-width: 850px) { .grid2 { grid-template-columns: 1fr; } }

.gridProducts { margin-top: 12px; display: grid; gap: 12px; grid-template-columns: repeat(auto-fit, minmax(260px, 1fr)); }

.muted { color: #555; }
.badge { border: 1px solid #111; border-radius: 999px; padding: 4px 10px; font-size: 12px; }

.table { width: 100%; border-collapse: collapse; }
.table th, .table td { border-bottom: 1px solid #eee; padding: 10px; text-align: left; vertical-align: top; }

input, select, button { padding: 10px; border-radius: 10px; border: 1px solid #ddd; }
button { cursor: pointer; background: #fff; }

.btn { text-decoration: none; display: inline-flex; align-items: center; justify-content: center; padding: 10px 12px; border-radius: 10px; border: 1px solid #111; color: #111; background: #fff; }
.btnDark { padding: 10px 12px; border-radius: 10px; border: 1px solid #111; color: #fff; background: #111; }

.header { position: sticky; top: 0; z-index: 10; background: #ffffffcc; backdrop-filter: blur(8px); border-bottom: 1px solid #eee; }
.banner { background: #fff; border-bottom: 1px solid #eee; }
.space { justify-content: space-between; }

.nav { text-decoration: none; padding: 8px 12px; border-radius: 999px; border: 1px solid #111; color: #111; }
.navActive { background: #111; color: #fff; }
code { background: #f1f1f1; padding: 2px 6px; border-radius: 6px; }
'@

Write-Host "`n✅ E-shop code generated." -ForegroundColor Green
Write-Host "Next:" -ForegroundColor Cyan
Write-Host "  npm install" -ForegroundColor Cyan
Write-Host "  npm run dev" -ForegroundColor Cyan
Write-Host "`nUsers:" -ForegroundColor Yellow
Write-Host "  Admin  : ghanem / azerty" -ForegroundColor Yellow
Write-Host "  Client : ghanem2 / azerty" -ForegroundColor Yellow
