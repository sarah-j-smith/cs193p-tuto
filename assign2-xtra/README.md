# Assignment 2 - Memorize Game - extras

* Has the code improvements from Lecture 5.

Includes turning this var 

```swift 
    private var indexOfOnlyFaceUpCard: Int?
```

from the previous version into a computed var based off the collection of cards:

```swift
    private var indexOfOnlyFaceUpCard: Int? {
        get { cards.indices.filter({ cards[$0].isFaceUp }).oneAndOnly }
        set { cards.indices.forEach { cards[$0].isFaceUp = $0 == newValue } }
    }
```

* And from Lecture 6

Creates the `AspectVGrid` to make the cards smaller to fit more cards on screen


## Attributions

I added an App Icon by using this image and putting a background on it:

* [Brain icon](https://www.flaticon.com/free-icons/mindset){title="mindset icons"} Mindset icons created by Becris - Flaticon
