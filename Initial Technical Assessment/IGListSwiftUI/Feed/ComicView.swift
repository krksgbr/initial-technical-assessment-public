import CoreImage
import SwiftUI

struct ComicView: View {
    let comic: Comic

    @State var color: Color?

    init(comic: Comic) {
        self.comic = comic
    }

    var body: some View {
        Color.clear
            .overlay {
                ForEach(comic.images, id: \.path) { image in
                    ComicImage(
                        url: image.imageURL(size: .portrait)!,
                        color: $color
                    )
                }
            }
            .overlay(alignment: .bottomLeading) {
                if let color {
                    VStack {
                        Text(comic.title)
                            .font(.title)
                            .fontWeight(.black)
                    }
                    .padding(40)
                    .shadow(color: .black, radius: 4)
                    .foregroundColor(color)
                    .transition(.opacity)
                }
            }
    }
}

struct ComicImage: View {
    let url: URL

    @State var image: Image?

    @Binding var color: Color?

    enum Status {
        case loading
        case loaded
        case idle
    }

    class ViewModel: ObservableObject {
        @Published var image: UIImage?
        @Published var state: Status = .idle

        @MainActor
        func fetchImage(url: URL) async {
            state = .loading
            do {
                let data = try await NetworkManager.session.data(for: URLRequest(url: url)).0
                if let image = UIImage(data: data) {
                    self.image = image
                }
            } catch {
                print(error)
            }
            state = .loaded
        }
    }

    @StateObject var viewModel = ViewModel()

    var body: some View {
        ZStack {
            if viewModel.state == .loading {
                ProgressView()
                    .scaleEffect(2)
            } else if viewModel.state == .loaded, let image = viewModel.image {
                Image(uiImage: image).resizable()
                    .aspectRatio(contentMode: .fill)
                    .overlay {
                        LinearGradient(
                            colors: [.clear, .black],
                            startPoint: .center,
                            endPoint: .bottom
                        )
                    }
            } else {
                Color.gray
            }
        }
        .onChange(of: viewModel.image) { _, newValue in
            guard let newValue = newValue else {
                return
            }
            DispatchQueue.global(qos: .userInteractive).async {
                let newColor = Color(uiColor: newValue.blurAndAverageColor(blurRadius: 1))
                DispatchQueue.main.async {
                    self.color = newColor
                }
            }
        }
        .task {
            await viewModel.fetchImage(url: url)
        }
    }
}
