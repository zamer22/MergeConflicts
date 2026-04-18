// HI-FI Detalle evento

function HFDetail() {
  return (
    <HFPhone>
      <div style={{ position: 'absolute', top: 0, left: 0, right: 0, zIndex: 10 }}>
        <HFStatus dark/>
      </div>

      {/* hero */}
      <div style={{ position: 'relative', height: 260, flexShrink: 0 }}>
        <div className="hf-img plants" style={{ width: '100%', height: '100%', borderRadius: 0 }}/>
        <div style={{ position: 'absolute', inset: 0, background: 'linear-gradient(180deg, rgba(0,0,0,0.3) 0%, transparent 40%, transparent 60%, rgba(0,0,0,0.4) 100%)' }}/>
        <div style={{ position: 'absolute', top: 56, left: 14, display: 'flex', gap: 8 }}>
          <IconBtn><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#000" strokeWidth="2.5"><path d="M15 18l-6-6 6-6"/></svg></IconBtn>
        </div>
        <div style={{ position: 'absolute', top: 56, right: 14, display: 'flex', gap: 8 }}>
          <IconBtn><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#000" strokeWidth="2"><path d="M20.8 4.6a5.5 5.5 0 0 0-7.8 0L12 5.7l-1-1.1a5.5 5.5 0 0 0-7.8 7.8l1 1.1L12 21l7.8-7.5 1-1.1a5.5 5.5 0 0 0 0-7.8z"/></svg></IconBtn>
          <IconBtn><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#000" strokeWidth="2"><path d="M4 12v8a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-8"/><polyline points="16 6 12 2 8 6"/><line x1="12" y1="2" x2="12" y2="15"/></svg></IconBtn>
        </div>
        <div style={{ position: 'absolute', bottom: 14, left: 14, display: 'flex', gap: 6 }}>
          <div className="hf-chip live" style={{ fontSize: 11, fontWeight: 700 }}>● EN VIVO</div>
          <div className="hf-chip" style={{ fontSize: 11, background: 'rgba(255,255,255,0.95)' }}>Gratis</div>
        </div>
      </div>

      {/* tabs Info/Fotos */}
      <div style={{ display: 'flex', gap: 0, padding: '0 18px', borderBottom: '1px solid var(--line)' }}>
        <div style={{ padding: '12px 14px', fontSize: 14, fontWeight: 700, borderBottom: '2.5px solid var(--brand)' }}>Info</div>
        <div style={{ padding: '12px 14px', fontSize: 14, color: 'var(--text-2)', fontWeight: 500 }}>Fotos</div>
      </div>

      <div style={{ flex: 1, overflow: 'auto', padding: '14px 18px 16px' }}>
        <div style={{ fontSize: 22, fontWeight: 800, letterSpacing: -0.5, lineHeight: 1.1 }}>Feria de las Flores</div>
        <div style={{ fontSize: 13, color: 'var(--text-2)', marginTop: 6, display: 'flex', flexDirection: 'column', gap: 3 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
            <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#6b6b76" strokeWidth="2"><rect x="3" y="4" width="18" height="18" rx="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/></svg>
            Hoy 10:00 – 22:00
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
            <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#6b6b76" strokeWidth="2"><path d="M12 22s-8-7.58-8-13a8 8 0 0 1 16 0c0 5.42-8 13-8 13z"/><circle cx="12" cy="9" r="2.5"/></svg>
            Plaza de la Ciudadela · a 4 min
          </div>
        </div>

        <div style={{ display: 'flex', gap: 5, marginTop: 10, flexWrap: 'wrap' }}>
          <div className="hf-chip" style={{ fontSize: 11 }}>#feria</div>
          <div className="hf-chip" style={{ fontSize: 11 }}>#artesanal</div>
          <div className="hf-chip" style={{ fontSize: 11 }}>#familiar</div>
        </div>

        {/* AI summary */}
        <div style={{ marginTop: 14, padding: 14, borderRadius: 16, background: 'linear-gradient(135deg, #faf5ff 0%, #fff5ef 50%, #fef3c7 100%)', border: '1px solid #e9d5ff' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 8 }}>
            <div className="hf-ai"><span className="sp">✦</span> Resumen IA</div>
            <span style={{ fontSize: 11, color: 'var(--text-2)' }}>de 47 comentarios</span>
          </div>
          <div style={{ fontSize: 13, lineHeight: 1.45, color: 'var(--text)' }}>
            Gente destaca los <b>puestos de plantas raras</b> y el <b>ambiente tranquilo</b>. Mencionan que <b>se llena después de las 16h</b>.
          </div>
          <div style={{ display: 'flex', gap: 5, marginTop: 10, flexWrap: 'wrap' }}>
            <div style={{ fontSize: 10, padding: '3px 9px', borderRadius: 100, background: '#dcfce7', color: '#166534', fontWeight: 600 }}>+ variedad</div>
            <div style={{ fontSize: 10, padding: '3px 9px', borderRadius: 100, background: '#dcfce7', color: '#166534', fontWeight: 600 }}>+ ambiente</div>
            <div style={{ fontSize: 10, padding: '3px 9px', borderRadius: 100, background: '#fef3c7', color: '#854d0e', fontWeight: 600 }}>– precios</div>
          </div>
        </div>

        {/* asistentes + rating */}
        <div style={{ marginTop: 14, display: 'flex', alignItems: 'center', gap: 14 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
            <div style={{ display: 'flex' }}>
              {['A','M','L'].map((l,i) => (
                <div key={i} className="hf-avatar" style={{ width: 28, height: 28, fontSize: 11, marginLeft: i?-8:0, background: ['linear-gradient(135deg,#ffd8c6,#ff9a7a)','linear-gradient(135deg,#fde68a,#f59e0b)','linear-gradient(135deg,#bfdbfe,#3b82f6)'][i] }}>{l}</div>
              ))}
            </div>
            <div style={{ fontSize: 12, color: 'var(--text-2)' }}><b style={{ color: 'var(--text)' }}>+87</b> van</div>
          </div>
          <div style={{ width: 1, height: 18, background: 'var(--line)' }}/>
          <div style={{ fontSize: 14, fontWeight: 700, display: 'flex', alignItems: 'center', gap: 3 }}>
            <span style={{ color: '#f59e0b' }}>★</span> 4.6
          </div>
          <div style={{ fontSize: 12, color: 'var(--text-2)' }}>· 47 opiniones</div>
        </div>

        {/* Reseñas debajo */}
        <div style={{ marginTop: 16 }}>
          <div style={{ fontSize: 15, fontWeight: 700, letterSpacing: -0.2, marginBottom: 8 }}>Reseñas</div>
          <HFReview name="Sofía R." initial="S" color="#ff9a7a" stars={5} text="Encontré plantas que no se ven por ningún lado. Volveré sin dudarlo."/>
          <HFReview name="Mario L." initial="M" color="#f59e0b" stars={4} text="Buen ambiente pero hay que llegar temprano, después se llena mucho."/>
          <HFReview name="Ana P." initial="A" color="#3b82f6" stars={5} text="Los vendedores son muy amables. Solo llevan efectivo."/>
        </div>
      </div>

      {/* CTA footer */}
      <div style={{ padding: '12px 14px 14px', borderTop: '1px solid var(--line)', background: 'white', display: 'flex', gap: 8 }}>
        <button style={{ flex: 1, border: '1px solid var(--line)', borderRadius: 100, padding: '12px 0', background: 'white', fontSize: 14, fontWeight: 600, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 5 }}>
          <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
          Chat
        </button>
        <button style={{ flex: 1.5, background: 'var(--brand-grad)', border: 'none', borderRadius: 100, padding: '12px 0', color: 'white', fontSize: 14, fontWeight: 700, boxShadow: '0 6px 16px -4px rgba(255,90,60,0.4)' }}>Unirme</button>
        <button style={{ border: '1px solid var(--line)', borderRadius: 100, padding: '12px 14px', background: 'white', fontSize: 14, fontWeight: 600 }}>
          <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
        </button>
      </div>
    </HFPhone>
  );
}

function IconBtn({ children }) {
  return (
    <div style={{ width: 38, height: 38, borderRadius: '50%', background: 'rgba(255,255,255,0.95)', backdropFilter: 'blur(10px)', display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: '0 2px 8px rgba(0,0,0,0.1)' }}>{children}</div>
  );
}

function HFReview({ name, initial, color, stars, text }) {
  return (
    <div style={{ padding: '10px 0', borderBottom: '1px solid var(--line-2)' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 4 }}>
        <div className="hf-avatar" style={{ width: 26, height: 26, fontSize: 11, background: color }}>{initial}</div>
        <div style={{ fontSize: 12, fontWeight: 700 }}>{name}</div>
        <div style={{ fontSize: 11, color: '#f59e0b' }}>{'★'.repeat(stars)}<span style={{ color: '#e5e5ea' }}>{'★'.repeat(5-stars)}</span></div>
      </div>
      <div style={{ fontSize: 12, color: 'var(--text-2)', lineHeight: 1.4 }}>{text}</div>
    </div>
  );
}

Object.assign(window, { HFDetail, IconBtn, HFReview });
