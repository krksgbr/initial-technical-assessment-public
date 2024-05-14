import SwiftUI

struct FeedItemView: View {
    class ViewModel: ObservableObject {
        let character: Character
        let comic: Comic
        let imageURL: URL?
        @Published var likeCount: Int

        var didTapLike: () -> Void

        init(character: Character, comic: Comic, likeCount: Int, didTapLike: @escaping () -> Void) {
            self.character = character
            self.comic = comic
            self.likeCount = likeCount
            self.didTapLike = didTapLike
            self.imageURL = character.image?.imageURL(size: .portrait)
        }
    }

    @ObservedObject var viewModel: ViewModel

    var body: some View {
        Color.gray.overlay {
            ComicView(comic: viewModel.comic)
                .ignoresSafeArea()
        }
        .overlay(alignment: .topLeading) {
            header
                .padding()
        }
        .clipShape(RoundedRectangle(cornerRadius: 40))
        .padding(.horizontal, 20)
        .padding(.vertical, 5)
    }

    @ViewBuilder
    var header: some View {
        HStack {
            if let url = viewModel.imageURL {
                ComicImage(
                    url: url
                )
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .shadow(radius: 5)
            }
            Text(viewModel.character.name ?? "")
                .bold()
                .shadow(radius: 5)
            Spacer()
            Button(action: {
                viewModel.didTapLike()
            }, label: {
                ZStack {
                    if viewModel.likeCount == 0 {
                        Image(systemName: "heart")
                    } else {
                        HStack {
                            Text("\(viewModel.likeCount)")
                            Image(systemName: "heart.fill")
                        }
                    }
                }
                .font(.system(size: 17))
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Material.thin)
                .cornerRadius(10)
            })
        }
    }
}
