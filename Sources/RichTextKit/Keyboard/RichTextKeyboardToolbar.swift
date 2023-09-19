//
//  RichTextKeyboardToolbar.swift
//  RichTextKit
//
//  Created by Daniel Saidi on 2022-12-14.
//  Copyright © 2022 Daniel Saidi. All rights reserved.
//

#if os(iOS)
import SwiftUI

/**
 This toolbar can be added above the iOS keyboard to make it
 easy to provide rich text formatting in a very compact form.

 This view has customizable actions and also supports adding
 custom leading and trailing buttons. It shows more views if
 the horizontal size class is regular.

 This custom toolbar is needed since ``RichTextEditor`` will
 wrap a native `UIKit` text view, which means that using the
 `toolbar` modifier with a `keyboard` placement doesn't work:

 ```swift
 RichTextEditor(text: $text, context: context)
     .toolbar {
         ToolbarItemGroup(placement: .keyboard) {
             ....
         }
     }
 ```

 The above code will simply not show anything when you start
 to edit text. To work around this limitation, you can use a
 this custom toolbar instead, which by default will show and
 hide itself as you begin and end editing the text.
 */
public struct RichTextKeyboardToolbar<LeadingButtons: View, TrailingButtons: View, FormatSheet: View>: View {

    /**
     Create a rich text keyboard toolbar.

     - Parameters:
       - context: The context to affect.
       - style: The toolbar style to apply, by default ``RichTextKeyboardToolbarStyle/standard``.
       - leadingActions: The leading actions, by default `.undo`, `.redo` and `.copy`.
       - trailingActions: The trailing actions, by default `.dismissKeyboard`.
       - leadingButtons: The leading buttons to place after the leading actions.
       - trailingButtons: The trailing buttons to place after the trailing actions.
       - richTextFormatSheet: The rich text format sheet to use, given the default ``RichTextFormatSheet``.
     */
    public init(
        context: RichTextContext,
        style: RichTextKeyboardToolbarStyle = .standard,
        leadingActions: [RichTextAction] = [.undo, .redo, .copy],
        trailingActions: [RichTextAction] = [.dismissKeyboard],
        @ViewBuilder leadingButtons: @escaping () -> LeadingButtons,
        @ViewBuilder trailingButtons: @escaping () -> TrailingButtons,
        @ViewBuilder richTextFormatSheet: @escaping (RichTextFormatSheet) -> FormatSheet,
        alwaysVisible: Bool = false
    ) {
        self._context = ObservedObject(wrappedValue: context)
        self.leadingActions = leadingActions
        self.trailingActions = trailingActions
        self.style = style
        self.leadingButtons = leadingButtons
        self.trailingButtons = trailingButtons
        self.richTextFormatSheet = richTextFormatSheet
        self.alwaysVisible = alwaysVisible
    }

    /**
     Create a rich text keyboard toolbar.

     - Parameters:
       - context: The context to affect.
       - style: The toolbar style to apply, by default ``RichTextKeyboardToolbarStyle/standard``.
       - leadingActions: The leading actions, by default `.undo`, `.redo` and `.copy`.
       - trailingActions: The trailing actions, by default `.dismissKeyboard`.
       - leadingButtons: The leading buttons to place after the leading actions.
       - trailingButtons: The trailing buttons to place after the trailing actions.
       - richTextFormatSheet: The rich text format sheet to use, given the default ``RichTextFormatSheet``.
     */
    public init(
        context: RichTextContext,
        style: RichTextKeyboardToolbarStyle = .standard,
        leadingActions: [RichTextAction] = [.undo, .redo, .copy],
        trailingActions: [RichTextAction] = [.dismissKeyboard],
        @ViewBuilder leadingButtons: @escaping () -> LeadingButtons,
        @ViewBuilder trailingButtons: @escaping () -> TrailingButtons,
        alwaysVisible: Bool = false
    ) where FormatSheet == RichTextFormatSheet {
        self.init(
            context: context,
            style: style,
            leadingActions: leadingActions,
            trailingActions: trailingActions,
            leadingButtons: leadingButtons,
            trailingButtons: trailingButtons,
            richTextFormatSheet: { $0 },
            alwaysVisible: alwaysVisible
        )
    }

    private let leadingActions: [RichTextAction]
    private let trailingActions: [RichTextAction]
    private let style: RichTextKeyboardToolbarStyle

    private let leadingButtons: () -> LeadingButtons
    private let trailingButtons: () -> TrailingButtons
    private let richTextFormatSheet: (RichTextFormatSheet) -> FormatSheet

    @ObservedObject
    private var context: RichTextContext

    @State
    private var isFormatSheetPresented = false

    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass
    
    private let alwaysVisible: Bool

    public var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: style.itemSpacing) {
                leadingViews
                Spacer()
                trailingViews
            }
            .padding(10)
        }
        .environment(\.sizeCategory, .medium)
        .frame(height: style.toolbarHeight)
        .overlay(Divider(), alignment: .bottom)
        .accentColor(.primary)
        .background(
            Color.primary.colorInvert()
                .overlay(Color.white.opacity(0.2))
                .shadow(color: style.shadowColor, radius: style.shadowRadius, x: 0, y: 0)
        )
        .opacity(context.isEditingText || alwaysVisible ? 1 : 0)
        .offset(y: context.isEditingText || alwaysVisible ? 0 : style.toolbarHeight)
        .frame(height: context.isEditingText || alwaysVisible ? nil : 0)
        .sheet(isPresented: $isFormatSheetPresented) {
            richTextFormatSheet(RichTextFormatSheet(context: context))
        }
    }
}

private extension RichTextKeyboardToolbar {

    var isCompact: Bool { horizontalSizeClass == .compact }
}

private extension RichTextKeyboardToolbar {

    var divider: some View {
        Divider().frame(height: 25)
    }

    @ViewBuilder
    var leadingViews: some View {
        RichTextActionButtonStack(
            context: context,
            actions: leadingActions,
            spacing: style.itemSpacing
        )

        leadingButtons()

        divider
        
        if #available(iOS 15.0, *) {
            RichTextStyleToggleGroup(
                context: context
            )
        } else {
            RichTextStyleToggleStack(
                context: context
            )
        }

        RichTextStyleToggleStack(context: context)
            .keyboardShortcutsOnly(if: isCompact)
            .opacity(0.0)
    }

    @ViewBuilder
    var trailingViews: some View {
        RichTextAlignmentPicker(selection: $context.textAlignment)
            .pickerStyle(.segmented)
            .frame(maxWidth: 200)
            .keyboardShortcutsOnly(if: isCompact)

        trailingButtons()

        RichTextActionButtonStack(
            context: context,
            actions: trailingActions,
            spacing: style.itemSpacing
        )
    }
}

private extension View {

    @ViewBuilder
    func keyboardShortcutsOnly(if condition: Bool) -> some View {
        if condition {
            self.hidden()
                .frame(width: 0)
        } else {
            self
        }
    }
}

/**
 This can be used to style a ``RichTextKeyboardToolbar``.
 */
public struct RichTextKeyboardToolbarStyle {

    /**
     Create a custom toolbar style.

     - Parameters:
       - toolbarHeight: The height of the toolbar, by default `50`.
       - itemSpacing: The spacing between toolbar items, by default `15`.
       - shadowColor: The toolbar's shadow color, by default transparent black.
       - shadowRadius: The toolbar's shadow radius, by default `3`.
     */
    public init(
        toolbarHeight: Double = 50,
        itemSpacing: Double = 15,
        shadowColor: Color = .black.opacity(0.1),
        shadowRadius: Double = 3
    ) {
        self.toolbarHeight = toolbarHeight
        self.itemSpacing = itemSpacing
        self.shadowColor = shadowColor
        self.shadowRadius = shadowRadius
    }

    /// The height of the toolbar.
    public var toolbarHeight: Double

    /// The spacing between toolbar items.
    public var itemSpacing: Double

    /// The toolbar's shadow color.
    public var shadowColor: Color

    /// The toolbar's shadow radius.
    public var shadowRadius: Double
}

public extension RichTextKeyboardToolbarStyle {

    /// This standard style is used by default.
    static var standard = RichTextKeyboardToolbarStyle()
}

private extension RichTextKeyboardToolbar {

    func presentFormatSheet() {
        isFormatSheetPresented = true
    }
}

struct RichTextKeyboardToolbar_Previews: PreviewProvider {

    struct Preview: View {

        @State
        private var text = NSAttributedString(string: "")

        @StateObject
        private var context = RichTextContext()

        var body: some View {
            VStack(spacing: 0) {
                RichTextEditor(text: $text, context: context)
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding()
                    .background(Color.gray.ignoresSafeArea())
                RichTextKeyboardToolbar(
                    context: context,
                    leadingButtons: {},
                    trailingButtons: {},
                    alwaysVisible: false
                )
            }
        }
    }

    static var previews: some View {
        Preview()
    }
}
#endif
