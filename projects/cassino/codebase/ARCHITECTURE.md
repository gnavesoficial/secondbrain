# ARCHITECTURE

## Visão geral
- Aplicação monolítica web baseada em Next.js App Router.
- Frontend público e administrativo coexistem no mesmo projeto.
- Há backend leve embutido via Route Handlers (`src/app/api/**/route.ts`).
- Parte de estado operacional é persistida em arquivo local (`.data/`) no runtime Node.

## Camadas principais
- **Presentation/UI**: componentes e páginas em `src/app` e `src/components`.
- **Contexto de sessão/auth**: `src/contexts/auth-context.tsx`.
- **Serviços HTTP**: `src/services/apiClient.ts` (client) e `src/services/apiServer.ts` (server).
- **Domínio de regras server-side**: `src/lib/deposit-bonus-store.ts`, `src/lib/double-simulation/*`.
- **API interna**: handlers em `src/app/api`.

## Segmentação de rotas
- Grupo público em `src/app/(public)`.
- Grupo administrativo em `src/app/(admin)`.
- APIs internas no namespace `src/app/api`.
- Layouts compartilhados em `src/app/layouts`.

## Fluxo de autenticação
- Login no cliente chama `/auth` via `apiClient` em `src/contexts/auth-context.tsx`.
- Token é salvo em cookie `session` (client).
- Middleware (`src/middleware.ts`) protege `/profile`, `/affiliate`, `/admin`.
- No admin server-side, `use-auth-admin` valida token chamando `/user`.

## Fluxo de domínio: bônus de depósito
- Entrada por APIs internas em `src/app/api/deposit-bonuses/*`.
- Validação/consumo delegados para `src/lib/deposit-bonus-store.ts`.
- Persistência em `.data/deposit-bonus-rules.json`.
- Controle de concorrência local via fila `writeQueue`.

## Fluxo de domínio: simulação de double
- Configuração admin em `src/app/api/admin/double/simulation-settings/route.ts`.
- Leitura pública de configuração efetiva em `src/app/api/double/simulation-settings/route.ts`.
- Lógica de simulação e ajuste de popularidade em `src/lib/double-simulation/*`.
- Persistência em `.data/double-simulation-settings.json`.

## Padrão de erro e resposta
- Route handlers retornam `NextResponse.json` com mensagens e `status` explícito.
- No frontend, feedback de erro usa toasts e parsing de `axios` error.
- Não há camada central de observabilidade/telemetria detectada.
# Architecture

**Analysis Date:** 2026-03-30

## Pattern Overview

**Overall:** Next.js App Router with a hybrid BFF-style edge (`src/app/api`) and direct upstream API consumption (`src/services/apiClient.ts`, `src/services/apiServer.ts`).

**Key Characteristics:**
- Route groups split public and admin surfaces through `src/app/(public)` and `src/app/(admin)`.
- Shared UI shell is centralized in two layout compositions: `src/app/layouts/main.layout.tsx` and `src/app/layouts/admin.layout.tsx`.
- Domain-specific server logic lives in local libraries under `src/lib` and is exposed through local API routes in `src/app/api`.

## Layers

**Routing and Composition Layer (Next App Router):**
- Purpose: Compose page trees, route params, and top-level request handling.
- Location: `src/app`
- Contains: `page.tsx`, `layout.tsx`, `route.ts`, route-group folders like `(public)` and `(admin)`.
- Depends on: `@src/components`, `@src/contexts`, `@src/services`, `@src/lib`.
- Used by: Browser requests to page and API endpoints.

**Layout Shell Layer:**
- Purpose: Apply shared navigation, header/footer, and shell spacing for each context.
- Location: `src/app/layouts`
- Contains: `main.layout.tsx`, `admin.layout.tsx`, `index.ts`.
- Depends on: `@src/components`, sidebar route maps in `src/components/sidebar/routes.tsx` and `src/components/sidebar/routes.admin.tsx`.
- Used by: `src/app/(public)/layout.tsx` and `src/app/(admin)/layout.tsx`.

**UI Component Layer:**
- Purpose: Reusable presentational and interactive UI building blocks.
- Location: `src/components` and route-local `(components)` folders such as `src/app/(public)/(components)` and `src/app/(admin)/admin/(components)`.
- Contains: Navbar/sidebar primitives, auth modal UI, game UI, section widgets, route-level component sets.
- Depends on: Hooks, interfaces, `@src/services` for client-side data calls.
- Used by: All page modules and layouts.

**Client State and Session Layer:**
- Purpose: Keep authenticated user state and translation cache in browser runtime.
- Location: `src/contexts/auth-context.tsx`, `src/hooks/use-translation.ts`.
- Contains: Auth provider, sign-in/sign-out flow, translation cache synchronization with local API routes.
- Depends on: `js-cookie`, `@src/services/apiClient.ts`, `/api/translate`, `/api/cache-translations`.
- Used by: Public/admin layouts and any authenticated client component.

**Service Gateway Layer:**
- Purpose: Standardize outbound HTTP clients for browser and server-side calls to upstream API.
- Location: `src/services`
- Contains: `apiClient.ts`, `apiServer.ts`, `geolocation.ts`, barrel export in `index.ts`.
- Depends on: `axios`, runtime env `process.env.API_URL`.
- Used by: Server components, client components, auth utility in `src/functions/use-auth-admin.ts`.

**Domain and Persistence Layer (Local Node runtime):**
- Purpose: Encapsulate local business rules and file-backed persistence.
- Location: `src/lib`
- Contains: Deposit bonus rule engine (`src/lib/deposit-bonus-store.ts`), double simulation config/services (`src/lib/double-simulation/*`), auth header parser (`src/lib/api-auth.ts`).
- Depends on: Node modules (`fs`, `path`, `crypto`) and in-memory mutation queue patterns.
- Used by: API route handlers under `src/app/api`.

**API Adapter Layer (BFF Endpoints):**
- Purpose: Expose internal capabilities to browser as stable local endpoints.
- Location: `src/app/api`
- Contains: Translation/cache endpoints, admin/public double simulation settings, deposit bonus admin/user endpoints.
- Depends on: `@src/lib/*`, `NextRequest`/`NextResponse`.
- Used by: Client hooks/pages via `fetch('/api/...')`.

## Data Flow

**Flow Name: Server-rendered game launch (`/casino/[plataform]/[slug]`)**

1. Request enters `src/app/(public)/casino/[plataform]/[slug]/page.tsx`.
2. Page reads session cookie with `cookies()` and fetches game metadata via `apiServer.get('/game/slug/...')`.
3. Page calls upstream run endpoint via `apiServer.post('/games/run', ...)` and passes data to `FrameGame` component from `src/app/(public)/casino/[plataform]/[slug]/(components)/frame-game.tsx`.

**Flow Name: Admin guard and shell composition**

1. Request enters `src/app/(admin)/layout.tsx`.
2. `useAuthAdmin()` from `src/functions/use-auth-admin.ts` reads cookie from `next/headers` and validates token against `/user` via `apiServer`.
3. On success, tree renders `AdminLayout`; on failure, execution redirects to `/`.

**Flow Name: Double simulation settings lifecycle**

1. Admin UI in `src/app/(admin)/admin/double/simulation/page.tsx` calls `/api/admin/double/simulation-settings`.
2. API route `src/app/api/admin/double/simulation-settings/route.ts` validates bearer token and updates local store via `src/lib/double-simulation/adminSettings.ts`.
3. Public game UI in `src/app/(public)/casino/originals/double/page.tsx` polls `/api/double/simulation-settings` and computes simulated users through `applyDoubleSimulation()` from `src/lib/double-simulation/simulationService.ts`.

**State Management:**
- Global authenticated user state uses React context in `src/contexts/auth-context.tsx`.
- Translation state uses module-level singleton + listeners in `src/hooks/use-translation.ts`.
- Local server-side state persists in JSON files under `.data` (paths created by `src/lib/deposit-bonus-store.ts` and `src/lib/double-simulation/adminSettings.ts`).

## Key Abstractions

**Route Group Separation:**
- Purpose: Isolate public and admin trees without URL pollution.
- Examples: `src/app/(public)`, `src/app/(admin)`.
- Pattern: Next.js App Router route groups with dedicated layout files.

**Service Pair (`apiClient` / `apiServer`):**
- Purpose: Distinguish browser-side and server-side HTTP entry points while keeping same base URL model.
- Examples: `src/services/apiClient.ts`, `src/services/apiServer.ts`.
- Pattern: Axios instance wrappers with centralized base URL and auth header injection.

**Sidebar Route Registry:**
- Purpose: Keep navigation metadata declarative and contextual.
- Examples: `src/components/sidebar/routes.tsx`, `src/components/sidebar/routes.admin.tsx`, `src/components/sidebar/route-context.ts`.
- Pattern: Hook-returned route arrays filtered by pathname context.

**Node Runtime Domain Modules:**
- Purpose: Keep business logic out of route handlers.
- Examples: `src/lib/deposit-bonus-store.ts`, `src/lib/double-simulation/adminSettings.ts`, `src/lib/double-simulation/simulationService.ts`.
- Pattern: Pure/service functions consumed by route handlers.

## Entry Points

**Public Root Entry:**
- Location: `src/app/(public)/page.tsx`
- Triggers: HTTP GET `/`
- Responsibilities: Compose hero/topbar/platform sections and inject auth URL detector.

**Admin Root Entry:**
- Location: `src/app/(admin)/admin/page.tsx`
- Triggers: HTTP GET `/admin`
- Responsibilities: Render dashboard summary modules under admin shell.

**Middleware Entry:**
- Location: `src/middleware.ts`
- Triggers: Requests matching `/profile/:path*`, `/affiliate/:path*`, `/admin/:path*`.
- Responsibilities: Enforce session cookie presence and redirect unauthenticated requests.

**API Route Entries:**
- Location: `src/app/api/**/route.ts`
- Triggers: Browser `fetch('/api/...')` and internal API calls.
- Responsibilities: Validate requests, call domain libraries, return normalized JSON responses.

## Error Handling

**Strategy:** Per-boundary try/catch with user-facing fallback in UI and JSON error payloads in route handlers.

**Patterns:**
- Client pages/components catch request errors and surface toast feedback (`react-hot-toast`) as in `src/app/(public)/casino/originals/double/page.tsx` and `src/app/(admin)/admin/double/simulation/page.tsx`.
- API routes return explicit status codes and message payloads in handlers like `src/app/api/admin/deposit-bonuses/route.ts` and `src/app/api/deposit-bonuses/consume/route.ts`.

## Cross-Cutting Concerns

**Logging:** `console.log`/`console.error` usage appears in server pages, hooks, and routes (for example `src/app/(public)/casino/[plataform]/[slug]/page.tsx`, `src/hooks/use-translation.ts`, `src/app/api/translate/route.ts`).
**Validation:** Input normalization and guard validation are centralized in library functions (`normalizeDoubleSimulationSettingsInput` in `src/lib/double-simulation/doubleSimulationConfig.ts`, `normalizeRuleInput` in `src/lib/deposit-bonus-store.ts`).
**Authentication:** Cookie-based session token (`session`) is read in middleware/layout/functions; bearer token is parsed through `resolveAuthToken` in `src/lib/api-auth.ts` for `/api` routes.

---

*Architecture analysis: 2026-03-30*
