//
//  EmojiConstants.swift
//  Memorize
//
//  Created by Sarah Smith on 21/8/2022.
//

import Foundation

struct EmojiConstants {
    static let smileys = [ "😀", "😃", "😄", "😁", "😆", "😅", "😂", "🤣", "☺️", "😊",
                           "😇", "🙂", "🙃", "😉", "😌", "😍", "🤗", "🤓", "😎", "🤠",
                           "😣", "😤", "😥", "😦", "😧"]

    static let animals = [ "🐶", "🐱", "🐭", "🐹", "🐰", "🦊", "🐻", "🐼", "🐨", "🐯",
                           "🦁", "🐮", "🐷", "🐽", "🐸", "🐵", "🙈", "🙉", "🙊", "🐒",
                           "🦀", "🦑", "🐙", "🦐", "🐠" ]

    static let food = [ "🍏", "🍎", "🍐", "🍊", "🍋", "🍌", "🍉", "🍇", "🍓", "🍈",
                        "🍒", "🍑", "🍍", "🥝", "🥑", "🍅", "🍆", "🥒", "🥕", "🌽",
                        "🥫", "🥟", "🥠", "🥡", "🥧" ]
    
    static let hearts = [ "💋", "💌", "💘", "💝", "💖", "💗", "💓", "💞", "💕", "💟",
                          "❣", "💔", "❤️‍🔥", "❤️‍🩹", "❤", "🧡", "💛", "💚", "💙", "💜" ]

    static let office = [ "📒", "📕", "📗", "📘", "📙", "📚", "📖", "🔖", "🔗", "📎",
                              "🖇", "📐", "📏", "📌", "📍", "✂️", "🖊", "🖋", "✒️", "🖌",
                              "🎀", "🎊", "🎉", "🎎", "✉️",]

    static let travel = [ "🚗", "🚕", "🚙", "🚌", "🚎", "🏎", "🚓", "🚑", "🚒", "🚐",
                          "🚚", "🚛", "🚜", "🛴", "🚲", "🛵", "🏍", "🚨", "🚔", "🚍",
                          "⛩", "🗾", "🎑", "🏞", "🌅" ]
    
    static func all() -> [String: [String]] {
        return [
            "smileys" : smileys,
            "animals" : animals,
            "food" : food,
            "hearts" : hearts,
            "office" : office,
            "travel" : travel
        ]
    }
}
