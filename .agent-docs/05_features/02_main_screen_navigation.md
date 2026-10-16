# Feature 2. Main Screen & Navigation

Priority: MVP

Description:
The root screen of the app. Three text-based entry points: Respirar,
Hablar, Leer. No tab bar, no icons, no bottom navigation.

US 2.1
As a user,
I want to see three entry points on one screen without extra information,
so that I can choose my path intuitively without reading instructions.

  Given the user is on the main screen after onboarding
  When the screen is displayed
  Then three lines are centered — Respirar, Hablar, Leer
  And the font is Cormorant Garamond, 28pt, color Crema
  And there are no icons, subtitles, or tab bar

US 2.2
As a user,
I want the line I tap to softly highlight,
so that I get tactile feedback without visual noise.

  Given the user is on the main screen
  When the user taps the line "Respirar"
  Then the line smoothly highlights in Oro (#C4A265)
  And after 200ms the transition to the Respirar module occurs
  And there is no bounce animation, only a smooth transition

US 2.3
As a user,
I want the main screen to be the navigation root with no back button,
so that there are no dead-end states or confusion about where I am.

  Given the user is on the main screen
  When the user presses the system back button (Android)
       or performs a back swipe (iOS)
  Then nothing happens
  And the app stays on the main screen
