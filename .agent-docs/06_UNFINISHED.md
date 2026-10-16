# ALMA — Unfinished Work & TODO

Things that ship as placeholders or are knowingly incomplete. Remove an entry
once it is done.


## Leer — Seed Content Only

The Leer module ships with a small seed set so the flow can be built and
tested end to end. It is NOT release content.

Files (in `modules/data/assets/content/`):
  texts.json            3 texts of the planned 20–25
  lunfardo_words.json   13 words of the planned 160 (shared with Hablar)

The seed texts use real titles, authors, years and context cards, but the
verses are PLACEHOLDER lines written in the style of the song (only the
opening of "Yira, yira", already used in quotes.json, comes from the
original). Before release:

  - Replace every text with its verified original lyrics. Check public-domain
    status for each one (authors deceased before 1955; also check the date of
    first publication for the US).
  - Annotate ~200 Lunfardo tokens across all texts (consultant).
  - Review every context card (3–4 sentences, historical facts checked).
  - Review word meanings and etymologies with the philologist consultant.
  - Translations of the texts are not in scope yet.

### texts.json schema

    {
      "id": "yira_yira",            unique, referenced by quotes.json textId
      "title": "Yira, yira",
      "author": "Enrique Santos Discépolo",
      "year": 1930,
      "context": "Three to four sentences of historical background.",
      "stanzas": [["line", "line"], ["line"]]
    }

Lunfardo words are marked inline in a line:
  {grela}           surface text "grela", word id "grela" (lowercased)
  {morfo|morfar}    surface text "morfo", word id "morfar"

Every word id must exist in lunfardo_words.json and every quotes.json textId
must exist in texts.json. `modules/data/test/content/bundled_content_test.dart`
enforces both.

### lunfardo_words.json schema

    { "id": "grela", "word": "grela", "pronunciation": "/ˈɣɾe.la/",
      "meaning": "fickle fate",
      "etymology": ["Italian grilla → \"cricket\"", "Lunfardo: \"fickle fate\""],
      "example": { "line": "Y si un día la suerte,\nque es {grela}, te deja,",
                   "title": "Yira, yira", "year": 1930, "textId": "yira_yira" },
      "related": ["suerte", "yeta"] }

`etymology` is the chain, oldest source first; the word card shows one step
per line. `example.line` uses the same `{word}` / `{surface|wordId}` markup
as texts.json and must mark the word itself (the quiz blanks it out).
`related` entries are display strings, not word ids. Every `example.textId`
must exist in texts.json with the same title and year;
`bundled_content_test.dart` enforces it.


## Hablar — Seed Content Only

The 13 seed words carry PLACEHOLDER pronunciations, etymology chains, example
lines and related words, written to exercise the word card and the quiz. The
example lines come from the placeholder seed verses in texts.json. Before
release:

  - Write all 160 cards with the philologist consultant (pronunciation,
    meaning, etymology chain, example line, related words).
  - Re-pick every example line once the original lyrics replace the seed
    verses.


## Hablar — Not Implemented

  - Buenos Aires Map (Feature 9, Full Release) and its quote → Leer link
    (US 14.5). The map entry is left off the Hablar main screen
    (`HablarEntry`). Needs district tagging per word and milestone quotes.
  - "All words learned" is shown in My Dictionary when every word is saved;
    with seed content that means 13 words, not 160.


## Leer — Not Implemented

  - "All texts read" edge state (01_USER_FLOW.md, States and Edge Cases):
    needs read tracking, which does not exist yet.
