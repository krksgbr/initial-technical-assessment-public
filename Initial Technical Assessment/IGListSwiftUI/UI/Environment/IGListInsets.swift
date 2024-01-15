import Foundation
import SwiftUI

private struct IGListContentInsetKey: EnvironmentKey {
    static var defaultValue: UIEdgeInsets = .zero
}

extension EnvironmentValues {
    var igListContentInset: UIEdgeInsets {
        get { self[IGListContentInsetKey.self] }
        set { self[IGListContentInsetKey.self] = newValue }
    }
}

public extension View {
    func igListInsets(top: CGFloat = 0, left: CGFloat = 0, bottom: CGFloat = 0, right: CGFloat = 0) -> some View {
        environment(\.igListContentInset, .init(top: top, left: left, bottom: bottom, right: right))
    }
}
