import SwiftUI
import UIKit

class IGListCVCoordinator: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    typealias Parent = IGListCV

    var parent: Parent

    private var data: _VariadicView.Children

    weak var collectionView: UICollectionView?

    init(parent: Parent) {
        self.parent = parent
        data = parent.data
        super.init()
    }

    func updateCollectionView(_ view: UICollectionView) {
        guard collectionView == nil else { return }
        collectionView = view
        view.delegate = self
        collectionView?.register(IGListHostingCell<_VariadicView.Children.Element>.self, forCellWithReuseIdentifier: "cell")
        view.dataSource = self
    }

    func updateData(_ data: _VariadicView.Children, animated: Bool) {
        self.data = data
        collectionView?.reloadData()
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        data.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! IGListHostingCell<_VariadicView.Children.Element>

        cell.setView(data[indexPath.item])

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        data[indexPath.item][IGListCellSizeTrait.self]?(collectionView) ?? .init(width: collectionView.frame.width, height: collectionView.frame.height)
    }
}
