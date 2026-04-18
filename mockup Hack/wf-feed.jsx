// Wireframes — FEED / Descubrir
// A) Feed vertical con cards grandes + chips filtro    B) Stories top + feed dual-column con "acontece ahora"

function FeedVariationA() {
  return (
    <PhoneFrame rotate="r1">
      <StatusBar />
      {/* header */}
      <div style={{ padding: '6px 16px 10px' }}>
        <div className="display" style={{ fontSize: 30, lineHeight: 1 }}>Descubrir</div>
        <div style={{ fontSize: 13, color: 'var(--ink-2)', marginTop: 2 }}>📍 Roma Norte, CDMX</div>
      </div>

      {/* buscar + filtros */}
      <div style={{ padding: '0 16px 10px' }}>
        <div className="wf-box" style={{ display: 'flex', alignItems: 'center', padding: '6px 10px', borderRadius: 100, gap: 6 }}>
          <span style={{ fontSize: 13 }}>🔍</span>
          <span style={{ fontSize: 13, color: 'var(--ink-3)', flex: 1 }}>Buscar eventos…</span>
          <span className="wf-pill accent" style={{ padding: '0 8px', fontSize: 11 }}>≡</span>
        </div>
      </div>

      {/* chips de etiquetas */}
      <div style={{ display: 'flex', gap: 6, padding: '0 16px 8px', flexWrap: 'nowrap', overflow: 'hidden' }}>
        <div className="wf-pill ink" style={{ fontSize: 12 }}>Todos</div>
        <div className="wf-pill" style={{ fontSize: 12 }}>🎵 Música</div>
        <div className="wf-pill" style={{ fontSize: 12 }}>🎪 Ferias</div>
        <div className="wf-pill" style={{ fontSize: 12 }}>🎨 Arte</div>
      </div>

      {/* AI recomendación card */}
      <div style={{ margin: '6px 16px 10px', padding: 10, border: '1.5px dashed var(--ink)', borderRadius: 12, background: 'linear-gradient(135deg, rgba(255,90,60,0.08), rgba(255,217,61,0.12))' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 4 }}>
          <div className="ai-badge small">✨ Para ti</div>
          <span style={{ fontSize: 11, color: 'var(--ink-2)' }}>según tus gustos</span>
        </div>
        <div style={{ fontSize: 13, lineHeight: 1.3 }}>3 ferias de diseño este fin de semana · te podrían interesar</div>
      </div>

      {/* feed cards */}
      <div style={{ flex: 1, overflow: 'hidden', padding: '0 16px' }}>
        <FeedCard
          badge="AHORA"
          badgeColor="green"
          title="Jam session abierta"
          meta="Parque México · hasta 22:00"
          tags={['Música', 'Gratis']}
          going="14"
        />
        <FeedCard
          badge="MAÑANA"
          badgeColor="yellow"
          title="Mercado de diseñadores"
          meta="Sáb 10:00 · Monumento a la Revolución"
          tags={['Feria', 'Econ. circular']}
          going="87"
        />
      </div>

      <TabBar active="feed" />
    </PhoneFrame>
  );
}

function FeedCard({ badge, badgeColor, title, meta, tags = [], going }) {
  return (
    <div className="wf-box" style={{ marginBottom: 10, padding: 10 }}>
      <div style={{ position: 'relative' }}>
        <div className="wf-fill-slash" style={{ height: 90, borderRadius: 6, border: '1.5px solid var(--ink)', marginBottom: 8 }}/>
        <div style={{ position: 'absolute', top: 6, left: 6 }}>
          <div className={`wf-pill ${badgeColor}`} style={{ fontSize: 10, fontWeight: 700, padding: '1px 8px' }}>{badge}</div>
        </div>
        <div style={{ position: 'absolute', top: 6, right: 6, display: 'flex', gap: 4 }}>
          <div className="wf-circle" style={{ width: 22, height: 22, fontSize: 11, background: 'var(--paper)' }}>♡</div>
        </div>
      </div>
      <div style={{ fontSize: 14, fontWeight: 700, lineHeight: 1.2 }}>{title}</div>
      <div style={{ fontSize: 12, color: 'var(--ink-2)', marginTop: 2 }}>{meta}</div>
      <div style={{ display: 'flex', gap: 4, marginTop: 6, alignItems: 'center' }}>
        {tags.map(t => <div key={t} className="wf-pill" style={{ fontSize: 10, padding: '1px 7px' }}>{t}</div>)}
        <div style={{ flex: 1 }}/>
        <div style={{ fontSize: 11, color: 'var(--ink-2)' }}>👥 {going} van</div>
      </div>
    </div>
  );
}

// ═══════════ VARIACIÓN B: stories de "ahora mismo" + grid + secciones por comunidad ═══════════
function FeedVariationB() {
  return (
    <PhoneFrame rotate="r2">
      <StatusBar />

      <div style={{ padding: '6px 16px 6px', display: 'flex', alignItems: 'baseline', justifyContent: 'space-between' }}>
        <div>
          <div className="display" style={{ fontSize: 28, lineHeight: 1 }}>Qué onda</div>
          <div style={{ fontSize: 12, color: 'var(--ink-2)' }}>📍 a 2km de ti</div>
        </div>
        <div className="wf-circle" style={{ width: 30, height: 30 }}>🔔</div>
      </div>

      {/* stories "PASANDO AHORA" */}
      <div style={{ padding: '4px 10px 8px' }}>
        <div style={{ fontSize: 11, fontWeight: 700, color: 'var(--accent)', padding: '0 6px 4px', letterSpacing: 1 }}>◉ EN VIVO · PASANDO AHORA</div>
        <div style={{ display: 'flex', gap: 8, padding: '0 4px', overflow: 'hidden' }}>
          {['🎵','🎪','🍴','🎨','🏃'].map((ic, i) => (
            <div key={i} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 3 }}>
              <div style={{ width: 54, height: 54, borderRadius: '50%', border: '2.5px solid var(--accent)', padding: 2, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                <div className="wf-fill-dots" style={{ width: '100%', height: '100%', borderRadius: '50%', border: '1.5px solid var(--ink)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 18 }}>{ic}</div>
              </div>
              <div style={{ fontSize: 9, color: 'var(--ink-2)', lineHeight: 1 }}>a {(i+1)*3}min</div>
            </div>
          ))}
        </div>
      </div>

      {/* chips filtros */}
      <div style={{ display: 'flex', gap: 5, padding: '6px 16px 8px', overflow: 'hidden' }}>
        <div className="wf-pill ink" style={{ fontSize: 11 }}>Hoy</div>
        <div className="wf-pill" style={{ fontSize: 11 }}>Finde</div>
        <div className="wf-pill" style={{ fontSize: 11 }}>Gratis</div>
        <div className="wf-pill" style={{ fontSize: 11 }}>Música</div>
      </div>

      {/* AI resumen zona */}
      <div style={{ margin: '2px 16px 8px', padding: '6px 10px', borderRadius: 12, background: 'var(--ink)', color: 'var(--paper)', display: 'flex', alignItems: 'center', gap: 8 }}>
        <div className="ai-badge small">✨ IA</div>
        <div style={{ fontSize: 11, flex: 1, lineHeight: 1.2 }}>Tu colonia está <b>más movida que de costumbre</b></div>
      </div>

      {/* grid 2 col */}
      <div style={{ flex: 1, overflow: 'hidden', padding: '0 16px' }}>
        <div style={{ fontSize: 14, fontWeight: 700, marginBottom: 6 }}>Cerca de ti</div>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 8 }}>
          <GridCard title="Feria floral" meta="200m" tag="Ahora" tagColor="green"/>
          <GridCard title="Concierto" meta="450m" tag="20min" tagColor="yellow"/>
          <GridCard title="Expo fotos" meta="600m" tag="Hoy" tagColor="blue"/>
          <GridCard title="Bazar vinyl" meta="1.2km" tag="Finde"/>
        </div>
      </div>

      <TabBar active="feed"/>
    </PhoneFrame>
  );
}

function GridCard({ title, meta, tag, tagColor }) {
  return (
    <div className="wf-box" style={{ padding: 6 }}>
      <div style={{ position: 'relative' }}>
        <div className="wf-fill-slash" style={{ height: 60, borderRadius: 6, border: '1.5px solid var(--ink)', marginBottom: 5 }}/>
        {tag && <div style={{ position: 'absolute', top: 4, left: 4 }}>
          <div className={`wf-pill ${tagColor || ''}`} style={{ fontSize: 9, padding: '0 6px' }}>{tag}</div>
        </div>}
      </div>
      <div style={{ fontSize: 12, fontWeight: 700, lineHeight: 1.15 }}>{title}</div>
      <div style={{ fontSize: 10, color: 'var(--ink-2)' }}>📍 {meta}</div>
    </div>
  );
}

Object.assign(window, { FeedVariationA, FeedVariationB });
