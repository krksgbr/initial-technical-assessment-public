import Foundation
import SwiftUI

private struct IGListRefreshableKey: EnvironmentKey {
    static var defaultValue: (() async -> Void)? = nil
}

extension EnvironmentValues {
    var igListRefreshable: (() async -> Void)? {
        get { self[IGListRefreshableKey.self] }
        set { self[IGListRefreshableKey.self] = newValue }
    }
}

public extension View {
    func igListRefreshable(_ refreshAction: @escaping () async -> Void) -> some View {
        environment(\.igListRefreshable, refreshAction)
    }
}
