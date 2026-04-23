import AppKit
import CoreImage
import UniformTypeIdentifiers

enum ImageIOHelper {

    static func loadImage(from url: URL) -> NSImage? {
        if let img = NSImage(contentsOf: url) {
            return img
        }
        if let ciImage = CIImage(contentsOf: url),
           let cgImage = CIContext().createCGImage(ciImage, from: ciImage.extent) {
            return NSImage(cgImage: cgImage,
                           size: NSSize(width: cgImage.width, height: cgImage.height))
        }
        return nil
    }

    static func resizeToSquare(_ image: NSImage, size: CGFloat) -> NSImage? {
        let targetSize = NSSize(width: size, height: size)
        let newImage   = NSImage(size: targetSize)
        newImage.lockFocus()
        NSColor.black.setFill()
        NSBezierPath(rect: NSRect(origin: .zero, size: targetSize)).fill()
        let srcSize  = image.size
        let scale    = min(targetSize.width / srcSize.width, targetSize.height / srcSize.height)
        let drawSize = NSSize(width: srcSize.width * scale, height: srcSize.height * scale)
        let drawRect = NSRect(
            x: (targetSize.width  - drawSize.width)  / 2,
            y: (targetSize.height - drawSize.height) / 2,
            width: drawSize.width, height: drawSize.height)
        image.draw(in: drawRect)
        newImage.unlockFocus()
        return newImage
    }

    static func cgImage(from image: NSImage) -> CGImage? {
        var rect = NSRect(origin: .zero, size: image.size)
        return image.cgImage(forProposedRect: &rect, context: nil, hints: nil)
    }

    static func nsImage(from cgImage: CGImage) -> NSImage {
        NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
    }

    static func savePNG(image: NSImage, to url: URL) throws {
        try saveImage(image: image, to: url, type: .png)
    }

    static func saveJPEG(image: NSImage, to url: URL, quality: Double = 0.92) throws {
        guard let tiffData = image.tiffRepresentation,
              let bitmap   = NSBitmapImageRep(data: tiffData),
              let jpegData = bitmap.representation(using: .jpeg,
                                                   properties: [.compressionFactor: quality])
        else { throw NSError(domain: "ImageIOHelper", code: -2) }
        try jpegData.write(to: url)
    }

    private static func saveImage(image: NSImage, to url: URL, type: NSBitmapImageRep.FileType) throws {
        guard let tiffData = image.tiffRepresentation,
              let bitmap   = NSBitmapImageRep(data: tiffData),
              let data     = bitmap.representation(using: type, properties: [:])
        else { throw NSError(domain: "ImageIOHelper", code: -1) }
        try data.write(to: url)
    }
}
