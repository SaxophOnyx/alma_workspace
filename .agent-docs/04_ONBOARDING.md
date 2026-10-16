# ALMA — Onboarding

## Format

A four-slide wizard. Horizontal swipe or tap "Next".
Progress: four dots at the bottom of the screen. Active — gold (6pt).
Inactive — grey-brown (4pt).

"Skip" button in the top-right corner. Cormorant small caps, 17pt, Humo color.
On tap — transitions directly to the main screen. Onboarding progress
is recorded as complete.

No slide animations. Transition — smooth crossfade, 400ms, ease-in-out.
No icons. No illustrations. No app screenshots.
Only text on black.


## Slide 1: The Name

The screen is empty. Black.

After 800ms a word appears in the center:

    Alma

Font: Cormorant Garamond, 42pt, Crema.
Appearance: fade in, 1200ms.

Below it, after another 1000ms, in small type:

    Tango is not what you dance.
    It's what you breathe,
    what you whisper,
    what you leave unsaid.

Font: Cormorant Garamond, 18pt, Humo.
Line spacing: 28pt.

Bottom: dot 1 of 4 (active) and the word "Next" (Cormorant italic, 22pt, Crema).

Purpose: set the tone. Do not explain what the app does.
Say what it is not. Tango is not movement. Tango is the silence
around movement.


## Slide 2: Three Paths

Black screen.

In the center, one below the other, three lines. They appear sequentially
with a 600ms interval:

    Respirar
    Hablar
    Leer

Font: Cormorant Garamond, 30pt, Crema.
Line spacing: 48pt.

Below each line, after it appears, a small caption (14pt, Humo):

    Respirar
    breathe in the pauses

    Hablar
    learn the words they whispered

    Leer
    read what they felt

Purpose: show three doors. Not as a feature list but as three paths.
The user chooses where to start. No hierarchy.

Bottom: dot 2 of 4 and "Next".


## Slide 3: Silence

Black screen. One line in the center:

    No account.
    No internet.
    No notifications.

Font: Montserrat, 18pt, Crema.
Line spacing: 32pt.

After 800ms a second part appears below (14pt, Humo):

    Just you, the dark,
    and a city that whispers.

Purpose: relieve anxiety. The user is used to apps asking for email,
enabling push, demanding a subscription. Here — nothing.
This is not a marketing move. It is a fact. The manifest does not
contain the INTERNET permission.

Bottom: dot 3 of 4 and "Next".


## Slide 4: Entry

Black screen.

In the center, one word:

    Enter

Font: Cormorant Garamond, 26pt, Crema.
Not a rectangular button. Just a word. But on tap it softly
highlights gold (200ms) and the transition occurs.

Below the word, in small type (13pt, Humo):

    Alma does not store your data.
    It has nothing to store.

Purpose: not "Start" and not "Done". "Enter". Like entering a room.
Like entering a milonga hall where they dim the lights.
The final line is not a legal disclaimer but an intonation.

Bottom: dot 4 of 4. No "Next" button anymore. Only "Enter".


## Technical Details

Onboarding state is stored in local store: key "onboarding_complete", boolean.
On first launch: value is absent or false -> show the wizard.
After completion or after "Skip": write true.
On subsequent launches: go directly to the main screen.

Slides are not cached. Not loaded from the network. Contain no images.
Four screens with text. Render: under 50ms on any device.

If the user closed the app mid-onboarding (slide 2),
on next launch onboarding starts from slide 1.
Progress within onboarding is not saved. This is a deliberate decision:
onboarding takes 20 seconds. It is simpler to show it again than to
persist state.


## Android Adaptation

Back navigation on onboarding slides:
  Slide 1: back button closes the app.
  Slides 2-4: back button returns to the previous slide.

On slide 4 the word "Enter" replaces the forward action:
  Back button returns to slide 3.
  "Enter" goes forward to the main screen.

Font sizes scale via sp. On tablets text does not scale proportionally
but is capped at a maximum text block width of 420dp. Text is always
centered with large top and bottom padding.


## What Onboarding Does NOT Do

Does not show interface screenshots.
Does not list features.
Does not explain how to use modules.
Does not request permissions.
Does not offer to create an account.
Does not contain animated illustrations.
Does not use the words "unique" or "innovative".
Does not promise. Sets the tone.
