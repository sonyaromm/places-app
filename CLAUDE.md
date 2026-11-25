# haunts — project context

Read this first before changing anything. Keep it updated: add a line to the changelog for every shipped change, and update the decision sections when something changes.

## Product
- **haunts** — a Letterboxd-style app for places & experiences. Tagline: "We bring together / more than places". Subline: "From hidden cafés to sunset rituals — save what you love, rate it honestly and share it with people who get your taste" (no trailing periods) — shown on the Create account screen, not on welcome.
- Founder: Sofia (@sonyaromm on Instagram/Telegram), travels a lot, based in Bali. Not a developer; communicates in Russian, casual tone. UI is English for now.
- Concept: personal diary of places (ratings, notes, photos) + social (friends, profiles, recommendations) + creators (guides that open via web link, paid guides / creator subscriptions).
- Target: travelers / digital nomads, starting with Bali & SE Asia.

## Brand & design system
- **Process rule (Sofia 2026-11-26): for visual/design changes show a mockup first; implement only after she approves.**
- Logo: wordmark `img/brand/wordmark.png` (transparent, espresso) + `wordmark-light.png` (in-app it is rendered through a CSS mask filled with `--orb`). App icon v2 (approved 2026-11-26) = white "h with a location pin" on the wine–sage gradient: `img/brand/icon-v2-180.png` (apple-touch), `icon-v2-192.png`, `icon-v2-512.png`; old espresso icons kept but unused. Originals were uploaded by Sofia in chat.
- **Design principle (2026-11-26, decided with Sofia from Instagram 2016 redesign + Apple HIG + NN/g):** content screens are NEUTRAL so users' place photos are the colour; colour/brand lives only in brand moments (welcome, intro, quiz, taste card, places without photo). One accent colour, used sparingly.
- Colors: bg white `#FFFFFF`, surfaces `#F4F3F1`, lines `rgba(17,18,22,.08)`, ink Charcoal `#111216` (text, primary buttons, selected chips), ink2 `#56545C`, muted `#75737B`. **Accent = wine–sage gradient `--orb`** (approved by Sofia 2026-11-26, variant "A" built from her grainy burgundy/green ref: wine #5A2333 → #6B2A35, red edge #A93A35, green #8DB36C, light sage #C9DBB6): active tab circle, "Your taste" badge, taste label text, arrow circle on onboarding buttons, welcome "Create account" button, and the welcome wordmark (CSS mask over wordmark-light.png, `.orbmark`). Everything else graphite/white. + button = white circle on the dark tab bar. Aura colours (brand moments only): Coral, Periwinkle `#6078F6`, Lavender `#B7A7D8`, Peach `#FFC2A8`, Milk `#F5F1EC`.
- Auras: `auraBG(name)` sunset / dusk / rose / matcha / night; night = glowing orb (peach core, coral, periwinkle rim, lavender haze) on charcoal. Intro = dark charcoal with night orbs + thin white line drawing, outline pill button with arrow circle; quiz on plain white (aura removed — too wellness); taste card = night orb; places without photo get an aura by tags. `#bgAura` wash is turned off.
- Glowing orbs read as "wellness app" (Sofia, 2026-11-26) → intro slides and taste card use PHOTOS (for now Sofia's s7/s2/s3, later her new pictures) with a dark fade for text; no line drawings. Orb aura only remains as an invisible fallback under the photo. Slots: `data-img` on `.inPh`, taste card background url in renderQuiz. Replacing an image = new filename (iPhone cache).
- Photo-first: Explore = big 300px photo cards (`pcardHTML`: glass ★ rating + heart pills, spaced-caps location, light title, "Your taste" orb badge when tasteScore≥2); Profile = photo cover (latest own photo, fallback s5) with avatar overlap, glass pills for handle/menu, My haunts = 2-column 4:5 photo grid (`.ptile`). Tab bar = dark graphite floating pill.
- Glass only on temporary/floating layers: tab bar, sheets, toasts. Content-screen chips/inputs/buttons are flat.
- Type (2026-11-26, Sofia's Ohm ref "Start Where You Are"): **Albert Sans** for everything — titles 300 Light with tight tracking (`.serif` class name kept for titles), UI 400–600; **Newsreader** for serif accents: italic words inside titles (`.serif .it`) and `.book` semibold subheads. Fonts self-hosted in `fonts/` (woff2, latin) — no Google Fonts request. Fraunces/Inter removed.
- Scale: display 40–46px, titles ~19–28px serif, body 16px, secondary 14px, nothing below 11px.
- Primary buttons (`.btn.dark`) = solid Charcoal pill, white text; in onboarding (intro/quiz) the pill gets an arrow-in-circle on the right.
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
  - SQL lives in `supabase/setup.sql`, `002_postcards_scenes.sql`, `003_countries_map.sql`, `004_onboarding.sql` (profiles: interests[], home_city, home_lat, home_lng, taste, onboarded) — Sofia runs them manually in SQL Editor. New schema changes = new numbered file + tell her to run it.
- Claude's sandbox cannot reach supabase.co, so backend changes can't be tested from here; UI is checked with headless Chrome (playwright).
- Maps: Leaflet 1.9.4 vendored in `vendor/leaflet/` (sandbox can't reach CDNs), OpenStreetMap standard raster tiles (no key; muted/sepia via CSS filter on `.leaflet-tile`). CARTO was dropped 2026-11-26 — it started requiring an API key. Upgrade path: Stadia `alidade_smooth` (domain auth) or MapTiler custom style (key), country shapes `data/countries.geojson` (Natural Earth 50m via world-atlas, simplified, antimeridian-fixed, Antarctica removed, property `a2`). `countryAt(lat,lng)` = point-in-polygon with nearest-vertex fallback (small islands like Bali).
- Images are cached hard by iPhone home-screen apps: when replacing an image, give it a NEW filename (that's why welcome photos are `s1…s10`).
- QA routine: playwright screenshots of every screen at iPhone 15 (393×852, safe areas 59/34 via `--top/--bot` override) and iPhone SE (375×667, 20/0); check nothing hides under the Dynamic Island or home bar and nothing overflows.
- `.grain` sets position:relative — a `.screen` with `.grain` must stay absolute (`.screen.grain` rule).
- Toasts appear at the bottom above the tab bar (never at the top — the Dynamic Island hides them).
- User-generated text is escaped (`esc`) and media URLs are whitelisted to the project's storage (`safeMedia`) — keep this for anything new.

## App structure (screens in index.html)
MVP navigation (decided with Sofia 2026-11-26, based on her UX research): **Explore · Map · + · Profile** (4 tabs, + in the middle).
- welcome (full-screen slideshow of Sofia's photos `img/welcome/s1–s10.jpg`, dark gradient, light wordmark + "We bring together more than places", Create account + "I already have an account · Log in") → Create account opens **intro** (3 swipeable slides: Save what you love / Rate it honestly / Share your taste, Skip + Next) → sign-up → **quiz** (3 steps + taste card: interests chips · where are you now (location or city) · countries visited (popular chips + search) → "Your travel taste" card, e.g. "Slow coffee & sunset chaser") → Explore sorted by taste. "Log in" goes straight to auth → Explore. Quiz can be retaken from Edit profile; taste shows under the name in Profile.
- **Explore**: Postcards row, title "Find your next haunt", search, Filters (bottom sheet) + Map chip, places list; empty search = icon + "No haunts for …" + Clear search / Clear filters / + Add a place. First-run hint bubble above + ("Tap + to add your first haunt", once, Explore only).
- **Map** tab: modes Everyone / Mine / Countries; pins → popup → place card; summary card sits above the tab bar.
- **+** sheet: Postcard (24h photo/video) · Place. Scenes removed from the sheet for MVP.
- **Profile** (one job): avatar, name, bio, socials, stats row (countries · places · cities → Stats screen), My map card (→ Map tab, Mine), **My haunts** list of own places; empty state "Add your first haunt" with button; skeleton rows while loading.
- Other screens: place card (own places: set location), add place, new post, stats, countries picker, edit profile.
- Hidden for MVP (code kept, unreachable): Swipe deck, Match, Scenes feed/tab, Collections, Paywall, profile top-4 and Collections/Diary/Want/Scenes tabs (hidden stubs `#top4 #ptabs #ptBody` remain so old code doesn't crash).
- Interaction patterns: bottom sheets slide up, background scales down, drag down to close; swipe from the left edge = back on non-tab screens; long-press a place row = quick actions (Open / Show on map / Share) over a blurred background; buttons scale on press; long actions show a moving bar on the button (`.btn.loading`); errors go through `niceErr()` (human messages, never raw server text); body text 17px.
- `.screen` has z-index:1 so overlays (#qa, sheets, toasts) always sit above screen content like Leaflet panes.


## Naming
- Stories = **Postcards** (24h), Reels = **Scenes**. Proposed by Claude, Sofia hasn't objected; alternatives offered: Glimpses/Moments, Walks.

## Still demo / not real yet
- Demo places have Bali coordinates so the Everyone map isn't empty, and use Sofia's photos (`img/welcome/s*.jpg`) instead of gradients; no "[photo: …]" placeholders anywhere.
- Hidden for MVP: Swipe deck, Match, Collections ("Bali, édition 01"), Paywall, Scenes. Still visible demo: demo places (Single Fin, Kopi Pagi, Amed reef, Slow Hours, Green Bowl, Crumb & Co).
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
- 2026-11-25 — Welcome subline: "From hidden cafés to sunset rituals — …" (chosen by Sofia).
- 2026-11-26 — QA pass: welcome fits small iPhones (slideshow flexes), Match screen full height, paywall/place hero account for status bar, Swipe has a labeled Match button.
- 2026-11-26 — Welcome: smaller bottom gap; hidden toast no longer leaves a faint shadow (opacity 0 when hidden).
- 2026-11-26 — Welcome redesigned (Sofia: too much text, too many fonts): full-bleed photos, light logo, one line, two actions; long subline moved to sign-up screen.
- 2026-11-26 — MVP simplification + UX patterns from Sofia's research (infogra guide + mobile UI video): 4-tab nav Explore·Map·+·Profile, Explore landing, Profile = My haunts, empty states, first-run + hint, sheet animations/drag-to-close, edge-swipe back, long-press quick actions, pressed states, loading bars, skeletons, human error messages, 17px body.
- 2026-11-26 — Onboarding: intro slides before sign-up, 3-question taste quiz after sign-up (interests, home city/location, countries), taste card, Explore sorted by interests, taste label in profile, retake from edit profile; `004_onboarding.sql`.
- 2026-11-26 — Fix: on iPhone home-screen launch the welcome screen stopped ~60pt short (ivory strip at bottom) → #app stretched to screen height in standalone mode + dark html background under welcome.
- 2026-11-26 — Map tiles: CARTO now requires an API key (tiles showed "API KEY REQUIRED") → switched to OpenStreetMap tiles with a muted sepia filter; "Tap +" hint now hides on every tab except Explore (it covered the map summary card).
- 2026-11-26 — Visual redesign pass 1 (Sofia: "too template-beige"): aura gradients with grain, glass tab bar/chips/inputs/sheets, lighter background, aura fallback thumbs, aura intro slides, quiz and taste card.
- 2026-11-26 — Palette swap: brown espresso → near-black #141317, ivory → milk, accents blue/coral/lavender; auras re-tuned (dusk = lavender/coral/blue, night = blue-coral orb on black); greyer map tiles.
- 2026-11-26 — Fonts: Fraunces+Inter → Albert Sans (light titles) + Newsreader (italic accents), self-hosted in fonts/.
- 2026-11-26 — Primary buttons → frosted white glass (Sofia's choice).
- 2026-11-26 — Preview `wine.html`: same app in olive green + burgundy + cream (Sofia's emerald-wine refs) for side-by-side comparison.
- 2026-11-26 — wine.html: burgundy primary (darkened to #4A121C per Sofia) buttons/+/selected chips, cleaner lighter auras (burgundy and olive kept apart so they don't mix into brown), bg #F8F3EC, softer grain.
- 2026-11-26 — Preview `coral.html` (Charcoal/Milk/Periwinkle/Coral/Lavender, finance-app ref).
- 2026-11-26 — Neutral redesign (research: Instagram 2016, Apple HIG "use colour sparingly", NN/g content over chrome): white/Charcoal content screens, single Coral accent on +, colour only in onboarding/taste card/no-photo places; previews wine.html and coral.html removed.
- 2026-11-26 — Intro slides and taste card are image slots (img/intro/intro-N.jpg, img/taste/taste-1.jpg) with orb fallback.
- 2026-11-26 — Orbs looked like a wellness app → intro slides and taste card show Sofia's photos with charcoal fade; line drawings removed.
- 2026-11-26 — Stylish-minimal pass from Sofia's refs: photo-first Explore cards, profile cover + photo grid, dark pill tab bar; orb gradient becomes the single accent (active tab, taste badge/label, onboarding arrow, gradient wordmark on welcome).
- 2026-11-26 — Orb accent: less orange in the centre (smaller peach/coral core, more periwinkle/lavender).
- 2026-11-26 — Reverted the accent picker + warm sunset accent (Sofia: too orange, no colour choice). RULE from Sofia: do NOT implement visual changes until she approves a mockup (show static mockups first).
- 2026-11-26 — Approved mockups implemented: accent gradient = wine–sage "A" (active tab, taste badge/label, onboarding arrow, gradient wordmark, Create account button); new app icon v2 (white h on wine–sage gradient).
