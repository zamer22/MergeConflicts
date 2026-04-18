// Wireframes — DETALLE DE EVENTO
// A) Hero grande + info + AI summary destacado   B) Split: info compacta arriba, comentarios prominentes

function DetailVariationA() {
  return (
    <PhoneFrame rotate="r1">
      <StatusBar />

      {/* hero */}
      <div style={{ position: 'relative', borderBottom: '1.5px solid var(--ink)' }}>
        <div className="wf-fill-slash" style={{ height: 160, borderBottom: '1.5px solid var(--ink)' }}/>
        <div style={{ position: 'absolute', top: 10, left: 10, display: 'flex', gap: 6 }}>
          <div className="wf-circle" style={{ width: 30, height: 30, fontSize: 14 }}>←</div>
        </div>
        <div style={{ position: 'absolute', top: 10, right: 10, display: 'flex', gap: 6 }}>
          <div className="wf-circle" style={{ width: 30, height: 30, fontSize: 14 }}>♡</div>
          <div className="wf-circle" style={{ width: 30, height: 30, fontSize: 14 }}>↗</div>
        </div>
        <div style={{ position: 'absolute', bottom: 8, left: 10, display: 'flex', gap: 4 }}>
          <div className="wf-pill green" style={{ fontSize: 10, fontWeight: 700 }}>● EN VIVO</div>
          <div className="wf-pill" style={{ fontSize: 10 }}>Gratis</div>
        </div>
      </div>

      {/* info principal */}
      <div style={{ padding: '10px 16px 8px' }}>
        <div style={{ fontSize: 20, fontWeight: 700, lineHeight: 1.1 }}>Feria de las Flores</div>
        <div style={{ fontSize: 13, color: 'var(--ink-2)', marginTop: 3, lineHeight: 1.3 }}>🗓 Hoy 10:00 – 22:00<br/>📍 Plaza de la Ciudadela · a 4 min</div>

        <div style={{ display: 'flex', gap: 4, marginTop: 8, flexWrap: 'wrap' }}>
          <div className="wf-pill" style={{ fontSize: 10 }}>#feria</div>
          <div className="wf-pill" style={{ fontSize: 10 }}>#artesanal</div>
          <div className="wf-pill" style={{ fontSize: 10 }}>#familiar</div>
        </div>
      </div>

      {/* AI SUMMARY destacado */}
      <div style={{ margin: '4px 16px 8px', padding: 10, border: '1.5px solid var(--ink)', borderRadius: 12, background: 'linear-gradient(135deg, rgba(255,90,60,0.1), rgba(255,217,61,0.15))' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 5 }}>
          <div className="ai-badge small">✨ Resumen IA</div>
          <span style={{ fontSize: 10, color: 'var(--ink-2)' }}>de 47 comentarios</span>
        </div>
        <div style={{ fontSize: 12, lineHeight: 1.35 }}>
          Gente destaca los <b>puestos de plantas raras</b> y <b>ambiente tranquilo</b>. Algunos mencionan que <b>se llena después de las 16h</b>.
        </div>
        <div style={{ display: 'flex', gap: 5, marginTop: 6 }}>
          <div className="wf-pill green" style={{ fontSize: 9, padding: '0 6px' }}>+ variedad</div>
          <div className="wf-pill green" style={{ fontSize: 9, padding: '0 6px' }}>+ ambiente</div>
          <div className="wf-pill yellow" style={{ fontSize: 9, padding: '0 6px' }}>– precios</div>
        </div>
      </div>

      {/* asistentes + botones */}
      <div style={{ padding: '0 16px 10px', display: 'flex', alignItems: 'center', gap: 10 }}>
        <div style={{ display: 'flex' }}>
          {[0,1,2].map(i => <div key={i} className="wf-circle" style={{ width: 26, height: 26, marginLeft: i?-8:0, background: ['var(--accent-soft)','var(--yellow)','var(--blue)'][i] }}/>)}
        </div>
        <div style={{ fontSize: 12, color: 'var(--ink-2)' }}><b>+87</b> van</div>
      </div>

      {/* rating */}
      <div style={{ padding: '0 16px 8px', display: 'flex', alignItems: 'center', gap: 6 }}>
        <div style={{ fontSize: 14, fontWeight: 700 }}>★ 4.6</div>
        <div style={{ fontSize: 11, color: 'var(--ink-2)' }}>· 47 opiniones</div>
      </div>

      <div style={{ flex: 1 }}/>

      {/* CTA footer */}
      <div style={{ padding: '10px 14px', borderTop: '1.5px solid var(--ink)', background: 'var(--paper)', display: 'flex', gap: 8 }}>
        <div style={{ flex: 1, border: '1.5px solid var(--ink)', borderRadius: 100, padding: '8px 0', textAlign: 'center', fontSize: 13, fontWeight: 700 }}>💬 Chat</div>
        <div style={{ flex: 1.4, background: 'var(--accent)', border: '1.5px solid var(--ink)', borderRadius: 100, padding: '8px 0', textAlign: 'center', fontSize: 13, fontWeight: 700, color: 'white', boxShadow: '2px 2px 0 var(--ink)' }}>Unirme</div>
        <div style={{ border: '1.5px solid var(--ink)', borderRadius: 100, padding: '8px 12px', fontSize: 13 }}>➕</div>
      </div>
    </PhoneFrame>
  );
}

// ═══════════ VARIACIÓN B: info compacta + comentarios protagonistas ═══════════
function DetailVariationB() {
  return (
    <PhoneFrame rotate="r2">
      <StatusBar />

      {/* header compacto */}
      <div style={{ padding: '6px 14px 0', display: 'flex', alignItems: 'center', gap: 8 }}>
        <div className="wf-circle" style={{ width: 30, height: 30, fontSize: 14 }}>←</div>
        <div style={{ flex: 1 }}/>
        <div className="wf-circle" style={{ width: 30, height: 30, fontSize: 14 }}>♡</div>
        <div className="wf-circle" style={{ width: 30, height: 30, fontSize: 14 }}>⋯</div>
      </div>

      {/* card info compacta */}
      <div style={{ margin: '10px 14px 0', padding: 10, border: '2px solid var(--ink)', borderRadius: 14, boxShadow: '3px 3px 0 var(--ink)' }}>
        <div style={{ display: 'flex', gap: 10 }}>
          <div className="wf-fill-slash" style={{ width: 64, height: 64, border: '1.5px solid var(--ink)', borderRadius: 8, flexShrink: 0 }}/>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div className="wf-pill green" style={{ fontSize: 9, padding: '0 6px', marginBottom: 3, fontWeight: 700 }}>● EN VIVO</div>
            <div style={{ fontSize: 15, fontWeight: 700, lineHeight: 1.1 }}>Feria de las Flores</div>
            <div style={{ fontSize: 11, color: 'var(--ink-2)', marginTop: 2 }}>Plaza Ciudadela · 4min</div>
          </div>
        </div>
        <div style={{ display: 'flex', gap: 12, marginTop: 8, fontSize: 11 }}>
          <div><b>10:00-22:00</b><br/><span style={{ color: 'var(--ink-2)' }}>horario</span></div>
          <div style={{ width: 1, background: 'var(--ink-3)' }}/>
          <div><b>★ 4.6</b><br/><span style={{ color: 'var(--ink-2)' }}>47 opin.</span></div>
          <div style={{ width: 1, background: 'var(--ink-3)' }}/>
          <div><b>+87 van</b><br/><span style={{ color: 'var(--ink-2)' }}>hoy</span></div>
        </div>
      </div>

      {/* tabs secundarios */}
      <div style={{ display: 'flex', gap: 0, margin: '10px 14px 0', borderBottom: '1.5px solid var(--ink-3)' }}>
        <div style={{ padding: '6px 12px', fontSize: 13, fontWeight: 700, borderBottom: '2.5px solid var(--accent)' }}>Reseñas</div>
        <div style={{ padding: '6px 12px', fontSize: 13, color: 'var(--ink-2)' }}>Info</div>
        <div style={{ padding: '6px 12px', fontSize: 13, color: 'var(--ink-2)' }}>Fotos</div>
      </div>

      {/* AI resumen simple inline */}
      <div style={{ margin: '8px 14px 4px', padding: '8px 10px', background: 'var(--paper-2)', border: '1.5px solid var(--ink)', borderRadius: 10 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 3 }}>
          <span className="ai-badge small">✨</span>
          <span style={{ fontSize: 11, fontWeight: 700 }}>TL;DR de la gente</span>
        </div>
        <div style={{ fontSize: 11, lineHeight: 1.3, color: 'var(--ink-2)' }}>Ambiente tranqui, puestos variados, se llena tarde.</div>
      </div>

      {/* comentarios */}
      <div style={{ flex: 1, overflow: 'hidden', padding: '4px 14px' }}>
        <Review name="Sofía R." stars={5} text="Encontré plantas que no se ven por ningún lado. Volveré."/>
        <Review name="Mario L." stars={4} text="Buen ambiente pero hay que llegar temprano, después se llena."/>
        <Review name="Ana P." stars={5} text="Los vendedores son muy amables. Pago solo efectivo."/>
      </div>

      {/* CTA */}
      <div style={{ padding: '10px 14px', borderTop: '1.5px solid var(--ink)', display: 'flex', gap: 8 }}>
        <div className="wf-box" style={{ flex: 1, padding: '6px 10px', borderRadius: 100, fontSize: 12, color: 'var(--ink-3)' }}>Escribe una reseña…</div>
        <div style={{ background: 'var(--accent)', border: '1.5px solid var(--ink)', borderRadius: 100, padding: '6px 16px', fontSize: 13, fontWeight: 700, color: 'white' }}>Unirme</div>
      </div>
    </PhoneFrame>
  );
}

function Review({ name, stars, text }) {
  return (
    <div style={{ padding: '8px 0', borderBottom: '1px dashed var(--ink-3)' }}>
      <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 3 }}>
        <div className="wf-circle" style={{ width: 22, height: 22, fontSize: 10, background: 'var(--accent-soft)' }}>{name[0]}</div>
        <div style={{ fontSize: 12, fontWeight: 700 }}>{name}</div>
        <div style={{ fontSize: 11, color: 'var(--accent)' }}>{'★'.repeat(stars)}</div>
      </div>
      <div style={{ fontSize: 12, color: 'var(--ink-2)', lineHeight: 1.3 }}>{text}</div>
    </div>
  );
}

Object.assign(window, { DetailVariationA, DetailVariationB });
