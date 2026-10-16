# ALMA — Color System

## Principle

The app exists only in dark theme. There is no light theme.
This is not a user setting — it is an aesthetic decision.
A milonga at 2 am. A candle. Shadow. Gold on black.

Five colors total. No additional colors.


## Primary Palette

### Black (background)
Name:          Negro
HEX:           #0D0B09
RGB:           13, 11, 9
Purpose:       Background of all screens. Not pure black (#000000)
               but warm black with a barely perceptible brown undertone.
               Creates a sense of depth and warmth rather than
               "a turned-off device screen."
Usage:         100% of background surfaces.

### Cream (primary text)
Name:          Crema
HEX:           #F2EBE0
RGB:           242, 235, 224
Purpose:       Primary text: headings, poetry lines, section names,
               button-words.
Usage:         All first-level readable content.

### Gold (accent)
Name:          Oro
HEX:           #C4A265
RGB:           196, 162, 101
Purpose:       The only accent color. Lunfardo word underlines in texts.
               Line highlight on tap. The breathing point in Respirar.
               Progress on the map. Highlighted elements.
Usage:         No more than 10-15% of screen area. Gold is rare,
               like an accent in music: one hit per phrase.

### Carmine (rare signal)
Name:          Carmín
HEX:           #7B2233
RGB:           123, 34, 51
Purpose:       Extremely rare. Quiz error (soft, not aggressive).
               A thin divider line on the map screen.
               The word "Leave" in session exit confirmation.
Usage:         No more than 2-3% of screen area. Appears for a fraction
               of a second.

### Grey-brown (secondary text)
Name:          Humo
HEX:           #8A8078
RGB:           138, 128, 120
Purpose:       Captions, dates, author names, secondary explanations,
               unlearned words on the map, "Skip" button text
               in onboarding.
Usage:         Everything that does not require full attention.


## Summary Table

    Role                  Color       HEX       Frequency on screen
    ---------------------------------------------------------------
    Background            Negro       #0D0B09   ~80%
    Primary text          Crema       #F2EBE0   ~10%
    Accent                Oro         #C4A265   ~7%
    Secondary text        Humo        #8A8078   ~2%
    Rare signal           Carmín      #7B2233   ~1%


## Application Rules

1. Gold is never used for large blocks. Only for lines, underlines,
   points, short words. Gold is an accent in music: one hit per phrase.

2. Carmine is never used as a background. Only text or a thin line.
   It is not a "red error button." It is a slight sting.

3. No white (#FFFFFF). Anywhere. Not even for text. Crema (#F2EBE0)
   is contrasty enough and does not strain the eyes in darkness.

4. No pure black (#000000). Background is always warm (#0D0B09).
   Pure black creates a "dead pixel" feeling.

5. No grey (#808080). All intermediate shades go through the warm
   scale (brown undertone).

6. Transparency is allowed only for overlays (word annotation popup:
   background #0D0B09 at 95% opacity).


## Contrast and Accessibility

    Pair                  Contrast    Compliance
    -------------------------------------------------------
    Crema on Negro        15.2:1      WCAG AAA (normal and large text)
    Oro on Negro          7.1:1       WCAG AA large text,
                                      sufficient contrast for accents
    Humo on Negro         4.8:1       WCAG AA normal text
    Carmín on Negro       3.1:1       Decorative elements only,
                                      does not carry critical information


## Typography and Color

    Element                    Font                Size     Color
    -------------------------------------------------------------------
    "Alma" title               Cormorant Garamond  42pt     Crema
    Section title              Cormorant Garamond  44pt     Crema +
                                                             24pt Oro rule
    Navigation lines           Cormorant Garamond  28pt     Crema
    Poetry line                Cormorant Garamond  24pt     Crema
    Lunfardo word in text      Cormorant Garamond  24pt     Crema +
                                                             Oro underline
    Word card title            Cormorant Garamond  44pt     Oro
    Button-word                Cormorant Garamond  22pt     Crema
                               italic
    Running head, quiet        Cormorant Garamond  17pt     Humo
    actions ("Skip", "Home",   small caps, letter-
    "Close"), labels           spaced
    Definition                 Montserrat          16-18pt  Crema
    Etymology                  Montserrat          14pt     Humo
    Date, author name          Montserrat          13pt     Humo

Montserrat is the only sans-serif and is kept to reading copy
(definitions, context, captions). Anything that acts — buttons,
labels, the running head — is set in Cormorant, so actions read
as part of the book rather than as interface chrome.
Cormorant figures are set as lining figures, so counters such as
"(1)" and "3 / 10" do not read as letters.

The running head is a single small-caps line at the top of every
screen that has one, naming the parent: "Alma" on module menus,
the module name inside a module, "3 / 10" in the quiz. The back
arrow sits to its left in Humo.


## The Breathing Point in Respirar

The point is not a flat circle. It is a radial gradient:
  Center:    #F2EBE0 (Crema), opacity 100%
  Middle:    #C4A265 (Oro), opacity 60%
  Edge:      #C4A265 (Oro), opacity 0%

Diameter at rest: 12pt.
Diameter at inhale (maximum): 140pt.
Diameter at exhale (minimum): 20pt.
Transition: ease-in-out, duration equals the breathing phase.

Halo: a second, much fainter radial gradient behind the point
(Oro at 14% fading to 0%), 2.6 times the point's diameter, growing
and shrinking with it. It makes the point read as light, not a disc.

On hold the point does not change size. It is frozen. Like a dancer.
Only its light flickers very slowly (opacity 100% to 94%, 2.4 s),
like a candle.

Paused: the point dims to 40% and the word "pausa" appears below
it in Humo small caps.


## Onboarding Colors

Background:   Negro (#0D0B09)
Text:         Crema (#F2EBE0)
Accent:       one word per slide may be Oro (#C4A265)
Progress indicator dots:
  Active:     Oro, diameter 6pt
  Inactive:   Humo, diameter 4pt


## What Is Forbidden

No gradients in the interface (except the breathing point in Respirar).
No shadows. No outlines. No borders.
No colored icons. No colored rectangular buttons.
No second accent color. Gold is one. Carmine is the exception.
No color animation, with two exceptions: a tapped word-button
eases from Crema to Oro (200 ms), and in the quiz the right answer
turns Oro while a wrong choice gets a thin Carmín line. Everything
else appears and disappears only through opacity (fade).

Motion: screens change by fade-through (the old screen fades out
first, the new one fades in while rising 8pt), and menus, lists
and card sections enter one after another, 90 ms apart.
Loading shows nothing for 300 ms, then a single slowly pulsing
Oro dot.
