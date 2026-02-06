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