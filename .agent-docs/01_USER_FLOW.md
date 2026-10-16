# ALMA — User Flow & Navigation

## Global Structure

The app does not use a classic tab bar.
Navigation is built like a book's table of contents: three text-based
entry points on the main screen.
Inside modules — a linear flow with back navigation.

Maximum nesting depth: 3 screens from the main screen.
Back gesture (iOS swipe / Android button) works on every level.


## Navigation Map

    [FIRST LAUNCH]
          |
          v
    [ONBOARDING: 4 slides]
          |
          v
    [MAIN SCREEN: ALMA]
          |
          +-- Respirar --> mode select --> duration --> session --> end
          |                                                            |
          |                                                            v
          |                                                        [Leer]
          |
          +-- Hablar --> word of day --> card --> [Leer]
          |           +-> my dictionary -> card
          |           +-> quiz ----------> question series -> result
          |           +-> map -----------> district -> words / quote -> [Leer]
          |
          +-- Leer -----> text list --> context --> reading
                                                   |         |
                                                   |         +-> word -> [Hablar]
                                                   v
                                             end -> [Respirar, Abrazo]


## Screen 0: First Launch

Condition: app opened for the first time, no data in local store.

    Black screen. Pause. The word "Alma" appears.
          |
          v  (automatic, after 2.5 sec)
    [ONBOARDING: slide 1 of 4]


## Screen 1: Onboarding

Wizard, four slides. Swipe right or tap "Next".
"Skip" in the top-right corner.
Progress: four dots at the bottom.

    Slide 1 -> Slide 2 -> Slide 3 -> Slide 4 -> [MAIN SCREEN]

After completion: onboarding_complete = true is written to local store.
On subsequent launches, onboarding is not shown.


## Screen 2: Main Screen (Alma)

    +-----------------------------+
    |                             |
    |                             |
    |        Respirar             |
    |                             |
    |         Hablar              |
    |                             |
    |          Leer               |
    |                             |
    |                             |
    +-----------------------------+

Three lines centered, Cormorant Garamond, 28pt.
Color Crema (#F2EBE0) on Negro (#0D0B09).
"Alma" as the small-caps running head at the top; the tagline
"tres caminos del tango" in Humo at the bottom.

Module menus (Respirar, Hablar, Leer list, duration) share one
layout: the section title large on the left margin about a third
down, a short Oro rule under it, the entries below, entering one
after another.
On tap the line softly highlights in Oro (#C4A265), then transition.

No icons. No subtitles. No tab bar.
This is the root screen: no back button.


## Screen 3: Respirar Module

### 3.1. Mode Selection

    <- (back to Alma)

    Respirar

    Compás
    Pausa
    Caminar
    Abrazo

Four lines, like a table of contents. Tap -> duration selection.

### 3.2. Duration Selection

    <- (back to modes)

    2 min
    5 min
    10 min
    15 min

Tap -> active session begins immediately.

### 3.3. Active Session

    +-----------------------------+
    |                             |
    |                             |
    |           *                 |
    |    (golden point of light)  |
    |                             |
    |                             |
    |                             |
    +-----------------------------+

No buttons on screen.
Tap on screen — soft pause.
Long press (2 sec) — exit with confirmation.
On completion: smooth transition to the end screen.

### 3.4. Session End

    "Y si un día la suerte,
     que es grela..."

        — Yira, yira, 1930

    [Read the full text]

    [Home]

The line appears after 2 seconds of darkness (fade in).
"Read the full text" or tap on the line -> Leer, full text.
"Home" -> root screen Alma.


## Screen 4: Hablar Module

### 4.1. Hablar Main Screen

    <- (back to Alma)

    Hablar

    Word of the Day
    My Dictionary (47)
    Quiz
    Buenos Aires Map

Four entry lines. Word counter updates locally.

### 4.2. Word of the Day / Word Card

    <- (back to Hablar)

    grela
    /'ɣɾe.la/

    Fate, luck —
    usually cruel, capricious

    Etymology:
    Italian grilla -> "cricket"
    -> Lunfardo: "fickle fate"

    Example:
    "Y si un día la suerte,
     que es grela..."
    [Open text ->]

    Related: suerte, yeta

    [Add to my dictionary]

"Open text" -> Leer, corresponding text.
"Add to my dictionary" -> word is saved, button changes to "In dictionary".

### 4.3. My Dictionary

    <- (back to Hablar)

    My Dictionary (47)

    grela
    laburar
    mina
    morfar
    gotán
    ...

    (scroll)

Simple list. Tap on a word -> word card (4.2).

### 4.4. Quiz

    <- (back to Hablar)

    What does "grela" mean?

    o Street
    o Fate
    o Knife
    o Dance

After selection — explanation screen (etymology or example).
Then the next question. Series of 10 questions.
At the end: result without grading — "You recalled 8 out of 10".

### 4.5. Buenos Aires Map

    <- (back to Hablar)

    +------------------------------+
    |  San Telmo    32/60          |
    |  .........................   |
    |                              |
    |  La Boca      18/50          |
    |  .........................   |
    |                              |
    |  Abasto        5/50          |
    |  .........................   |
    +------------------------------+

    Tap a district -> word list

Learned words highlighted gold. Unlearned — dark grey.
At milestone thresholds a quote appears -> tap -> Leer.


## Screen 5: Leer Module

### 5.1. Text List

    <- (back to Alma)

    Leer

    Mi Noche Triste          1917
    Yira, Yira               1930
    Cambalache               1934
    El día que me quieras    1935
    Volver                   1934
    Sur                      1948
    ...

Tap on a text -> context card.

### 5.2. Context Card

    <- (back to list)

    Yira, Yira
    Enrique Santos Discépolo
    1930

    Argentina after the 1930 coup.
    Discépolo writes a song about a man
    abandoned by everyone, including luck.

    [Read]

Tap "Read" -> line-by-line mode.

### 5.3. Line-by-Line Reading

    +-----------------------------+
    |                             |
    |                             |
    |  Cuando la suerte,          |
    |  que es grela,              |
    |                             |
    |                             |
    |  (tap -> next line)         |
    +-----------------------------+

Lines appear one at a time and build up within a stanza
(earlier lines dimmed). Tap on screen -> next line.
Lunfardo words have a gold underline.

Tap on a Lunfardo word -> popup card:

    +-------------------------+
    |  grela                  |
    |  fickle fate            |
    |  Italian grilla         |
    |                         |
    |  [Add to dictionary]    |
    |  [Close]                |
    +-------------------------+

Between stanzas — 1 second of empty black screen.

### 5.4. Text End

After the last line — 3 seconds of darkness. Then:

    [Another text]

    [Breathe with this text]

    [Home]

"Breathe with this text" -> Respirar, Abrazo mode.
"Another text" -> text list.
"Home" -> root screen Alma.


## Cross-Module Transitions (Summary)

    From                   To                      Trigger
    ----------------------------------------------------------
    Respirar, end      ->  Leer, text              Tap on the line
    Leer, word         ->  Hablar, card            Tap on Lunfardo word
    Leer, end          ->  Respirar, Abrazo        Tap "Breathe"
    Hablar, example    ->  Leer, text              Tap "Open text"
    Hablar, map        ->  Leer, text              Tap on district quote

All transitions are one-directional within a session.
Back button returns to the previous screen.
No full-screen modals except the word annotation popup.


## Back Button Behavior

    Screen                    Back action
    ----------------------------------------------------------
    Main (Alma)               No button (root)
    Mode selection            -> Main screen
    Duration selection        -> Mode selection
    Active session            Long press -> exit confirmation
    Session end               -> Main screen
    Word list / quiz          -> Hablar main screen
    Word card                 -> Previous screen
    Text list                 -> Main screen
    Context card              -> Text list
    Line-by-line reading      -> Context card
    Text end                  -> Text list

On Android: system back button duplicates the gesture.
On iOS: swipe from the left edge.


## States and Edge Cases

Empty dictionary:
    "Nothing here yet. Tap a word in a text to begin."

All words learned:
    "Your Lunfardo is complete. 160 words."

All texts read:
    Suggestion to re-read or breathe.

Interrupted breathing session:
    Not saved. Start over.

No unfinished reading states.
The app does not store a "position in text".
Every entry into a text starts from the first line.
