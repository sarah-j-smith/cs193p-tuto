
//
//  AspectVGrid.swift
//  SetGame
//
//  Created by Sarah Smith on 15/9/2022.
//
import SwiftUI

struct AspectVGrid<Item, ItemView>: View where ItemView: View, Item: Identifiable {
    var items: [ Item ]
    var aspectRatio: CGFloat
    var content: (Item) -> ItemView
    
    init(items: [ Item ], aspectRatio: CGFloat, @ViewBuilder content: @escaping (Item) -> ItemView) {
        self.items = items
        self.aspectRatio = aspectRatio
        self.content = content
    }
    
    var body: some View {
        GeometryReader { geometry in
            let _ = print("Aspcect Grid sz: \(geometry.size)")
            if geometry.size.width == 0.0 {
                Color.clear
            } else {
                let width: CGFloat = widthThatFits(itemCount: items.count, in: geometry.size, itemAspectRatio: aspectRatio)
                VStack {
                    LazyVGrid(columns: [adaptiveGridItem(width: width)], spacing: 0) {
                        ForEach(items) { item in
                            content(item).aspectRatio(aspectRatio, contentMode: .fit)
                        }
                    }
                    Spacer(minLength: 0)
                }
            }
        }
    }
    
    private func adaptiveGridItem(width: CGFloat) -> GridItem {
        var gridItem = GridItem(.adaptive(minimum: width))
        gridItem.spacing = 0
        return gridItem
    }
    
    private func widthThatFits(itemCount: Int, in size: CGSize, itemAspectRatio: CGFloat) -> CGFloat {
        var columnCount = 1
        var rowCount = itemCount
        print("widthThatFits - in size: \(size) - aspect: \(itemAspectRatio)")
        repeat {
            print("widthThatFits - itemCount: \(itemCount) - rowCount: \(rowCount) - cols: \(columnCount)")
            let itemWidth = size.width / CGFloat(columnCount)
            let itemHeight = itemWidth / itemAspectRatio
            print("   w: \(itemWidth) - h: \(itemHeight)")
            if CGFloat(rowCount) * itemHeight < size.height {
                break
            }
            columnCount += 1
            rowCount = (itemCount + (columnCount - 1)) / columnCount
        } while columnCount < itemCount
        if columnCount > itemCount {
            columnCount = itemCount
        }
        let resultWidth = floor(size.width / CGFloat(columnCount))
        print("   resultWidth: \(resultWidth)")
        return resultWidth
    }
}
