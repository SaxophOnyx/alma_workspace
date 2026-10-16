# Feature 10. Leer — Text List & Context Card

Priority: MVP

Description:
A list of tango lyrics with year and author. Before reading — a short
context card: year, author, historical background.

US 10.1
As a user,
I want to see all texts in one list with years,
so that I can choose by mood or by era.

  Given the user has entered the Leer module
  When the text list is displayed
  Then poem titles and years are visible
  And title font is Cormorant Garamond, 22pt, Crema,
       with the author below in Montserrat, 13pt, Humo
  And years are Cormorant Garamond, 20pt, Humo, right-aligned
  And the list is scrollable

US 10.2
As a user,
I want to read historical context before the text,
so that I understand what was happening in Buenos Aires when the text
was written.

  Given the user tapped the text "Yira, yira"
  When the context card is displayed
  Then the title, author, and year are visible
  And three to four sentences of historical background are shown
  And a "Read" button appears at the bottom
