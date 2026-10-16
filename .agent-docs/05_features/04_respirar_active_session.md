# Feature 4. Respirar — Active Breathing Session

Priority: MVP

Description:
The core breathing screen. A golden point of light on a black background
that expands and contracts in the rhythm of the selected pattern.
No buttons, numbers, or timers.

US 4.1
As a user,
I want to see only a point of light on a black background with no numbers
or labels,
so that I can focus on breathing rather than the interface.

  Given the user has selected Compás mode and 5-minute duration
  When the session begins
  Then only a golden point is visible in the center of the screen
  And there is no timer, counter, mode name, or stop button
  And the point expands on inhale, freezes on hold, contracts on exhale

US 4.2
As a user,
I want to feel phase transitions through gentle vibration,
so that I can breathe with my eyes closed without looking at the screen.

  Given an active breathing session
  When the phase changes (inhale to hold to exhale)
  Then the device emits a single soft haptic pulse
  And on iOS it uses UIImpactFeedbackGenerator(style: .soft)
  And on Android it uses VibrationEffect.createOneShot(30, 80)
  And the pulse is singular, not repeated

US 4.3
As a user,
I want to pause with a simple tap on the screen,
so that I can stop if I lose the rhythm or get distracted.

  Given an active breathing session
  When the user performs a short tap on the screen
  Then the point freezes at its current size
  And the session timer pauses
  And a second tap resumes the session from the same point

US 4.4
As a user,
I want to exit a session through a deliberate action, not an accidental tap,
so that I don't interrupt my practice by mistake.

  Given an active breathing session
  When the user performs a long press (hold for 2 seconds)
  Then a text confirmation appears: "Leave this session?"
  And two options are shown — "Leave" and "Stay"
  And "Leave" is colored Carmín, "Stay" is Crema
  And there are no rectangular buttons, only words

US 4.5
As a user,
I want the session to end on its own when the time is up,
so that I don't have to watch a timer.

  Given a 5-minute session
  When 5 minutes of active breathing time have elapsed
       (excluding pauses)
  Then the point fades out smoothly (fade out, 2 seconds)
  And the screen becomes fully black
  And after 2 seconds the closing line appears (see Feature 5)
