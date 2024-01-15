import SwiftUI

struct IGListLayout: _VariadicView_MultiViewRoot {
    func body(children: _VariadicView.Children) -> some View {
        let _ = print("CHILD LEVEL RELOAD")
        return IGListCV(
            data: children
        )
    }
}
