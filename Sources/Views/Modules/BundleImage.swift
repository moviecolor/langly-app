import SwiftUI

/// Loads an image from the app bundle by filename (without extension).
struct BundleImage: View {
    let name: String

    var body: some View {
        if let uiImage = UIImage(contentsOfFile: Bundle.main.bundlePath + "/\(name).png") {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
        } else {
            Color.black
        }
    }
}
