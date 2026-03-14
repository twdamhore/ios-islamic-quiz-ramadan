import SwiftUI

enum AppFonts {
    static let largeTitle: Font = .system(.largeTitle, design: .rounded)
    static let title: Font = .system(.title, design: .rounded)
    static let title2: Font = .system(.title2, design: .rounded)
    static let title3: Font = .system(.title3, design: .rounded)
    static let headline: Font = .system(.headline, design: .rounded)
    static let body: Font = .system(.body, design: .rounded)
    static let callout: Font = .system(.callout, design: .rounded)
    static let subheadline: Font = .system(.subheadline, design: .rounded)
    static let footnote: Font = .system(.footnote, design: .rounded)
    static let caption: Font = .system(.caption, design: .rounded)
    static let caption2: Font = .system(.caption2, design: .rounded)
}

#Preview("AppFonts") {
    VStack(alignment: .leading, spacing: 12) {
        Text("Large Title").font(AppFonts.largeTitle)
        Text("Title").font(AppFonts.title)
        Text("Title 2").font(AppFonts.title2)
        Text("Title 3").font(AppFonts.title3)
        Text("Headline").font(AppFonts.headline)
        Text("Body").font(AppFonts.body)
        Text("Callout").font(AppFonts.callout)
        Text("Subheadline").font(AppFonts.subheadline)
        Text("Footnote").font(AppFonts.footnote)
        Text("Caption").font(AppFonts.caption)
        Text("Caption 2").font(AppFonts.caption2)
    }
    .padding()
}
