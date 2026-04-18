// HI-FI Feed/Descubrir

function HFFeed() {
  return (
    <HFPhone>
      <HFStatus/>

      {/* header */}
      <div style={{ padding: '4px 18px 6px' }}>
        <div style={{ fontSize: 30, fontWeight: 800, letterSpacing: -0.8, lineHeight: 1 }}>Descubrir</div>
        <div style={{ fontSize: 13, color: 'var(--text-2)', marginTop: 4, display: 'flex', alignItems: 'center', gap: 4 }}>
          <svg width="12" height="12" viewBox="0 0 24 24" fill="#ff5a3c"><path d="M12 2a7 7 0 0 0-7 7c0 5.25 7 13 7 13s7-7.75 7-13a7 7 0 0 0-7-7z"/></svg>
          Roma Norte, CDMX
        </div>
      </div>

      {/* EN VIVO stories */}
      <div style={{ padding: '8px 0 6px' }}>
        <div style={{ padding: '0 18px 6px', fontSize: 11, fontWeight: 700, color: 'var(--brand)', letterSpacing: 0.8, display: 'flex', alignItems: 'center', gap: 5 }}>
          <span style={{ width: 6, height: 6, background: 'var(--brand)', borderRadius: '50%', boxShadow: '0 0 0 3px rgba(255,90,60,0.3)', animation: 'pulse 2s infinite' }}></span>
          EN VIVO · PASANDO AHORA
        </div>
        <div className="scrollx" style={{ padding: '0 14px' }}>
          {[
            { ic: '🎵', t: '3 min', c: '#7c6faa' },
            { ic: '🎪', t: '6 min', c: '#ff5a3c' },
            { ic: '🍴', t: '9 min', c: '#d4a574' },
            { ic: '🎨', t: '12 min', c: '#c87f7f' },
            { ic: '🏃', t: '15 min', c: '#22c55e' },
          ].map((s, i) => (
            <div key={i} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4, flexShrink: 0 }}>
              <div style={{ width: 62, height: 62, borderRadius: '50%', padding: 2.5, background: 'conic-gradient(from 0deg, #ff5a3c, #ec4899, #f59e0b, #ff5a3c)' }}>
                <div style={{ width: '100%', height: '100%', borderRadius: '50%', background: s.c, border: '2px solid white', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 22 }}>{s.ic}</div>
              </div>
              <div style={{ fontSize: 10, color: 'var(--text-2)', fontWeight: 500 }}>a {s.t}</div>
            </div>
          ))}
        </div>
      </div>

      {/* search */}
      <div style={{ padding: '4px 18px 10px' }}>
        <div className="hf-search">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#9aa0a6" strokeWidth="2"><circle cx="11" cy="11" r="7"/><path d="m20 20-3.5-3.5"/></svg>
          <span className="placeholder">Buscar eventos…</span>
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="var(--brand)" strokeWidth="2.5"><line x1="4" y1="6" x2="20" y2="6"/><line x1="7" y1="12" x2="17" y2="12"/><line x1="10" y1="18" x2="14" y2="18"/></svg>
        </div>
      </div>

      {/* chips */}
      <div className="scrollx" style={{ padding: '0 18px 12px' }}>
        <div className="hf-chip solid">Todos</div>
        <div className="hf-chip outline">🎵 Música</div>
        <div className="hf-chip outline">🎪 Ferias</div>
        <div className="hf-chip outline">🎨 Arte</div>
        <div className="hf-chip outline">🍴 Comida</div>
      </div>

      {/* AI para ti */}
      <div style={{ margin: '0 18px 14px', padding: 14, borderRadius: 16, background: 'linear-gradient(135deg, #fff5ef 0%, #fef3c7 100%)', border: '1px solid #fed7aa' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 6 }}>
          <div className="hf-ai"><span className="sp">✦</span> Para ti</div>
          <span style={{ fontSize: 11, color: 'var(--text-2)' }}>según tus gustos</span>
        </div>
        <div style={{ fontSize: 13, lineHeight: 1.4, color: 'var(--text)' }}><b>3 ferias de diseño</b> este fin de semana · te podrían interesar</div>
      </div>

      {/* feed */}
      <div style={{ flex: 1, overflow: 'hidden', padding: '0 18px' }}>
        <HFFeedCard img="music" badge="AHORA" badgeLive title="Jam session abierta" meta="Parque México · hasta 22:00" tags={['Música', 'Gratis']} going={14}/>
        <HFFeedCard img="market" badge="MAÑANA" badgeSoon title="Mercado de diseñadores" meta="Sáb 10:00 · Monumento a la Revolución" tags={['Feria', 'Econ. circular']} going={87}/>
      </div>

      <HFTabBar active="feed"/>
    </HFPhone>
  );
}

function HFFeedCard({ img, badge, badgeLive, badgeSoon, title, meta, tags, going }) {
  return (
    <div style={{ marginBottom: 16, borderRadius: 16, overflow: 'hidden', border: '1px solid var(--line)', background: 'white', boxShadow: '0 2px 8px rgba(0,0,0,0.04)' }}>
      <div style={{ position: 'relative' }}>
        <div className={`hf-img ${img}`} style={{ height: 120, borderRadius: 0 }}/>
        <div style={{ position: 'absolute', top: 10, left: 10 }}>
          <div className={`hf-chip ${badgeLive ? 'live' : 'soon'}`} style={{ fontSize: 10, fontWeight: 700, padding: '3px 8px' }}>{badgeLive ? '● ' : ''}{badge}</div>
        </div>
        <div style={{ position: 'absolute', top: 10, right: 10 }}>
          <div style={{ width: 32, height: 32, borderRadius: '50%', background: 'rgba(255,255,255,0.9)', backdropFilter: 'blur(10px)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#000" strokeWidth="2"><path d="M20.8 4.6a5.5 5.5 0 0 0-7.8 0L12 5.7l-1-1.1a5.5 5.5 0 0 0-7.8 7.8l1 1.1L12 21l7.8-7.5 1-1.1a5.5 5.5 0 0 0 0-7.8z"/></svg>
          </div>
        </div>
      </div>
      <div style={{ padding: 12 }}>
        <div style={{ fontSize: 15, fontWeight: 700, letterSpacing: -0.2, lineHeight: 1.25 }}>{title}</div>
        <div style={{ fontSize: 12, color: 'var(--text-2)', marginTop: 3 }}>{meta}</div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 4, marginTop: 8 }}>
          {tags.map(t => <div key={t} className="hf-chip" style={{ fontSize: 10, padding: '3px 8px' }}>{t}</div>)}
          <div style={{ flex: 1 }}/>
          <div style={{ fontSize: 11, color: 'var(--text-2)', display: 'flex', alignItems: 'center', gap: 3 }}>
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><circle cx="9" cy="8" r="3"/><path d="M3 21a6 6 0 0 1 12 0"/><circle cx="17" cy="7" r="2.5"/><path d="M21 17a5 5 0 0 0-5-4"/></svg>
            <b style={{ color: 'var(--text)' }}>{going}</b> van
          </div>
        </div>
      </div>
    </div>
  );
}

Object.assign(window, { HFFeed, HFFeedCard });
