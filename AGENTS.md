# AGENTS.md — Drop

## ¿Qué es Drop?

Drop es una app móvil iOS que te saca de tu casa en menos de 5 minutos.
No es un app de eventos. Es un app de impulso social espontáneo con consecuencias reales.

El usuario abre la app, ve rallies activos cerca de él ahora mismo, paga un entry fee mínimo para unirse, y va. Si cancela, pierde el dinero. Si va, construye reputación.

Los negocios locales (bares, restaurantes, gimnasios) pagan para ser el venue de un rally y atraer clientes jóvenes.

---

## Problema que resuelve

Meetup es para gente mayor, cobra al organizador, no tiene urgencia ni consecuencias, y Gen Z no lo usa.
La gente de 18-27 quiere salir pero es perezosa para planear.
Drop elimina la fricción: tú no decides nada, solo dices sí o no.

---

## Stack tecnológico y por qué

### SwiftUI (no UIKit)
- Velocidad de desarrollo: misma pantalla en 3x menos código
- Animaciones nativas fluidas sin librerías externas
- Componentes iOS premium desde el día uno
- Ideal para hackathon: resultado visual impresionante rápido

### Supabase (no Firebase)
- Base de datos relacional (PostgreSQL): Drop necesita relaciones complejas entre usuarios, rallies, venues y pagos
- Firestore de Firebase no escala bien con relaciones — se vuelve caos
- Auth, Realtime, Storage y DB en un solo SDK
- SDK oficial de Swift bien documentado
- Realtime nativo: los rallies se actualizan en vivo sin polling

### MapKit (nativo Apple)
- Gratis, sin API keys, sin límites
- Integración nativa con SwiftUI en 10 líneas de código
- Para el mapa de rallies activos cerca del usuario

### Stripe SDK
- Sandbox mode: demos de pagos reales sin cobrar
- Entry fee del rally: el diferenciador más importante de Drop
- SDK oficial para iOS

---

## Arquitectura del proyecto

```
Drop/
├── App/
│   └── DropApp.swift
├── Core/
│   ├── Supabase/
│   │   └── SupabaseClient.swift       # Cliente singleton de Supabase
│   ├── Auth/
│   │   └── AuthManager.swift          # Login, registro, sesión
│   └── Location/
│       └── LocationManager.swift      # CLLocationManager wrapper
├── Features/
│   ├── Home/
│   │   ├── HomeView.swift             # Mapa + lista de rallies activos
│   │   └── HomeViewModel.swift
│   ├── Rally/
│   │   ├── RallyCardView.swift        # Card de un rally
│   │   ├── RallyDetailView.swift      # Detalle + botón de unirse
│   │   ├── RallyDetailViewModel.swift
│   │   └── CreateRallyView.swift      # Crear un nuevo rally
│   ├── Profile/
│   │   ├── ProfileView.swift          # Score, historial, badges
│   │   └── ProfileViewModel.swift
│   └── Payment/
│       └── StripePaymentView.swift    # Entry fee
├── Models/
│   ├── Rally.swift
│   ├── User.swift
│   └── Venue.swift
└── Resources/
    └── Assets.xcassets
```

---

## Esquema de base de datos (Supabase)

```sql
-- Usuarios
create table users (
  id uuid primary key default gen_random_uuid(),
  email text unique not null,
  username text unique not null,
  avatar_url text,
  rally_score integer default 0,
  rallies_attended integer default 0,
  created_at timestamp default now()
);

-- Venues (negocios locales patrocinadores)
create table venues (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  address text not null,
  lat double precision not null,
  lng double precision not null,
  category text,
  is_sponsor boolean default false,
  created_at timestamp default now()
);

-- Rallies
create table rallies (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text,
  venue_id uuid references venues(id),
  creator_id uuid references users(id),
  entry_fee integer default 20,
  max_participants integer default 20,
  starts_at timestamp not null,
  expires_at timestamp not null,
  status text default 'active',
  lat double precision not null,
  lng double precision not null,
  created_at timestamp default now()
);

-- Participantes
create table rally_participants (
  id uuid primary key default gen_random_uuid(),
  rally_id uuid references rallies(id),
  user_id uuid references users(id),
  joined_at timestamp default now(),
  payment_status text default 'pending',
  stripe_payment_intent text,
  cancelled_at timestamp,
  unique(rally_id, user_id)
);
```

---

## Flujo principal de la app

### 1. Onboarding
- Login con Apple o email via Supabase Auth
- Pedir permisos de ubicación
- Crear username + avatar

### 2. Home (pantalla principal)
- Mapa con MapKit mostrando rallies activos como pins
- Lista de rallies ordenados por distancia y urgencia
- Cada card muestra: título, venue, cuántos van, tiempo restante, entry fee

### 3. Rally Detail
- Descripción del rally y del venue
- Quiénes ya se unieron (avatars)
- Barra de progreso de participantes
- Botón "Drop in" → pagar entry fee con Stripe
- Una vez pagado, apareces en la lista

### 4. Cancelación
- Cancelas antes de 2 horas → pierdes el entry fee
- Cancelas antes → reembolso parcial (50%)
- El dinero va al fondo del rally

### 5. Post-rally
- Rate a los otros participantes
- Tu rally_score sube según asistencia + ratings
- Badges: "First Drop", "5 Rallies", "Top Rated"

### 6. Crear Rally
- Título + descripción
- Seleccionar venue en el mapa
- Entry fee, máx participantes, hora
- Venues sponsor → rally aparece destacado

---

## Pantallas para el hackathon (MVP)

Construir en este orden:

1. **HomeView** — mapa + lista de rallies activos
2. **RallyDetailView** — detalle + botón Drop in
3. **ProfileView** — score y rallies asistidos
4. **CreateRallyView** — crear un rally

Dejar para después:
- Stripe real (usar mock en demo)
- Cancelación y reembolso real
- Notificaciones push
- Venue dashboard para negocios

---

## Diferenciadores vs Meetup

| | Meetup | Drop |
|---|---|---|
| Quién paga | Organizador ($16/mes) | Negocios locales |
| Urgencia | Días de anticipación | Horas o minutos |
| Consecuencias | Sin costo de cancelar | Entry fee que pierdes |
| Target | Adultos mayores | Gen Z 18-27 |
| Gamificación | Ninguna | Score + badges |
| Modelo B2B | No | Venues patrocinados |
| Rating Trustpilot | 1.3/5 | — |

---

## Variables de entorno

```
SUPABASE_URL=
SUPABASE_ANON_KEY=
STRIPE_PUBLISHABLE_KEY=
```

---

## Convenciones de código

- `@MainActor` en todos los ViewModels
- Patrón MVVM estricto: la View no llama a Supabase directamente
- Todos los errores con `Result<T, Error>` o `throws`
- `async/await` para todas las llamadas async
- Naming en inglés, comentarios en español

---

## ODS

- **ODS 11** — Ciudades sostenibles: fomenta conexión humana presencial en espacios urbanos locales
- **ODS 8** — Trabajo decente: genera tráfico y revenue para negocios locales pequeños

---

## Pitch en una frase

**"Drop elimina la fricción de salir: abres la app, pagas el entry, vas. No hay excusas."**
