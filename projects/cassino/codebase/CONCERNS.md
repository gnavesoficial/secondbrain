# CONCERNS

## Segurança
- `API_URL` está hardcoded em `next.config.mjs`; ambiente fica menos flexível para segurança/segregação.
- `next.config.mjs` permite imagens de qualquer host HTTPS (`hostname: '**'`), ampliando superfície para conteúdo remoto não confiável.
- `src/middleware.ts` apenas verifica existência do cookie `session`; não valida expiração/assinatura no edge.
- `src/app/api/cache-translations/route.ts` grava arquivo com `writeFileSync` sem autenticação explícita.

## Integridade e concorrência
- Persistência em `.data/*.json` funciona para instância única, mas escala mal em múltiplas réplicas.
- `writeQueue` reduz race condition local, porém não resolve concorrência distribuída.
- Atualizações de regras/contadores de bônus em arquivo podem sofrer inconsistência após crash no meio da operação.

## Performance
- Componentes muito grandes (ex.: `src/components/auth/auth.tsx`) aumentam custo de manutenção e render.
- Leitura/escrita síncrona em `cache-translations` pode bloquear event loop sob carga.
- Grande volume de assets/imagens remotas sem estratégia clara de cache seletivo.

## Observabilidade e operação
- Não há evidência de monitoramento estruturado (Sentry, logs centralizados, métricas).
- Erros são majoritariamente `console.error`/`console.warn`, dificultando rastreio em produção.
- Processo de deploy existe (Docker/PM2), mas sem pipeline CI de qualidade visível.

## Qualidade e manutenção
- Ausência de testes automatizados para fluxos críticos (auth, bônus, simulação).
- `tsconfig.json` contém configuração redundante de `lib`, indicando dívida técnica de configuração.
- Inconsistências de nomenclatura (PT/EN, termos como `validadeToken`) podem confundir novos contribuidores.

## Priorização sugerida
1. Fortalecer segurança de APIs internas sensíveis (authz e validação robusta).
2. Introduzir testes automatizados para domínios financeiros e autenticação.
3. Revisar persistência em arquivo para alternativa mais resiliente (DB/KV).
4. Ajustar `next.config.mjs` para reduzir permissões amplas de hosts externos.
# Codebase Concerns

**Analysis Date:** 2026-03-30

## Tech Debt

**File-backed business state inside app runtime:**
- Issue: Business-critical state is persisted in local JSON files instead of a durable database.
- Files: `src/lib/deposit-bonus-store.ts`, `src/lib/double-simulation/adminSettings.ts`, `src/app/api/cache-translations/route.ts`, `.data/double-simulation-settings.json`, `translations-cache.json`
- Impact: State can diverge across instances, break in serverless/container restarts, and create data corruption risk under concurrent traffic.
- Fix approach: Move bonus rules, simulation settings, and translation cache to a shared datastore (SQL/Redis). Keep file fallback only for local dev.

**Monolithic page/components with mixed responsibilities:**
- Issue: Very large files combine UI, API orchestration, state machines, and business rules.
- Files: `src/app/(public)/casino/originals/mines/page.tsx`, `src/app/(admin)/admin/roulette/page.tsx`, `src/components/auth/auth.tsx`, `src/app/(admin)/admin/config-site/components/config-siteForm.tsx`
- Impact: Regression risk is high during edits, onboarding is slow, and defect isolation is difficult.
- Fix approach: Split each file into feature modules (hooks/services/presentational components), then add focused tests per module.

**Lockfile/package-manager inconsistency:**
- Issue: Both npm and yarn lockfiles are present at project root.
- Files: `package-lock.json`, `yarn.lock`
- Impact: Non-reproducible installs and "works on my machine" dependency drift.
- Fix approach: Standardize on one package manager, delete the other lockfile, enforce via CI check.

## Known Bugs

**PIX sending ignores user-entered document:**
- Symptoms: Submitted PIX flow does not use the form `document` value and uses hardcoded transfer identity fields.
- Files: `src/app/(admin)/admin/send-pix/(components)/sending-pix.tsx`
- Trigger: Submit the form with any `document`; request payload still uses fixed values.
- Workaround: None in UI; code change required to map form fields into payload and move provider credentials to backend.

**Server component error handler can throw inside catch:**
- Symptoms: Runtime error in fallback path when request fails without `error.response`.
- Files: `src/app/(public)/Esportes/page.tsx`
- Trigger: Network timeout/DNS/offline condition where thrown error lacks `response`.
- Workaround: Use optional chaining in catch (`error?.response?.status`) and guard unknown errors.

## Security Considerations

**Admin API authorization checks token presence only:**
- Risk: Any bearer token-like value that passes upstream caller logic can reach privileged admin mutations without role/claim verification in these route handlers.
- Files: `src/app/api/admin/double/simulation-settings/route.ts`, `src/app/api/admin/deposit-bonuses/route.ts`, `src/app/api/admin/deposit-bonuses/[id]/route.ts`, `src/lib/api-auth.ts`
- Current mitigation: Header must contain `Authorization: Bearer ...`.
- Recommendations: Enforce role validation (`admin`) in Next route handlers or backend gateway, and verify token signature/claims before privileged actions.

**Sensitive reset token is logged to browser console:**
- Risk: Password reset token can leak via browser logs, shared devices, support screenshots, or recording tooling.
- Files: `src/components/auth/AuthURLDetector.tsx`
- Current mitigation: Token is removed from URL after detection.
- Recommendations: Remove token logging entirely and treat token as sensitive data.

**Payment/provider secrets handled in client-side admin screens:**
- Risk: Provider tokens/secrets are loaded into browser memory and editable in client code, increasing exposure surface.
- Files: `src/app/(admin)/admin/config-provider/components/config-provedorForm.tsx`, `src/app/(admin)/admin/config-site/components/config-siteForm.tsx`, `src/app/(admin)/admin/send-pix/(components)/sending-pix.tsx`
- Current mitigation: Admin UI gating in app routes and session cookie checks.
- Recommendations: Move secret read/write to server-only endpoints with least-privilege responses (masked values), and never embed third-party credential headers in client bundles.

**Over-broad remote image allowlist:**
- Risk: `next/image` remote source accepts any hostname, increasing abuse/performance and content trust risks.
- Files: `next.config.mjs`
- Current mitigation: HTTPS protocol restriction only.
- Recommendations: Replace wildcard host with explicit trusted domains.

## Performance Bottlenecks

**Synchronous filesystem I/O in API routes:**
- Problem: Translation cache endpoints use `fs.writeFileSync`/`fs.readFileSync` on request path.
- Files: `src/app/api/cache-translations/route.ts`
- Cause: Blocking I/O in Node runtime route handlers.
- Improvement path: Use async I/O or move to Redis/database; add payload size limits and TTL-based pruning.

**Repeated client translation round-trips and cache growth:**
- Problem: Translation hook can issue frequent `/api/translate` calls and persists unbounded cache to local and server storage.
- Files: `src/hooks/use-translation.ts`, `src/app/api/translate/route.ts`, `src/app/api/cache-translations/route.ts`
- Cause: On-demand per-string translation without strict request throttling, size limits, or expiry.
- Improvement path: Add cache TTL/size cap, debounce/batch requests, and pre-translate static strings.

**Large page components increase render/update cost:**
- Problem: Very large React modules can trigger heavier reconciliation and slower developer feedback loops.
- Files: `src/app/(public)/casino/originals/mines/page.tsx`, `src/app/(admin)/admin/roulette/page.tsx`, `src/components/auth/auth.tsx`
- Cause: High state density and mixed concerns in single files.
- Improvement path: Decompose into memoized subcomponents/hooks and isolate frequent state updates.

## Fragile Areas

**Casino game launch flow (SSR + token + upstream API):**
- Files: `src/app/(public)/casino/[plataform]/[slug]/page.tsx`, `src/app/(public)/Esportes/page.tsx`, `src/services/apiServer.ts`
- Why fragile: SSR path depends on cookie token, upstream API shape, and manual error branching; small backend response changes can break page rendering.
- Safe modification: Introduce typed response models, centralized error mapper, and shared launch service used by both pages.
- Test coverage: No detected tests around launch flow and error paths.

**Bonus rules mutation logic in JSON store:**
- Files: `src/lib/deposit-bonus-store.ts`, `src/app/api/deposit-bonuses/consume/route.ts`, `src/app/api/deposit-bonuses/validate/route.ts`
- Why fragile: In-process queue guards only a single instance; scale-out deployments can produce race conditions and inconsistent redemption counters.
- Safe modification: Migrate to transactional datastore and enforce uniqueness/limits at DB layer.
- Test coverage: No detected tests for redemption limit races or malformed payload scenarios.

## Scaling Limits

**Single-node local file persistence for mutable state:**
- Current capacity: Reliable only on one instance with local disk continuity.
- Limit: Breaks under horizontal scaling, ephemeral storage, or rolling restarts.
- Scaling path: Externalize to shared DB + cache and add migration for `.data` JSON sources.

**In-memory/global translation listener state on client:**
- Current capacity: Works for one browser session/tab lifecycle.
- Limit: Can grow listener/cache complexity as app size increases and does not coordinate across tabs/devices.
- Scaling path: Use context/store with bounded cache and server-backed translation catalog.

## Dependencies at Risk

**Unofficial translation packages in production path:**
- Risk: Community/unofficial translation wrappers are brittle to upstream provider changes and may break without notice.
- Impact: User-facing translation endpoints fail (`/api/translate`) and degrade multilingual UX.
- Migration plan: Move to a supported paid API/SDK with SLA and explicit quotas.

**CLI package installed as runtime dependency:**
- Risk: `@nestjs/cli` is listed in runtime `dependencies` rather than `devDependencies`.
- Impact: Unnecessary production install footprint and larger dependency attack surface.
- Migration plan: Move CLI-only packages to `devDependencies` in `package.json`.

## Missing Critical Features

**No automated role/authorization policy enforcement at route layer:**
- Problem: Admin routes currently implement basic bearer presence checks, not explicit role policy validation.
- Blocks: Confident multi-role expansion and secure delegated admin operations.

**No centralized observability pipeline:**
- Problem: Errors are mostly `console.error`/`console.log` with no structured tracing.
- Blocks: Fast incident triage and production diagnostics.

## Test Coverage Gaps

**No project test suite detected in source:**
- What's not tested: Core auth flows, admin mutation endpoints, bonus redemption limits, and game-launch error handling.
- Files: `src/contexts/auth-context.tsx`, `src/app/api/admin/deposit-bonuses/route.ts`, `src/app/api/admin/deposit-bonuses/[id]/route.ts`, `src/lib/deposit-bonus-store.ts`, `src/app/(public)/casino/[plataform]/[slug]/page.tsx`, `src/app/(public)/Esportes/page.tsx`
- Risk: High chance of regressions in critical money/auth/game paths.
- Priority: High

**No dedicated test tooling configuration detected at root:**
- What's not tested: Integration and E2E behavior under realistic browser/API failures.
- Files: `package.json`
- Risk: Manual QA dependency and delayed bug discovery.
- Priority: High

---

*Concerns audit: 2026-03-30*
