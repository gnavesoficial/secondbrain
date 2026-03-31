# STACK

## Runtime e plataforma
- Framework principal: `next` `14.1.3` (App Router) em `package.json`.
- UI em `react` `18` + `react-dom` `18`.
- Linguagem dominante: TypeScript (`.ts`/`.tsx`) com `strict: true` em `tsconfig.json`.
- Node alvo: imagem de deploy `node:20.11.1-alpine` em `Dockerfile`.
- Processo de produção também previsto com PM2 em `ecosystem.config.cjs`.

## Ferramentas de build e estilo
- Scripts: `dev`, `build`, `build:vps`, `start`, `lint` em `package.json`.
- Lint: `eslint` + `eslint-config-next` em `.eslintrc.json`.
- CSS utilitário: `tailwindcss` + `postcss` + `autoprefixer` em `tailwind.config.ts` e `postcss.config.js`.
- PWA: `next-pwa` aplicado em `next.config.mjs`.
- Imagens remotas amplamente permitidas via `remotePatterns` com hostname curinga em `next.config.mjs`.

## Bibliotecas de UI e UX
- Biblioteca de componentes: `antd` + `@ant-design/icons`.
- Animações: `framer-motion`.
- Formulários: `react-hook-form`.
- Ícones e utilidades visuais: `react-icons`, `lucide-react`.
- Feedback: `react-hot-toast`, `react-toastify`, `sonner`, `sweetalert2`.

## Dados, utilidades e domínio
- HTTP client: `axios` em `src/services/apiClient.ts` e `src/services/apiServer.ts`.
- Persistência local de regras/config: `fs` em `src/lib/deposit-bonus-store.ts` e `src/lib/double-simulation/adminSettings.ts`.
- Helpers de data: `date-fns`.
- Cookies no client: `js-cookie`.
- Geração de IDs/hashes no server: `crypto` (Node) em `src/lib/deposit-bonus-store.ts`.

## Configuração e ambiente
- Base API central definida em `process.env.API_URL` usada por `apiClient` e `apiServer`.
- `API_URL` também está hardcoded em `next.config.mjs` (`https://api2.apexbr.bet/`).
- Alias de import: `@src/*` definido em `tsconfig.json`.
- Diretório de dados local usado pelo app: `.data/`.

## Escala atual de código
- Aproximadamente `247` arquivos de código em `src` (`.ts/.tsx/.js/.jsx`).
- Organização por domínio funcional em `src/app` (grupos `(public)` e `(admin)`), `src/components`, `src/lib`, `src/services`.
# Technology Stack

**Analysis Date:** 2026-03-30

## Languages

**Primary:**
- TypeScript (strict mode) - Main app, API routes, services, and UI code in `src/**/*.ts` and `src/**/*.tsx`

**Secondary:**
- JavaScript (Node config) - Build/runtime configs in `next.config.mjs`, `postcss.config.js`, and `ecosystem.config.cjs`
- CSS (Tailwind utility pipeline) - Styling configured by `tailwind.config.ts` and consumed in app components

## Runtime

**Environment:**
- Node.js 20.x (explicit `node:20.11.1-alpine` in `Dockerfile`; Next.js runtime in `package.json` scripts)

**Package Manager:**
- npm and Yarn are both present in repository metadata
- Lockfile: `package-lock.json` and `yarn.lock` both present at project root (`package.json` exists at root)

## Frameworks

**Core:**
- Next.js 14.1.3 - Full-stack React framework for App Router pages and API routes (`package.json`, `src/app/**/*`)
- React 18 - UI rendering and component model (`package.json`, `src/components/**/*`)

**Testing:**
- Not detected (no Jest/Vitest config files at project root)

**Build/Dev:**
- TypeScript ^5 - Type checking and editor tooling (`tsconfig.json`, `package.json`)
- Tailwind CSS ^3.3.0 + PostCSS + Autoprefixer - Utility-first CSS pipeline (`tailwind.config.ts`, `postcss.config.js`)
- ESLint ^8 + `eslint-config-next` - Linting workflow via `npm run lint` (`package.json`)
- PM2 ecosystem config - Process management for production node process (`ecosystem.config.cjs`)
- `next-pwa` - PWA service worker integration (`next.config.mjs`, `package.json`)

## Key Dependencies

**Critical:**
- `next` 14.1.3 - Application runtime and routing core (`package.json`)
- `react` / `react-dom` ^18 - Component rendering (`package.json`)
- `axios` ^1.6.7 - HTTP client for backend and third-party requests (`src/services/apiClient.ts`, `src/services/geolocation.ts`)
- `google-translate-api-x` ^10.7.2 - Translation API wrapper used by server route (`src/app/api/translate/route.ts`)
- `js-cookie` ^3.0.5 - Browser token/session retrieval for auth headers (`src/services/apiClient.ts`)

**Infrastructure:**
- `next-pwa` ^5.6.0 - PWA registration/build integration (`next.config.mjs`)
- `sharp` ^0.33.5 - Image optimization support for Next image pipeline (`package.json`)
- `i18next` + `react-i18next` - Internationalization in frontend (`package.json`, `src/hooks/use-translation.ts`)
- UI stack: `antd`, `@radix-ui/*`, `framer-motion`, `react-hook-form` (`package.json`)

## Configuration

**Environment:**
- `API_URL` is required for backend/base API communication (`src/services/apiClient.ts`, `src/services/apiServer.ts`)
- `API_URL` is also injected from Next config env block (`next.config.mjs`)
- `.env*.local` is ignored by git (`.gitignore`), but no root `.env*` files were detected during this analysis

**Build:**
- Next build/dev/start scripts in `package.json`
- TypeScript compiler behavior in `tsconfig.json` (strict mode enabled, alias `@src/*`)
- Tailwind scan/theme in `tailwind.config.ts`
- PostCSS plugins in `postcss.config.js`
- Docker image build/start in `Dockerfile`
- PM2 runtime settings and logs in `ecosystem.config.cjs`

## Platform Requirements

**Development:**
- Node.js compatible with Next 14 and TypeScript 5 (Docker pins Node 20.11.1)
- npm/yarn dependency install from root `package.json`
- Writable project filesystem for local JSON persistence used by API routes (`.data` and `translations-cache.json` created via server code in `src/lib/*` and `src/app/api/cache-translations/route.ts`)

**Production:**
- Node.js server runtime for `next start` (`package.json`, `ecosystem.config.cjs`)
- Port 3000 exposed in Docker and PM2 (`Dockerfile`, `ecosystem.config.cjs`)
- External backend API reachable through `API_URL` (`src/services/apiClient.ts`)

---

*Stack analysis: 2026-03-30*
