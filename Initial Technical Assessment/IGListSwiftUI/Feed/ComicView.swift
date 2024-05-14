import CoreImage
import SwiftUI

class ColorCache {
    private let colors = NSCache<NSNumber, UIColor>()
    static let shared = ColorCache()
    init() {
        colors.countLimit = 10
    }

    func setColor(image: UIImage, uiColor: UIColor) {
        colors.setObject(uiColor, forKey: image.hashValue as NSNumber)
    }

    func getColor(image: UIImage) -> UIColor? {
        return colors.object(forKey: image.hashValue as NSNumber)
    }
}

struct ComicView: View {
    let comic: Comic
    let thumbnail: CharacterImage?

    @State var color: Color?

    init(comic: Comic) {
        self.comic = comic
        self.thumbnail = comic.images.first
    }

    func calculateColor(image: UIImage) {
        if let uiColor = ColorCache.shared.getColor(image: image) {
            color = Color(uiColor: uiColor)
            return
        }
        DispatchQueue.global(qos: .userInteractive).async {
            let uiColor = image.averageColor()
            ColorCache.shared.setColor(image: image, uiColor: uiColor)
            DispatchQueue.main.async {
                self.color = Color(uiColor: uiColor)
            }
        }
    }

    var body: some View {
        let thumbnailURL = thumbnail?.imageURL(size: .portrait)
        Color.clear
            .overlay {
                if let url = thumbnailURL {
                    ComicImage(
                        url: url,
                        onLoad: calculateColor
                    )
                } else {
                    LinearGradient(
                        colors: [.cyan, .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ).saturation(0.2)
                }
            }
            .overlay(alignment: .bottomLeading) {
                if let color = color {
                    VStack {
                        Text(comic.title)
                            .font(.title)
                            .fontWeight(.black)
                    }
                    .padding(40)
                    .shadow(color: .black, radius: thumbnailURL != nil ? 4 : 0)
                    .foregroundColor(color)
                    .transition(.opacity)
                }
            }.onAppear {
                if thumbnailURL == nil {
                    color = Color.black
                }
            }
    }
}

struct ComicImage: View {
    let url: URL

    @State var image: Image?
    var onLoad: ((UIImage) -> Void)?

    enum Status {
        case loading
        case loaded
        case idle
    }

    class ViewModel: ObservableObject {
        @Published var image: UIImage?
        @Published var state: Status = .idle

        @MainActor
        func fetchImage(url: URL, onLoad: ((UIImage) -> Void)?) async {
            state = .loading
            do {
                let data = try await NetworkManager.session.data(for: URLRequest(url: url)).0
                if let image = UIImage(data: data) {
                    self.image = image
                    onLoad?(image)
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
        .task {
            await viewModel.fetchImage(url: url, onLoad: onLoad)
        }
    }
}
