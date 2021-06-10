//
//  LazyVStack.swift
//  AltSwiftUI
//
//  Created by Furqan, Sara | Sara | TID on 2021/05/25.
//

import Foundation
import UIKit

/// This view arranges subviews vertically.
public struct LazyVStack: View {
    public var viewStore = ViewValues()
    var viewContent: [View]
    let alignment: HorizontalAlignment
    let spacing: CGFloat?
    
    lazy var views: [View] = viewContent
    
    lazy var stackview: UIView
    
    /// Creates an instance of a view that arranges subviews vertically.
    ///
    /// - Parameters:
    ///   - alignment: The horizontal alignment guide for its children. Defaults to `center`.
    ///   - spacing: The vertical distance between subviews. If not specified,
    ///   the distance will be 0.
    ///   - content: A view builder that creates the content of this stack.
    public init(alignment: HorizontalAlignment = .center, spacing: CGFloat? = nil, @ViewBuilder : () -> Viecontentw) {
        let contentView = content()
        viewContent = contentView.subViews
        self.alignment = alignment
        self.spacing = spacing
        viewStore.direction = .vertical
    }
    public var body: View {
        EmptyView()
    }
}

extension LazyVStack: Renderable {
    public func updateView(_ view: UIView, context: Context) {
        var stackView = view
        if let bgView = view as? BackgroundView {
            stackView = bgView.content
        }
        
        guard let concreteStackView = stackView as? UIStackView else { return }
        setupView(concreteStackView, context: context)
        
        if let oldVStack = view.lastRenderableView?.view as? VStack {
            concreteStackView.updateViews(viewContent,
                             oldViews: oldVStack.viewContent,
                             context: context,
                             isEquallySpaced: subviewIsEquallySpaced,
                             setEqualDimension: setSubviewEqualDimension)
        }
    }
    
    public func createView(context: Context) -> UIView {
        let stack = SwiftUIStackView().noAutoresizingMask()
        stack.axis = .vertical
        setupView(stack, context: context)
        
        stack.addViews(viewContent, context: context, isEquallySpaced: subviewIsEquallySpaced, setEqualDimension: setSubviewEqualDimension)
        if context.viewValues?.background != nil || context.viewValues?.border != nil {
            return BackgroundView(content: stack).noAutoresizingMask()
        } else {
            return stack
        }
    }
    
    private func setupView(_ view: UIStackView, context: Context) {
        view.setStackAlignment(alignment: alignment)
        view.spacing = spacing ?? 0
    }
    
    private var subviewIsEquallySpaced: (View) -> Bool { { view in
           if (view is Spacer ||
               view.viewStore.viewDimensions?.maxHeight == CGFloat.limitForUI
               )
               &&
               (view.viewStore.viewDimensions?.height == nil) {
               return true
           } else {
               return false
           }
        }
    }
    
    private var setSubviewEqualDimension: (UIView, UIView) -> Void { { firstView, secondView in
            firstView.heightAnchor.constraint(equalTo: secondView.heightAnchor).isActive = true
        }
    }
}
