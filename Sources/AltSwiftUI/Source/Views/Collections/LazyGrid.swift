//
//  LazyGrid.swift
//  AltSwiftUI
//
//  Created by Furqan, Sara | Sara | TID on 2021/02/26.
//

import UIKit

/// A container view that arranges its child views in a grid that
/// grows horizontally, creating items only as needed.
///
/// The grid is "lazy," in that the grid view does not create items until
/// they are needed.
public struct LazyHGrid<Content>: View where Content : View {
    var rows: [GridItem]
    var alignment: VerticalAlignment
    var spacing: CGFloat?
    let viewContent: [Content]
    public var viewStore = ViewValues()
    /// Creates a grid that grows horizontally, given the provided properties.
    ///
    /// - Parameters:
    ///   - rows: An array of grid items to size and position each column of
    ///    the grid.
    ///   - alignment: The alignment of the grid within its parent view.
    ///   - spacing: The spacing beween the grid and the next item in its
    ///   parent view.
    ///   - pinnedViews: Views to pin to the bounds of a parent scroll view.
    ///   - content: The content of the grid.
    public init(rows: [GridItem], alignment: VerticalAlignment = .center, spacing: CGFloat? = nil, @ViewBuilder content: () -> View) {
        let contentView = content()
        viewContent = contentView.mappedSubViews { $0 } as! [Content]
        self.rows = rows
        self.alignment = alignment
        self.spacing = spacing
        viewStore.direction = .horizontal
    }
    init(viewContent: [Content]) {
        self.viewContent = viewContent
        alignment = .center
        spacing = SwiftUIConstants.defaultSpacing
    }
    public var body: View {
        EmptyView()
    }
}
extension LazyHGrid: Renderable {
    public func createView(context: Context) -> UIView {
        let configuration = CollectionView<Content>.Configuration(
                itemSize: rows.first?.size,
                automaticItemSize: true,
                scrollDirection: UICollectionView.ScrollDirection.horizontal,
                backgroundColor: nil,
                showsHorizontalScrollIndicator: true,
                showsVerticalScrollIndicator: false,
                minimumInteritemSpacing: rows.first?.spacing ?? 0,
                minimumLineSpacing: 0,
                isItemPagingEnabled: true,
                extraEmptyItems: 1
            )
        let hGrid = CollectionView(
            cellData: viewContent,
            configuration: configuration) { (data, index) -> UIHostingController in
            UIHostingController(rootView: data)
        }
        return hGrid
    }
    public func updateView(_ view: UIView, context: Context) {
        
    }
}

/// A container view that arranges its child views in a grid that
/// grows vertically, creating items only as needed.
///
/// The grid is "lazy," in that the grid view does not create items until
/// they are needed.
public struct LazyVGrid<Content>: View where Content : View {
    public var viewStore = ViewValues()
    
    var columns: [GridItem]
    var alignment: HorizontalAlignment
    var spacing: CGFloat?
    var viewContent: [Content]

    /// Creates a grid that grows vertically, given the provided properties.
    ///
    /// - Parameters:
    ///   - columns: An array of grid items to size and position each row of
    ///    the grid.
    ///   - alignment: The alignment of the grid within its parent view.
    ///   - spacing: The spacing beween the grid and the next item in its
    ///   parent view.
    ///   - pinnedViews: Views to pin to the bounds of a parent scroll view.
    ///   - content: The content of the grid.
    public init(columns: [GridItem], alignment: HorizontalAlignment = .center, spacing: CGFloat? = nil, @ViewBuilder content: @escaping () -> View) {
        self.columns = columns
        self.alignment = alignment
        self.spacing = spacing
        let contentView = content()
        self.viewContent = contentView.totallyFlatSubViews // mappedSubViews { $0 } as! [Content]
    }
    public var body: View {
        EmptyView()
    }
}
extension LazyVGrid: Renderable {
    public func createView(context: Context) -> UIView {
        let configuration = CollectionView<Content>.Configuration(
            itemSize: columns.first?.size,
            automaticItemSize: true,
            scrollDirection: UICollectionView.ScrollDirection.vertical,
            backgroundColor: nil,
            showsHorizontalScrollIndicator: false,
            showsVerticalScrollIndicator: true,
            minimumInteritemSpacing: columns.first?.spacing ?? 0,
            minimumLineSpacing: 0,
            isItemPagingEnabled: true,
            extraEmptyItems: 1)
        
        let vGrid = CollectionView(
            cellData: viewContent,
            configuration: configuration) { (data, index) -> UIHostingController in
            UIHostingController(rootView: data)
        }
        return vGrid
    }
    public func updateView(_ view: UIView, context: Context) {
    }
}

public struct GridItem {
    /// The size in the minor axis of one or more rows or columns in a grid
    /// layout.
    public enum Size {
        /// A single item with the specified fixed size.
        case fixed(CGFloat)
        /// A single flexible item.
        ///
        /// The size of this item is the size of the grid with spacing and
        /// inflexible items removed, divided by the number of flexible items,
        /// clamped to the provided bounds.
        case flexible(minimum: CGFloat = 10, maximum: CGFloat = .infinity)
        /// Multiple items in the space of a single flexible item.
        ///
        /// This size case places one or more items into the space assigned to
        /// a single `flexible` item, using the provided bounds and
        /// spacing to decide exactly how many items fit. This approach prefers
        /// to insert as many items of the `minimum` size as possible
        /// but lets them increase to the `maximum` size.
        case adaptive(minimum: CGFloat, maximum: CGFloat = .infinity)
    }
    /// The size of the item, which is the width of a column item or the
    /// height of a row item.
    public var size: GridItem.Size
    /// The spacing to the next item.
    ///
    /// If this value is `nil`, the item uses a reasonable default for the
    /// current platform.
    public var spacing: CGFloat?
    /// The alignment to use when placing each view.
    ///
    /// Use this property to anchor the view's relative position to the same
    /// relative position in the view's assigned grid space.
    public var alignment: Alignment?
    /// Creates a grid item with the provided size, spacing, and alignment
    /// properties.
    ///
    /// - Parameters:
    ///   - size: The size of the grid item.
    ///   - spacing: The spacing to use between this and the next item.
    ///   - alignment: The alignment to use for this grid item.
    public init(_ size: GridItem.Size = .flexible(), spacing: CGFloat? = nil, alignment: Alignment? = nil) {
        self.size = size
        self.spacing = spacing
        self.alignment = alignment
    }
}

/// In the following example, a ``ScrollView`` contains a
/// `LazyVGrid` consisting of a two-column grid of ``Text`` views, showing
/// Unicode code points from the "Smileys" group and their corresponding emoji:
///
///      var columns: [GridItem] =
///              Array(repeating: .init(.flexible()), count: 2)
///      ScrollView {
///          LazyVGrid(columns: columns) {
///              ForEach((0...79), id: \.self) {
///                  let codepoint = $0 + 0x1f600
///                  let codepointString = String(format: "%02X", codepoint)
///                  Text("\(codepointString)")
///                  let emoji = String(Character(UnicodeScalar(codepoint)!))
///                  Text("\(emoji)")
///              }
///          }.font(.largeTitle)
///      }
///
/// In the following example, a ``ScrollView`` contains a `LazyHGrid` that
/// consists of a horizontally-arranged grid of ``Text`` views, aligned to
/// the top of the scroll view. For each column in the grid, the top row shows
/// a Unicode code point from the "Smileys" group, and the bottom shows its
/// corresponding emoji.
///
///     var rows: [GridItem] =
///             Array(repeating: .init(.fixed(20)), count: 2)
///     ScrollView(.horizontal) {
///         LazyHGrid(rows: rows, alignment: .top) {
///             ForEach((0...79), id: \.self) {
///                 let codepoint = $0 + 0x1f600
///                 let codepointString = String(format: "%02X", codepoint)
///                 Text("\(codepointString)")
///                     .font(.footnote)
///                 let emoji = String(Character(UnicodeScalar(codepoint)!))
///                 Text("\(emoji)")
///                     .font(.largeTitle)
///             }
///         }
///     }

