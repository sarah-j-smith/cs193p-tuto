# Assignment 2 - Memorize Game v2

* All requirements done

* The [PDF for assignment two](https://cs193p.sites.stanford.edu/sites/g/files/sbiybj16636/files/media/file/Assignment%202.pdf) specifies the requirements.

1. ✅ Get the Memorize game working as demonstrated in lectures 1 through 4. Type in all the code. Do not copy/paste from anywhere.
2. ✅ If you’re starting with your assignment 1 code, remove your theme-choosing buttons and (optionally) the title of your game.
3. ✅ Add the formal concept of a “Theme” to your Model. A Theme consists of a name for the theme, a set of emoji to use, a number of pairs of cards to show, and an appropriate color to use to draw the cards.
4. ✅ At least one Theme in your game should show fewer pairs of cards than the number of emoji available in that theme.
5. ✅ If the number of pairs of emoji to show in a Theme is fewer than the number of emojis that are available in that theme, then it should not just always use the first few emoji in the theme. It must use any of the emoji in the theme. In other words, do not have any “dead emoji” in your code that can never appear in a game.
6. ✅ Never allow more than one pair of cards in a game to have the same emoji on it.
7. ✅ If a Theme mistakenly specifies to show more pairs of cards than there are emoji available, then automatically reduce the count of cards to show to match the count of available emoji.
8. ✅ Support at least 6 different themes in your game.
9. ✅ A new theme should be able to be added to your game with a single line of code.
10. ✅ Add a “New Game” button to your UI (anywhere you think is best) which begins a brand new game.
11. ✅ A new game should use a randomly chosen theme and touching the New Game button should repeatedly keep choosing a new random theme.
12. ✅ The cards in a new game should all start face down.
13. ✅ The cards in a new game should be fully shuffled. This means that they are not in any predictable order, that they are selected from any of the emojis in the theme (i.e. Required Task 5), and also that the matching pairs are not all side-by-side like they were in lecture (though they can accidentally still appear side-by-side at random).
14. ✅ Show the theme’s name in your UI. You can do this in whatever way you think looks best.
15. ✅ Keep score in your game by penalizing 1 point for every previously seen card that is involved in a mismatch and giving 2 points for every match (whether or not the cards involved have been “previously seen”). See Hints below for a more detailed explanation. The score is allowed to be negative if the user is bad at Memorize.
16. ✅ Display the score in your UI. You can do this in whatever way you think looks best.


# Screenshots


## Attributions

I added an App Icon by using this image and putting a background on it:

* [Brain icon](https://www.flaticon.com/free-icons/mindset){title="mindset icons"} Mindset icons created by Becris - Flaticon
