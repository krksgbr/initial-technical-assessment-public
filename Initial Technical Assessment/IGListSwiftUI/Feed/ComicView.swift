import CoreImage
import SwiftUI

struct ComicView: View {
    let comic: Comic
    let image: CharacterImage?

    @State var color: Color?

    init(comic: Comic) {
        self.comic = comic
        self.image = comic.images.first
    }

    func calculateColor(image: UIImage) {
        DispatchQueue.global(qos: .userInteractive).async {
            let uiColor = image.averageColor()
            DispatchQueue.main.async {
                self.color = Color(uiColor: uiColor)
            }
        }
    }

    var body: some View {
        Color.clear
            .overlay {
                if let image = image {
                    ComicImage(
                        url: image.imageURL(size: .portrait)!,
                        onLoad: calculateColor
                    )
                } else {
                    Color.gray
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
                    .shadow(color: .black, radius: image != nil ? 4 : 0)
                    .foregroundColor(color)
                    .transition(.opacity)
                }
            }.onAppear {
                if comic.images.isEmpty {
                    self.color = Color.black
                }
            }
    }
}

struct ComicImage: View {
    let url: URL
    var onLoad: ((UIImage) -> Void)? = nil

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
            loadImage()
        }
    }

    func loadImage() {
        imageLoader.fetch(url) { result in
            switch result {
            case .success(let loadedImage):
                image = .loaded(loadedImage)
                onLoad?(loadedImage)
            case .failure:
                image = .error
            }
        }
    }
}
