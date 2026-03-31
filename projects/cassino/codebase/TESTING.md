# TESTING

## Estado atual
- Não foi identificado framework de testes ativo no projeto raiz.
- Não há scripts de teste em `package.json` (apenas `dev`, `build`, `start`, `lint`).
- Não foram encontrados arquivos de configuração como `jest.config.*`, `vitest.config.*` ou `playwright.config.*`.
- Não foram identificados testes de aplicação em `src` no padrão `*.test.*` ou `*.spec.*`.

## O que existe hoje como verificação
- Lint com `next lint` (ESLint + regras Next).
- Type checking implícito no build TypeScript/Next.
- Validação manual durante `npm run dev`.

## Áreas prioritárias para cobertura
- Auth flow: `src/contexts/auth-context.tsx` e `src/functions/use-auth-admin.ts`.
- APIs internas de bônus: `src/app/api/deposit-bonuses/*` e `src/lib/deposit-bonus-store.ts`.
- APIs internas de simulação: `src/app/api/admin/double/simulation-settings/route.ts`.
- Lógica de simulação: `src/lib/double-simulation/simulationService.ts`.
- Middleware de proteção: `src/middleware.ts`.

## Estratégia recomendada (incremental)
- **Unit tests** para regras puras (`src/lib/double-simulation/doubleSimulationConfig.ts`).
- **Integration tests** para route handlers críticos de bônus e simulação.
- **Component tests** para autenticação/modal de login (`src/components/auth/auth.tsx`).
- **Smoke E2E** básico para login, rota protegida e fluxo de depósito.

## Ferramentas sugeridas
- Unit/Integration: Vitest ou Jest + Testing Library.
- E2E: Playwright.
- Mock de HTTP: MSW (quando necessário).

## Gap de qualidade atual
- Sem testes automatizados, regressões podem passar para produção.
- Rotas com lógica financeira e de autorização deveriam ter cobertura primeiro.
# Testing Patterns

**Analysis Date:** 2026-03-30

## Test Framework

**Runner:**
- Not detected in application code (`src/` has no `*.test.*`, `*.spec.*`, `__tests__/`, or `tests/` files).
- Config: Not detected (`jest.config.*`, `vitest.config.*`, `playwright.config.*`, `cypress.config.*` are not present at project root).

**Assertion Library:**
- Not detected for app code in `src/`.

**Run Commands:**
```bash
# No test script configured in `package.json`
npm run test           # Not available
npm run test:watch     # Not available
npm run test:coverage  # Not available
```

## Test File Organization

**Location:**
- Not currently implemented for application source under `src/`.
- Existing matches for `.test`/`.spec` are only dependency files under `node_modules/`, not project tests.

**Naming:**
- Not applicable in current app code (`src/` has no test file naming pattern yet).

**Structure:**
```
Not applicable - no app test directories are present under `src/`.
```

## Test Structure

**Suite Organization:**
```typescript
// Not detected in this codebase:
// describe('feature', () => { ... })
// it('does something', () => { ... })
```

**Patterns:**
- Setup pattern: Not detected (no test runner setup files in repository root).
- Teardown pattern: Not detected.
- Assertion pattern: Not detected.

## Mocking

**Framework:** Not detected

**Patterns:**
```typescript
// Not detected in `src/` because test files are not present.
```

**What to Mock:**
- Not established yet; no test harness present in `package.json` or root config files.

**What NOT to Mock:**
- Not established yet.

## Fixtures and Factories

**Test Data:**
```typescript
// No fixture or factory pattern is implemented in `src/`.
```

**Location:**
- Not detected (`src/` has no fixture/factory test directories).

## Coverage

**Requirements:** None enforced

**View Coverage:**
```bash
# Coverage tooling is not configured in `package.json`.
npm run test:coverage  # Not available
```

## Test Types

**Unit Tests:**
- Not used in current application repository (`src/` contains no unit test files).

**Integration Tests:**
- Not used in current application repository.

**E2E Tests:**
- Not used (no Playwright/Cypress config files at root).

## Common Patterns

**Async Testing:**
```typescript
// Not detected - no async test suites in project code.
```

**Error Testing:**
```typescript
// Not detected - no error assertion patterns in test files.
```

---

*Testing analysis: 2026-03-30*
