# Feature 14. Cross-Module Transitions

Priority: MVP / Full

Description:
Connections between the three modules that make them feel like one app.
Each transition is one-directional with a back button to return.

US 14.1
As a user,
I want to transition from breathing to poetry through the quote
at session end,
so that the modules feel connected rather than separate tabs.

  Given the Respirar session has ended and a line from "Yira, yira"
       is shown
  When the user taps the line
  Then Leer opens with the context card for "Yira, yira"
  And the back button returns to the session end screen

US 14.2
As a user,
I want to transition from poetry to the dictionary by tapping
a Lunfardo word,
so that I can go deeper into the language as I read.

  Given the user is reading a text in Leer and sees the word "grela"
  When the user taps the word
  Then a popup card appears with data from Hablar
  And the card does not navigate away from the reading screen
  And the user can optionally add the word to their personal dictionary

US 14.3
As a user,
I want to transition from poetry to breathing through the button
at text end,
so that I can close my reading with a bodily practice.

  Given the end of a text in Leer
  When the user taps "Breathe with this text"
  Then Respirar opens in Abrazo mode
  And the back button after the session returns to Leer

US 14.4
As a user,
I want to transition from the dictionary to poetry through the example
in a word card,
so that I can see the word in a living context.

  Given the word card for "grela" in Hablar
  When the user taps "Open text"
  Then Leer opens with the text "Yira, yira"
  And the back button returns to the word card

US 14.5
As a user,
I want to transition from the map to poetry through a quote
at a milestone,
so that progress in words unlocks new texts.

  Given the user has learned 25 words in the San Telmo neighborhood
  When a quote from "Sur" appears on the map
  And the user taps the quote
  Then Leer opens with the text "Sur"
  And the back button returns to the map
