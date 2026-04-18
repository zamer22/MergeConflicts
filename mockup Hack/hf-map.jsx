// HI-FI mockups — Mapa (01), Descubrir (02), Detalle (03)

function HFPhone({ children }) {
  return (
    <div className="hf-phone">
      <div className="island"></div>
      <div className="hf-screen">{children}</div>
      <div className="hf-home-indicator"></div>
    </div>
  );
}

function HFStatus({ dark = false }) {
  return (
    <div className="hf-status" style={{ color: dark ? '#fff' : '#000' }}>
      <span>9:41</span>
      <span style={{ display: 'flex', gap: 6, alignItems: 'center' }}>
        <span style={{ fontSize: 11 }}>●●●●</span>
        <svg width="16" height="11" viewBox="0 0 16 11" fill="none"><path d="M8 2.5a6 6 0 0 1 4.2 1.7l1.4-1.4a8 8 0 0 0-11.3 0l1.5 1.4A6 6 0 0 1 8 2.5z" fill="currentColor"/><path d="M8 6a3 3 0 0 1 2.1.9l1.4-1.5a5 5 0 0 0-7 0l1.4 1.4A3 3 0 0 1 8 6z" fill="currentColor"/><circle cx="8" cy="9.5" r="1.5" fill="currentColor"/></svg>
        <svg width="24" height="11" viewBox="0 0 24 11" fill="none"><rect x="0.5" y="0.5" width="20" height="10" rx="2.5" stroke="currentColor" opacity="0.4"/><rect x="2" y="2" width="17" height="7" rx="1" fill="currentColor"/><rect x="21" y="3.5" width="2" height="4" rx="1" fill="currentColor" opacity="0.4"/></svg>
      </span>
    </div>
  );
}

function HFTabBar({ active }) {
  const items = [
    { id: 'mapa', label: 'Mapa', ic: (
      <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M12 22s-8-7.58-8-13a8 8 0 0 1 16 0c0 5.42-8 13-8 13z"/><circle cx="12" cy="9" r="2.5"/></svg>
    )},
    { id: 'feed', label: 'Descubrir', ic: (
      <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><circle cx="11" cy="11" r="7"/><path d="m20 20-3.5-3.5"/></svg>
    )},
    { id: 'fab', label: '', ic: '+', fab: true },
    { id: 'saved', label: 'Guardado', ic: (
      <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M20.8 4.6a5.5 5.5 0 0 0-7.8 0L12 5.7l-1-1.1a5.5 5.5 0 0 0-7.8 7.8l1 1.1L12 21l7.8-7.5 1-1.1a5.5 5.5 0 0 0 0-7.8z"/></svg>
    )},
    { id: 'perfil', label: 'Yo', ic: (
      <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><circle cx="12" cy="8" r="4"/><path d="M4 21a8 8 0 0 1 16 0"/></svg>
    )},
  ];
  return (
    <div className="hf-tabbar">
      {items.map(it => it.fab ? (
        <div key={it.id} className="hf-fab">+</div>
      ) : (
        <div key={it.id} className={`item ${active === it.id ? 'active' : ''}`}>
          <div className="ic">{it.ic}</div>
          <div>{it.label}</div>
        </div>
      ))}
    </div>
  );
}

// ═══════ MAPA HI-FI ═══════
function HFMap() {
  return (
    <HFPhone>
      <HFStatus/>

      <div style={{ padding: '4px 16px 10px', zIndex: 5, position: 'relative' }}>
        <div className="hf-search">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#9aa0a6" strokeWidth="2"><circle cx="11" cy="11" r="7"/><path d="m20 20-3.5-3.5"/></svg>
          <span className="placeholder">Buscar eventos o lugares</span>
          <button style={{ background: 'var(--brand)', border: 'none', borderRadius: 100, width: 32, height: 32, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2.5"><line x1="4" y1="6" x2="20" y2="6"/><line x1="7" y1="12" x2="17" y2="12"/><line x1="10" y1="18" x2="14" y2="18"/></svg>
          </button>
        </div>
      </div>

      {/* chips */}
      <div className="scrollx" style={{ padding: '0 16px 10px' }}>
        <div className="hf-chip live">● Ahora</div>
        <div className="hf-chip soon">Pronto</div>
        <div className="hf-chip outline">Hoy</div>
        <div className="hf-chip outline">Finde</div>
        <div className="hf-chip outline">Gratis</div>
      </div>

      {/* MAP */}
      <div style={{ flex: 1, position: 'relative', overflow: 'hidden', background: '#e4e8ed' }}>
        {/* streets SVG */}
        <svg width="100%" height="100%" style={{ position: 'absolute', inset: 0 }} preserveAspectRatio="none" viewBox="0 0 360 500">
          <rect width="360" height="500" fill="#e8ecf0"/>
          <rect x="0" y="380" width="360" height="120" fill="#c8dce8" opacity="0.7"/>
          <path d="M0 60 Q 80 80 180 50 T 360 70" stroke="#fff" strokeWidth="22" fill="none"/>
          <path d="M0 60 Q 80 80 180 50 T 360 70" stroke="#dde2e8" strokeWidth="2" fill="none"/>
          <path d="M50 0 L 70 500" stroke="#fff" strokeWidth="18" fill="none"/>
          <path d="M50 0 L 70 500" stroke="#dde2e8" strokeWidth="2" fill="none"/>
          <path d="M230 0 L 240 500" stroke="#fff" strokeWidth="16" fill="none"/>
          <path d="M230 0 L 240 500" stroke="#dde2e8" strokeWidth="2" fill="none"/>
          <path d="M0 200 Q 180 180 360 220" stroke="#fff" strokeWidth="14" fill="none"/>
          <path d="M0 200 Q 180 180 360 220" stroke="#dde2e8" strokeWidth="2" fill="none"/>
          <path d="M0 340 L 360 335" stroke="#fff" strokeWidth="16" fill="none"/>
          <path d="M0 340 L 360 335" stroke="#dde2e8" strokeWidth="2" fill="none"/>
          <path d="M140 0 Q 130 250 150 500" stroke="#fff" strokeWidth="10" fill="none"/>
          {/* parque verde */}
          <rect x="80" y="150" width="90" height="60" rx="6" fill="#c8dcb4" opacity="0.8"/>
        </svg>

        {/* heatmap IA glow */}
        <div style={{ position: 'absolute', left: 60, top: 30, width: 200, height: 220, borderRadius: '50%', background: 'radial-gradient(circle, rgba(255,90,60,0.35), rgba(236,72,153,0.18) 40%, transparent 70%)', pointerEvents: 'none', filter: 'blur(4px)' }}/>

        {/* AI badge */}
        <div style={{ position: 'absolute', top: 12, right: 14 }}>
          <div className="hf-ai"><span className="sp">✦</span> Zona hot</div>
        </div>

        {/* Pines */}
        <HFPin x={55} y={80} color="#22c55e" ic="🎵"/>
        <HFPin x={130} y={65} color="#ff5a3c" ic="🎪" big/>
        <HFPin x={200} y={100} color="#3b82f6" ic="🎨"/>
        <HFPin x={90} y={160} color="#f59e0b" ic="🍴"/>
        <HFPin x={240} y={170} color="#22c55e" ic="🎵"/>
        <HFPin x={170} y={220} color="#ff5a3c" ic="🛒"/>
        <HFPin x={70} y={260} color="#3b82f6" ic="🎨"/>
        <HFPin x={260} y={270} color="#22c55e" ic="🏃"/>
        <HFPin x={120} y={310} color="#f59e0b" ic="🍴"/>

        {/* mi ubicación */}
        <div style={{ position: 'absolute', right: 14, bottom: 180, width: 42, height: 42, borderRadius: '50%', background: 'white', boxShadow: '0 4px 12px rgba(0,0,0,0.15)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#ff5a3c" strokeWidth="2.5"><circle cx="12" cy="12" r="3" fill="#ff5a3c"/><circle cx="12" cy="12" r="8"/><line x1="12" y1="2" x2="12" y2="5"/><line x1="12" y1="19" x2="12" y2="22"/><line x1="2" y1="12" x2="5" y2="12"/><line x1="19" y1="12" x2="22" y2="12"/></svg>
        </div>
      </div>

      {/* bottom sheet */}
      <div style={{ position: 'relative', background: 'white', borderRadius: '24px 24px 0 0', marginTop: -22, padding: '10px 18px 14px', boxShadow: '0 -8px 24px rgba(0,0,0,0.08)', zIndex: 4 }}>
        <div style={{ width: 40, height: 4, background: '#e5e5ea', borderRadius: 100, margin: '0 auto 10px' }}/>
        <div style={{ display: 'flex', gap: 12, alignItems: 'center' }}>
          <div className="hf-img plants" style={{ width: 60, height: 60, borderRadius: 12, flexShrink: 0 }}/>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ display: 'flex', gap: 6, marginBottom: 2 }}>
              <div className="hf-chip live" style={{ fontSize: 10, padding: '2px 8px' }}>● EN VIVO</div>
              <div className="hf-chip" style={{ fontSize: 10, padding: '2px 8px' }}>Gratis</div>
            </div>
            <div style={{ fontSize: 15, fontWeight: 700, lineHeight: 1.2, letterSpacing: -0.2 }}>Feria de las Flores</div>
            <div style={{ fontSize: 12, color: 'var(--text-2)', marginTop: 2 }}>📍 a 4 min · hasta 22:00 · <b style={{ color: 'var(--text)' }}>+23 van</b></div>
          </div>
        </div>
      </div>

      <HFTabBar active="mapa"/>
    </HFPhone>
  );
}

function HFPin({ x, y, color, ic, big }) {
  const size = big ? 38 : 30;
  return (
    <div style={{ position: 'absolute', left: x, top: y, width: size, height: size, transform: 'translate(-50%, -100%)', filter: big ? 'drop-shadow(0 4px 6px rgba(0,0,0,0.25))' : 'drop-shadow(0 2px 3px rgba(0,0,0,0.2))' }}>
      <div style={{
        width: size, height: size,
        background: color,
        borderRadius: '50% 50% 50% 0',
        transform: 'rotate(-45deg)',
        border: '2px solid white',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
      }}>
        <span style={{ transform: 'rotate(45deg)', fontSize: big ? 16 : 13 }}>{ic}</span>
      </div>
    </div>
  );
}

Object.assign(window, { HFPhone, HFStatus, HFTabBar, HFMap, HFPin });
