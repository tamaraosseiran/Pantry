//
//  EmojiPickerView.swift
//  Pantry
//
//  Created by Tamara Osseiran on 8/29/25.
//

import SwiftUI

struct EmojiPickerView: View {
    @Binding var selectedEmoji: String
    
    private let foodEmojis = [
        // Vegetables
        "🥬", "🥦", "🥕", "🧅", "🧄", "🍅", "🥔", "🍆", "🥒", "🫑", "🌽", "🥬", "🥬", "🍄",
        // Fruits
        "🍎", "🍌", "🍊", "🍋", "🍇", "🍓", "🫐", "🍒", "🍑", "🥭", "🍍", "🥥", "🥝", "🍐",
        // Meat & Protein
        "🥩", "🍗", "🐟", "🦐", "🥚", "🥓", "🍖", "🦴", "🦞", "🦀", "🐙", "🦑",
        // Dairy
        "🥛", "🧀", "🧈", "🥜", "🥜", "🥜", "🥜", "🥜", "🥜", "🥜", "🥜", "🥜", "🥜", "🥜",
        // Grains & Bread
        "🍞", "🥖", "🥨", "🥯", "🥐", "🍝", "🍚", "🌾", "🥜", "🥜", "🥜", "🥜", "🥜", "🥜",
        // Spices & Condiments
        "🧂", "🫒", "🌿", "🌶️", "🧄", "🧅", "🥜", "🥜", "🥜", "🥜", "🥜", "🥜", "🥜", "🥜",
        // Beverages
        "🥤", "🧃", "🥛", "☕", "🍵", "🥜", "🥜", "🥜", "🥜", "🥜", "🥜", "🥜", "🥜", "🥜",
        // Other
        "🥫", "🧊", "🍯", "🥜", "🥜", "🥜", "🥜", "🥜", "🥜", "🥜", "🥜", "🥜", "🥜", "🥜"
    ]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(foodEmojis, id: \.self) { emoji in
                    Button(action: {
                        selectedEmoji = emoji
                    }) {
                        Text(emoji)
                            .font(.title2)
                            .padding(8)
                            .background(
                                Circle()
                                    .fill(selectedEmoji == emoji ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                            )
                            .scaleEffect(selectedEmoji == emoji ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: selectedEmoji)
                    }
                }
            }
            .padding(.horizontal)
        }
        .frame(height: 60)
    }
}

// MARK: - String Extension for Emoji to Image
extension String {
    func image(size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let rect = CGRect(origin: .zero, size: size)
            
            // Clear background
            UIColor.clear.setFill()
            context.fill(rect)
            
            // Draw emoji
            let font = UIFont.systemFont(ofSize: size.width * 0.6)
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font
            ]
            
            let emojiSize = self.size(withAttributes: attributes)
            let emojiRect = CGRect(
                x: (size.width - emojiSize.width) / 2,
                y: (size.height - emojiSize.height) / 2,
                width: emojiSize.width,
                height: emojiSize.height
            )
            
            self.draw(in: emojiRect, withAttributes: attributes)
        }
    }
}

#Preview {
    EmojiPickerView(selectedEmoji: .constant("🍅"))
        .padding()
} 