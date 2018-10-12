//
//  MessageTextCacheManager.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 02/05/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

final class MessageTextCacheManager {

    static let shared = MessageTextCacheManager()
    let cache = NSCache<NSString, NSAttributedString>()

    internal func cachedKey(for identifier: String) -> NSString {
        return NSString(string: "\(identifier)-cachedattrstring")
    }

    func clear() {
        cache.removeAllObjects()
    }

    func remove(for message: Message) {
        guard let identifier = message.identifier else { return }
        cache.removeObject(forKey: cachedKey(for: identifier))
    }

    @discardableResult func update(for message: Message, with theme: Theme? = nil) -> NSMutableAttributedString? {
        guard let identifier = message.identifier else { return nil }

        let key = cachedKey(for: identifier)

        let text = NSMutableAttributedString(attributedString:
            NSAttributedString(string: message.textNormalized()).applyingCustomEmojis(CustomEmoji.emojiStrings)
        )

        if message.isSystemMessage() {
            text.setFont(MessageTextFontAttributes.italicFont)
            text.setFontColor(MessageTextFontAttributes.systemFontColor(for: theme))
        } else {
            text.setFont(MessageTextFontAttributes.defaultFont)
            text.setFontColor(MessageTextFontAttributes.defaultFontColor(for: theme))
            text.setLineSpacing(MessageTextFontAttributes.defaultFont)
        }

        let mentions = Array(message.mentions.compactMap { $0 })
        let channels = Array(message.channels.compactMap { $0.name })
        let username = AuthManager.currentUser()?.username

        let attributedString = text.transformMarkdown()
        let finalText = NSMutableAttributedString(attributedString: attributedString)

        // Set text color for markdown quotes
        finalText.enumerateAttribute(.backgroundColor, in: NSRange(location: 0, length: finalText.length), options: []) { (value, range, _) in
            if let backgroundColor = value as? UIColor, backgroundColor != .clear {
                finalText.addAttribute(.foregroundColor, value: UIColor.darkGray, range: range)
            }
        }

        finalText.trimCharacters(in: .whitespaces)
        finalText.highlightMentions(mentions, currentUsername: username)
        finalText.highlightChannels(channels)

        cache.setObject(finalText, forKey: key)
        return finalText
    }

    func message(for message: Message, with theme: Theme? = nil) -> NSMutableAttributedString? {
        guard let identifier = message.identifier else { return nil }

        var resultText: NSAttributedString?
        let key = cachedKey(for: identifier)

        if let cachedVersion = cache.object(forKey: key) {
            resultText = cachedVersion
        } else if let result = update(for: message, with: theme) {
            resultText = result
        }

        if let resultText = resultText {
            return NSMutableAttributedString(attributedString: resultText)
        }

        return nil
    }

}
