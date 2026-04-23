import SwiftUI
import AppKit
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var originalImage: NSImage?
    @State private var processedImage: NSImage?
    @State private var isProcessing = false
    @State private var statusText = "画像をドラッグ＆ドロップしてください"
    @State private var strength: Double = 0.6
    @State private var isTargeted = false
    @State private var sliderPosition: Double = 0.5
    @State private var showComparison = false
    @State private var sharpenStrength: Double = 30
    @State private var detailStrength: Double = 80
    @State private var progress: Double = 0.0

    // バッチ
    @State private var batchFiles: [URL] = []
    @State private var batchProgress: Double = 0.0
    @State private var batchCurrent: Int = 0
    @State private var isBatchMode = false
    @State private var outputFolder: URL? = nil

    private let runner = DenoiseRunner()

    var body: some View {
        VStack(spacing: 16) {
            header

            if isBatchMode {
                batchPanel
            } else {
                if showComparison, let original = originalImage, let processed = processedImage {
                    ComparisonCanvas(
                        originalImage: original,
                        processedImage: processed,
                        sliderPosition: $sliderPosition
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.secondary.opacity(0.15), lineWidth: 1))
                } else {
                    HStack(spacing: 16) {
                        dropPanel
                        imagePanel(title: "After", image: processedImage)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }

            controls
        }
        .padding(20)
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Iro Denoise AI").font(.system(size: 28, weight: .semibold))
                Text("AIがノイズだけを静かに消す、Mac専用ノイズ除去ツール").foregroundStyle(.secondary)
            }
            Spacer()
            HStack(spacing: 8) {
                if originalImage != nil && processedImage != nil && !isBatchMode {
                    Toggle("比較", isOn: $showComparison).toggleStyle(.button)
                }
                Toggle(isBatchMode ? "1枚モード" : "バッチモード", isOn: $isBatchMode)
                    .toggleStyle(.button)
                    .onChange(of: isBatchMode) { _ in
                        batchFiles = []
                        batchProgress = 0
                        batchCurrent = 0
                        statusText = isBatchMode ? "複数の画像をドロップしてください" : "画像をドラッグ＆ドロップしてください"
                    }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Batch Panel

    private var batchPanel: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(isTargeted ? Color.accentColor.opacity(0.10) : Color(nsColor: .windowBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(isTargeted ? Color.accentColor : Color.secondary.opacity(0.15), lineWidth: isTargeted ? 2 : 1)
                    )

                if batchFiles.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "photo.stack")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)
                        Text("複数の画像をドロップ")
                            .font(.headline)
                        Text("JPEG / PNG / TIFF / RAW")
                            .foregroundStyle(.secondary)
                    }
                } else {
                    VStack(spacing: 8) {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(Array(batchFiles.enumerated()), id: \.offset) { i, url in
                                    HStack {
                                        Image(systemName: "photo")
                                            .foregroundStyle(.secondary)
                                            .frame(width: 20)
                                        Text(url.lastPathComponent)
                                            .lineLimit(1)
                                            .truncationMode(.middle)
                                        Spacer()
                                        if isProcessing && i < batchCurrent {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(.green)
                                        } else if isProcessing && i == batchCurrent {
                                            ProgressView().controlSize(.mini)
                                        }
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(i == batchCurrent && isProcessing ? Color.accentColor.opacity(0.08) : Color.clear)
                                    .cornerRadius(6)
                                }
                            }
                            .padding(12)
                        }

                        if isProcessing {
                            VStack(spacing: 4) {
                                ProgressView(value: batchProgress)
                                    .padding(.horizontal, 20)
                                Text("\(batchCurrent)/\(batchFiles.count) 枚処理中...")
                                    .font(.system(size: 12))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.bottom, 12)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onDrop(of: [UTType.fileURL.identifier], isTargeted: $isTargeted) { providers in
                handleBatchDrop(providers: providers)
            }
        }
    }

    // MARK: - Single Mode Panels

    private var dropPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Before").font(.headline)
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(isTargeted ? Color.accentColor.opacity(0.10) : Color(nsColor: .windowBackgroundColor))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(isTargeted ? Color.accentColor : Color.secondary.opacity(0.15), lineWidth: isTargeted ? 2 : 1))
                if let image = originalImage {
                    Image(nsImage: image).resizable().scaledToFit().padding(16)
                } else {
                    VStack(spacing: 10) {
                        Image(systemName: "photo.badge.plus").font(.system(size: 34)).foregroundStyle(.secondary)
                        Text("ここに画像をドロップ").font(.headline)
                        Text("JPEG / PNG / TIFF / RAW").foregroundStyle(.secondary)
                    }
                }
            }
            .onDrop(of: [UTType.fileURL.identifier], isTargeted: $isTargeted) { providers in
                handleDrop(providers: providers)
            }
        }
    }

    private func imagePanel(title: String, image: NSImage?) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(nsColor: .windowBackgroundColor))
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.secondary.opacity(0.15), lineWidth: 1))
                if let image {
                    Image(nsImage: image).resizable().scaledToFit().padding(16)
                } else {
                    Text("処理後の画像がここに表示されます").foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: - Controls

    private var controls: some View {
        VStack(spacing: 12) {
            DialControlPanel(
                denoiseStrength: Binding(
                    get: { strength * 100 },
                    set: { strength = $0 / 100 }
                ),
                sharpenStrength: $sharpenStrength,
                detailStrength:  $detailStrength
            )

            HStack(spacing: 12) {
                if isBatchMode {
                    Button("ファイルを選択") { openBatchPanel() }
                    Button(outputFolder == nil ? "保存先: 元と同じ" : "保存先: " + (outputFolder!.lastPathComponent)) { selectOutputFolder() }
                        .foregroundColor(outputFolder == nil ? .secondary : .accentColor)
                    Button("一括ノイズ除去") { runBatch() }
                        .disabled(batchFiles.isEmpty || isProcessing)
                    Button("クリア") {
                        batchFiles = []
                        batchProgress = 0
                        batchCurrent = 0
                        statusText = "複数の画像をドロップしてください"
                    }
                    .disabled(isProcessing)
                } else {
                    Button("画像を開く") { openImageWithPanel() }
                    Button("ノイズ除去") { runDenoise() }.disabled(originalImage == nil || isProcessing)
                    Button("保存") { saveImage() }.disabled(processedImage == nil || isProcessing)
                }
                Spacer()
                if isProcessing {
                    VStack(spacing: 4) {
                        ProgressView(value: isBatchMode ? batchProgress : progress)
                            .frame(width: 120)
                        Text(statusText)
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }
                }
                if !isProcessing { Text(statusText).foregroundStyle(.secondary).lineLimit(2) }
            }
        }
    }

    // MARK: - Single Mode

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) }) else {
            statusText = "画像ファイルをドロップしてください"; return false
        }
        provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, error in
            var url: URL?
            if let data = item as? Data { url = URL(dataRepresentation: data, relativeTo: nil) }
            else if let nsData = item as? NSData { url = URL(dataRepresentation: nsData as Data, relativeTo: nil) }
            else if let droppedURL = item as? URL { url = droppedURL }
            guard let fileURL = url else { return }
            loadImage(from: fileURL)
        }
        return true
    }

    private func openImageWithPanel() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.jpeg, .png, .tiff, .rawImage,
            UTType("com.sony.arw") ?? .data, UTType("com.canon.cr3") ?? .data, UTType("com.nikon.nef") ?? .data]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories    = false
        if panel.runModal() == .OK, let url = panel.url { loadImage(from: url) }
    }

    private func loadImage(from url: URL) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let image = ImageIOHelper.loadImage(from: url) else {
                DispatchQueue.main.async { statusText = "画像を読み込めませんでした" }; return
            }
            DispatchQueue.main.async {
                originalImage = image; processedImage = nil
                showComparison = false; sliderPosition = 0.5
                statusText = "読み込み完了"
            }
        }
    }

    private func runDenoise() {
        guard let originalImage else { return }
        isProcessing = true; progress = 0.0; statusText = "ノイズ除去中..."
        Task {
            do {
                let output = try await runner.process(image: originalImage, strength: strength) { p in
                    self.progress   = p
                    self.statusText = String(format: "処理中... %.0f%%", p * 100)
                }
                await MainActor.run {
                    self.processedImage = output
                    self.isProcessing   = false
                    self.statusText     = "完了"
                    self.showComparison = true
                    self.sliderPosition = 0.5
                }
            } catch {
                await MainActor.run { self.isProcessing = false; self.statusText = "失敗: \(error.localizedDescription)" }
            }
        }
    }

    private func saveImage() {
        guard let processedImage else { return }
        let panel = NSSavePanel()
        panel.allowedContentTypes  = [.jpeg, .png]
        panel.nameFieldStringValue = "iro_denoised.jpg"
        if panel.runModal() == .OK, let url = panel.url {
            do {
                if url.pathExtension.lowercased() == "png" {
                    try ImageIOHelper.savePNG(image: processedImage, to: url)
                } else {
                    try ImageIOHelper.saveJPEG(image: processedImage, to: url)
                }
                statusText = "保存しました"
            } catch { statusText = "保存失敗: \(error.localizedDescription)" }
        }
    }

    // MARK: - Batch Mode

    private func handleBatchDrop(providers: [NSItemProvider]) -> Bool {
        let group = DispatchGroup()
        var urls: [URL] = []
        for provider in providers {
            guard provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) else { continue }
            group.enter()
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
                defer { group.leave() }
                var url: URL?
                if let data = item as? Data { url = URL(dataRepresentation: data, relativeTo: nil) }
                else if let nsData = item as? NSData { url = URL(dataRepresentation: nsData as Data, relativeTo: nil) }
                else if let droppedURL = item as? URL { url = droppedURL }
                if let u = url { urls.append(u) }
            }
        }
        group.notify(queue: .main) {
            let imageExts = ["jpg","jpeg","png","tiff","tif","arw","cr3","nef","dng","heic"]
            let filtered  = urls.filter { imageExts.contains($0.pathExtension.lowercased()) }
            batchFiles.append(contentsOf: filtered)
            batchFiles = Array(Set(batchFiles)).sorted { $0.lastPathComponent < $1.lastPathComponent }
            statusText = "\(batchFiles.count) 枚の画像が選択されました"
        }
        return true
    }

    private func selectOutputFolder() {
        let panel = NSOpenPanel()
        panel.canChooseFiles        = false
        panel.canChooseDirectories  = true
        panel.allowsMultipleSelection = false
        panel.prompt = "選択"
        if panel.runModal() == .OK {
            outputFolder = panel.url
        }
    }

    private func openBatchPanel() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.jpeg, .png, .tiff, .rawImage,
            UTType("com.sony.arw") ?? .data, UTType("com.canon.cr3") ?? .data, UTType("com.nikon.nef") ?? .data]
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories    = false
        if panel.runModal() == .OK {
            batchFiles.append(contentsOf: panel.urls)
            batchFiles = Array(Set(batchFiles)).sorted { $0.lastPathComponent < $1.lastPathComponent }
            statusText = "\(batchFiles.count) 枚の画像が選択されました"
        }
    }

    private func runBatch() {
        guard !batchFiles.isEmpty else { return }
        isProcessing  = true
        batchCurrent  = 0
        batchProgress = 0.0
        statusText    = "バッチ処理中..."

        Task {
            let files   = batchFiles
            let total   = files.count

            for (i, url) in files.enumerated() {
                await MainActor.run {
                    batchCurrent = i
                    statusText   = "\(i + 1)/\(total) 処理中: \(url.lastPathComponent)"
                }

                guard let image = ImageIOHelper.loadImage(from: url) else { continue }

                do {
                    let output = try await runner.process(image: image, strength: strength) { p in
                        let overall = (Double(i) + p) / Double(total)
                        self.batchProgress = overall
                    }

                    // 保存先：指定フォルダ or 元と同じフォルダ
                    let stem      = url.deletingPathExtension().lastPathComponent
                    let folder    = self.outputFolder ?? url.deletingLastPathComponent()
                    let saveURL   = folder.appendingPathComponent("\(stem)_denoised.jpg")
                    try ImageIOHelper.saveJPEG(image: output, to: saveURL)

                } catch {
                    print("失敗: \(url.lastPathComponent) - \(error)")
                }
            }

            await MainActor.run {
                isProcessing  = false
                batchProgress = 1.0
                batchCurrent  = total
                statusText    = "\(total) 枚の処理が完了しました"
            }
        }
    }
}

// MARK: - Comparison Canvas


// MARK: - Comparison Canvas (NSViewRepresentable)

struct ComparisonCanvas: NSViewRepresentable {
    let originalImage: NSImage
    let processedImage: NSImage
    @Binding var sliderPosition: Double

    func makeNSView(context: Context) -> ComparisonNSView {
        let view = ComparisonNSView()
        view.originalImage  = originalImage
        view.processedImage = processedImage
        view.sliderPosition = sliderPosition
        view.onSliderChanged = { sliderPosition = $0 }
        return view
    }

    func updateNSView(_ nsView: ComparisonNSView, context: Context) {
        nsView.originalImage  = originalImage
        nsView.processedImage = processedImage
        nsView.sliderPosition = sliderPosition
        nsView.needsDisplay   = true
    }
}

class ComparisonNSView: NSView {
    var originalImage: NSImage?
    var processedImage: NSImage?
    var sliderPosition: Double = 0.5
    var onSliderChanged: ((Double) -> Void)?

    private var scale: CGFloat = 1.0
    private var offset: CGPoint = .zero
    private var isDraggingSlider = false
    private var lastDragLocation: CGPoint?
    private let minScale: CGFloat = 0.5
    private let maxScale: CGFloat = 8.0

    // MARK: - Setup

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        // トラックパッドのピンチ・スクロールを有効化
        allowedTouchTypes = [.indirect]
    }

    override var acceptsFirstResponder: Bool { true }
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }

    // MARK: - Draw

    private func imageRect() -> NSRect {
        guard let img = originalImage else { return .zero }
        let base  = min(bounds.width / img.size.width, bounds.height / img.size.height)
        let drawW = img.size.width  * base * scale
        let drawH = img.size.height * base * scale
        return NSRect(x: bounds.midX - drawW/2 + offset.x,
                      y: bounds.midY - drawH/2 + offset.y,
                      width: drawW, height: drawH)
    }

    override func draw(_ dirtyRect: NSRect) {
        guard let original = originalImage, let processed = processedImage else { return }

        NSColor.windowBackgroundColor.setFill()
        bounds.fill()

        let imgRect = imageRect()
        let splitX  = imgRect.minX + imgRect.width * sliderPosition

        // After（右）
        NSGraphicsContext.saveGraphicsState()
        NSRect(x: splitX, y: 0, width: bounds.maxX - splitX, height: bounds.height).clip()
        processed.draw(in: imgRect)
        NSGraphicsContext.restoreGraphicsState()

        // Before（左）
        NSGraphicsContext.saveGraphicsState()
        NSRect(x: 0, y: 0, width: splitX, height: bounds.height).clip()
        original.draw(in: imgRect)
        NSGraphicsContext.restoreGraphicsState()

        // 仕切り線
        NSColor.white.withAlphaComponent(0.9).setStroke()
        let line = NSBezierPath()
        line.lineWidth = 2
        line.move(to: NSPoint(x: splitX, y: 0))
        line.line(to: NSPoint(x: splitX, y: bounds.height))
        line.stroke()

        // ハンドル
        let r = CGFloat(20)
        let circle = NSBezierPath(ovalIn: NSRect(x: splitX-r, y: bounds.midY-r, width: r*2, height: r*2))
        NSColor.white.setFill(); circle.fill()
        NSColor.gray.withAlphaComponent(0.3).setStroke(); circle.lineWidth = 1; circle.stroke()

        let arrowAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 11, weight: .medium),
            .foregroundColor: NSColor.darkGray
        ]
        let arrow = NSAttributedString(string: "◀ ▶", attributes: arrowAttrs)
        let as_   = arrow.size()
        arrow.draw(at: NSPoint(x: splitX - as_.width/2, y: bounds.midY - as_.height/2))

        drawLabel("Before", at: NSPoint(x: imgRect.minX + 10, y: imgRect.maxY - 26))
        drawLabel("After",  at: NSPoint(x: min(splitX + 10, bounds.maxX - 60), y: imgRect.maxY - 26))

        if scale > 1.01 {
            drawLabel(String(format: "%.0f%%", scale * 100),
                      at: NSPoint(x: bounds.maxX - 52, y: 10))
        }
    }

    private func drawLabel(_ text: String, at point: NSPoint) {
        let attrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 11, weight: .semibold),
            .foregroundColor: NSColor.white
        ]
        let str  = NSAttributedString(string: text, attributes: attrs)
        let size = str.size()
        let bg   = NSBezierPath(roundedRect: NSRect(x: point.x-4, y: point.y-2,
                                                     width: size.width+10, height: size.height+4),
                                xRadius: 5, yRadius: 5)
        NSColor.black.withAlphaComponent(0.45).setFill()
        bg.fill()
        str.draw(at: NSPoint(x: point.x+1, y: point.y+1))
    }

    // MARK: - Mouse

    private func isNearSlider(_ x: CGFloat) -> Bool {
        let rect = imageRect()
        return abs(x - (rect.minX + rect.width * sliderPosition)) < 24
    }

    override func mouseDown(with event: NSEvent) {
        window?.makeFirstResponder(self)
        let loc = convert(event.locationInWindow, from: nil)
        if event.clickCount == 2 {
            withZoomReset(); return
        }
        isDraggingSlider = isNearSlider(loc.x)
        lastDragLocation = isDraggingSlider ? nil : loc
    }

    override func mouseDragged(with event: NSEvent) {
        let loc = convert(event.locationInWindow, from: nil)
        if isDraggingSlider {
            let rect = imageRect()
            let val  = max(0, min(1, (loc.x - rect.minX) / rect.width))
            sliderPosition = val
            onSliderChanged?(val)
        } else if let last = lastDragLocation {
            offset.x += loc.x - last.x
            offset.y += loc.y - last.y
            lastDragLocation = loc
        }
        needsDisplay = true
    }

    override func mouseUp(with event: NSEvent) {
        isDraggingSlider = false
        lastDragLocation = nil
    }

    // MARK: - Trackpad pinch zoom

    override func magnify(with event: NSEvent) {
        window?.makeFirstResponder(self)
        zoom(by: 1 + event.magnification)
    }

    // MARK: - Scroll（トラックパッド2本指スクロール＋マウスホイール）

    override func scrollWheel(with event: NSEvent) {
        window?.makeFirstResponder(self)

        // ⌘+スクロール or トラックパッドのピンチ相当（deltaZ）
        if event.modifierFlags.contains(.command) {
            zoom(by: 1 + event.scrollingDeltaY * 0.02)
            return
        }

        // トラックパッド2本指スクロール or マウスホイール
        if !event.phase.isEmpty || !event.momentumPhase.isEmpty {
            // トラックパッド：パン
            offset.x += event.scrollingDeltaX
            offset.y -= event.scrollingDeltaY
        } else {
            // マウスホイール：ズーム
            zoom(by: 1 - event.scrollingDeltaY * 0.05)
        }
        needsDisplay = true
    }

    private func zoom(by factor: CGFloat) {
        scale        = max(minScale, min(maxScale, scale * factor))
        needsDisplay = true
    }

    private func withZoomReset() {
        scale        = 1.0
        offset       = .zero
        needsDisplay = true
    }
}
