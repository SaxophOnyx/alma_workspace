# ALMA — Unfinished Work & TODO

Things that ship as placeholders or are knowingly incomplete. Remove an entry
once it is done.


## Leer — Seed Content Only

The Leer module ships with a small seed set so the flow can be built and
tested end to end. It is NOT release content.

Files (in `modules/data/assets/content/`):
  texts.json            3 texts of the planned 20–25
  lunfardo_words.json   13 words of the planned 160

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

    { "id": "grela", "word": "grela", "meaning": "fickle fate",
      "etymology": "Italian grilla, \"cricket\"" }

This holds only what the Leer annotation popup needs. Hablar (Features 6–9)
will extend it: pronunciation, full etymology chain, example line with text
reference, related words.


## Leer — Depends on Hablar

  - US 12.2 "the counter in Hablar updates": the word is saved to the shared
    personal dictionary (`DictionaryRepository`, key `personal_dictionary`),
    but there is no Hablar screen to show the counter yet.
  - US 14.4 (word card "Open text") and US 14.5 (map quote) should call the
    Leer context card, as `RouterRespirarNavigator.openText` does.


## Leer — Not Implemented

  - "All texts read" edge state (01_USER_FLOW.md, States and Edge Cases):
    needs read tracking, which does not exist yet.
