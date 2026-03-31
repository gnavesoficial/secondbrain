# CONVENTIONS

## Linguagem e tipagem
- Código majoritariamente TypeScript em `src/**/*.ts` e `src/**/*.tsx`.
- `tsconfig.json` usa `strict: true`, `noEmit: true` e alias `@src/*`.
- Tipos explícitos em vários domínios (`DoubleSimulationSettings`, `DepositBonusRule`).

## Padrões de import
- Imports absolutos via alias `@src/...` são comuns.
- Dependências externas importadas no topo e organização geralmente consistente.
- Barrel files usados em alguns módulos (`src/services/index.ts`, `src/functions/index.ts`).

## Padrões de UI
- Estilização utilitária com Tailwind em classes longas no JSX.
- Componentização orientada por domínio (auth, sidebar, casino, admin).
- Feedback de ações via toasts (`react-hot-toast`).

## Padrões de API interna
- Route Handlers em `src/app/api/**/route.ts`.
- Respostas JSON via `NextResponse.json`.
- Autorização por Bearer token com helper `resolveAuthToken` em `src/lib/api-auth.ts`.

## Padrões de persistência local
- Uso de `fs/promises` para armazenar estado em `.data/*.json`.
- Inicialização de store via `ensureStoreFile`.
- Serialização de escrita via fila `writeQueue` para reduzir race conditions.

## Tratamento de erro
- No server: `try/catch` com mensagens de erro localizadas.
- No client: detecção de erro Axios com fallback de mensagem amigável.
- Estratégia global de logging/monitoramento não foi encontrada.

## Padrões de autenticação
- Cookie `session` como token principal.
- Interceptor/default header de autorização configurado no `apiClient`.
- Middleware bloqueia rotas protegidas e redireciona para `/`.

## Inconsistências observadas
- Mistura de idioma PT/EN em variáveis, mensagens e comentários.
- Pequenas diferenças de estilo (aspas, espaçamento, nomes como `validadeToken`).
- `tsconfig.json` contém entradas duplicadas de `lib`, sugerindo necessidade de limpeza.
# Coding Conventions

**Analysis Date:** 2026-03-30

## Naming Patterns

**Files:**
- Use `kebab-case` for most files in `src` (examples: `src/services/apiClient.ts`, `src/components/navbar-bottom.tsx`, `src/app/(public)/casino/originals/double/page.tsx`).
- Keep route handlers as `route.ts` inside App Router API directories (examples: `src/app/api/double/simulation-settings/route.ts`, `src/app/api/admin/double/simulation-settings/route.ts`).
- Use `index.ts` barrel files to re-export module members (examples: `src/services/index.ts`, `src/components/index.ts`, `src/hooks/index.ts`).
- Accept existing PascalCase exceptions for component files that are already established (examples: `src/components/AgeGate.tsx`, `src/components/auth/AuthURLDetector.tsx`, `src/app/(admin)/admin/telegramcofig/components/TelegramConfigForm.tsx`).

**Functions:**
- Use `camelCase` for utilities and handlers (examples: `resolveAuthToken()` in `src/lib/api-auth.ts`, `applyDoubleSimulation()` in `src/lib/double-simulation/simulationService.ts`, `getPaymentMethods()` in `src/config/payment.ts`).
- Use `PascalCase` for React components and layout exports (examples: `MainLayout` in `src/app/layouts/main.layout.tsx`, `Win` in `src/components/wins/win.tsx`, `Auth` in `src/components/auth/auth.tsx`).

**Variables:**
- Prefer `camelCase` for state and local variables (examples: `isAuthenticated` in `src/contexts/auth-context.tsx`, `roundSeed` in `src/app/(public)/casino/originals/double/page.tsx`).
- Keep snake_case only when matching backend/API payload contracts (examples: `remember_me` in `src/components/auth/auth.tsx`, `winning_number` in `src/app/(public)/casino/originals/double/page.tsx`).

**Types:**
- Use `type` aliases for local data structures (examples: `SignInData` in `src/contexts/auth-context.tsx`, `DoubleRoundUser` in `src/lib/double-simulation/simulationService.ts`).
- Use `interface` and legacy `I` prefix for shared contracts in `src/interfaces` (examples: `IUser` consumed from `src/interfaces/index.ts`, `ITransaction` used in `src/components/wins/win.tsx`).

## Code Style

**Formatting:**
- Primary formatter is editor-driven; no Prettier config is detected at project root (`.prettierrc*` and `prettier.config.*` are not present).
- Keep semicolons and trailing commas consistent with existing files (examples in `src/contexts/auth-context.tsx`, `src/config/payment.ts`).
- Follow existing project style for JSX utility classes inline (examples in `src/components/auth/auth.tsx`, `src/app/layouts/main.layout.tsx`).

**Linting:**
- Use ESLint via Next.js with `next/core-web-vitals` from `.eslintrc.json`.
- Run lint through `npm run lint` defined in `package.json`.
- Preserve TypeScript strict mode (`"strict": true`) and alias config from `tsconfig.json`.

## Import Organization

**Order:**
1. Framework/external packages first (examples: `react`, `next/navigation`, `axios`, `js-cookie` in `src/contexts/auth-context.tsx`).
2. Internal alias imports second using `@src/*` (examples: `@src/interfaces`, `@src/services` in `src/contexts/auth-context.tsx`).
3. Relative imports last for same-folder modules/assets (examples: `../checkbox` and `../../../BANNER-LOGIN.webp` in `src/components/auth/auth.tsx`).

**Path Aliases:**
- Use `@src/*` alias configured in `tsconfig.json` (`"@src/*": ["./src/*"]`).
- Prefer alias imports for cross-domain references (examples: `@src/lib/double-simulation/simulationService` in `src/app/(public)/casino/originals/double/page.tsx`).

## Error Handling

**Patterns:**
- Wrap async network operations in `try/catch/finally` and always reset loading state in `finally` (example: `signIn()` in `src/contexts/auth-context.tsx`).
- Use `axios.isAxiosError()` before consuming response-specific fields (examples in `src/contexts/auth-context.tsx`, `src/app/(public)/casino/originals/double/page.tsx`).
- Return fallback values on recoverable failures in utility layers (examples in `src/hooks/use-translation.ts`, `src/lib/double-simulation/adminSettings.ts`).
- Keep API route failures as JSON responses with status codes (examples in `src/app/api/admin/double/simulation-settings/route.ts`, `src/app/api/translate/route.ts`).

## Logging

**Framework:** console

**Patterns:**
- Use `console.error` for operational failures (examples in `src/components/doubleHistory.tsx`, `src/app/(public)/casino/originals/crash/page.tsx`).
- Use `console.warn` for recoverable external/service issues (example in `src/services/geolocation.ts` and `src/hooks/use-translation.ts`).
- Reduce debug `console.log` in production-sensitive paths (examples currently present in `src/app/(public)/casino/[plataform]/[slug]/page.tsx`, `src/app/(admin)/admin/roulette/page.tsx`).

## Comments

**When to Comment:**
- Add brief intent comments around non-obvious UI/state behavior (examples: token validation flow and loading branches in `src/components/auth/auth.tsx`).
- Keep explanatory comments near fallback logic (example: fallback API settings note in `src/app/(public)/casino/originals/double/page.tsx`).

**JSDoc/TSDoc:**
- Use JSDoc selectively for exported domain helpers (examples in `src/config/payment.ts`).
- Do not require JSDoc for internal React event handlers unless logic is non-obvious.

## Function Design

**Size:** 
- Keep utility functions small and pure in `src/lib` and `src/config` (examples: `clamp()` and `hashString()` in `src/lib/double-simulation/simulationService.ts`).
- Split large multi-form UIs into smaller components when editing `src/components/auth/auth.tsx` to avoid additional complexity.

**Parameters:**
- Use object parameters for multi-argument operations and typed payloads (examples: `applyDoubleSimulation({ ... })` in `src/lib/double-simulation/simulationService.ts`, `signIn({ ... })` in `src/contexts/auth-context.tsx`).
- Keep explicit typed event signatures for form handlers (example: `handleBetChange(event: React.ChangeEvent<HTMLInputElement>)` in `src/app/(public)/casino/originals/double/page.tsx`).

**Return Values:**
- Return explicit nullable values for parser/validator helpers (example: `resolveAuthToken(): string | null` in `src/lib/api-auth.ts`).
- Return typed arrays/objects for business logic helpers (examples in `src/lib/double-simulation/simulationService.ts`, `src/config/payment.ts`).

## Module Design

**Exports:**
- Centralize shared exports with barrel files (`src/components/index.ts`, `src/services/index.ts`, `src/contexts/index.ts`).
- Export route handlers as named HTTP methods (`GET`, `POST`, `PATCH`) in `src/app/api/**/route.ts`.

**Barrel Files:**
- Continue using `index.ts` per feature folder to keep imports stable (examples in `src/components/wins/index.ts`, `src/app/layouts/index.ts`, `src/app/(admin)/admin/(components)/index.ts`).
- Prefer adding new exports to local barrel files before updating high-level aggregators like `src/components/index.ts`.

---

*Convention analysis: 2026-03-30*
