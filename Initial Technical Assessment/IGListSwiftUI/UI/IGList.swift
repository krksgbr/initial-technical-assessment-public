import SwiftUI

public struct IGList<Content: View>: View {
    var content: Content

    public init(
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
    }

    public var body: some View {
        _VariadicView.Tree(
            IGListLayout()
        ) {
            let _ = print("TOP LEVEL RELOAD")
            content
        }
    }
}
