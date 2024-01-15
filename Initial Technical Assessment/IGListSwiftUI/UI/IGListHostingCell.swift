import SwiftUI

public class IGListHostingCell<Content: View>: UICollectionViewCell {
    override public init(frame: CGRect) {
        super.init(frame: frame)
        autoresizesSubviews = false
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func setView(_ view: Content) {
        contentConfiguration = UIHostingConfiguration {
            view
                .ignoresSafeArea()
        }
        .background(.clear)
        .margins(.all, 0)
    }
}
