import SwiftUI

struct FeedItemView: View {
    class ViewModel: ObservableObject {
        @Published var character: Character
        @Published var comic: Comic
        @Published var imageURL: URL?
        @Published var likeCount: Int

        var didTapLike: (Character) -> Void

        init(character: Character, comic: Comic, likeCount: Int, didTapLike: @escaping (Character) -> Void) {
            self.character = character
            self.comic = comic
            self.likeCount = likeCount
            self.didTapLike = didTapLike
        }

        func onAppear() {
            imageURL = character.image?.imageURL(size: .portrait)
        }
    }

    @ObservedObject var viewModel: ViewModel

    let comicView: (Comic) -> AnyView

    var body: some View {
        Color.gray.overlay {
            comicView(viewModel.comic)
                .frame(height: 400)
                .ignoresSafeArea()
        }
        .overlay(alignment: .topLeading) {
            header
                .padding()
        }
        .clipShape(RoundedRectangle(cornerRadius: 40))
    }

    @ViewBuilder
    var header: some View {
        HStack {
            if let url = viewModel.imageURL {
                ComicImage(
                    url: url,
                    color: .constant(nil)
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
                viewModel.didTapLike(viewModel.character)
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
        .onAppear {
            viewModel.onAppear()
        }
    }
}
