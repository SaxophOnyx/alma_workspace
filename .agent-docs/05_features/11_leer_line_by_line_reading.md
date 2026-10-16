# Feature 11. Leer — Line-by-Line Reading

Priority: MVP

Description:
The text appears one line at a time. Tap the screen — next line.
Within a stanza the lines build up: the newest in full Crema, the
earlier ones dimmed but kept, on a fixed left margin about a third
down the screen. At a stanza break the whole stanza fades out.
Between stanzas — one second of empty black screen.
On the first line a Humo "tap to continue" hint shows at the bottom;
a row of dots (one per stanza) marks the position.
Lunfardo words are highlighted with a gold underline.

US 11.1
As a user,
I want to read the text line by line instead of scrolling,
so that I can feel the phrasing rhythm and pauses, as in tango.

  Given the user pressed "Read" on the context card
  When reading mode is active
  Then the first line of the stanza is on screen
  And tapping the screen reveals the next line below it
       (the previous lines dim to 40% and stay)
  And the transition between lines is a fade, 400ms

US 11.2
As a user,
I want to experience a pause between stanzas,
so that I can feel the silence that in tango is as important as sound.

  Given the last line of a stanza has been shown
  When the user taps for the next line
  Then the screen stays empty and black for 1 second
  And then the first line of the next stanza appears

US 11.3
As a user,
I want to see Lunfardo words highlighted in the text,
so that I notice them and can tap for an explanation.

  Given a line contains a Lunfardo word
  When the line is displayed
  Then the word has a thin gold underline
  And the word color remains Crema (only the underline is added)
  And tapping the word opens the annotation popup (see Feature 12)
