//
//  TextStyles.swift
//  TriviaApp
//
//  Created by Tino on 18/12/2022.
//

import SwiftUI

/// Tests for the text styles
struct TextStyles: View {
    var body: some View {
        VStack {
            Text("Trivia")
                .titleStyle()
            Text("Hello, World!")
                .bodyStyle()
            Text("Hello, World!")
                .mediumBodyStyle()
        }
    }
}

/// An enum that holds all of the apps fonts.
enum CustomFont {
    case sfCompactRoundedRegular
    case sfCompactRoundedMedium
    case caveatRegular
    case caveatBold
    
    var fontName: String {
        switch self {
        case .caveatRegular: return "Caveat-Regular"
        case .caveatBold: return "CaveatRoman-Bold"
        case .sfCompactRoundedRegular: return "SFCompactRounded-Regular"
        case .sfCompactRoundedMedium: return "SFCompactRounded-Medium"
        }
    }
}

struct TextStyle: ViewModifier {
    @ScaledMetric private var fontSize = 10
    private let font: CustomFont
    private let color: Color
    private let relativeFont: Font.TextStyle
    
    init(font: CustomFont, fontSize: Double, color: Color, relativeTo relativeFont: Font.TextStyle = .body) {
        _fontSize = ScaledMetric(wrappedValue: fontSize)
        self.font = font
        self.color = color
        self.relativeFont = relativeFont
    }
    
    func body(content: Content) -> some View {
        content
            .font(.custom(font.fontName, size: fontSize))
            .foregroundColor(color)
    }
}

// MARK: - View extension
extension View {
    func bodyStyle() -> some View {
        modifier(TextStyle(font: .sfCompactRoundedRegular, fontSize: 20, color: .text))
    }
    
    func mediumBodyStyle() -> some View {
        modifier(TextStyle(font: .sfCompactRoundedMedium, fontSize: 20, color: .text))
    }
    
    func titleStyle() -> some View {
        modifier(TextStyle(font: .caveatRegular, fontSize: 90, color: .text, relativeTo: .title))
    }
}

// MARK: - Previews
struct TextStyles_Previews: PreviewProvider {
    static var previews: some View {
        TextStyles()
    }
}
