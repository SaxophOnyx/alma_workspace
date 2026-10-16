# Feature 7. Hablar — Personal Dictionary

Priority: MVP

Description:
A list of words the user has added to their personal dictionary.
Simple scroll, tap on a word opens its card.

US 7.1
As a user,
I want to see all the words I've collected,
so that I can feel my vocabulary growing.

  Given the user has 47 words in their personal dictionary
  When the "My Dictionary" section opens
  Then a list of 47 words is displayed
  And the counter (47) appears next to the section title

US 7.2
As a user,
I want to open the card of any word from the list,
so that I can re-read the etymology or example.

  Given the personal dictionary list
  When the user taps the word "morfar"
  Then the word card for "morfar" opens
  And the "Add" button already shows "In dictionary"
