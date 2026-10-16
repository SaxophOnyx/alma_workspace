# Feature 3. Respirar — Mode & Duration Selection

Priority: MVP

Description:
The user selects one of four breathing modes and one of four session
durations before starting a session.

US 3.1
As a user,
I want to choose the type of breathing practice,
so that I can match the session to my current state — calming down,
breathing in tango rhythm, or preparing for an embrace.

  Given the user has entered the Respirar module
  When the mode selection screen is displayed
  Then four lines are visible — Compás, Pausa, Caminar, Abrazo
  And tapping a line opens the duration selection

US 3.2
As a user,
I want to choose the session duration,
so that I can start with a short practice if I'm unsure,
or commit to a long one.

  Given the user has selected a mode
  When the duration selection screen is displayed
  Then four options are visible — 2 min, 5 min, 10 min, 15 min
  And tapping an option immediately starts the session
  And there is no "Start" button or confirmation step
