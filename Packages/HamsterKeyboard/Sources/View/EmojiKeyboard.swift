//
//  EmojiKeyboard.swift
//  Hamster
//
//  Created by morse on 2023/6/7.
//

//
//  EmojiKeyboard.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-01-17.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import KeyboardKit
import SwiftUI

/**
 This view can be used as an emoji keyboard and will list an
 emoji collection using the provided configuration.

 You can customize the emoji views in the keyboard, by using
 the `button` initializer. The initializer without a `button`
 parameter will use an ``EmojiKeyboardItem`` for every emoji.

 Note that this keyboard only lists the provided emojis. Use
 an ``EmojiCategoryKeyboard`` if you want surrounding titles
 and actions as in the iOS emoji keyboard.
 */
public struct HamsterEmojiKeyboard<ButtonView: View>: View {
  /**
   Create an emoji keyboard.

   - Parameters:
     - emojis: The emojis to include in the menu.
     - actionHandler: The action handler to use.
     - calloutContext: The callout context to affect, if any.
     - style: The style to apply to the keyboard, by default ``EmojiKeyboardStyle/standardPhonePortrait``.
     - button: A emoji keyboard button builder function.
   */
  public init(
    emojis: [Emoji],
    actionHandler: KeyboardActionHandler,
    calloutContext: KeyboardCalloutContext?,
    style: EmojiKeyboardStyle = .standardPhonePortrait,
    button: @escaping ButtonBuilder<ButtonView>
  ) {
    let gridItem = GridItem(.fixed(style.itemSize), spacing: style.verticalItemSpacing - 9)
    self.emojis = emojis
    self.rows = Array(repeating: gridItem, count: style.rows)
    self.actionHandler = actionHandler
    self.calloutContext = calloutContext
    self.style = style
    self.buttonBuilder = button
  }

  /**
   Create an emoji keyboard that applies a standard button
   for every emoji in the provided collection.

   - Parameters:
     - emojis: The emojis to include in the menu.
     - actionHandler: The action handler to use.
     - calloutContext: The callout context to affect, if any.
     - style: The style to apply to the keyboard, by default ``EmojiKeyboardStyle/standardPhonePortrait``.
   */
  init(
    emojis: [Emoji],
    actionHandler: KeyboardActionHandler,
    calloutContext: KeyboardCalloutContext?,
    style: EmojiKeyboardStyle = .standardPhonePortrait
  ) where ButtonView == EmojiKeyboardItem {
    self.init(
      emojis: emojis,
      actionHandler: actionHandler,
      calloutContext: calloutContext,
      style: style,
      button: { EmojiKeyboardItem(emoji: $0, style: $1) }
    )
  }

  private let emojis: [Emoji]
  private let rows: [GridItem]
  private let actionHandler: KeyboardActionHandler
  private let calloutContext: KeyboardCalloutContext?
  private let style: EmojiKeyboardStyle
  private let buttonBuilder: ButtonBuilder<ButtonView>

  /**
   This typealias represents functions that can be used to
   create an emoji button.
   */
  public typealias ButtonBuilder<EmojiButton: View> = (Emoji, EmojiKeyboardStyle) -> EmojiButton

  public var body: some View {
    LazyHGrid(rows: rows, spacing: style.horizontalItemSpacing) {
      ForEach(emojis) { emoji in
        buttonView(
          for: emoji,
          style: style
        )
        .hamsterKeyboardGestures(
          for: .emoji(emoji),
          actionHandler: actionHandler,
          calloutContext: calloutContext,
          isInScrollView: true
        )
      }
    }
    .padding(.horizontal)
    .frame(height: style.totalHeight)
  }
}

private extension HamsterEmojiKeyboard {
  func buttonView(for emoji: Emoji, style: EmojiKeyboardStyle) -> some View {
    buttonBuilder(emoji, style)
      .accessibilityLabel(emoji.unicodeName ?? "")
      .accessibilityIdentifier(emoji.unicodeIdentifier ?? "")
  }
}

public extension HamsterEmojiKeyboard {
  /**
   This typealias represents an emoji-based action.
   */
  typealias EmojiAction = (Emoji) -> Void

  /**
   The standard action to use when tapping an emoji button.
   */
  static func standardEmojiView(
    for emoji: Emoji,
    style: EmojiKeyboardStyle
  ) -> some View {
    EmojiKeyboardItem(emoji: emoji, style: style)
  }
}

struct HamsterEmojiKeyboard_Previews: PreviewProvider {
  static var previews: some View {
    ScrollView(.horizontal) {
      HamsterEmojiKeyboard(
        emojis: Array(Emoji.all.prefix(50)),
        actionHandler: .preview,
        calloutContext: .preview
      )
    }
  }
}
