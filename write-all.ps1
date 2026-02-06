# write-all.ps1
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

function Write-File {
  param(
    [Parameter(Mandatory=$true)][string]$Path,
    [Parameter(Mandatory=$true)][string]$Content
  )
  $dir = Split-Path $Path -Parent
  if ($dir -and !(Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
  Set-Content -Path $Path -Value $Content -Encoding UTF8
  Write-Host "wrote $Path"
}

# --- folders ---
$folders = @(
  "src","src\app","src\components","src\context",
  "src\features\inventory","src\features\products","src\features\cart",
  "src\pages"
)
foreach ($f in $folders) { New-Item -ItemType Directory -Force -Path $f | Out-Null }

# --- src/app/store.js ---
Write-File "src/app/store.js" @"
import { configureStore } from "@reduxjs/toolkit";
import inventoryReducer from "../features/inventory/inventorySlice";
import productsReducer from "../features/products/productsSlice";
import cartReducer from "../features/cart/cartSlice";

export const store = configureStore({
  reducer: {
    inventory: inventoryReducer,
    products: productsReducer,
    cart: cartReducer,
  },
});
"@

# --- src/context/AuthContext.jsx ---
Write-File "src/context/AuthContext.jsx" @"
import React, { createContext, useContext, useEffect, useMemo, useState } from "react";

const AuthCtx = createContext(null);

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);

  useEffect(() => {
    const raw = localStorage.getItem("tp_user");
    if (raw) setUser(JSON.parse(raw));
  }, []);

  const login = (username, password) => {
    if (username === "ghanem" && password === "azerty") {
      const u = { username: "ghanem", displayName: "Ghanem Bouchmel" };
      setUser(u);
      localStorage.setItem("tp_user", JSON.stringify(u));
      return { ok: true };
    }
    return { ok: false, message: "Identifiants invalides" };
  };

  const logout = () => {
    setUser(null);
    localStorage.removeItem("tp_user");
  };

  const value = useMemo(() => ({ user, login, logout }), [user]);
  return <AuthCtx.Provider value={value}>{children}</AuthCtx.Provider>;
}

export function useAuth() {
  return useContext(AuthCtx);
}
"@

# --- src/context/ThemeContext.jsx ---
Write-File "src/context/ThemeContext.jsx" @"
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
"@

# --- inventory slice ---
Write-File "src/features/inventory/inventorySlice.js" @"
import { createSlice } from "@reduxjs/toolkit";

const initialState = {
  products: [
    { id: 1, name: "Chaise", quantity: 5, price: 50 },
    { id: 2, name: "Table", quantity: 3, price: 150 },
  ],
};

const inventorySlice = createSlice({
  name: "inventory",
  initialState,
  reducers: {
    addProduct: (state, action) => {
      state.products.push(action.payload);
    },
    deleteProduct: (state, action) => {
      const id = action.payload.id;
      state.products = state.products.filter((p) => p.id !== id);
    },
    updateProduct: (state, action) => {
      const updated = action.payload;
      const idx = state.products.findIndex((p) => p.id === updated.id);
      if (idx !== -1) state.products[idx] = { ...state.products[idx], ...updated };
    },
  },
});

export const { addProduct, deleteProduct, updateProduct } = inventorySlice.actions;
export const selectInventoryProducts = (state) => state.inventory.products;
export default inventorySlice.reducer;
"@

# --- products slice ---
Write-File "src/features/products/productsSlice.js" @"
import { createSlice } from "@reduxjs/toolkit";

const initialState = {
  items: [
    { id: 1, title: "Laptop Lenovo", price: 2500, category: "Informatique" },
    { id: 2, title: "Souris Sans Fil", price: 60, category: "Accessoires" },
    { id: 3, title: "Clavier Mécanique", price: 180, category: "Accessoires" },
    { id: 4, title: "Écran 24 pouces", price: 650, category: "Informatique" },
  ],
};

const productsSlice = createSlice({
  name: "products",
  initialState,
  reducers: {},
});

export const selectAllProducts = (state) => state.products.items;
export default productsSlice.reducer;
"@

# --- cart slice ---
Write-File "src/features/cart/cartSlice.js" @"
import { createSlice } from "@reduxjs/toolkit";

const initialState = { items: [] }; // {id,title,price,quantity}

const cartSlice = createSlice({
  name: "cart",
  initialState,
  reducers: {
    addToCart: (state, action) => {
      const product = action.payload;
      const existing = state.items.find((i) => i.id === product.id);
      if (existing) existing.quantity += 1;
      else state.items.push({ id: product.id, title: product.title, price: product.price, quantity: 1 });
    },
    removeFromCart: (state, action) => {
      const id = action.payload;
      state.items = state.items.filter((i) => i.id !== id);
    },
    decreaseQuantity: (state, action) => {
      const id = action.payload;
      const existing = state.items.find((i) => i.id === id);
      if (!existing) return;
      if (existing.quantity > 1) existing.quantity -= 1;
      else state.items = state.items.filter((i) => i.id !== id);
    },
    clearCart: (state) => {
      state.items = [];
    },
  },
});

export const { addToCart, removeFromCart, decreaseQuantity, clearCart } = cartSlice.actions;
export const selectCartItems = (state) => state.cart.items;
export const selectCartCount = (state) => state.cart.items.reduce((sum, i) => sum + i.quantity, 0);
export const selectCartTotal = (state) => state.cart.items.reduce((sum, i) => sum + i.price * i.quantity, 0);
export default cartSlice.reducer;
"@

# --- components ---
Write-File "src/components/ProtectedRoute.jsx" @"
import React from "react";
import { Navigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext.jsx";

export default function ProtectedRoute({ children }) {
  const { user } = useAuth();
  if (!user) return <Navigate to="/login" replace />;
  return children;
}
"@

Write-File "src/components/AppHeader.jsx" @"
import { NavLink, useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext.jsx";
import { useSelector } from "react-redux";
import { selectCartCount } from "../features/cart/cartSlice";
import { useTheme } from "../context/ThemeContext.jsx";

function Nav({ to, children }) {
  return (
    <NavLink
      to={to}
      end
      style={({ isActive }) => ({
        textDecoration: "none",
        padding: "8px 12px",
        borderRadius: 999,
        border: "1px solid #111",
        background: isActive ? "#111" : "transparent",
        color: isActive ? "#fff" : "#111",
      })}
    >
      {children}
    </NavLink>
  );
}

export default function AppHeader() {
  const { logout } = useAuth();
  const cartCount = useSelector(selectCartCount);
  const { theme, toggleTheme } = useTheme();
  const nav = useNavigate();

  return (
    <header style={{ position: "sticky", top: 0, zIndex: 10, backdropFilter: "blur(8px)", background: "#ffffffcc", borderBottom: "1px solid #eee" }}>
      <div className="container row" style={{ justifyContent: "space-between" }}>
        <div className="row">
          <strong style={{ fontSize: 16 }}>TP React - Inventaire & Shop</strong>
          <span className="badge">Ghanem Bouchmel</span>
          <span className="badge">Thème: {theme}</span>
          <button onClick={toggleTheme} style={{ padding: "7px 10px", borderRadius: 10, border: "1px solid #111", background: "white" }}>
            Changer thème
          </button>
        </div>

        <nav className="row">
          <Nav to="/dashboard">Dashboard</Nav>
          <Nav to="/inventory">Inventaire</Nav>
          <Nav to="/shop">Shop</Nav>
          <Nav to="/cart">Panier ({cartCount})</Nav>
          <Nav to="/search">Search</Nav>
          <Nav to="/users">Users</Nav>
          <Nav to="/about">About (lazy)</Nav>
          <button
            onClick={() => {
              logout();
              nav("/login");
            }}
            style={{ padding: "8px 12px", borderRadius: 10, border: "1px solid #111", background: "#111", color: "#fff" }}
          >
            Logout
          </button>
        </nav>
      </div>
    </header>
  );
}
"@

# --- pages ---
Write-File "src/pages/Login.jsx" @"
import React, { useState } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext.jsx";

export default function Login() {
  const [username, setUsername] = useState("ghanem");
  const [password, setPassword] = useState("azerty");
  const [error, setError] = useState("");
  const { login } = useAuth();
  const nav = useNavigate();

  const onSubmit = (e) => {
    e.preventDefault();
    const res = login(username.trim(), password);
    if (res.ok) nav("/dashboard");
    else setError(res.message || "Erreur login");
  };

  return (
    <div className="container" style={{ paddingTop: 40 }}>
      <div className="card grid" style={{ maxWidth: 520, margin: "0 auto" }}>
        <h1 style={{ margin: 0 }}>Connexion</h1>
        <p className="muted" style={{ marginTop: 0 }}>
          Projet TP React - <strong>Ghanem Bouchmel</strong>
        </p>

        <form onSubmit={onSubmit} className="grid">
          <label className="grid">
            <span>Login</span>
            <input value={username} onChange={(e) => setUsername(e.target.value)} placeholder="ghanem" />
          </label>
          <label className="grid">
            <span>Mot de passe</span>
            <input value={password} onChange={(e) => setPassword(e.target.value)} placeholder="azerty" type="password" />
          </label>

          {error && <div className="card" style={{ borderColor: "#ffb3b3", background: "#fff5f5" }}>{error}</div>}

          <button style={{ padding: 10, borderRadius: 10, border: "1px solid #111", background: "#111", color: "#fff" }}>
            Se connecter
          </button>

          <div className="muted" style={{ fontSize: 12 }}>
            Identifiants : <code>ghanem</code> / <code>azerty</code>
          </div>
        </form>
      </div>
    </div>
  );
}
"@

Write-File "src/pages/Dashboard.jsx" @"
import React, { useEffect, useMemo, useState } from "react";
import { useTheme } from "../context/ThemeContext.jsx";
import { useNavigate } from "react-router-dom";

export default function Dashboard() {
  const [counter, setCounter] = useState(0);
  const [seconds, setSeconds] = useState(0);
  const { theme } = useTheme();
  const nav = useNavigate();

  useEffect(() => {
    const t = setInterval(() => setSeconds((s) => s + 1), 1000);
    return () => clearInterval(t);
  }, []);

  useEffect(() => {
    document.title = `Dashboard - compteur ${counter}`;
  }, [counter]);

  const message = useMemo(() => {
    return counter >= 5 ? "Bravo, compteur >= 5 !" : "Augmente le compteur pour déclencher un message.";
  }, [counter]);

  const bg = theme === "clair" ? "#ffffff" : "#1d1d1d";
  const fg = theme === "clair" ? "#111" : "#fff";

  return (
    <div className="container">
      <div className="grid">
        <div className="card" style={{ background: bg, color: fg }}>
          <h1 style={{ marginTop: 0 }}>Dashboard</h1>
          <p className="muted">Nom affiché partout : <strong>Ghanem Bouchmel</strong></p>

          <div className="kpi">
            <div className="card">
              <div className="muted">Compteur (useState)</div>
              <strong>{counter}</strong>
              <div className="row">
                <button onClick={() => setCounter((c) => c + 1)}>+1</button>
                <button onClick={() => setCounter(0)}>Reset</button>
              </div>
            </div>
            <div className="card">
              <div className="muted">Temps (useEffect)</div>
              <strong>{seconds}s</strong>
              <div className="muted">{message}</div>
            </div>
            <div className="card">
              <div className="muted">Navigation</div>
              <strong>Demo Router</strong>
              <div className="row">
                <button onClick={() => nav("/users/2")}>Aller user id=2</button>
                <button onClick={() => nav("/search?q=redux&sort=desc")}>Aller search</button>
              </div>
            </div>
          </div>
        </div>

        <div className="card">
          <h2 style={{ marginTop: 0 }}>Landing section (mini)</h2>
          <p className="muted">Section type landing page intégrée.</p>
          <div className="row">
            <span className="badge">Fast</span>
            <span className="badge">Responsive</span>
            <span className="badge">Redux</span>
            <span className="badge">Router</span>
          </div>
        </div>
      </div>
    </div>
  );
}
"@

Write-File "src/pages/Inventory.jsx" @"
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
            <input type="number" placeholder="Quantité" value={form.quantity} onChange={(e) => setForm((f) => ({ ...f, quantity: e.target.value }))} />
            <input type="number" placeholder="Prix" value={form.price} onChange={(e) => setForm((f) => ({ ...f, price: e.target.value }))} />
            <button style={{ padding: "8px 12px" }}>{editId ? "Mettre à jour" : "Ajouter"}</button>
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
                <th>Quantité</th>
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
"@

Write-File "src/pages/Shop.jsx" @"
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
          {filtered.length === 0 && <div className="card muted">Aucun résultat.</div>}
        </div>
      </div>
    </div>
  );
}
"@

Write-File "src/pages/Cart.jsx" @"
import React from "react";
import { useDispatch, useSelector } from "react-redux";
import { clearCart, decreaseQuantity, removeFromCart, selectCartItems, selectCartTotal } from "../features/cart/cartSlice";

export default function Cart() {
  const items = useSelector(selectCartItems);
  const total = useSelector(selectCartTotal);
  const dispatch = useDispatch();

  return (
    <div className="container">
      <div className="card">
        <h1 style={{ marginTop: 0 }}>Panier</h1>
        <p className="muted">Gestion quantités + total. Nom: <strong>Ghanem Bouchmel</strong></p>

        <div className="row">
          <strong>Total:</strong> {total} DT
          <button onClick={() => dispatch(clearCart())}>Vider</button>
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
                  <button onClick={() => dispatch(decreaseQuantity(i.id))}>-</button>
                  <button onClick={() => dispatch(removeFromCart(i.id))}>Supprimer</button>
                </td>
              </tr>
            ))}
            {items.length === 0 && <tr><td colSpan="5" className="muted">Panier vide.</td></tr>}
          </tbody>
        </table>
      </div>
    </div>
  );
}
"@

Write-File "src/pages/Search.jsx" @"
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
          {results.length === 0 && <li className="muted">Aucun résultat.</li>}
        </ul>
      </div>
    </div>
  );
}
"@

Write-File "src/pages/Users.jsx" @"
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
              <Link to={`/users/${u.id}`} style={{ textDecoration: "underline" }}>{u.name}</Link>
              <div className="muted" style={{ fontSize: 12 }}>{u.email}</div>
            </li>
          ))}
        </ul>
      </div>
    </div>
  );
}
"@

Write-File "src/pages/UserDetail.jsx" @"
import React from "react";
import { useNavigate, useParams } from "react-router-dom";

export default function UserDetail() {
  const { id } = useParams();
  const nav = useNavigate();

  return (
    <div className="container">
      <div className="card">
        <h1 style={{ marginTop: 0 }}>Détails utilisateur</h1>
        <p className="muted">Nom: <strong>Ghanem Bouchmel</strong></p>
        <p>Identifiant: <strong>{id}</strong></p>
        <button onClick={() => nav(-1)}>Retour</button>
      </div>
    </div>
  );
}
"@

Write-File "src/pages/NotFound.jsx" @"
import React from "react";
import { Link } from "react-router-dom";

export default function NotFound() {
  return (
    <div className="container">
      <div className="card">
        <h1 style={{ marginTop: 0 }}>404</h1>
        <p className="muted">Page introuvable - Ghanem Bouchmel</p>
        <Link to="/dashboard">Retour Dashboard</Link>
      </div>
    </div>
  );
}
"@

Write-File "src/pages/About.jsx" @"
import React from "react";

export default function About() {
  return (
    <div className="container">
      <div className="card">
        <h1 style={{ marginTop: 0 }}>About (Lazy Loaded)</h1>
        <p className="muted">Cette page est chargée en lazy via React.lazy + Suspense.</p>
        <p>Nom: <strong>Ghanem Bouchmel</strong></p>
      </div>
    </div>
  );
}
"@

# --- App + main ---
Write-File "src/App.jsx" @"
import React, { lazy } from "react";
import { Navigate, Route, Routes } from "react-router-dom";
import AppHeader from "./components/AppHeader.jsx";
import ProtectedRoute from "./components/ProtectedRoute.jsx";

import Login from "./pages/Login.jsx";
import Dashboard from "./pages/Dashboard.jsx";
import Inventory from "./pages/Inventory.jsx";
import Shop from "./pages/Shop.jsx";
import Cart from "./pages/Cart.jsx";
import Search from "./pages/Search.jsx";
import Users from "./pages/Users.jsx";
import UserDetail from "./pages/UserDetail.jsx";
import NotFound from "./pages/NotFound.jsx";

const About = lazy(() => import("./pages/About.jsx"));

function Shell({ children }) {
  return (
    <>
      <AppHeader />
      {children}
      <footer className="container" style={{ paddingBottom: 28 }}>
        <div className="muted" style={{ fontSize: 12 }}>
          © TP React - <strong>Ghanem Bouchmel</strong>
        </div>
      </footer>
    </>
  );
}

export default function App() {
  return (
    <Routes>
      <Route path="/login" element={<Login />} />

      <Route path="/" element={<ProtectedRoute><Shell><Navigate to="/dashboard" replace /></Shell></ProtectedRoute>} />
      <Route path="/dashboard" element={<ProtectedRoute><Shell><Dashboard /></Shell></ProtectedRoute>} />
      <Route path="/inventory" element={<ProtectedRoute><Shell><Inventory /></Shell></ProtectedRoute>} />
      <Route path="/shop" element={<ProtectedRoute><Shell><Shop /></Shell></ProtectedRoute>} />
      <Route path="/cart" element={<ProtectedRoute><Shell><Cart /></Shell></ProtectedRoute>} />
      <Route path="/search" element={<ProtectedRoute><Shell><Search /></Shell></ProtectedRoute>} />
      <Route path="/users" element={<ProtectedRoute><Shell><Users /></Shell></ProtectedRoute>} />
      <Route path="/users/:id" element={<ProtectedRoute><Shell><UserDetail /></Shell></ProtectedRoute>} />

      <Route
        path="/about"
        element={
          <ProtectedRoute>
            <Shell>
              <React.Suspense fallback={<div className="container"><div className="card">Loading...</div></div>}>
                <About />
              </React.Suspense>
            </Shell>
          </ProtectedRoute>
        }
      />

      <Route path="*" element={<ProtectedRoute><Shell><NotFound /></Shell></ProtectedRoute>} />
    </Routes>
  );
}
"@

Write-File "src/main.jsx" @"
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
"@

# --- CSS ---
Write-File "src/index.css" @"
:root { font-family: system-ui, Arial, sans-serif; }
body { margin: 0; background: #f6f7fb; }
.container { max-width: 1100px; margin: 0 auto; padding: 16px; }
.card { background: white; border: 1px solid #e9e9ef; border-radius: 14px; padding: 16px; }
.row { display: flex; gap: 10px; align-items: center; flex-wrap: wrap; }
.grid { display: grid; gap: 12px; }
.kpi { display: grid; gap: 12px; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); }
.badge { border: 1px solid #111; border-radius: 999px; padding: 4px 10px; font-size: 12px; }
.muted { color: #555; }
.table { width: 100%; border-collapse: collapse; }
.table th, .table td { border-bottom: 1px solid #eee; padding: 10px; text-align: left; }
input, select, button { padding: 10px; border-radius: 10px; border: 1px solid #ddd; }
button { cursor: pointer; background: #fff; }
code { background: #f1f1f1; padding: 2px 6px; border-radius: 6px; }
"@

# --- cleanup (optional) ---
if (Test-Path "src/App.css") { Remove-Item "src/App.css" -Force }
if (Test-Path "src/assets") { } # keep vite assets if you want

Write-Host "`n✅ Files generated." -ForegroundColor Green
Write-Host "Next:" -ForegroundColor Cyan
Write-Host "  npm install" -ForegroundColor Cyan
Write-Host "  npm run dev" -ForegroundColor Cyan
Write-Host "`nLogin: ghanem / azerty" -ForegroundColor Yellow
