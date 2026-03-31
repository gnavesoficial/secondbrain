# INTEGRATIONS

## Backend principal (API de negócio)
- Cliente HTTP client-side: `src/services/apiClient.ts` com `baseURL: process.env.API_URL`.
- Cliente HTTP server-side: `src/services/apiServer.ts` com `baseURL: process.env.API_URL`.
- Fluxos de autenticação usam endpoints como `/auth` e `/user` em `src/contexts/auth-context.tsx`.
- Vários fluxos de cadastro/login/reset chamam backend via `apiClient` em `src/components/auth/auth.tsx`.

## APIs internas (Next Route Handlers)
- `src/app/api/admin/deposit-bonuses/route.ts`
- `src/app/api/admin/deposit-bonuses/[id]/route.ts`
- `src/app/api/deposit-bonuses/validate/route.ts`
- `src/app/api/deposit-bonuses/consume/route.ts`
- `src/app/api/admin/double/simulation-settings/route.ts`
- `src/app/api/double/simulation-settings/route.ts`
- `src/app/api/translate/route.ts`
- `src/app/api/cache-translations/route.ts`

## Provedores e endpoints externos identificados
- Geolocalização por IP com fallback em `src/services/geolocation.ts`:
  - `https://ipapi.co/json/`
  - `https://ip-api.com/json/`
  - `https://ipinfo.io/json`
- Tradução automática via `google-translate-api-x` em `src/app/api/translate/route.ts`.
- Pixel Meta/Facebook em `src/components/facebook-pixel.tsx`:
  - script `https://connect.facebook.net/en_US/fbevents.js`
  - beacon `https://www.facebook.com/tr?...`
- Integração de chat embutido via token em `src/app/(public)/suporte/components/suporteFrom.tsx` (`tawk.to`).

## Integrações de mídia/CDN
- Várias imagens remotas em `src/components/casino/games/games.tsx` e páginas públicas.
- `next.config.mjs` aceita imagens HTTPS de hosts remotos com curinga (`hostname: '**'`).

## Persistência local (server filesystem)
- Regras de bônus em `.data/deposit-bonus-rules.json` via `src/lib/deposit-bonus-store.ts`.
- Configuração de simulação de double em `.data/double-simulation-settings.json` via `src/lib/double-simulation/adminSettings.ts`.
- Cache de tradução em `translations-cache.json` via `src/app/api/cache-translations/route.ts`.

## Autenticação e autorização
- Token Bearer extraído por `resolveAuthToken` em `src/lib/api-auth.ts`.
- Middleware de rota usa cookie `session` para rotas protegidas em `src/middleware.ts`.
- Layout admin valida role via chamada `/user` em `src/functions/use-auth-admin.ts`.
# External Integrations

**Analysis Date:** 2026-03-30

## APIs & External Services

**Core backend API:**
- Custom backend (base URL via `API_URL`) - Primary data/config/game communication from frontend
  - SDK/Client: `axios` through `src/services/apiClient.ts` and `src/services/apiServer.ts`
  - Auth: Bearer token from cookie `session` added in `src/services/apiClient.ts`; server-side token parsing in `src/lib/api-auth.ts`

**Translation service:**
- Google Translate endpoint via package wrapper - Used by internal API route for dynamic translation
  - SDK/Client: `google-translate-api-x` in `src/app/api/translate/route.ts`
  - Auth: Not detected (no API key usage in route implementation)

**Geolocation services:**
- `ipapi.co`, `ip-api.com`, and `ipinfo.io` - Country/language detection fallback chain
  - SDK/Client: `axios` in `src/services/geolocation.ts`
  - Auth: None detected

**Customer support chat:**
- Tawk chat embed - Support iframe rendered from token delivered by backend config
  - SDK/Client: iframe integration in `src/app/(public)/suporte/components/suporteFrom.tsx`
  - Auth: Chat token obtained from backend endpoint `/api/config/integrations` via `apiClient`

**Marketing analytics:**
- Meta/Facebook Pixel - Page view tracking script and noscript fallback image beacon
  - SDK/Client: Script injection in `src/components/facebook-pixel.tsx` (also package `react-facebook-pixel` in `package.json`)
  - Auth: Pixel ID embedded in component code

**Payment-related external service call:**
- SuitPay gateway endpoint - PIX payout request in admin UI utility flow
  - SDK/Client: direct `axios.post` to `https://ws.suitpay.app/api/v1/gateway/pix-payment` in `src/app/(admin)/admin/send-pix/(components)/sending-pix.tsx`
  - Auth: Custom request headers (`ci`/`cs`) hardcoded in the same file

## Data Storage

**Databases:**
- Not detected in this repository (no Prisma/TypeORM/Mongoose/SQL client usage found in `src`)
  - Connection: Not applicable
  - Client: Not applicable

**File Storage:**
- Local filesystem only (server runtime)
  - Translation cache file: `translations-cache.json` from `src/app/api/cache-translations/route.ts`
  - App state files: `.data/deposit-bonus-rules.json` and `.data/double-simulation-settings.json` managed by `src/lib/deposit-bonus-store.ts` and `src/lib/double-simulation/adminSettings.ts`

**Caching:**
- Browser storage cache (`localStorage`) for translation and locale-related data in `src/hooks/use-translation.ts` and `src/components/footer.tsx`
- Server-side JSON file cache for translations in `src/app/api/cache-translations/route.ts`

## Authentication & Identity

**Auth Provider:**
- Custom bearer-token handling
  - Implementation: Token extracted from `Authorization` header by `resolveAuthToken()` in `src/lib/api-auth.ts`; admin/internal API routes enforce token presence (`src/app/api/admin/**`, `src/app/api/deposit-bonuses/consume/route.ts`)

## Monitoring & Observability

**Error Tracking:**
- None detected (no Sentry/Datadog/Bugsnag integration found)

**Logs:**
- Console logging in browser/server code (`src/services/geolocation.ts`, `src/app/api/translate/route.ts`, other components)
- PM2 log files configured in `ecosystem.config.cjs` (`error_file`, `out_file`)

## CI/CD & Deployment

**Hosting:**
- Self-managed Node deployment is configured (PM2 profile at `ecosystem.config.cjs`, Linux paths under `/root/cassino_project`)
- Container deployment path is also defined in `Dockerfile`

**CI Pipeline:**
- None detected at project root (no repository-owned workflow files found under `.github/workflows`)

## Environment Configuration

**Required env vars:**
- `API_URL` - Base URL for axios clients (`src/services/apiClient.ts`, `src/services/apiServer.ts`, consumed in UI references such as `src/components/beforeinstallprompt.tsx`)

**Secrets location:**
- Local env files pattern `.env*.local` is ignored by git (`.gitignore`)
- Admin forms send provider credentials to backend endpoints (managed through UI forms in `src/app/(admin)/admin/payment-gateways/components/PaymentGatewaysForm.tsx` and `src/app/(admin)/admin/config-provider/components/config-provedorForm.tsx`)

## Webhooks & Callbacks

**Incoming:**
- Not detected in this frontend repository (no inbound webhook route handlers identified under `src/app/api`)

**Outgoing:**
- Callback URL field in PIX payout payload (`callbackUrl`) sent to SuitPay endpoint in `src/app/(admin)/admin/send-pix/(components)/sending-pix.tsx`

---

*Integration audit: 2026-03-30*
