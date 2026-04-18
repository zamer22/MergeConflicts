// Pantalla PERFIL + componentes finales restantes

function ProfileFinal() {
  return (
    <PhoneFrame rotate="r1">
      <StatusBar />

      {/* header */}
      <div style={{ padding: '6px 14px 8px', display: 'flex', alignItems: 'center' }}>
        <div className="display" style={{ fontSize: 26, flex: 1, lineHeight: 1 }}>Mi perfil</div>
        <div className="wf-circle" style={{ width: 30, height: 30, fontSize: 14 }}>⚙</div>
      </div>

      {/* avatar + nombre */}
      <div style={{ padding: '4px 14px 10px', display: 'flex', alignItems: 'center', gap: 12 }}>
        <div style={{ width: 68, height: 68, borderRadius: '50%', border: '2px solid var(--ink)', background: 'var(--accent-soft)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 28, fontWeight: 700 }}>A</div>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ fontSize: 17, fontWeight: 700, lineHeight: 1.1 }}>Ana Rivera</div>
          <div style={{ fontSize: 12, color: 'var(--ink-2)' }}>@anarivera · Roma Nte, CDMX</div>
          <div style={{ display: 'flex', gap: 10, marginTop: 4 }}>
            <div style={{ fontSize: 11 }}><b>42</b> eventos</div>
            <div style={{ fontSize: 11 }}><b>128</b> seguidores</div>
            <div style={{ fontSize: 11 }}><b>87</b> sigo</div>
          </div>
        </div>
      </div>

      {/* INTERESES */}
      <div style={{ padding: '6px 14px' }}>
        <div style={{ fontSize: 11, fontWeight: 700, color: 'var(--ink-2)', letterSpacing: 0.5, marginBottom: 5 }}>MIS INTERESES</div>
        <div style={{ display: 'flex', gap: 5, flexWrap: 'wrap' }}>
          <div className="wf-pill accent" style={{ fontSize: 11 }}>🎵 Música</div>
          <div className="wf-pill accent" style={{ fontSize: 11 }}>🎨 Arte</div>
          <div className="wf-pill accent" style={{ fontSize: 11 }}>🛒 Mercados</div>
          <div className="wf-pill accent" style={{ fontSize: 11 }}>📚 Talleres</div>
          <div className="wf-pill" style={{ fontSize: 11, borderStyle: 'dashed' }}>+ editar</div>
        </div>
      </div>

      {/* AI recomendación basada en intereses */}
      <div style={{ margin: '10px 14px', padding: 9, border: '1.5px dashed var(--ink)', borderRadius: 12, background: 'linear-gradient(135deg, rgba(255,90,60,0.08), rgba(255,217,61,0.12))' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 3 }}>
          <div className="ai-badge small">✨ IA</div>
          <span style={{ fontSize: 10, color: 'var(--ink-2)' }}>recomendación</span>
        </div>
        <div style={{ fontSize: 12, lineHeight: 1.3 }}>Basado en tus gustos: <b>Bazar de diseño sábado</b> te encantaría 🎨</div>
      </div>

      {/* tabs */}
      <div style={{ display: 'flex', gap: 0, margin: '4px 14px 0', borderBottom: '1.5px solid var(--ink-3)' }}>
        <div style={{ padding: '6px 10px', fontSize: 12, fontWeight: 700, borderBottom: '2.5px solid var(--accent)' }}>Próximos</div>
        <div style={{ padding: '6px 10px', fontSize: 12, color: 'var(--ink-2)' }}>Pasados</div>
        <div style={{ padding: '6px 10px', fontSize: 12, color: 'var(--ink-2)' }}>Publicados</div>
      </div>

      {/* listado eventos */}
      <div style={{ flex: 1, overflow: 'hidden', padding: '6px 14px' }}>
        <ProfileEvent title="Jam session · Parque México" date="Hoy · 20:00" status="Voy"/>
        <ProfileEvent title="Mercado diseñadores" date="Sáb · 10:00" status="Guardado"/>
        <ProfileEvent title="Expo arte urbano" date="Dom · 12:00" status="Voy"/>
      </div>

      <TabBar active="perfil"/>
    </PhoneFrame>
  );
}

function ProfileEvent({ title, date, status }) {
  const color = status === 'Voy' ? 'green' : '';
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '6px 0', borderBottom: '1px dashed var(--ink-3)' }}>
      <div className="wf-fill-slash" style={{ width: 40, height: 40, border: '1.5px solid var(--ink)', borderRadius: 8, flexShrink: 0 }}/>
      <div style={{ flex: 1, minWidth: 0 }}>
        <div style={{ fontSize: 13, fontWeight: 700, lineHeight: 1.15 }}>{title}</div>
        <div style={{ fontSize: 11, color: 'var(--ink-2)' }}>{date}</div>
      </div>
      <div className={`wf-pill ${color}`} style={{ fontSize: 10 }}>{status}</div>
    </div>
  );
}

Object.assign(window, { ProfileFinal });
