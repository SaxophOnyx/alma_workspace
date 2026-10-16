# ALMA — App Overview

## Identity

Name: Alma
Tagline: Tres caminos del tango
Platforms: iOS, Android (Flutter)
Mode: Offline-only. No account. No internet. No notifications.


## The Idea

Tango is commonly reduced to steps, spins, and dresses. But any maestro
will tell you: tango lives in what happens between the steps. The pause.
The breath. The word left unspoken. The story danced, not displayed.

Alma is built on three pillars without which tango does not exist:

  Breathing — the body enters the music.
  The Word — the music finds its language.
  Poetry — the language becomes feeling.

These are not three utilities bundled into one app. They are three doors
into a single space. The user does not switch between modules — they
flow through them.


## Target User

A woman or a man, 30 to 55 years old. Dances tango for one to four years,
or does not dance yet but is captivated by the culture. Travels to Buenos
Aires or dreams of it. Reads. Appreciates poetry. Interested in languages.
Tired of apps that shout, demand subscriptions, and send push notifications.
Wants a quiet thing to open at 11 pm after a milonga. Not looking for
sacada tutorials. Looking for understanding.


## Three Modules

### Respirar (Breathe)

A breathing and pause trainer rooted in tango phrasing. A single golden
point of light on a black screen expands on inhale, freezes on hold,
contracts on exhale. No numbers, no timers, no progress bars.

Four modes:
  Compás — breathing in an 8-count phrase. Inhale 1-4, hold 5, exhale 6-8.
  Pausa — extending the silence between breath cycles. Hold grows from 3 to 12 seconds.
  Caminar — breathing synced to an imagined walk. Inhale-step-step, exhale-step-pause.
  Abrazo — breathing as entering an embrace. Slow inhale, hold, gentle exhale-settle.

Session durations: 2, 5, 10, 15 minutes.
Haptic feedback: a single soft pulse on each phase transition.

At the end of each session, a line of tango poetry fades in from darkness.
Tapping it leads to the full text in the Leer module.


### Hablar (Speak)

A living dictionary of Lunfardo — the slang of Buenos Aires in which all
classic tango lyrics are written. 160 words with pronunciation, meaning,
etymology chains, and examples from actual tango texts.

Components:
  Word of the Day — one new word every 24 hours.
  Personal Dictionary — words the user has collected.
  Quiz — 10-question sessions across 5 question types. Explanations, not grades.
  Buenos Aires Map — three neighborhoods (San Telmo, La Boca, Abasto) that
  fill in as words are learned. Quotes appear at milestones.

No streaks. No gamification pressure. Just a quiet counter:
"Your Lunfardo: 47 words."


### Leer (Read)

Interactive poetry of tango. 20 to 25 classic texts (all authors deceased
before 1955, public domain). Each text is annotated: Lunfardo words are
underlined in gold, tappable for instant definitions.

Reading mode: lines appear one at a time, in phrasing rhythm. Tap for the
next line. Between stanzas — one second of empty black screen. After the
last line — three seconds of darkness before options appear.

Each text is preceded by a context card: year, author, three to four
sentences of historical background.

At the end of each text, the user can read another, return home, or
"Breathe with this text" — a transition to Respirar in Abrazo mode.


## Cross-Module Connections

The three modules are not isolated. They reference each other:

  Respirar ends → a line of poetry appears → tap → Leer opens the full text.
  Leer, tap a Lunfardo word → popup card with data from Hablar → add to dictionary.
  Leer ends → "Breathe with this text" → Respirar opens in Abrazo mode.
  Hablar, word card example → "Open text" → Leer opens the referenced poem.
  Hablar, map milestone → a quote appears → tap → Leer opens the full text.

Every transition is one-directional within a session. The back button
always returns to the previous screen.


## Visual Language

Dark theme only. No light mode. This is not a setting — it is the aesthetic.
A milonga at 2 am. A candle. Shadow. Gold on black.

Five colors total:
  Negro #0D0B09 — background. Warm black, not pure black.
  Crema #F2EBE0 — primary text. Warm cream, never pure white.
  Oro #C4A265 — the only accent. Lunfardo underlines, the breathing point,
  progress highlights. Never more than 10-15% of screen area.
  Carmín #7B2233 — rare signal. Quiz errors, exit confirmation. 2-3% max.
  Humo #8A8078 — secondary text. Dates, authors, subtitles.

Typography: Cormorant Garamond for poetry and headings. Inter for UI and cards.
No icons. No illustrations of dancers. No stock photos.
No bounce animations. Only fade and ease-in-out.
Silence as a design element: empty black screens between stanzas,
three-second pauses after texts.


## Technical Approach

Framework: Flutter 3.x (single codebase for iOS and Android).
Platform channels: one thin Swift module and one thin Kotlin module for haptics.
Local storage: Hive or shared_preferences. No cloud, no backend, no server.
Navigation: go_router.
Fonts: google_fonts.
Data: JSON files in the assets folder. No database required.
Network: none. The INTERNET permission is not included in the manifest.
Analytics: none. No Firebase, no trackers, no telemetry.


## Permissions

Camera — not needed.
Microphone — not needed.
Location — not needed.
Notifications — not needed.
Internet — not needed. INTERNET permission is absent from the manifest.
File access — not needed. All content is bundled.
Contacts — not needed.
Health / Fitness — not needed.
Analytics / Trackers — not included.
Registration — not needed. The app works immediately.

The only system-level access: the vibration motor.
On Android this is a normal permission (VIBRATE), auto-granted at install,
no user prompt. On iOS it is a standard API, no permission required.

iOS Info.plist: zero usage description entries.
Android Manifest: one VIBRATE line. The user never sees a permission dialog.


## Content Plan

Breathing patterns: 4 presets. Author-designed. 2 days. $0.
Lunfardo words: 160 cards. Philologist consultant. 3 weeks. $800-1200.
Tango texts (originals): 20-25. Public domain. $0.
Translations: 20-25. Commissioned from a Spanish translator. 2 weeks. $600-1000.
Word annotations in texts: ~200 tokens. Consultant. 1 week. Included above.
Context cards for texts: 20-25, three to four sentences each. 1 week. $0-300.
Quotes for Respirar: 40 lines. Drawn from the same texts. 1 day. $0.

Total content budget: approximately $1500-2500 and 5-6 weeks.


## App Store Rejection Protection

Minimum functionality: three modules, cross-links, progress. Sufficient.
Not a website wrapper: fully native, offline.
User-generated content: absent.
Moderation: not needed.
Subscription without value: no subscription exists.
Permissions: zero user-facing requests.
Age rating: 4+ / Everyone.
Data Safety (Google Play): no data is collected.
Analytics / trackers: absent.


## Positioning

App name: Alma
iOS subtitle: Tres caminos del tango
Android subtitle: Breath, Word, Poetry

Short description:

  Breathe in the pauses. Read in the words. Listen between the lines.

  Alma — three doors into the soul of tango. Breathing practices, living
  Lunfardo words, and the poetry of Buenos Aires in one quiet app.

  No internet. No registration.

ASO keywords: tango, lunfardo, tango poetry, tango breathing, Buenos Aires,
tango culture, meditation tango, tango lyrics.


## The Word-of-Mouth Test

If a user can say this to a friend, the app works:

  "There's this app where a point of light breathes in the dark, and then
  it shows you poetry in Lunfardo. And you're sitting there at 1 am reading
  about Buenos Aires in 1930. And you don't need internet. Weird thing.
  Beautiful."


## Document Index

  00_APP_OVERVIEW.md — this file. Overall description of the app.
  01_USER_FLOW.md — user flow, navigation, screen-by-screen walkthrough.
  02_COLOR_PALETTE.md — color system, typography, visual rules.
  03_USE_CASES.md — usage scenarios across six personas.
  04_ONBOARDING.md — four-slide onboarding wizard specification.
  05_features/ — 14 features, 47 user stories with acceptance criteria.
                 One file per feature; README.md is the index.
