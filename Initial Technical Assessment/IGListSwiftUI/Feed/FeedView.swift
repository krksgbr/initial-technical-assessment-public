import SwiftUI

struct FeedView: View {
    @ObservedObject var viewModel = FeedViewModel()

    var body: some View {
        Group {
            if viewModel.sections.isEmpty {
                switch viewModel.status {
                case .loadable, .loading:
                    LoadingView()
                case .noMoreData:
                    Text("All you are seeking is already within you")
                case .error(let error):
                    Text(error.localizedDescription)
                        .foregroundColor(.red)
                }
            } else {
                IGList {
                    ForEach(viewModel.sections, id: \.character.id) { section in
                        superHero(character: section.character)
                            .igListCellSize { cv in
                                .init(width: cv.frame.width, height: 200)
                            }
                        ForEach(section.comics, id: \.id) { comic in
                            FeedItemView(
                                viewModel: .init(character: section.character, comic: comic, likeCount: viewModel.like[comic] ?? 0) {
                                    viewModel.didTapLike(comic: comic)
                                }
                            )
                            .igListCellSize { cv in
                                .init(width: cv.frame.width, height: cv.frame.width)
                            }
                        }
                    }

                    Group {
                        switch viewModel.status {
                        case .error(let error):
                            Text(error.localizedDescription).foregroundStyle(.red)
                        case .noMoreData:
                            Text("Data provided by Marvel. © 2014 Marvel")
                        case .loadable, .loading:
                            ProgressView()
                                .igListCellSize(size: { cv in .init(width: cv.frame.width, height: 20) })
                                .onAppear {
                                    Task {
                                        await viewModel.loadData()
                                    }
                                }
                        }
                    }
                    .igListCellSize { cv in
                        .init(width: cv.frame.width, height: 30)
                    }
                }
                .ignoresSafeArea()
            }
        }
        .task {
            await viewModel.loadData()
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
}

class FeedViewModel: ObservableObject {
    class FeedSection: ObservableObject {
        var character: Character
        var comicsOffset: Int
        @Published var comics: [Comic]

        init(character: Character, comics: [Comic], comicsOffset: Int) {
            self.character = character
            self.comics = comics
            self.comicsOffset = comicsOffset
        }
    }

    enum Status {
        case loadable
        case loading
        case error(Error)
        case noMoreData
    }

    @Published var like: [Comic: Int] = [:]
    @Published var sections: [FeedSection] = []
    @Published var status: Status = .loadable

    let comicsPageSize = 10
    var charactersOffset = 0

    @MainActor
    private func loadNextSection() async throws {
        do {
            let characters = try await NetworkManager.shared.fetchCharacters(offset: charactersOffset, limit: 1)
            charactersOffset += 1
            if let character = characters.first {
                let offset = 0
                let comics = try await NetworkManager.shared.fetchComics(with: character.id, offset: offset, limit: comicsPageSize)
                let feedSection = FeedSection(character: character, comics: comics, comicsOffset: comicsPageSize)
                sections.append(feedSection)
            } else {
                status = .noMoreData
            }
        } catch {
            throw error
        }
    }

    @MainActor
    func loadData() async {
        switch status {
        case .loading, .error, .noMoreData:
            return
        case .loadable:
            do {
                status = .loading
                if let lastFeedSection = sections.last {
                    let newComics = try await NetworkManager.shared.fetchComics(with: lastFeedSection.character.id, offset: lastFeedSection.comicsOffset, limit: comicsPageSize)
                    if newComics.count > 0 {
                        lastFeedSection.comics += newComics
                        lastFeedSection.comicsOffset += comicsPageSize
                    } else {
                        try await loadNextSection()
                    }
                } else {
                    try await loadNextSection()
                }
                status = .loadable
            } catch {
                status = .error(error)
                print(error)
            }
        }
    }

    func didTapLike(comic: Comic) {
        like[comic] = like[comic].flatMap { $0 + 1 } ?? 1
    }
}

struct LoadingView: View {
    var body: some View {
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
