# Feature 1. Onboarding

Priority: MVP

Description:
A four-slide wizard shown on first launch. Sets the tone, communicates
core principles (no account, no internet, no notifications), and presents
the three paths. It does not teach — it introduces the atmosphere.

US 1.1
As a new user,
I want to see only text on a black background with no icons or illustrations,
so that I immediately feel the app's aesthetic and stay focused.

  Given the app is launched for the first time
  When onboarding slide 1 appears
  Then the screen shows only the word "Alma" and four lines of text
  And there are no icons, images, or rectangular buttons
  And the background is #0D0B09, text is #F2EBE0

US 1.2
As a new user,
I want to understand what three paths are available to me,
so that I can consciously choose where to begin.

  Given the user is on onboarding slide 2
  When the slide is displayed
  Then three lines are visible — Respirar, Hablar, Leer
  And each line has a two-to-three-word subtitle beneath it
  And the lines appear sequentially with a 600ms interval

US 1.3
As a new user,
I want to know that the app will not require an account, internet,
or notifications,
so that I don't worry about privacy or waste time on setup.

  Given the user is on onboarding slide 3
  When the slide is displayed
  Then the lines "No account.", "No internet.", "No notifications."
       are visible
  And below them: "Just you, the dark, and a city that whispers."

US 1.4
As a new user,
I want to skip the onboarding if I'm not interested,
so that I can get straight into the app.

  Given any onboarding slide is displayed
  When the user taps "Skip" in the top-right corner
  Then onboarding is dismissed
  And the main screen with three lines appears
  And onboarding_complete = true is written to local storage
  And on next launch, onboarding is not shown

US 1.5
As a new user,
I want to finish onboarding with a single word "Enter",
so that the transition into the app feels like stepping into a space,
not pressing a button.

  Given the user is on onboarding slide 4
  When the user taps the word "Enter" in the center of the screen
  Then the word softly highlights gold for 200ms
  And the main screen appears
  And onboarding_complete = true is written to local storage

US 1.6
As a developer,
I want onboarding to not persist its intermediate state,
so that I don't complicate logic for a 20-second screen.

  Given the user closed the app on onboarding slide 2
  When the app is opened again
  Then onboarding starts from slide 1
  And there is no saved "current slide" state
