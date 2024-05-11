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

    var onLoad: ((UIImage) -> Void)?
    @State var image: LoadableImage = .idle
    @Environment(\.imageLoader) private var imageLoader

    enum LoadableImage {
        case idle
        case loading
        case loaded(UIImage)
        case error
    }

    var body: some View {
        ZStack {
            switch image {
            case .idle, .loading:
                ProgressView()
                    .scaleEffect(2)
            case .error:
                Rectangle()
                    .background(Color.red)
            case .loaded(let uiImage):
                Image(uiImage: uiImage).resizable()
                    .aspectRatio(contentMode: .fill)
                    .overlay {
                        LinearGradient(
                            colors: [.clear, .black],
                            startPoint: .center,
                            endPoint: .bottom
                        )
                    }
            }
        }
        .onAppear {
            imageLoader.fetch(url) { result in
                switch result {
                case .success(let loaded):
                    image = .loaded(loaded)
                    onLoad?(loaded)
                case .failure:
                    image = .error
                }
            }
        }
    }
}
