// The Swift Programming Language
// https://docs.swift.org/swift-book

import UIKit
import SwiftUI

//
//public struct MyPakage
//{
//    public init() {}
//    public func sayHello() -> String{
//       return "Hello world!"
//    }
//}


public class AsyncImageView: UIImageView {
    private var currentUrl: URL?

    public override init(frame: CGRect = .zero) {  // Default frame provided
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        self.contentMode = .scaleAspectFit
        self.clipsToBounds = true
    }

    public func loadImage(from url: URL) {
        self.currentUrl = url
        self.image = nil // Clear old image

        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let data = try? Data(contentsOf: url), let image = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                if self?.currentUrl == url { // Ensure correct image is set
                    self?.image = image
                }
            }
        }
    }
}


public struct AsyncImageViewRepresentable: UIViewRepresentable {
    let url: String

    public init(url: String) {
        self.url = url
    }

    public func makeUIView(context: Context) -> AsyncImageView {
        let imageView = AsyncImageView()
        return imageView
    }

    public func updateUIView(_ uiView: AsyncImageView, context: Context) {
        if let imageUrl = URL(string: url) {
            uiView.loadImage(from: imageUrl)
        }
    }
}
