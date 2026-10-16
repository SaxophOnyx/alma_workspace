# Feature 13. Leer — Text End & Bridge to Respirar

Priority: MVP

Description:
After the last line — 3 seconds of darkness. Then three options:
read another, breathe with this text, or return to the main screen.

US 13.1
As a user,
I want to feel silence after the end of a text,
so that I don't switch instantly and can let the lines settle.

  Given the last line of the text has been shown
  When the user taps for the next line
  Then the screen stays black and empty for 3 seconds
  And there is no "the end" label, no button, no sound
  And after 3 seconds, three option lines appear

US 13.2
As a user,
I want to transition to a breathing session linked to the text,
so that I can embody what I've read, not just see it.

  Given the end of the text "El día que me quieras"
  When the user taps "Breathe with this text"
  Then Respirar opens in Abrazo mode
  And duration selection is standard (2/5/10/15)

US 13.3
As a user,
I want to read another text or return to the list,
so that I can continue reading on my own terms.

  Given the end of a text
  When the user taps "Another text"
  Then the text list in Leer opens

  Given the end of a text
  When the user taps "Home"
  Then the main Alma screen appears
