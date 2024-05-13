import SwiftUI

struct FeedView: View {
    @ObservedObject var viewModel = FeedViewModel()

    var body: some View {
        ZStack {
            if !viewModel.items.isEmpty {
                IGList {
                    ForEach(Array(viewModel.items.keys.sorted(by: { $0.name ?? "" < $1.name ?? "" })), id: \.id) { character in
                        superHero(character: character)
                            .igListCellSize { cv in
                                .init(width: cv.frame.width, height: 110)
                            }
                        if let comics = viewModel.items[character] {
                            ForEach(comics, id: \.id) { comic in
                                FeedItemView(
                                    viewModel: .init(character: character, comic: comic, likeCount: viewModel.like[character] ?? 0, didTapLike: viewModel.didTapLike),
                                    comicView: {
                                        comicView(comic: $0)
                                    }
                                )
                                .igListCellSize { cv in
                                    .init(width: cv.frame.width, height: cv.frame.width)
                                }
                            }
                        }
                    }
                    Text("Data provided by Marvel. © 2014 Marvel")
                }
            } else {
                TimelineView(.periodic(from: .now, by: 0.5)) { _ in
                    let scale = CGFloat.random(in: 0.3 ... 1.0)
                    let color: Color = [.green, .blue, .red, .yellow].randomElement()!
                    Circle()
                        .scale(scale)
                        .foregroundColor(color)
                        .animation(.linear, value: scale)
                        .animation(.linear, value: color)
                }
                .frame(width: 100, height: 100)
                .font(.title)
            }
        }
        .task {
            await viewModel.fetchData()
        }
    }

    func superHero(character: Character) -> AnyView {
        AnyView(
            VStack {
                if let url = character.image?.imageURL(size: .portrait) {
                    ComicImage(
                        url: url
                    )
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    .shadow(radius: 5)
                }
                Text(character.name ?? "")
                    .bold()
                    .shadow(radius: 5)
            }
        )
    }

    func comicView(comic: Comic) -> AnyView {
        if !comic.images.isEmpty {
            AnyView(ComicView(
                comic: comic
            ))
        } else {
            AnyView(Text("No comic"))
        }
    }
}

class FeedViewModel: ObservableObject {
    @Published var items: [Character: [Comic]] = [:]
    @Published var like: [Character: Int] = [:]
    @Published var color: [Character: Color] = [:]

    @Published var currentChartacter: Character?

    func fetchData() async {
        do {
            items = try await withThrowingTaskGroup(of: (Character, [Comic]).self, returning: [Character: [Comic]].self) { taskGroup in
                let items = try await NetworkManager.shared.fetchCharacters()
                for character in items {
                    taskGroup.addTask {
                        (character, (try? await NetworkManager.shared.fetchComics(with: String(character.id))) ?? [])
                    }
                }
                var comics = [Character: [Comic]]()
                for try await result in taskGroup {
                    comics[result.0] = result.1
                }
                return comics
            }
        } catch {
            print(error)
        }
    }

    func didTapLike(character: Character) {
        like[character] = like[character].flatMap { $0 + 1 } ?? 1
    }
}
