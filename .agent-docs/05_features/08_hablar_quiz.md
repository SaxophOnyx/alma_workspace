# Feature 8. Hablar — Quiz

Priority: MVP

Description:
A series of 10 questions about encountered words. Five question types.
After each answer — an explanation, not a grade. At the end — a soft
summary.

US 8.1
As a user,
I want to test myself through a quiz,
so that I can reinforce words I've already seen in cards and texts.

  Given the user is in the "Quiz" section
  When the quiz begins
  Then the first of 10 questions is displayed
  And questions are drawn from words the user has previously encountered
       (in cards, texts, or word of the day)

US 8.2
As a user,
I want to see an explanation after each answer,
so that I learn from mistakes rather than just guessing.

  Given the user has answered a question (correctly or incorrectly)
  When the answer is registered
  Then a short explanation appears (etymology or example)
  And there is no sound, no "correct/incorrect" animation,
       no score display
  And after 2 seconds or on tap — the next question appears

US 8.3
As a user,
I want to see the final result without a grade or pressure,
so that the quiz feels like reflection, not an exam.

  Given the user has answered all 10 questions
  When the quiz is complete
  Then the line "You recalled 8 out of 10" is displayed
  And there are no percentages, stars, levels, or "excellent/poor" labels
  And there are buttons "Try again" and "Back to Hablar"
