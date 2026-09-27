# User Journeys

Each journey lists the actor, trigger, goal, happy path, what "done" looks like, failure paths, and the questions it raises. Questions feed into non-functional requirements (step 4) and ADRs.

---

## Journey 0: Minimal onboarding (MVP)

**Actor:** A shop owner, non-technical.
**Trigger:** They decide to try the platform.
**Goal:** A working, branded catalog address they can share.

**Happy path**

1. The owner signs up with an email address.
2. The system creates an **Organization** and one default **Venue** behind the scenes (the word "venue" never appears in the MVP UI).
3. The owner sets the shop name, default language, logo, and brand colors.
4. The owner receives their catalog address (subdomain or path) and a printable QR code.

**Done looks like:** A live, branded, empty catalog in under 10 minutes.

**Failure paths**

- Chosen address already taken: suggest alternatives.
- Logo upload fails or is too large: resize automatically or fall back to shop name text.

**Questions raised**

- Subdomain (`shop.example.jp`) or path (`example.jp/shop`)? Affects TLS certificates, DNS, and caching.
- Invite-only during MVP, or open signup?

---

## Journey 1: A new beer arrives (MVP)

**Actor:** Owner or staff, on a phone.
**Trigger:** A new shipment arrives.
**Goal:** Each new beer appears in the catalog, filterable and bilingual, with minimal effort.

**Happy path**

1. The owner opens the app and taps **Add beer**.
2. They fill a short form: name, brewery (pick existing or create inline), style (dropdown from the controlled list), ABV, container, volume, price, stock status, optional canned-on date, optional best-before date, optional photo.
3. They tap **Save**. The beer publishes immediately in Japanese.
4. The system drafts the English name and description in the background.
5. The owner reviews the English draft and accepts or edits it.
6. The beer appears in the catalog under "New this week", in every relevant filter, in both languages.

**Done looks like:** Under one minute per beer. Picking from lists wherever possible (brewery, style) instead of typing.

**Failure paths**

- Brewery is new: create it inline without leaving the form.
- **Translation fails or the AI service is down:** the beer still publishes in Japanese; translation retries later. AI is never in the critical path of publishing (see ADR 0006).
- Owner never reviews the English draft: see open question below.

**Questions raised**

- Is an unreviewed English draft shown to customers (labeled as machine-translated) or hidden until approved?
- How much does translation cost per beer? Measure it, don't assume it.
- Every manually entered beer is labeled data for testing future extraction features (label photo, pasted text). Keep it clean.

---

## Journey 2: A customer finds a beer (MVP)

**Actor:** A customer on a phone, possibly not a Japanese speaker.
**Trigger:** They open the catalog from a link, QR code, or social post.
**Goal:** Go from "I want something good" to a specific beer quickly.

**Happy path**

1. The catalog loads quickly and shows what is currently available, with new arrivals visible without hunting.
2. They switch language if they want; the choice persists.
3. They combine filters: style family, ABV range, brewery, country or region, container and size, price, freshness. The result count updates as they go.
4. They open a beer and see style, ABV, volume, tasting notes, brewery, and freshness.
5. They note it to order in store, or (later) tap through to buy on the shop's existing store.

**Done looks like:** Three or four taps from landing to a specific beer, on a phone, in either language.

**Failure paths**

- A filter combination has no results: suggest relaxing one filter instead of showing an empty page.
- A beer sells out while they browse: show it as sold out rather than a broken page.
- English text not yet available: show Japanese with a clear indicator.
- Slow connection (for example, in a bar): pages must be light and aggressively cached.

**Questions raised**

- Which filters are MVP and which come later?
- Filter state in the URL, so combinations like "hazy IPAs under 7%" are shareable links? (Recommended: yes.)
- Search-as-you-type in the MVP, or filters only?

---

## Journey 3: The daily stock update (MVP)

**Actor:** Owner or staff, mid-task, on a phone.
**Trigger:** A beer sold out, came back in stock, or went on sale.
**Goal:** The catalog reflects reality within seconds.

**Happy path**

1. They open the app and land on the list of current beers, most recently changed first.
2. They find the beer by scrolling or by searching its name.
3. They tap its status (in stock / low / sold out). No form, no save button, no detail page.
4. The public catalog updates right away.

**Done looks like:** Under five seconds per change. This journey happens daily and decides whether the product gets used at all.

**Failure paths**

- Several beers change at once: is one-tap per beer fast enough, or is a bulk mode needed?
- Two staff members edit at the same time: last write wins, or conflict detection?
- Wrong beer tapped: easy undo (backed by the activity log).
- Bad signal in a back room: the change must queue visibly or fail clearly, never vanish silently.

**Questions raised**

- How quickly must a status change reach the public catalog? This drives cache invalidation design.
- This journey carries the reliability story: it must work on a Friday evening.

---

## Deferred journeys (post-MVP)

Listed in rough priority order. See [02-mvp-scope.md](02-mvp-scope.md).

- **External sync:** the owner keeps listing in their existing store (MakeShop first, then Color Me Shop); the platform imports and enriches. Read-only access to start.
- **AI recommender:** customer answers a few quick-pick questions and gets two matches from what is actually available, with reasons. Optional free-text chat.
- **Bar tap list and TV board:** on tap / next up / kicked; full-screen board view; printable menu.
- **Social image:** "today's taps" or "new arrivals" image in the shop's theme, for Instagram.
- **Embedded widget:** the catalog embedded in a shop's existing site, using the same public read API.
- **Label photo extraction:** photo of a can or label pre-fills the Journey 1 form.
