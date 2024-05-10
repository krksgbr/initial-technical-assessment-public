import SwiftUI

struct FeedItemView: View {
    class ViewModel: ObservableObject {
        @Published var character: Character
        @Published var comic: Comic
        @Published var imageURL: URL?
        @Published var likeCount: Int

        init(character: Character, comic: Comic) {
            self.character = character
            self.comic = comic
            self.likeCount = 0
            self.imageURL = character.image?.imageURL(size: .portrait)
        }

        func likeButtonTapped() {
            likeCount += 1
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
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .igListCellSize { cv in
            .init(width: cv.frame.width, height: cv.frame.width)
        }
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
                viewModel.likeButtonTapped()
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
