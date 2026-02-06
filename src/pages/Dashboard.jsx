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
    document.title = Dashboard - counter ;
  }, [counter]);

  const message = useMemo(() => {
    return counter >= 5 ? "Bravo, counter >= 5 !" : "Augmente le counter pour dÃ©clencher un message.";
  }, [counter]);

  const bg = theme === "clair" ? "#ffffff" : "#1d1d1d";
  const fg = theme === "clair" ? "#111" : "#fff";

  return (
    <div className="container">
      <div className="grid">
        <div className="card" style={{ background: bg, color: fg }}>
          <h1 style={{ marginTop: 0 }}>Dashboard</h1>
          <p className="muted">Nom affichÃ© partout : <strong>Ghanem Bouchmel</strong></p>

          <div className="kpi">
            <div className="card">
              <div className="muted">counter (useState)</div>
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
          <p className="muted">Section type landing page intÃ©grÃ©e.</p>
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

