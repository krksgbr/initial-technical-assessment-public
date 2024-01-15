import SwiftUI

@usableFromInline
struct IGListCellSizeTrait: SwiftUI._ViewTraitKey {
    @usableFromInline
    static var defaultValue: ((UICollectionView) -> CGSize)? = nil

    @usableFromInline
    typealias Value = ((UICollectionView) -> CGSize)?
}

public extension View {
    func igListCellSize(size: @escaping (UICollectionView) -> CGSize) -> some View {
        _trait(IGListCellSizeTrait.self, size)
    }
}
