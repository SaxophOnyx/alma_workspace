# Feature 6. Hablar — Word Card & Word of the Day

Priority: MVP

Description:
A card for a single Lunfardo word: pronunciation, meaning, etymology,
example from a tango lyric, related words. The word of the day refreshes
daily.

US 6.1
As a user,
I want to see one new word every day,
so that I learn Lunfardo gradually without overload.

  Given the user enters Hablar
  When the "Word of the Day" section opens
  Then one word card is displayed
  And the word of the day changes every 24 hours based on local
       device time
  And no word repeats until all 160 have been shown

US 6.2
As a user,
I want to see the etymology of a word,
so that I remember not just a translation but a story — where the word
came from and how it evolved.

  Given the word card for "grela"
  When the card is displayed
  Then the chain is visible: Italian "grilla" to "cricket"
       to Lunfardo "fickle fate"
  And the chain is set in Montserrat, 14pt, color Humo

US 6.3
As a user,
I want to see an example of the word in a tango lyric line,
so that I understand usage in context, not just a definition.

  Given the word card for "grela"
  When the card is displayed
  Then the line "Y si un día la suerte, que es grela..." is visible
  And below the line — the poem title and year
  And there is an "Open text" button leading to Leer

US 6.4
As a user,
I want to add a word to my personal dictionary with one tap,
so that I can return to it later and track my progress.

  Given a word card
  When the user taps "Add to my dictionary"
  Then the word is saved to the local dictionary
  And the button changes to "In dictionary"
  And the counter on the Hablar main screen increments by 1
