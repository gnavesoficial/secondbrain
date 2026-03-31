# STRUCTURE

## Diretórios raiz relevantes
- `src/` - código de aplicação.
- `public/` - assets públicos e PWA output.
- `.data/` - dados persistidos localmente no runtime.
- `.next/` - build artifacts de desenvolvimento/produção.
- `node_modules/` - dependências.

## Estrutura principal de `src`
- `src/app/` - rotas App Router (público, admin e API).
- `src/components/` - componentes reutilizáveis de UI e domínio.
- `src/contexts/` - providers e estado compartilhado (ex.: auth).
- `src/services/` - clientes HTTP e integrações diretas.
- `src/lib/` - lógica de domínio server-side e utilitários.
- `src/functions/` - helpers específicos (ex.: auth admin).
- `src/hooks/`, `src/interfaces/`, `src/types/`, `src/config/`.

## Organização de rotas
- `src/app/(public)/...` para páginas públicas (casino, profile, suporte etc.).
- `src/app/(admin)/...` para painel e operações administrativas.
- `src/app/api/...` para endpoints internos.
- `src/app/layouts/` para `main.layout.tsx` e `admin.layout.tsx`.

## Pontos de entrada relevantes
- Layout público principal: `src/app/(public)/layout.tsx`.
- Layout admin principal: `src/app/(admin)/layout.tsx`.
- Middleware global de proteção: `src/middleware.ts`.
- Configuração Next: `next.config.mjs`.

## Convenção de nomes observada
- Mistura de `kebab-case` em arquivos (`use-auth-admin.ts`) e nomes longos descritivos.
- Uso intensivo de route groups `(...)` e segmentos dinâmicos `[id]`, `[slug]`.
- Componentes geralmente em `.tsx`, libs/services em `.ts`.

## APIs internas mapeadas
- Admin bônus: `src/app/api/admin/deposit-bonuses/...`.
- Bônus público/autenticado: `src/app/api/deposit-bonuses/...`.
- Admin/public config double: `src/app/api/admin/double/...` e `src/app/api/double/...`.
- Tradução/cache: `src/app/api/translate/route.ts`, `src/app/api/cache-translations/route.ts`.

## Observações de modularidade
- Boa separação de camada entre UI (`components`) e lógica de domínio (`lib`).
- Persistência por arquivo local mantém simplicidade, porém acopla runtime a disco local.
- `services` centraliza acesso HTTP, reduzindo duplicação de base URL.
# Codebase Structure

**Analysis Date:** 2026-03-30

## Directory Layout

```text
PROJETO - CASSINO/
├── src/                    # Application source code (Next.js App Router + shared modules)
│   ├── app/                # Route tree (`(public)`, `(admin)`, and `api`)
│   ├── components/         # Shared UI components used across routes
│   ├── contexts/           # React context providers (auth)
│   ├── functions/          # Server utility functions used by layouts/pages
│   ├── hooks/              # Reusable client hooks
│   ├── interfaces/         # Shared TypeScript interfaces
│   ├── lib/                # Local domain logic and file-backed stores
│   ├── services/           # Axios clients and service adapters
│   └── types/              # Ambient/custom type declarations
├── public/                 # Static assets, manifest, generated PWA worker files
├── .next/                  # Next.js build/dev output (generated)
├── node_modules/           # Installed dependencies (generated)
├── .planning/              # GSD planning and mapping artifacts
├── next.config.mjs         # Next.js + next-pwa configuration
├── tailwind.config.ts      # Tailwind theme/content configuration
├── postcss.config.js       # PostCSS plugin configuration
├── tsconfig.json           # TypeScript compiler configuration and alias mapping
└── package.json            # Scripts and dependencies
```

## Directory Purposes

**`src/app`:**
- Purpose: Primary routing surface and route-level composition.
- Contains: Public/admin page modules, route-group layouts, and API route handlers.
- Key files: `src/app/(public)/layout.tsx`, `src/app/(admin)/layout.tsx`, `src/app/api/translate/route.ts`.

**`src/app/(public)`:**
- Purpose: Public-facing product area (casino, profile, affiliate, content pages).
- Contains: `page.tsx` routes and route-local `(components)` folders.
- Key files: `src/app/(public)/page.tsx`, `src/app/(public)/casino/[plataform]/[slug]/page.tsx`, `src/app/(public)/casino/originals/double/page.tsx`.

**`src/app/(admin)`:**
- Purpose: Admin panel routes and dashboards under `/admin`.
- Contains: Admin pages and nested `(components)` folders for each management screen.
- Key files: `src/app/(admin)/layout.tsx`, `src/app/(admin)/admin/page.tsx`, `src/app/(admin)/admin/double/simulation/page.tsx`.

**`src/app/api`:**
- Purpose: Local Next.js API endpoints for translation/cache and domain-backed admin/user actions.
- Contains: `route.ts` handlers by feature slice.
- Key files: `src/app/api/admin/deposit-bonuses/route.ts`, `src/app/api/deposit-bonuses/consume/route.ts`, `src/app/api/admin/double/simulation-settings/route.ts`.

**`src/components`:**
- Purpose: Shared cross-route UI primitives and feature widgets.
- Contains: Navbar/sidebar/shell components, modal/auth widgets, casino support components, barrel exports.
- Key files: `src/components/index.ts`, `src/components/sidebar/routes.tsx`, `src/components/auth/auth.tsx`.

**`src/lib`:**
- Purpose: Domain logic and persistence modules that must run on Node runtime.
- Contains: Deposit bonus store, double simulation config/service/store adapters, auth header parser.
- Key files: `src/lib/deposit-bonus-store.ts`, `src/lib/double-simulation/adminSettings.ts`, `src/lib/api-auth.ts`.

**`src/services`:**
- Purpose: External API clients and service wrappers.
- Contains: Browser/server Axios instances and geolocation service.
- Key files: `src/services/apiClient.ts`, `src/services/apiServer.ts`, `src/services/geolocation.ts`.

**`src/contexts`:**
- Purpose: Shared application state context.
- Contains: Auth provider and barrel export.
- Key files: `src/contexts/auth-context.tsx`, `src/contexts/index.ts`.

**`src/functions`:**
- Purpose: Server-side helper functions for guarded execution in layouts/pages.
- Contains: Admin auth token validation helper.
- Key files: `src/functions/use-auth-admin.ts`, `src/functions/index.ts`.

**`src/hooks`:**
- Purpose: Client-side reusable hooks.
- Contains: Translation/cache hook and barrel export.
- Key files: `src/hooks/use-translation.ts`, `src/hooks/index.ts`.

**`src/interfaces`:**
- Purpose: Shared TS interface contracts.
- Contains: User, route, transaction, platform, and game interfaces.
- Key files: `src/interfaces/routes-interface.ts`, `src/interfaces/user-interface.tsx`, `src/interfaces/index.ts`.

**`public`:**
- Purpose: Static web assets and PWA files.
- Contains: SVG icons/logos, `manifest.json`, generated `sw.js` and `workbox-*.js`.
- Key files: `public/manifest.json`, `public/sw.js`, `public/ICON-SITE.svg`.

## Key File Locations

**Entry Points:**
- `src/app/(public)/page.tsx`: Public home entry route.
- `src/app/(admin)/admin/page.tsx`: Admin dashboard entry route.
- `src/middleware.ts`: Request guard entry point for protected path prefixes.

**Configuration:**
- `package.json`: Runtime scripts and dependency catalog.
- `next.config.mjs`: App runtime config, image policy, and PWA integration.
- `tsconfig.json`: TS strictness and alias (`@src/*`).
- `tailwind.config.ts`: Design tokens and scanned content paths.
- `postcss.config.js`: Tailwind + autoprefixer plugin pipeline.

**Core Logic:**
- `src/contexts/auth-context.tsx`: Auth lifecycle and session state.
- `src/services/apiClient.ts`: Browser-side API client.
- `src/services/apiServer.ts`: Server-side API client.
- `src/lib/deposit-bonus-store.ts`: Bonus rule persistence/validation engine.
- `src/lib/double-simulation/simulationService.ts`: Deterministic user simulation logic.

**Testing:**
- Not detected in current tree (`*.test.*` and `*.spec.*` patterns not present under `src`).

## Naming Conventions

**Files:**
- Route entries follow Next conventions: `page.tsx`, `layout.tsx`, and `route.ts` in `src/app/**`.
- Shared component files are primarily kebab-case in `src/components` (for example `navbar-user.tsx`, `offerbar.tsx`), with occasional PascalCase files (`AgeGate.tsx`, `AuthURLDetector.tsx`).
- Route-local component folders use Next route-group notation with parentheses, for example `src/app/(public)/(components)` and `src/app/(admin)/admin/(components)`.

**Directories:**
- Feature domains are directory-first in routes (`src/app/(public)/casino/originals/double`, `src/app/(admin)/admin/levels/edit/[id]`).
- Nested route params use bracket notation (`[slug]`, `[plataform]`, `[id]`, `[code]`).

## Where to Add New Code

**New Feature:**
- Primary code:
  - Public page feature: add route and local components under `src/app/(public)/<feature>`.
  - Admin panel feature: add route and local components under `src/app/(admin)/admin/<feature>`.
  - Local API feature: add endpoint under `src/app/api/<feature>/route.ts` (or nested admin path under `src/app/api/admin/<feature>/route.ts`).
- Tests:
  - No existing test directory standard is present; introduce tests near feature (`src/**`) or establish a top-level test convention before broad adoption.

**New Component/Module:**
- Implementation:
  - Reusable app-wide UI: `src/components/<feature>.tsx` plus export in `src/components/index.ts`.
  - Route-scoped UI: create `(components)` folder alongside route page (pattern used in `src/app/(public)/profile/(components)`).
  - Business/domain module for API routes: `src/lib/<feature>.ts` or `src/lib/<feature>/`.

**Utilities:**
- Shared helpers:
  - Browser/server API adapters belong in `src/services`.
  - Request/token parsing helpers belong in `src/lib` (example: `src/lib/api-auth.ts`).
  - Cross-component hooks belong in `src/hooks`.

## Special Directories

**`.next`:**
- Purpose: Build artifacts and dev server output.
- Generated: Yes.
- Committed: No (should remain uncommitted).

**`node_modules`:**
- Purpose: Installed package dependency tree.
- Generated: Yes.
- Committed: No.

**`.planning`:**
- Purpose: Planning/mapping artifacts for workflow orchestration.
- Generated: Partially (workflow-generated content).
- Committed: Project-dependent; current repository is not initialized as git, so commit policy is not inferred.

**`.data` (runtime-created):**
- Purpose: File-backed state for deposit bonuses and double simulation settings.
- Generated: Yes (created by `src/lib/deposit-bonus-store.ts` and `src/lib/double-simulation/adminSettings.ts`).
- Committed: No by default; treat as runtime state storage.

---

*Structure analysis: 2026-03-30*
