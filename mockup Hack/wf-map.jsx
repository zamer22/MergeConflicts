// Wireframes — Pantalla MAPA (tipo Waze)
// 2 variaciones: A) Mapa full-bleed + bottom sheet  B) Mapa + rail lateral de filtros

function PhoneFrame({ children, rotate = 'r1' }) {
  return (
    <div className={`phone ${rotate}`}>
      <div className="notch"></div>
      <div className="phone-screen">{children}</div>
    </div>
  );
}

function StatusBar() {
  return (
    <div className="statusbar">
      <span>9:41</span>
      <span>•••  ▲  ▮▮</span>
    </div>
  );
}

// ═══════════ VARIACIÓN A: mapa full-bleed + bottom sheet ═══════════
function MapVariationA() {
  return (
    <PhoneFrame rotate="r1">
      <StatusBar />
      {/* barra búsqueda flotante */}
      <div style={{ padding: '6px 14px 10px', position: 'relative', zIndex: 4 }}>
        <div className="wf-box" style={{ display: 'flex', alignItems: 'center', padding: '8px 12px', gap: 8, borderRadius: 100 }}>
          <div className="wf-circle" style={{ width: 22, height: 22, fontSize: 12 }}>🔍</div>
          <div style={{ flex: 1, fontSize: 14, color: 'var(--ink-3)' }}>Buscar eventos o lugares</div>
          <div className="wf-pill accent" style={{ padding: '2px 8px', fontSize: 12 }}>Filtros</div>
        </div>
      </div>

      {/* chips de tiempo */}
      <div style={{ display: 'flex', gap: 6, padding: '0 14px 10px', overflow: 'hidden' }}>
        <div className="wf-pill green">Ahora</div>
        <div className="wf-pill yellow">Pronto</div>
        <div className="wf-pill">Hoy</div>
        <div className="wf-pill">Finde</div>
      </div>

      {/* MAPA */}
      <div style={{ flex: 1, position: 'relative', background: '#e8e4d4', overflow: 'hidden', borderTop: '1.5px solid var(--ink)', borderBottom: '1.5px solid var(--ink)' }}>
        {/* streets sketch */}
        <svg width="100%" height="100%" style={{ position: 'absolute', inset: 0 }}>
          <path d="M0 60 Q 80 80 160 50 T 320 70" stroke="#b8b1a0" strokeWidth="18" fill="none" />
          <path d="M40 0 L 60 400" stroke="#b8b1a0" strokeWidth="14" fill="none" />
          <path d="M200 0 L 210 400" stroke="#b8b1a0" strokeWidth="12" fill="none" />
          <path d="M0 180 Q 160 160 320 200" stroke="#c9c2af" strokeWidth="10" fill="none" />
          <path d="M0 320 L 320 310" stroke="#c9c2af" strokeWidth="14" fill="none" />
          <rect x="0" y="360" width="320" height="60" fill="#b8d4e8" opacity="0.6" />
          <path d="M260 0 Q 240 200 280 420" stroke="#b8d4e8" strokeWidth="18" fill="none" opacity="0.7" />
        </svg>

        {/* pines */}
        <MapPin x={50} y={70} color="green" icon="🎵" />
        <MapPin x={130} y={55} color="accent" icon="🎪" big />
        <MapPin x={190} y={90} color="blue" icon="🎨" />
        <MapPin x={90} y={140} color="yellow" icon="🍴" />
        <MapPin x={220} y={160} color="green" icon="🎵" />
        <MapPin x={160} y={200} color="accent" icon="🛒" />
        <MapPin x={70} y={240} color="blue" icon="🎨" />
        <MapPin x={250} y={250} color="green" icon="🏃" />
        <MapPin x={110} y={280} color="yellow" icon="🍴" />

        {/* heatmap AI overlay — sutil */}
        <div style={{ position: 'absolute', left: 90, top: 30, width: 160, height: 180, borderRadius: '50%', background: 'radial-gradient(circle, rgba(255,90,60,0.28), transparent 70%)', pointerEvents: 'none' }}/>

        {/* label AI */}
        <div style={{ position: 'absolute', top: 10, right: 10 }}>
          <div className="ai-badge small">✨ Zona hot</div>
        </div>
      </div>

      {/* bottom sheet — card del pin seleccionado */}
      <div className="wf-box" style={{ borderRadius: '20px 20px 0 0', padding: '12px 14px', margin: '-22px 8px 0', position: 'relative', zIndex: 3, background: 'var(--paper)', boxShadow: '0 -2px 0 rgba(0,0,0,0.05)' }}>
        <div style={{ width: 40, height: 3, background: 'var(--ink-3)', borderRadius: 2, margin: '0 auto 8px' }}/>
        <div style={{ display: 'flex', gap: 10 }}>
          <div className="wf-fill-slash" style={{ width: 54, height: 54, border: '1.5px solid var(--ink)', borderRadius: 10, flexShrink: 0 }}/>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ fontSize: 15, fontWeight: 700, lineHeight: 1.15 }}>Feria de las Flores · Centro</div>
            <div style={{ fontSize: 12, color: 'var(--ink-2)', marginTop: 2 }}>📍 a 4 min · ⏱ hasta 22:00</div>
            <div style={{ display: 'flex', gap: 4, marginTop: 6 }}>
              <div className="wf-pill" style={{ fontSize: 11, padding: '1px 8px' }}>Feria</div>
              <div className="wf-pill" style={{ fontSize: 11, padding: '1px 8px' }}>Gratis</div>
              <div className="wf-pill accent" style={{ fontSize: 11, padding: '1px 8px' }}>+23 van</div>
            </div>
          </div>
        </div>
      </div>

      {/* tab bar */}
      <TabBar active="mapa" />
    </PhoneFrame>
  );
}

// ═══════════ VARIACIÓN B: mapa + rail de filtros lateral + lista inferior ═══════════
function MapVariationB() {
  return (
    <PhoneFrame rotate="r2">
      <StatusBar />

      {/* header estilo "Waze" con pin de ubicación */}
      <div style={{ display: 'flex', alignItems: 'center', gap: 8, padding: '6px 14px' }}>
        <div style={{ fontSize: 16, fontWeight: 700 }}>📍 Roma Norte</div>
        <div style={{ flex: 1 }}/>
        <div className="wf-circle" style={{ width: 32, height: 32 }}>🔍</div>
        <div className="wf-circle" style={{ width: 32, height: 32 }}>👤</div>
      </div>

      {/* MAPA con rail lateral de categorías */}
      <div style={{ flex: 1, position: 'relative', background: '#e8e4d4', overflow: 'hidden', borderTop: '1.5px solid var(--ink)' }}>
        <svg width="100%" height="100%" style={{ position: 'absolute', inset: 0 }}>
          <path d="M0 40 Q 80 70 160 40 T 320 60" stroke="#b8b1a0" strokeWidth="16" fill="none" />
          <path d="M80 0 L 90 500" stroke="#b8b1a0" strokeWidth="14" fill="none" />
          <path d="M230 0 L 220 500" stroke="#c9c2af" strokeWidth="12" fill="none" />
          <path d="M0 200 Q 160 220 320 180" stroke="#c9c2af" strokeWidth="12" fill="none" />
          <path d="M0 340 Q 160 320 320 350" stroke="#b8b1a0" strokeWidth="14" fill="none" />
          <path d="M150 0 L 160 500" stroke="#c9c2af" strokeWidth="8" fill="none" />
        </svg>

        {/* rail categorías izq */}
        <div style={{ position: 'absolute', left: 10, top: 12, display: 'flex', flexDirection: 'column', gap: 8, zIndex: 4 }}>
          <CatBtn icon="☰" label=""/>
          <CatBtn icon="🎵" on/>
          <CatBtn icon="🎪" on/>
          <CatBtn icon="🛒"/>
          <CatBtn icon="🎨"/>
          <CatBtn icon="🍴"/>
          <CatBtn icon="🏃"/>
        </div>

        {/* pines */}
        <MapPin x={140} y={60} color="accent" icon="🎵" big/>
        <MapPin x={200} y={100} color="accent" icon="🎪"/>
        <MapPin x={110} y={130} color="accent" icon="🎵"/>
        <MapPin x={240} y={160} color="accent" icon="🎪"/>
        <MapPin x={170} y={210} color="accent" icon="🎵"/>
        <MapPin x={90} y={250} color="accent" icon="🎪"/>

        {/* botón mi ubicación */}
        <div style={{ position: 'absolute', right: 12, bottom: 14, width: 44, height: 44, borderRadius: '50%', background: 'var(--paper)', border: '1.5px solid var(--ink)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 18 }}>◉</div>

        {/* contador AI top */}
        <div style={{ position: 'absolute', top: 12, right: 60, zIndex: 5 }}>
          <div className="wf-pill ink" style={{ fontSize: 12 }}>12 eventos cerca</div>
        </div>
      </div>

      {/* lista swipeable tipo Waze destinos */}
      <div style={{ background: 'var(--paper)', borderTop: '2px solid var(--ink)', padding: '10px 0 8px' }}>
        <div style={{ padding: '0 14px 8px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <div style={{ fontWeight: 700, fontSize: 15 }}>Pasando cerca de ti →</div>
          <div style={{ fontSize: 12, color: 'var(--ink-2)' }}>Ver todo</div>
        </div>
        <div style={{ display: 'flex', gap: 10, padding: '0 14px', overflow: 'hidden' }}>
          <MiniCard title="Jam session" time="En 20min" dist="200m"/>
          <MiniCard title="Mercado" time="Ahora" dist="450m"/>
        </div>
      </div>

      <TabBar active="mapa"/>
    </PhoneFrame>
  );
}

// ——— helpers ———
function MapPin({ x, y, color = 'accent', icon = '•', big = false }) {
  const size = big ? 34 : 26;
  return (
    <div style={{ position: 'absolute', left: x, top: y, width: size, height: size, transform: 'translate(-50%, -100%)' }}>
      <div style={{
        width: size, height: size,
        background: `var(--${color})`,
        border: '1.5px solid var(--ink)',
        borderRadius: '50% 50% 50% 0',
        transform: 'rotate(-45deg)',
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        boxShadow: '1px 2px 0 rgba(0,0,0,0.15)',
      }}>
        <span style={{ transform: 'rotate(45deg)', fontSize: big ? 14 : 11 }}>{icon}</span>
      </div>
    </div>
  );
}

function CatBtn({ icon, label, on }) {
  return (
    <div style={{
      width: 36, height: 36,
      background: on ? 'var(--accent)' : 'var(--paper)',
      border: '1.5px solid var(--ink)',
      borderRadius: 10,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      fontSize: 16,
      color: on ? 'white' : 'var(--ink)',
      boxShadow: '1.5px 1.5px 0 var(--ink)',
    }}>{icon}</div>
  );
}

function MiniCard({ title, time, dist }) {
  return (
    <div className="wf-box" style={{ minWidth: 140, padding: 8 }}>
      <div className="wf-fill-slash" style={{ height: 44, borderRadius: 6, marginBottom: 6 }}/>
      <div style={{ fontSize: 13, fontWeight: 700, lineHeight: 1.1 }}>{title}</div>
      <div style={{ fontSize: 11, color: 'var(--ink-2)', marginTop: 2 }}>{time} · {dist}</div>
    </div>
  );
}

function TabBar({ active }) {
  const items = [
    { id: 'mapa', label: 'Mapa', ic: '◎' },
    { id: 'feed', label: 'Descubrir', ic: '☷' },
    { id: 'crear', label: '', ic: '+', fab: true },
    { id: 'saved', label: 'Guardado', ic: '♡' },
    { id: 'perfil', label: 'Yo', ic: '◐' },
  ];
  return (
    <div className="tabbar">
      {items.map(it => it.fab ? (
        <div key={it.id} style={{ width: 50, height: 50, borderRadius: '50%', background: 'var(--accent)', border: '2px solid var(--ink)', color: 'white', fontSize: 24, fontWeight: 700, display: 'flex', alignItems: 'center', justifyContent: 'center', marginTop: -20, boxShadow: '2px 2px 0 var(--ink)' }}>+</div>
      ) : (
        <div key={it.id} className={`tab-item ${active === it.id ? 'active' : ''}`}>
          <div className={`ic ${it.id === 'perfil' ? 'round' : ''}`}>{it.ic}</div>
          <div>{it.label}</div>
        </div>
      ))}
    </div>
  );
}

Object.assign(window, { MapVariationA, MapVariationB, PhoneFrame, StatusBar, TabBar });
