import Foundation
import SwiftUI

private struct IGListContentInsetBehaviourKey: EnvironmentKey {
    static var defaultValue: UICollectionView.ContentInsetAdjustmentBehavior = .automatic
}

extension EnvironmentValues {
    var igListContentInsetAdjustmentBehaviour: UICollectionView.ContentInsetAdjustmentBehavior {
        get { self[IGListContentInsetBehaviourKey.self] }
        set { self[IGListContentInsetBehaviourKey.self] = newValue }
    }
}

public extension View {
    func igListInsetBehaviour(_ behaviour: UICollectionView.ContentInsetAdjustmentBehavior) -> some View {
        environment(\.igListContentInsetAdjustmentBehaviour, behaviour)
    }
}
