# Feature 12. Leer — Lunfardo Word Annotation

Priority: MVP

Description:
A popup card when tapping a Lunfardo word in the text.
Shows brief meaning, etymology, and an "Add to dictionary" button.

US 12.1
As a user,
I want to instantly see the meaning of an unfamiliar word within the text,
so that I don't interrupt my reading or switch to another module.

  Given the user is reading a text and sees the word "grela"
       with an underline
  When the user taps the word
  Then a popup card rises from the bottom of the screen
  And the line being read stays visible above it
  And the tapped word turns Oro in the line while the card is open
  And the card contains the word, brief meaning, and one-line etymology
  And the card background is Negro at 95% opacity

US 12.2
As a user,
I want to add the word to my personal dictionary directly from the text,
so that I don't have to memorize it and can return to it later.

  Given the word annotation popup is open
  When the user taps "Add to my dictionary"
  Then the word is saved to the local dictionary
  And the button changes to "In dictionary"
  And the counter in Hablar updates

US 12.3
As a user,
I want to close the card and continue reading,
so that I don't lose my rhythm.

  Given the word annotation popup is open
  When the user taps "Close" or taps outside the card
  Then the card disappears (fade out, 200ms)
  And reading continues from the same line
