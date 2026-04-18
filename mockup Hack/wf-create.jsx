// Wireframes — CREAR / PUBLICAR EVENTO
// A) Formulario lineal tipo Waze "reportar"      B) Quick-post con pin en mapa y formulario progresivo

function CreateVariationA() {
  return (
    <PhoneFrame rotate="r1">
      <StatusBar />
      {/* header */}
      <div style={{ display: 'flex', alignItems: 'center', padding: '6px 14px 10px', gap: 8, borderBottom: '1.5px solid var(--ink)' }}>
        <div style={{ fontSize: 16 }}>✕</div>
        <div className="display" style={{ fontSize: 24, flex: 1, textAlign: 'center', lineHeight: 1 }}>Nuevo evento</div>
        <div style={{ fontSize: 13, color: 'var(--ink-3)' }}>Borrador</div>
      </div>

      {/* scroll content */}
      <div style={{ flex: 1, overflow: 'hidden', padding: '12px 14px' }}>
        {/* categoría visual tipo Waze */}
        <div style={{ fontSize: 11, fontWeight: 700, color: 'var(--ink-2)', marginBottom: 6, letterSpacing: 0.5 }}>QUÉ ESTÁ PASANDO</div>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 6, marginBottom: 14 }}>
          {[
            { ic: '🎵', l: 'Música', on: true },
            { ic: '🎪', l: 'Feria' },
            { ic: '🎨', l: 'Arte' },
            { ic: '🍴', l: 'Comida' },
            { ic: '🏃', l: 'Deporte' },
            { ic: '🛒', l: 'Mercado' },
            { ic: '📚', l: 'Taller' },
            { ic: '＋', l: 'Otro' },
          ].map((c, i) => (
            <div key={i} style={{
              padding: 6, textAlign: 'center',
              border: '1.5px solid var(--ink)',
              borderRadius: 10,
              background: c.on ? 'var(--accent)' : 'var(--paper)',
              color: c.on ? 'white' : 'var(--ink)',
              boxShadow: c.on ? '2px 2px 0 var(--ink)' : 'none',
            }}>
              <div style={{ fontSize: 18 }}>{c.ic}</div>
              <div style={{ fontSize: 10, fontWeight: c.on ? 700 : 400 }}>{c.l}</div>
            </div>
          ))}
        </div>

        {/* nombre */}
        <Field label="Nombre" placeholder="ej. Jam session en el parque"/>
        {/* ubicación */}
        <div style={{ marginBottom: 10 }}>
          <div style={{ fontSize: 11, fontWeight: 700, color: 'var(--ink-2)', marginBottom: 4, letterSpacing: 0.5 }}>DÓNDE</div>
          <div className="wf-box" style={{ padding: '8px 10px', display: 'flex', alignItems: 'center', gap: 6 }}>
            <span style={{ fontSize: 13 }}>📍</span>
            <span style={{ fontSize: 13, flex: 1 }}>Parque México · Roma Nte.</span>
            <span style={{ fontSize: 11, color: 'var(--accent)', fontWeight: 700 }}>mapa</span>
          </div>
        </div>
        {/* cuándo */}
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 8, marginBottom: 10 }}>
          <Field label="Empieza" placeholder="Ahora" compact/>
          <Field label="Termina" placeholder="21:00" compact/>
        </div>
        {/* etiquetas */}
        <div style={{ marginBottom: 10 }}>
          <div style={{ fontSize: 11, fontWeight: 700, color: 'var(--ink-2)', marginBottom: 4, letterSpacing: 0.5 }}>ETIQUETAS</div>
          <div className="wf-box" style={{ padding: '6px 8px', display: 'flex', gap: 4, flexWrap: 'wrap', minHeight: 38 }}>
            <div className="wf-pill accent" style={{ fontSize: 11 }}>#gratis ✕</div>
            <div className="wf-pill accent" style={{ fontSize: 11 }}>#aire-libre ✕</div>
            <div style={{ fontSize: 12, color: 'var(--ink-3)', padding: '2px 4px' }}>+ añadir</div>
          </div>
        </div>

        {/* AI sugerencias */}
        <div style={{ padding: 8, border: '1.5px dashed var(--ink)', borderRadius: 10, background: 'rgba(255,90,60,0.05)', marginBottom: 10 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 4 }}>
            <div className="ai-badge small">✨ IA</div>
            <span style={{ fontSize: 10, color: 'var(--ink-2)' }}>sugerencias</span>
          </div>
          <div style={{ display: 'flex', gap: 4, flexWrap: 'wrap' }}>
            <div className="wf-pill" style={{ fontSize: 11 }}>+ #música-en-vivo</div>
            <div className="wf-pill" style={{ fontSize: 11 }}>+ #familiar</div>
          </div>
        </div>
      </div>

      {/* CTA */}
      <div style={{ padding: 12, borderTop: '1.5px solid var(--ink)' }}>
        <div style={{ background: 'var(--accent)', border: '1.5px solid var(--ink)', borderRadius: 100, padding: '10px 0', textAlign: 'center', fontSize: 14, fontWeight: 700, color: 'white', boxShadow: '2px 2px 0 var(--ink)' }}>Publicar evento</div>
      </div>
    </PhoneFrame>
  );
}

function Field({ label, placeholder, compact }) {
  return (
    <div style={{ marginBottom: 10 }}>
      <div style={{ fontSize: 11, fontWeight: 700, color: 'var(--ink-2)', marginBottom: 4, letterSpacing: 0.5 }}>{label.toUpperCase()}</div>
      <div className="wf-box" style={{ padding: compact ? '6px 10px' : '8px 10px', fontSize: 13, color: 'var(--ink-3)' }}>{placeholder}</div>
    </div>
  );
}

// ═══════════ VARIACIÓN B: estilo "dropear pin" rápido como Waze ═══════════
function CreateVariationB() {
  return (
    <PhoneFrame rotate="r2">
      <StatusBar />

      {/* header */}
      <div style={{ display: 'flex', alignItems: 'center', padding: '6px 14px 8px', gap: 8 }}>
        <div style={{ fontSize: 16 }}>←</div>
        <div className="display" style={{ fontSize: 24, flex: 1, lineHeight: 1 }}>Reportar evento</div>
      </div>

      {/* mapa interactivo con pin a colocar */}
      <div style={{ position: 'relative', height: 230, background: '#e8e4d4', borderTop: '1.5px solid var(--ink)', borderBottom: '1.5px solid var(--ink)', overflow: 'hidden' }}>
        <svg width="100%" height="100%" style={{ position: 'absolute', inset: 0 }}>
          <path d="M0 60 Q 80 80 160 50 T 320 70" stroke="#b8b1a0" strokeWidth="18" fill="none" />
          <path d="M40 0 L 60 300" stroke="#b8b1a0" strokeWidth="14" fill="none" />
          <path d="M200 0 L 210 300" stroke="#b8b1a0" strokeWidth="12" fill="none" />
          <path d="M0 170 Q 160 150 320 180" stroke="#c9c2af" strokeWidth="10" fill="none" />
        </svg>
        {/* pin que se coloca */}
        <div style={{ position: 'absolute', left: '50%', top: '50%', transform: 'translate(-50%, -100%)' }}>
          <div style={{
            width: 44, height: 44,
            background: 'var(--accent)',
            border: '2px solid var(--ink)',
            borderRadius: '50% 50% 50% 0',
            transform: 'rotate(-45deg)',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            boxShadow: '2px 3px 0 rgba(0,0,0,0.2)',
          }}>
            <span style={{ transform: 'rotate(45deg)', fontSize: 20 }}>＋</span>
          </div>
          <div style={{ width: 8, height: 8, background: 'var(--ink)', borderRadius: '50%', margin: '2px auto', transform: 'rotate(45deg)' }}/>
        </div>
        {/* hint */}
        <div style={{ position: 'absolute', top: 10, left: '50%', transform: 'translateX(-50%)' }}>
          <div className="wf-pill ink" style={{ fontSize: 11 }}>Arrastra para ubicar 👉</div>
        </div>
        <div style={{ position: 'absolute', bottom: 8, left: '50%', transform: 'translateX(-50%)' }}>
          <div className="wf-pill accent" style={{ fontSize: 11, boxShadow: '1.5px 1.5px 0 var(--ink)' }}>Confirmar esta ubicación</div>
        </div>
      </div>

      {/* tipo de evento — grande tipo Waze */}
      <div style={{ padding: '12px 14px 4px' }}>
        <div style={{ fontSize: 13, fontWeight: 700, marginBottom: 8 }}>¿Qué pasa aquí?</div>
        <div style={{ display: 'flex', gap: 8, overflow: 'hidden' }}>
          {[
            { ic: '🎵', l: 'Música', on: true },
            { ic: '🎪', l: 'Feria' },
            { ic: '🎨', l: 'Arte' },
            { ic: '🍴', l: 'Comida' },
          ].map((c, i) => (
            <div key={i} style={{
              minWidth: 64, padding: '8px 6px', textAlign: 'center',
              border: '1.5px solid var(--ink)',
              borderRadius: 12,
              background: c.on ? 'var(--accent)' : 'var(--paper)',
              color: c.on ? 'white' : 'var(--ink)',
              boxShadow: c.on ? '2px 2px 0 var(--ink)' : 'none',
            }}>
              <div style={{ fontSize: 22 }}>{c.ic}</div>
              <div style={{ fontSize: 11, fontWeight: 700, marginTop: 2 }}>{c.l}</div>
            </div>
          ))}
        </div>
      </div>

      {/* campo quick */}
      <div style={{ padding: '10px 14px' }}>
        <div className="wf-box" style={{ padding: '8px 10px', fontSize: 13, color: 'var(--ink-3)' }}>Título breve…</div>
        <div style={{ display: 'flex', gap: 6, marginTop: 8 }}>
          <div className="wf-pill" style={{ fontSize: 11 }}>⏱ Ahora</div>
          <div className="wf-pill" style={{ fontSize: 11 }}>↔ 2h</div>
          <div className="wf-pill" style={{ fontSize: 11 }}>＋ foto</div>
        </div>
      </div>

      <div style={{ flex: 1 }}/>

      {/* CTA footer */}
      <div style={{ padding: 12, borderTop: '1.5px solid var(--ink)' }}>
        <div style={{ background: 'var(--accent)', border: '1.5px solid var(--ink)', borderRadius: 100, padding: '10px 0', textAlign: 'center', fontSize: 14, fontWeight: 700, color: 'white', boxShadow: '2px 2px 0 var(--ink)' }}>🚀 Dropear pin ahora</div>
      </div>
    </PhoneFrame>
  );
}

Object.assign(window, { CreateVariationA, CreateVariationB });
