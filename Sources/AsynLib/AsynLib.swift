// The Swift Programming Language
// https://docs.swift.org/swift-book

import UIKit
import SwiftUI
import Dependencies

public struct AsyncImageLoader<Content: View>: View {
    private let url: URL?
    private let content: (Image) -> Content
    @State private var loadedImage: Image?
    @State private var isLoading = false
    @Dependency(\.weatherClient) var weatherClient
    
    public init(url: URL?, @ViewBuilder content: @escaping (Image) -> Content) {
        self.url = url
        self.content = content
    }
    
    public var body: some View {
        VStack {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else if let image = loadedImage {
                content(image)
            } else {
                Color.gray
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.white)
                    )
            }
        }
        .task {
            await loadImage()
        }
    }
    
     func loadImage() async {
        guard let url = url else {
            return
        }
         do {
             let temperature = try await weatherClient.fetchCurrentTemperature()
             print("Current temperature in Pune: \(temperature)°C")
         } catch {
             print("Failed to fetch temperature: \(error)")
         }
        isLoading = true
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            #if os(iOS)
            if let uiImage = UIImage(data: data) {
                loadedImage = Image(uiImage: uiImage)
            }
            #elseif os(macOS)
            if let nsImage = NSImage(data: data) {
                loadedImage = Image(nsImage: nsImage)
            }
            #endif
        } catch {
            print("Error loading image: \(error)")
        }
        isLoading = false
    }
}

public enum WeatherClientKey: DependencyKey {
    public static let liveValue = WeatherClient(
        fetchCurrentTemperature: {
            // Replace with actual implementation
            return 28.0
        }
    )
}

public extension DependencyValues {
    var weatherClient: WeatherClient {
        get { self[WeatherClientKey.self] }
        set { self[WeatherClientKey.self] = newValue }
    }
}


public struct WeatherClient : Sendable {
    public var fetchCurrentTemperature: @Sendable () async throws -> Double
}


public struct WeatherResponse: Decodable {
    let temperature: Double
}
