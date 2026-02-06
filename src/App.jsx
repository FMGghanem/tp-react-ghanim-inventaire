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
        <div className="muted" style={{ fontSize: 12 }}>Â© E-Shop â€” <strong>Ghanem Bouchmel</strong></div>
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