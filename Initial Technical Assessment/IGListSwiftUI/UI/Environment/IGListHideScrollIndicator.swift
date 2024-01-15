import Foundation
import SwiftUI

private struct IGListHideScrollIndicatorKey: EnvironmentKey {
    static var defaultValue: Bool = false
}

extension EnvironmentValues {
    var igListHideScrollIndicator: Bool {
        get { self[IGListHideScrollIndicatorKey.self] }
        set { self[IGListHideScrollIndicatorKey.self] = newValue }
    }
}

public extension View {
    func igListHideScrollIndicator(_ hide: Bool = true) -> some View {
        environment(\.igListHideScrollIndicator, hide)
    }
}
