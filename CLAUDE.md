# haunts — project context

Read this first before changing anything. Keep it updated: add a line to the changelog for every shipped change, and update the decision sections when something changes.

## Product
- **haunts** — a Letterboxd-style app for places & experiences. Tagline: "We bring together / more than places". Subline: "Save the places and experiences you love, rate them honestly and share them with people who get your taste" (no trailing periods).
- Founder: Sofia (@sonyaromm on Instagram/Telegram), travels a lot, based in Bali. Not a developer; communicates in Russian, casual tone. UI is English for now.
- Concept: personal diary of places (ratings, notes, photos) + social (friends, profiles, recommendations) + creators (guides that open via web link, paid guides / creator subscriptions).
- Target: travelers / digital nomads, starting with Bali & SE Asia.

## Brand & design system
- Logo: wordmark `img/brand/wordmark.png` (transparent, espresso) + `wordmark-light.png`; app icon "h with a location pin" `img/brand/apple-touch-icon.png`, `icon-192.png`, `icon-512.png`. Originals were uploaded by Sofia in chat.
- Colors: ivory `#F1E9DC` (bg), `#E8DFD1` (paper2), line `#DDD3C4`, espresso ink `#2B1A14`, ink2 `#5C4A3F`, muted `#6E5D52`, dashed borders `#857E70`, moss `#4F5A45`. All text passes WCAG contrast on ivory.
- Type: **Fraunces** (soft serif, `SOFT` 100) for display/titles, **Inter** for everything else; labels = Inter 11px uppercase +0.08em. Cormorant Garamond and JetBrains Mono were removed on purpose.
- Scale: display 40–46px, titles ~19–28px serif, body 16px, secondary 14px, nothing below 11px.
- Touch targets ≥ 44px (chips 40px + invisible hit area). Primary actions in the bottom third; filters live in a bottom sheet; tab bar shrinks on scroll.
- Glass/blur only on temporary layers (sheets, toasts, overlays). Scenes feed is dark, the rest is light.
- Full research: Claude doc "haunts: UX/UI и типографика" (https://claude.ai/artifact/DTf1kaunrCvzQCkdjQtcFe).

## Tech
- Single-page app: `index.html` (vanilla JS + CSS, no build step), installable to iPhone home screen (`manifest.json`, apple meta tags).
- Hosting: GitHub Pages → https://sonyaromm.github.io/places-app/ (repo `sonyaromm/places-app`, branch `main`; push = deploy in ~1–2 min).
- Backend: Supabase project `uaorlwqiarejbemexhte` (region ap-south-1). Publishable key is in `index.html` (safe to be public). NEVER commit a secret/service_role key.
  - Auth: email + password, email confirmation OFF, Site URL = the Pages URL.
  - Tables: `profiles` (id, username, name, bio, avatar_url, instagram, telegram, tiktok, website, countries[] ISO alpha-2), `places` (user_id, name, city, note, rating, tags[], photo_url, lat, lng, country), `postcards` (24h stories: media_url, media_type image|video, caption, place, expires_at), `scenes` (short videos: video_url, caption, place). RLS: everyone reads, users write only their own rows.
  - Storage: public bucket `photos`, each user writes only into `<uid>/…`; 50 MB file limit.
  - SQL lives in `supabase/setup.sql`, `002_postcards_scenes.sql`, `003_countries_map.sql` — Sofia runs them manually in SQL Editor. New schema changes = new numbered file + tell her to run it.
- Claude's sandbox cannot reach supabase.co, so backend changes can't be tested from here; UI is checked with headless Chrome (playwright).
- Maps: Leaflet 1.9.4 vendored in `vendor/leaflet/` (sandbox can't reach CDNs), CARTO Voyager raster tiles (sepia-tinted via CSS), country shapes `data/countries.geojson` (Natural Earth 50m via world-atlas, simplified, antimeridian-fixed, Antarctica removed, property `a2`). `countryAt(lat,lng)` = point-in-polygon with nearest-vertex fallback (small islands like Bali).
- Images are cached hard by iPhone home-screen apps: when replacing an image, give it a NEW filename (that's why welcome photos are `s1…s10`).
- Toasts appear at the bottom above the tab bar (never at the top — the Dynamic Island hides them).
- User-generated text is escaped (`esc`) and media URLs are whitelisted to the project's storage (`safeMedia`) — keep this for anything new.

## App structure (screens in index.html)
welcome (slideshow of Sofia's own photos `img/welcome/s1–s10.jpg`, no captions, no progress bars, login gate) → auth → tabs: **Swipe** (demo deck) · **Explore** (Postcards row, search, filters sheet, places list) · **+** (sheet: Postcard / Scene / Place) · **Scenes** (vertical video feed) · **Profile** (avatar, socials, real stats row → Stats screen, My map card, top-4, tabs Collections/Diary/Want/Scenes, edit profile). Other screens: place card (own places: set location), add place (location: my location / pick on map), new post, match, collection, paywall, **map** (modes Mine / Everyone / Countries; pins → popup → place card; Explore has a Map button that opens Everyone with current filters), **stats** (countries, % of world, places, cities, avg rating, scenes, taste tags, top cities, rating distribution), **countries** picker.

## Naming
- Stories = **Postcards** (24h), Reels = **Scenes**. Proposed by Claude, Sofia hasn't objected; alternatives offered: Glimpses/Moments, Walks.

## Still demo / not real yet
- Demo places have Bali coordinates so the Everyone map isn't empty, and use Sofia's photos (`img/welcome/s*.jpg`) instead of gradients; no "[photo: …]" placeholders anywhere.
- Swipe deck, Match, Collections ("Bali, édition 01"), Paywall, profile stats/top-4 when logged out, demo places (Single Fin, Kopi Pagi, Amed reef, Slow Hours, Green Bowl, Crumb & Co).
- No payments, no friends/follow graph, no comments/likes yet.

## Open decisions / next ideas
- Real collections from own places; swipe through other users' places; public profile link `?u=username`.
- Passwordless login (email code / Sign in with Apple).
- Import from Instagram/TikTok links; taste card / year-in-review; maybe mascot.
- Launch audience (Russian-speaking nomads vs international); check Fraunces Cyrillic before a Russian version.

## Changelog
- 2026-11-25 — Prototype screens (swipe, explore, place, collection, match, paywall, profile) as single HTML; published to GitHub Pages.
- 2026-11-25 — Profile handle @sonyaromm + Instagram/Telegram links; avatar; add-place on phone (IndexedDB).
- 2026-11-25 — Supabase: accounts, editable profile, shared places with photos.
- 2026-11-25 — Full-screen fix for home-screen mode; welcome screen + login gate; UI translated to English.
- 2026-11-25 — Welcome tagline; photo slideshow (no captions).
- 2026-11-25 — Postcards (24h stories) and Scenes (short videos) + `002_postcards_scenes.sql`; tab Collections replaced by Scenes; + opens a create sheet.
- 2026-11-25 — Brand: haunts name, logo, app icon, espresso/ivory palette.
- 2026-11-25 — UX pass: Fraunces + Inter, larger text, 44px targets, warm greys, filters bottom sheet, shrinking tab bar.
- 2026-11-25 — Countries visited, personal stats screen, maps (my places, everyone, countries) with pin → place card; location on add/edit place; `003_countries_map.sql`.
- 2026-11-25 — Welcome slideshow now uses Sofia's 10 own photos (Bali + Bangkok); Starbucks Reserve photo placed last.
- 2026-11-25 — UX fixes: removed slideshow progress bars, cache-busted photos, toast moved to bottom, demo content uses real photos, Explore title "Find your next haunt", Postcards add-circle with +.
- 2026-11-25 — Welcome subline now mentions experiences: "Save the places and experiences you love…".
