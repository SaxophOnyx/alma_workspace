# Feature 9. Hablar — Buenos Aires Map

Priority: Full Release

Description:
A stylized dark map of three neighborhoods: San Telmo, La Boca, Abasto.
Learned words "populate" the map. Quotes appear at milestone thresholds.

US 9.1
As a user,
I want to see my word-learning progress on a visual map,
so that I can feel the city "coming alive" as I advance.

  Given the user has learned 32 out of 60 San Telmo words
  When the map is displayed
  Then San Telmo shows progress 32/60
  And the neighborhood is visually partially "filled"
       (windows, signs, lanterns)
  And the unfilled portion is dark and empty

US 9.2
As a user,
I want to navigate from a neighborhood to its word list,
so that I can deliberately study words from a specific area.

  Given the map with three neighborhoods
  When the user taps "La Boca"
  Then the word list for that neighborhood opens
  And learned words are highlighted gold
  And unlearned words are dark grey
  And tapping any word opens its card

US 9.3
As a user,
I want to discover quotes on the map when I hit milestones,
so that progress feels like discovery rather than counting.

  Given the user has learned the 25th word of San Telmo
  When the map updates
  Then a quote from a text related to the neighborhood appears
       on the map
  And the quote is set in Cormorant Garamond, 16pt, Oro
  And tapping the quote leads to the full text in Leer
