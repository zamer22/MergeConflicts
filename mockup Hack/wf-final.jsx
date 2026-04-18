// Wireframes FINALES — versiones consolidadas según decisiones del usuario

// ═══════════════════════════════════════════════════════════
// 01 — MAPA (versión A — full-bleed + bottom sheet)
// ═══════════════════════════════════════════════════════════
function MapFinal() {
  return (
    <PhoneFrame rotate="r1">
      <StatusBar />
      <div style={{ padding: '6px 14px 10px', position: 'relative', zIndex: 4 }}>
        <div className="wf-box" style={{ display: 'flex', alignItems: 'center', padding: '8px 12px', gap: 8, borderRadius: 100 }}>
          <div className="wf-circle" style={{ width: 22, height: 22, fontSize: 12 }}>🔍</div>
          <div style={{ flex: 1, fontSize: 14, color: 'var(--ink-3)' }}>Buscar eventos o lugares</div>
          <div className="wf-pill accent" style={{ padding: '2px 8px', fontSize: 12 }}>Filtros</div>
        </div>
      </div>

      <div style={{ display: 'flex', gap: 6, padding: '0 14px 10px', overflow: 'hidden' }}>
        <div className="wf-pill green">Ahora</div>
        <div className="wf-pill yellow">Pronto</div>
        <div className="wf-pill">Hoy</div>
        <div className="wf-pill">Finde</div>
      </div>

      <div style={{ flex: 1, position: 'relative', background: '#e8e4d4', overflow: 'hidden', borderTop: '1.5px solid var(--ink)', borderBottom: '1.5px solid var(--ink)' }}>
        <svg width="100%" height="100%" style={{ position: 'absolute', inset: 0 }}>
          <path d="M0 60 Q 80 80 160 50 T 320 70" stroke="#b8b1a0" strokeWidth="18" fill="none" />
          <path d="M40 0 L 60 400" stroke="#b8b1a0" strokeWidth="14" fill="none" />
          <path d="M200 0 L 210 400" stroke="#b8b1a0" strokeWidth="12" fill="none" />
          <path d="M0 180 Q 160 160 320 200" stroke="#c9c2af" strokeWidth="10" fill="none" />
          <path d="M0 320 L 320 310" stroke="#c9c2af" strokeWidth="14" fill="none" />
          <rect x="0" y="360" width="320" height="60" fill="#b8d4e8" opacity="0.6" />
          <path d="M260 0 Q 240 200 280 420" stroke="#b8d4e8" strokeWidth="18" fill="none" opacity="0.7" />
        </svg>

        <MapPin x={50} y={70} color="green" icon="🎵" />
        <MapPin x={130} y={55} color="accent" icon="🎪" big />
        <MapPin x={190} y={90} color="blue" icon="🎨" />
        <MapPin x={90} y={140} color="yellow" icon="🍴" />
        <MapPin x={220} y={160} color="green" icon="🎵" />
        <MapPin x={160} y={200} color="accent" icon="🛒" />
        <MapPin x={70} y={240} color="blue" icon="🎨" />
        <MapPin x={250} y={250} color="green" icon="🏃" />
        <MapPin x={110} y={280} color="yellow" icon="🍴" />

        <div style={{ position: 'absolute', left: 90, top: 30, width: 160, height: 180, borderRadius: '50%', background: 'radial-gradient(circle, rgba(255,90,60,0.28), transparent 70%)', pointerEvents: 'none' }}/>
        <div style={{ position: 'absolute', top: 10, right: 10 }}>
          <div className="ai-badge small">✨ Zona hot</div>
        </div>
      </div>

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
      <TabBar active="mapa" />
    </PhoneFrame>
  );
}

// ═══════════════════════════════════════════════════════════
// 02 — FEED (A + stories en vivo por categoría)
// ═══════════════════════════════════════════════════════════
function FeedFinal() {
  return (
    <PhoneFrame rotate="r1">
      <StatusBar />
      <div style={{ padding: '6px 16px 6px' }}>
        <div className="display" style={{ fontSize: 30, lineHeight: 1 }}>Descubrir</div>
        <div style={{ fontSize: 13, color: 'var(--ink-2)', marginTop: 2 }}>📍 Roma Norte, CDMX</div>
      </div>

      {/* stories en vivo por tipo de evento */}
      <div style={{ padding: '4px 12px 8px' }}>
        <div style={{ fontSize: 11, fontWeight: 700, color: 'var(--accent)', padding: '0 4px 4px', letterSpacing: 1 }}>◉ EN VIVO · PASANDO AHORA</div>
        <div style={{ display: 'flex', gap: 8, padding: '0 4px', overflow: 'hidden' }}>
          {[
            { ic: '🎵', t: '3min' },
            { ic: '🎪', t: '6min' },
            { ic: '🍴', t: '9min' },
            { ic: '🎨', t: '12min' },
            { ic: '🏃', t: '15min' },
          ].map((s, i) => (
            <div key={i} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 3 }}>
              <div style={{ width: 54, height: 54, borderRadius: '50%', border: '2.5px solid var(--accent)', padding: 2, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                <div className="wf-fill-dots" style={{ width: '100%', height: '100%', borderRadius: '50%', border: '1.5px solid var(--ink)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 18 }}>{s.ic}</div>
              </div>
              <div style={{ fontSize: 9, color: 'var(--ink-2)', lineHeight: 1 }}>a {s.t}</div>
            </div>
          ))}
        </div>
      </div>

      {/* buscar */}
      <div style={{ padding: '0 16px 10px' }}>
        <div className="wf-box" style={{ display: 'flex', alignItems: 'center', padding: '6px 10px', borderRadius: 100, gap: 6 }}>
          <span style={{ fontSize: 13 }}>🔍</span>
          <span style={{ fontSize: 13, color: 'var(--ink-3)', flex: 1 }}>Buscar eventos…</span>
          <span className="wf-pill accent" style={{ padding: '0 8px', fontSize: 11 }}>≡</span>
        </div>
      </div>

      {/* chips */}
      <div style={{ display: 'flex', gap: 6, padding: '0 16px 8px', flexWrap: 'nowrap', overflow: 'hidden' }}>
        <div className="wf-pill ink" style={{ fontSize: 12 }}>Todos</div>
        <div className="wf-pill" style={{ fontSize: 12 }}>🎵 Música</div>
        <div className="wf-pill" style={{ fontSize: 12 }}>🎪 Ferias</div>
        <div className="wf-pill" style={{ fontSize: 12 }}>🎨 Arte</div>
      </div>

      {/* AI para ti */}
      <div style={{ margin: '2px 16px 10px', padding: 10, border: '1.5px dashed var(--ink)', borderRadius: 12, background: 'linear-gradient(135deg, rgba(255,90,60,0.08), rgba(255,217,61,0.12))' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 4 }}>
          <div className="ai-badge small">✨ Para ti</div>
          <span style={{ fontSize: 11, color: 'var(--ink-2)' }}>según tus gustos</span>
        </div>
        <div style={{ fontSize: 13, lineHeight: 1.3 }}>3 ferias de diseño este fin de semana · te podrían interesar</div>
      </div>

      <div style={{ flex: 1, overflow: 'hidden', padding: '0 16px' }}>
        <FeedCard badge="AHORA" badgeColor="green" title="Jam session abierta" meta="Parque México · hasta 22:00" tags={['Música', 'Gratis']} going="14"/>
        <FeedCard badge="MAÑANA" badgeColor="yellow" title="Mercado de diseñadores" meta="Sáb 10:00 · Monumento a la Revolución" tags={['Feria', 'Econ. circular']} going="87"/>
      </div>

      <TabBar active="feed" />
    </PhoneFrame>
  );
}

// ═══════════════════════════════════════════════════════════
// 03 — DETALLE (A + tabs Info/Fotos + chat CTA)
// ═══════════════════════════════════════════════════════════
function DetailFinal() {
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

      {/* tabs Info / Fotos — Reseñas se movieron abajo */}
      <div style={{ display: 'flex', gap: 0, margin: '6px 14px 0', borderBottom: '1.5px solid var(--ink-3)' }}>
        <div style={{ padding: '6px 12px', fontSize: 13, fontWeight: 700, borderBottom: '2.5px solid var(--accent)' }}>Info</div>
        <div style={{ padding: '6px 12px', fontSize: 13, color: 'var(--ink-2)' }}>Fotos</div>
      </div>

      {/* info compacta */}
      <div style={{ padding: '10px 16px 6px' }}>
        <div style={{ fontSize: 19, fontWeight: 700, lineHeight: 1.1 }}>Feria de las Flores</div>
        <div style={{ fontSize: 12, color: 'var(--ink-2)', marginTop: 3, lineHeight: 1.3 }}>🗓 Hoy 10:00 – 22:00 · 📍 Plaza de la Ciudadela · a 4 min</div>

        <div style={{ display: 'flex', gap: 4, marginTop: 6, flexWrap: 'wrap' }}>
          <div className="wf-pill" style={{ fontSize: 10 }}>#feria</div>
          <div className="wf-pill" style={{ fontSize: 10 }}>#artesanal</div>
          <div className="wf-pill" style={{ fontSize: 10 }}>#familiar</div>
        </div>
      </div>

      {/* AI SUMMARY */}
      <div style={{ margin: '4px 14px 8px', padding: 10, border: '1.5px solid var(--ink)', borderRadius: 12, background: 'linear-gradient(135deg, rgba(255,90,60,0.1), rgba(255,217,61,0.15))' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 5 }}>
          <div className="ai-badge small">✨ Resumen IA</div>
          <span style={{ fontSize: 10, color: 'var(--ink-2)' }}>de 47 comentarios</span>
        </div>
        <div style={{ fontSize: 12, lineHeight: 1.35 }}>
          Gente destaca los <b>puestos de plantas raras</b> y <b>ambiente tranquilo</b>. Mencionan que <b>se llena después de las 16h</b>.
        </div>
        <div style={{ display: 'flex', gap: 5, marginTop: 6 }}>
          <div className="wf-pill green" style={{ fontSize: 9, padding: '0 6px' }}>+ variedad</div>
          <div className="wf-pill green" style={{ fontSize: 9, padding: '0 6px' }}>+ ambiente</div>
          <div className="wf-pill yellow" style={{ fontSize: 9, padding: '0 6px' }}>– precios</div>
        </div>
      </div>

      {/* asistentes + rating en fila */}
      <div style={{ padding: '0 16px 6px', display: 'flex', alignItems: 'center', gap: 12 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
          <div style={{ display: 'flex' }}>
            {[0,1,2].map(i => <div key={i} className="wf-circle" style={{ width: 24, height: 24, marginLeft: i?-8:0, background: ['var(--accent-soft)','var(--yellow)','var(--blue)'][i] }}/>)}
          </div>
          <div style={{ fontSize: 12, color: 'var(--ink-2)' }}><b>+87</b> van</div>
        </div>
        <div style={{ width: 1, height: 16, background: 'var(--ink-3)' }}/>
        <div style={{ fontSize: 13, fontWeight: 700 }}>★ 4.6</div>
        <div style={{ fontSize: 11, color: 'var(--ink-2)' }}>· 47 opiniones</div>
      </div>

      {/* RESEÑAS debajo — movido desde los tabs */}
      <div style={{ padding: '4px 14px 0', flex: 1, overflow: 'hidden' }}>
        <div style={{ fontSize: 13, fontWeight: 700, marginBottom: 2 }}>Reseñas</div>
        <div style={{ padding: '6px 0', borderBottom: '1px dashed var(--ink-3)' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 2 }}>
            <div className="wf-circle" style={{ width: 20, height: 20, fontSize: 9, background: 'var(--accent-soft)' }}>S</div>
            <div style={{ fontSize: 11, fontWeight: 700 }}>Sofía R.</div>
            <div style={{ fontSize: 10, color: 'var(--accent)' }}>★★★★★</div>
          </div>
          <div style={{ fontSize: 11, color: 'var(--ink-2)', lineHeight: 1.3 }}>Encontré plantas raras, volveré.</div>
        </div>
        <div style={{ padding: '6px 0' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 2 }}>
            <div className="wf-circle" style={{ width: 20, height: 20, fontSize: 9, background: 'var(--yellow)' }}>M</div>
            <div style={{ fontSize: 11, fontWeight: 700 }}>Mario L.</div>
            <div style={{ fontSize: 10, color: 'var(--accent)' }}>★★★★</div>
          </div>
          <div style={{ fontSize: 11, color: 'var(--ink-2)', lineHeight: 1.3 }}>Buen ambiente, hay que llegar temprano.</div>
        </div>
      </div>

      {/* CTA footer con Chat */}
      <div style={{ padding: '10px 14px', borderTop: '1.5px solid var(--ink)', background: 'var(--paper)', display: 'flex', gap: 8 }}>
        <div style={{ flex: 1, border: '1.5px solid var(--ink)', borderRadius: 100, padding: '8px 0', textAlign: 'center', fontSize: 13, fontWeight: 700 }}>💬 Chat</div>
        <div style={{ flex: 1.4, background: 'var(--accent)', border: '1.5px solid var(--ink)', borderRadius: 100, padding: '8px 0', textAlign: 'center', fontSize: 13, fontWeight: 700, color: 'white', boxShadow: '2px 2px 0 var(--ink)' }}>Unirme</div>
        <div style={{ border: '1.5px solid var(--ink)', borderRadius: 100, padding: '8px 12px', fontSize: 13 }}>➕</div>
      </div>
    </PhoneFrame>
  );
}

// ═══════════════════════════════════════════════════════════
// 04 — CREAR (A + mini-mapa para dropear pin)
// ═══════════════════════════════════════════════════════════
function CreateFinal() {
  return (
    <PhoneFrame rotate="r1">
      <StatusBar />
      <div style={{ display: 'flex', alignItems: 'center', padding: '6px 14px 8px', gap: 8, borderBottom: '1.5px solid var(--ink)' }}>
        <div style={{ fontSize: 16 }}>✕</div>
        <div className="display" style={{ fontSize: 24, flex: 1, textAlign: 'center', lineHeight: 1 }}>Nuevo evento</div>
        <div style={{ fontSize: 13, color: 'var(--ink-3)' }}>Borrador</div>
      </div>

      <div style={{ flex: 1, overflow: 'hidden', padding: '10px 14px' }}>
        <div style={{ fontSize: 11, fontWeight: 700, color: 'var(--ink-2)', marginBottom: 6, letterSpacing: 0.5 }}>QUÉ ESTÁ PASANDO</div>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 6, marginBottom: 12 }}>
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
              padding: 5, textAlign: 'center',
              border: '1.5px solid var(--ink)',
              borderRadius: 10,
              background: c.on ? 'var(--accent)' : 'var(--paper)',
              color: c.on ? 'white' : 'var(--ink)',
              boxShadow: c.on ? '2px 2px 0 var(--ink)' : 'none',
            }}>
              <div style={{ fontSize: 16 }}>{c.ic}</div>
              <div style={{ fontSize: 10, fontWeight: c.on ? 700 : 400 }}>{c.l}</div>
            </div>
          ))}
        </div>

        <Field label="Nombre" placeholder="ej. Jam session en el parque"/>

        {/* DÓNDE con mini mapa pin-drop */}
        <div style={{ marginBottom: 10 }}>
          <div style={{ fontSize: 11, fontWeight: 700, color: 'var(--ink-2)', marginBottom: 4, letterSpacing: 0.5 }}>DÓNDE · arrastra el pin</div>
          <div style={{ position: 'relative', height: 110, border: '1.5px solid var(--ink)', borderRadius: 10, overflow: 'hidden', background: '#e8e4d4' }}>
            <svg width="100%" height="100%" style={{ position: 'absolute', inset: 0 }}>
              <path d="M0 30 Q 80 50 160 25 T 320 45" stroke="#b8b1a0" strokeWidth="14" fill="none"/>
              <path d="M60 0 L 80 150" stroke="#b8b1a0" strokeWidth="12" fill="none"/>
              <path d="M200 0 L 210 150" stroke="#b8b1a0" strokeWidth="10" fill="none"/>
              <path d="M0 90 Q 160 100 320 85" stroke="#c9c2af" strokeWidth="8" fill="none"/>
            </svg>
            {/* pin droppable */}
            <div style={{ position: 'absolute', left: '50%', top: '50%', transform: 'translate(-50%, -100%)' }}>
              <div style={{
                width: 34, height: 34,
                background: 'var(--accent)',
                border: '1.5px solid var(--ink)',
                borderRadius: '50% 50% 50% 0',
                transform: 'rotate(-45deg)',
                display: 'flex', alignItems: 'center', justifyContent: 'center',
                boxShadow: '2px 3px 0 rgba(0,0,0,0.2)',
              }}>
                <span style={{ transform: 'rotate(45deg)', fontSize: 14, color: 'white' }}>＋</span>
              </div>
              <div style={{ width: 6, height: 6, background: 'var(--ink)', borderRadius: '50%', margin: '1px auto', transform: 'rotate(45deg)' }}/>
            </div>
            <div style={{ position: 'absolute', bottom: 4, left: 6, right: 6, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <div style={{ fontSize: 11, color: 'var(--ink)', background: 'var(--paper)', border: '1px solid var(--ink)', borderRadius: 100, padding: '1px 8px' }}>📍 Parque México</div>
              <div className="wf-pill accent" style={{ fontSize: 10 }}>Confirmar</div>
            </div>
          </div>
        </div>

        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 8, marginBottom: 10 }}>
          <Field label="Empieza" placeholder="Ahora" compact/>
          <Field label="Termina" placeholder="21:00" compact/>
        </div>

        <div style={{ marginBottom: 8 }}>
          <div style={{ fontSize: 11, fontWeight: 700, color: 'var(--ink-2)', marginBottom: 4, letterSpacing: 0.5 }}>ETIQUETAS</div>
          <div className="wf-box" style={{ padding: '6px 8px', display: 'flex', gap: 4, flexWrap: 'wrap', minHeight: 34 }}>
            <div className="wf-pill accent" style={{ fontSize: 11 }}>#gratis ✕</div>
            <div className="wf-pill accent" style={{ fontSize: 11 }}>#aire-libre ✕</div>
            <div style={{ fontSize: 12, color: 'var(--ink-3)', padding: '2px 4px' }}>+ añadir</div>
          </div>
        </div>

        <div style={{ padding: 8, border: '1.5px dashed var(--ink)', borderRadius: 10, background: 'rgba(255,90,60,0.05)' }}>
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

      <div style={{ padding: 10, borderTop: '1.5px solid var(--ink)' }}>
        <div style={{ background: 'var(--accent)', border: '1.5px solid var(--ink)', borderRadius: 100, padding: '10px 0', textAlign: 'center', fontSize: 14, fontWeight: 700, color: 'white', boxShadow: '2px 2px 0 var(--ink)' }}>Publicar evento</div>
      </div>
    </PhoneFrame>
  );
}

Object.assign(window, { MapFinal, FeedFinal, DetailFinal, CreateFinal });
