import AppKit
import CoreML
import Vision
import CoreImage

final class DenoiseRunner {
    private let model: VNCoreMLModel
    private let tileSize: Int = 512

    init() {
        do {
            let config = MLModelConfiguration()
            config.computeUnits = .all
            let coreModel = try Denoise(configuration: config).model
            self.model = try VNCoreMLModel(for: coreModel)
        } catch {
            fatalError("モデル読み込み失敗: \(error)")
        }
    }

    func process(image: NSImage, strength: Double,
                 onProgress: ((Double) -> Void)? = nil) async throws -> NSImage {
        guard let cgImage = ImageIOHelper.cgImage(from: image) else {
            throw NSError(domain: "DenoiseRunner", code: -1)
        }
        let W = cgImage.width
        let H = cgImage.height

        let denoisedCG = try await processTiled(cgImage: cgImage,
                                                width: W, height: H,
                                                onProgress: onProgress)
        if strength < 0.999 {
            return blendCI(original: cgImage, denoised: denoisedCG,
                           strength: strength, width: W, height: H)
        }
        return NSImage(cgImage: denoisedCG, size: NSSize(width: W, height: H))
    }

    private func processTiled(cgImage: CGImage, width: Int, height: Int,
                               onProgress: ((Double) -> Void)?) async throws -> CGImage {
        let tile = tileSize
        let cols = Int(ceil(Double(width)  / Double(tile)))
        let rows = Int(ceil(Double(height) / Double(tile)))
        let total = cols * rows

        guard let ctx = CGContext(
            data: nil, width: width, height: height,
            bitsPerComponent: 8, bytesPerRow: width * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        else { throw NSError(domain: "DenoiseRunner", code: -10) }

        var completed = 0

        for row in 0..<rows {
            for col in 0..<cols {
                let srcX = col * tile
                let srcY = row * tile
                let cropW = min(tile, width  - srcX)
                let cropH = min(tile, height - srcY)
                guard cropW > 0, cropH > 0 else { continue }

                guard let tileImg = cgImage.cropping(
                    to: CGRect(x: srcX, y: srcY, width: cropW, height: cropH))
                else { continue }

                let resized    = resizeCG(tileImg, to: CGSize(width: tile, height: tile))
                let inferenced = try runInference(on: resized)
                let restored   = resizeCG(inferenced, to: CGSize(width: cropW, height: cropH))

                let ctxY = height - srcY - cropH
                ctx.draw(restored, in: CGRect(x: srcX, y: ctxY, width: cropW, height: cropH))

                completed += 1
                let progress = Double(completed) / Double(total)
                await MainActor.run { onProgress?(progress) }
            }
        }

        guard let result = ctx.makeImage() else {
            throw NSError(domain: "DenoiseRunner", code: -11)
        }
        return result
    }

    private func runInference(on cgImage: CGImage) throws -> CGImage {
        let request = VNCoreMLRequest(model: model)
        request.imageCropAndScaleOption = .scaleFill
        let handler = VNImageRequestHandler(cgImage: cgImage)
        try handler.perform([request])

        guard let result = request.results?.first as? VNPixelBufferObservation else {
            throw NSError(domain: "DenoiseRunner", code: -2)
        }
        let ciImage = CIImage(cvPixelBuffer: result.pixelBuffer)
        let context = CIContext()
        guard let outCG = context.createCGImage(ciImage, from: ciImage.extent) else {
            throw NSError(domain: "DenoiseRunner", code: -3)
        }
        return outCG
    }

    private func resizeCG(_ image: CGImage, to size: CGSize) -> CGImage {
        let w = Int(size.width), h = Int(size.height)
        guard let ctx = CGContext(
            data: nil, width: w, height: h,
            bitsPerComponent: 8, bytesPerRow: w * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        else { return image }
        ctx.interpolationQuality = .high
        ctx.draw(image, in: CGRect(x: 0, y: 0, width: w, height: h))
        return ctx.makeImage() ?? image
    }

    private func blendCI(original: CGImage, denoised: CGImage,
                         strength: Double, width: Int, height: Int) -> NSImage {
        let ciOrig     = CIImage(cgImage: original)
        let ciDenoised = CIImage(cgImage: denoised)
        guard let filter = CIFilter(name: "CIDissolveTransition") else {
            return NSImage(cgImage: denoised, size: NSSize(width: width, height: height))
        }
        filter.setValue(ciOrig,     forKey: kCIInputImageKey)
        filter.setValue(ciDenoised, forKey: kCIInputTargetImageKey)
        filter.setValue(strength,   forKey: kCIInputTimeKey)
        let context = CIContext()
        guard let out   = filter.outputImage,
              let cgOut = context.createCGImage(
                out, from: CGRect(x: 0, y: 0, width: width, height: height))
        else { return NSImage(cgImage: denoised, size: NSSize(width: width, height: height)) }
        return NSImage(cgImage: cgOut, size: NSSize(width: width, height: height))
    }
}
