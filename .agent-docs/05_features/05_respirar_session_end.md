# Feature 5. Respirar — Session End & Bridge to Leer

Priority: MVP

Description:
After the session ends, a line of tango poetry fades in from darkness.
The line is tappable and leads to the full text in the Leer module.

US 5.1
As a user,
I want to see a line of tango poetry after my breathing session,
so that the transition from breath to word feels like a natural
continuation of the practice.

  Given the breathing session has ended
  When the screen is black for 2 seconds
  Then one line of tango poetry fades in (fade in, 1.5 sec)
  And below the line — the poem title and year
  And the font is Cormorant Garamond, 24pt, Crema
  And Lunfardo words in the line have a thin Oro underline
  And the title and year (Montserrat, 13pt, Humo) fade in 600ms later
  And the actions fade in 600ms after that

US 5.2
As a user,
I want to tap the line and read the full text,
so that I can go deeper into the poetry if the line resonated with me.

  Given the session end screen showing a line from "Yira, yira"
  When the user taps the line or taps "Read the full text"
  Then the Leer module opens with the text "Yira, yira"
  And reading begins with the context card

US 5.3
As a user,
I want to return to the main screen without reading,
so that I can finish my practice and move on.

  Given the session end screen
  When the user taps "Home"
  Then the main Alma screen appears
  And no text is opened
