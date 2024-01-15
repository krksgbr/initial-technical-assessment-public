import SwiftUI

struct IGListCV: UIViewRepresentable {
    var data: _VariadicView.Children

    public func makeUIView(context: Context) -> UICollectionView {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.contentInsetAdjustmentBehavior = context.environment.igListContentInsetAdjustmentBehaviour
        collectionView.automaticallyAdjustsScrollIndicatorInsets = context.environment.igListContentInsetAdjustmentBehaviour == .automatic
        collectionView.contentInset = context.environment.igListContentInset
        collectionView.showsVerticalScrollIndicator = !context.environment.igListHideScrollIndicator
        collectionView.showsHorizontalScrollIndicator = !context.environment.igListHideScrollIndicator

        setupRefresh(context.environment.igListRefreshable, collectionView: collectionView)

        context.coordinator.updateCollectionView(collectionView)
        context.coordinator.updateData(data, animated: context.transaction.animation != nil && !context.transaction.disablesAnimations)

        return collectionView
    }

    public func updateUIView(_ uiView: UIViewType, context: Context) {
        uiView.contentInsetAdjustmentBehavior = context.environment.igListContentInsetAdjustmentBehaviour
        uiView.automaticallyAdjustsScrollIndicatorInsets = context.environment.igListContentInsetAdjustmentBehaviour == .automatic
        uiView.contentInset = context.environment.igListContentInset
        uiView.showsVerticalScrollIndicator = !context.environment.igListHideScrollIndicator
        uiView.showsHorizontalScrollIndicator = !context.environment.igListHideScrollIndicator

        setupRefresh(context.environment.igListRefreshable, collectionView: uiView)

        context.coordinator.updateCollectionView(uiView)
        context.coordinator.updateData(data, animated: context.transaction.animation != nil && !context.transaction.disablesAnimations)

        if uiView.contentOffset.y == 0 {
            uiView.setContentOffset(.init(x: 0, y: -uiView.adjustedContentInset.top), animated: false)
        }
    }

    func setupRefresh(_ refreshAction: (() async -> Void)?, collectionView: UICollectionView) {
        guard let refreshAction else {
            collectionView.refreshControl = nil
            return
        }

        collectionView.refreshControl = UIRefreshControl()

        let action = UIAction { [weak collectionView] _ in
            guard let collectionView,
                  let refresh = collectionView.refreshControl,
                  refresh.isRefreshing
            else {
                return
            }

            Task { @MainActor in
                await refreshAction()
                refresh.endRefreshing()
            }
        }

        collectionView.refreshControl?.addAction(action, for: .valueChanged)
    }

    func makeCoordinator() -> IGListCVCoordinator {
        .init(parent: self)
    }
}
