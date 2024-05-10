import Foundation
import SwiftUI

struct HomeView: View {
    let comicsLimit = 2

    @StateObject var dataLoader = DataLoader(limit: 10) { offset, limit in
        try await NetworkManager.shared.fetchCharacters(offset: offset, limit: limit)
    }

    var body: some View {
        if !dataLoader.data.isEmpty {
            NavigationStack {
                IGList {
                    ForEach(dataLoader.data) { character in
                        NavigationLink(value: character) {
                            VStack {
                                CharacterCard(character: character)
                                    .navigationDestination(for: Character.self) { character in
                                        let dataLoader = DataLoader(limit: comicsLimit) { offset, limit in
                                            try await NetworkManager.shared.fetchComics(with: character.id, offset: offset, limit: limit)
                                        }
                                        ComicsListView(character: character, dataLoader: dataLoader)
                                    }
                                Divider()
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .foregroundColor(.black)
                        .igListCellSize(size: { cv in .init(width: cv.frame.width, height: 90) })
                        .task {
                            if character == dataLoader.data.last {
                                await dataLoader.load()
                            }
                        }
                    }
                }
                .ignoresSafeArea()
                .navigationTitle("Characters")
            }
        } else {
            LoadingView()
                .task {
                    await dataLoader.load()
                }
        }
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

struct ComicsListView: View {
    let character: Character
    @ObservedObject var dataLoader: DataLoader<Comic>

    var body: some View {
        if !dataLoader.data.isEmpty {
            IGList {
                ForEach(dataLoader.data, id: \.id) { comic in
                    FeedItemView(
                        viewModel: .init(character: character, comic: comic)
                    )
                    .task {
                        if comic == dataLoader.data.last {
                            await dataLoader.load()
                        }
                    }
                }
                Text("Data provided by Marvel. © 2014 Marvel")
                    .igListCellSize { cv in
                        .init(width: cv.frame.width, height: 30)
                    }
            }.ignoresSafeArea()
        } else {
            LoadingView()
                .task {
                    await dataLoader.load()
                }
        }
    }
}

class DataLoader<T>: ObservableObject {
    typealias LoaderFn = (Int, Int) async throws -> [T]

    @Published var data: [T] = []
    private let loaderFn: LoaderFn

    private let limit: Int
    private var offset: Int
    private var hasMore = true

    init(limit: Int, loaderFn: @escaping LoaderFn) {
        self.limit = limit
        self.offset = 0
        self.loaderFn = loaderFn
    }

    func load() async {
        guard hasMore else { return }
        do {
            let newData = try await loaderFn(offset, limit)
            if newData.count > 0 {
                DispatchQueue.main.async { [weak self] in
                    guard let self_ = self else { return }
                    self_.data += newData
                    self_.offset += self_.limit
                }
            } else {
                hasMore = false
            }
        } catch {
            print(error)
        }
    }
}

struct CharacterCard: View {
    let character: Character
    var body: some View {
        HStack(spacing: 20) {
            if let url = character.image?.imageURL(size: .portrait) {
                ComicImage(
                    url: url
                )
                .frame(width: 80, height: 80)
                .clipShape(Circle())
            }
            Text(character.name ?? "")
                .bold()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
    }
}
