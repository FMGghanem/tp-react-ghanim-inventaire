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