import SwiftUI
import AppKit

// MARK: - Theme

struct AppTheme {
    let name: String
    let accentColor: Color
    let dialOuter: Color
    let dialOuterBorder: Color
    let dialInner: Color
    let dialInnerBorder: Color
    let lcdBg: Color
    let lcdBorder: Color
    let lcdTitle: Color
    let lcdDim: Color
    let lcdBright: Color
    let bodyBg: Color

    static let amber = AppTheme(
        name: "AMBER",
        accentColor:    Color(hex: "e8c060"),
        dialOuter:      Color(hex: "1a1e14"),
        dialOuterBorder:Color(hex: "3a4a28"),
        dialInner:      Color(hex: "141810"),
        dialInnerBorder:Color(hex: "2a3020"),
        lcdBg:          Color(hex: "0a1008"),
        lcdBorder:      Color(hex: "1a2a10"),
        lcdTitle:       Color(hex: "8ab840"),
        lcdDim:         Color(hex: "2a4a10"),
        lcdBright:      Color(hex: "6ab840"),
        bodyBg:         Color(hex: "111418")
    )
    static let blue = AppTheme(
        name: "BLUE",
        accentColor:    Color(hex: "4a9fff"),
        dialOuter:      Color(hex: "1a1e28"),
        dialOuterBorder:Color(hex: "2a3a5a"),
        dialInner:      Color(hex: "141820"),
        dialInnerBorder:Color(hex: "2a3050"),
        lcdBg:          Color(hex: "050d18"),
        lcdBorder:      Color(hex: "1a3a5a"),
        lcdTitle:       Color(hex: "2a7aff"),
        lcdDim:         Color(hex: "0a3a6a"),
        lcdBright:      Color(hex: "2a7aff"),
        bodyBg:         Color(hex: "111418")
    )
    static let green = AppTheme(
        name: "GREEN",
        accentColor:    Color(hex: "20e880"),
        dialOuter:      Color(hex: "141e18"),
        dialOuterBorder:Color(hex: "1a4a28"),
        dialInner:      Color(hex: "0e1812"),
        dialInnerBorder:Color(hex: "1a3020"),
        lcdBg:          Color(hex: "040e08"),
        lcdBorder:      Color(hex: "0a3a18"),
        lcdTitle:       Color(hex: "20c860"),
        lcdDim:         Color(hex: "083a18"),
        lcdBright:      Color(hex: "10a840"),
        bodyBg:         Color(hex: "111418")
    )
    static let red = AppTheme(
        name: "RED",
        accentColor:    Color(hex: "ff4a4a"),
        dialOuter:      Color(hex: "1e1414"),
        dialOuterBorder:Color(hex: "4a1a1a"),
        dialInner:      Color(hex: "180e0e"),
        dialInnerBorder:Color(hex: "301818"),
        lcdBg:          Color(hex: "0e0505"),
        lcdBorder:      Color(hex: "3a0a0a"),
        lcdTitle:       Color(hex: "dd2020"),
        lcdDim:         Color(hex: "5a0808"),
        lcdBright:      Color(hex: "aa1818"),
        bodyBg:         Color(hex: "141010")
    )
    static let purple = AppTheme(
        name: "PURPLE",
        accentColor:    Color(hex: "b060ff"),
        dialOuter:      Color(hex: "1a1420"),
        dialOuterBorder:Color(hex: "3a1a5a"),
        dialInner:      Color(hex: "140e1a"),
        dialInnerBorder:Color(hex: "2a1848"),
        lcdBg:          Color(hex: "080510"),
        lcdBorder:      Color(hex: "2a0a5a"),
        lcdTitle:       Color(hex: "8020dd"),
        lcdDim:         Color(hex: "3a0860"),
        lcdBright:      Color(hex: "6010aa"),
        bodyBg:         Color(hex: "111014")
    )

    static let white = AppTheme(
        name: "WHITE",
        accentColor:    Color(hex: "222222"),
        dialOuter:      Color(hex: "e8e8e8"),
        dialOuterBorder:Color(hex: "aaaaaa"),
        dialInner:      Color(hex: "f0f0f0"),
        dialInnerBorder:Color(hex: "cccccc"),
        lcdBg:          Color(hex: "f5f5f5"),
        lcdBorder:      Color(hex: "cccccc"),
        lcdTitle:       Color(hex: "333333"),
        lcdDim:         Color(hex: "888888"),
        lcdBright:      Color(hex: "222222"),
        bodyBg:         Color(hex: "e0e0e0")
    )

    static let all: [AppTheme] = [.amber, .blue, .green, .red, .purple, .white]
    static let themeColors: [Color] = [
        Color(hex: "c87020"),
        Color(hex: "1a5aaa"),
        Color(hex: "1a7a40"),
        Color(hex: "8a1a1a"),
        Color(hex: "5a1a9a"),
        Color(hex: "cccccc"),
    ]
}

extension Color {
    init(hex: String) {
        let h = hex.trimmingCharacters(in: .init(charactersIn: "#"))
        var rgb: UInt64 = 0
        Scanner(string: h).scanHexInt64(&rgb)
        self.init(
            red:   Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8)  & 0xFF) / 255,
            blue:  Double( rgb        & 0xFF) / 255
        )
    }
}

// MARK: - Rotary Dial

struct RotaryDial: View {
    let label: String
    @Binding var value: Double
    let defaultValue: Double
    let theme: AppTheme
    var scale: CGFloat = 1.0

    @State private var isDragging = false
    @State private var dragStartY: CGFloat = 0
    @State private var dragStartValue: Double = 0

    private var angle: Double { -135 + value * 2.7 }
    private var size: CGFloat { 96 * scale }

    var body: some View {
        VStack(spacing: 6 * scale) {
            ZStack {
                Circle()
                    .fill(theme.dialOuter)
                    .overlay(Circle().stroke(theme.dialOuterBorder, lineWidth: 3 * scale))
                    .frame(width: size, height: size)

                DialTicks(theme: theme)
                    .frame(width: size, height: size)

                Circle()
                    .fill(theme.dialInner)
                    .overlay(Circle().stroke(theme.dialInnerBorder, lineWidth: 1))
                    .frame(width: size * 0.875, height: size * 0.875)

                Rectangle()
                    .fill(theme.accentColor)
                    .frame(width: 3 * scale, height: 18 * scale)
                    .offset(y: -33 * scale)
                    .rotationEffect(.degrees(angle))

                Circle()
                    .fill(theme.dialInner)
                    .overlay(Circle().stroke(theme.dialOuterBorder, lineWidth: 2))
                    .frame(width: 18 * scale, height: 18 * scale)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3)) {
                            value = defaultValue
                        }
                    }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { g in
                        if !isDragging {
                            isDragging     = true
                            dragStartY     = g.location.y
                            dragStartValue = value
                        }
                        let delta = (dragStartY - g.location.y) * 0.8
                        value = max(0, min(100, dragStartValue + delta))
                    }
                    .onEnded { _ in isDragging = false }
            )

            Text(label)
                .font(.system(size: max(8, 10 * scale), design: .monospaced))
                .foregroundColor(theme.dialDim)
                .tracking(2)

            Text("\(Int(value))")
                .font(.system(size: max(9, 12 * scale), weight: .bold, design: .monospaced))
                .foregroundColor(theme.accentColor)
        }
    }
}

extension AppTheme {
    var dialDim: Color { lcdDim }
}

// MARK: - Dial Ticks

struct DialTicks: View {
    let theme: AppTheme
    var body: some View {
        Canvas { ctx, size in
            let c   = CGPoint(x: size.width/2, y: size.height/2)
            let r   = size.width/2 - 4
            let color = theme.dialOuterBorder

            let labels: [(Double, String)] = [(90,  "100"), (36,   "75"),
                                               (-18, "50"),  (-72,  "25"), (-126, "0")]
            for (deg, text) in labels {
                let rad = (deg - 90) * .pi / 180
                let tx  = c.x + (r - 14) * cos(rad)
                let ty  = c.y + (r - 14) * sin(rad)
                var attrs = AttributedString(text)
                attrs.font = .init(.systemFont(ofSize: 6))
                attrs.foregroundColor = NSColor(color)
                let t = Text(attrs)
                ctx.draw(t, at: CGPoint(x: tx, y: ty))
            }

            let tickAngles: [Double] = [90, 36, -18, -72, -126,
                                         63, 9, -45, -99,
                                         76.5, 22.5, -31.5, -85.5]
            for deg in tickAngles {
                let rad  = (deg - 90) * .pi / 180
                let len: CGFloat = tickAngles.prefix(5).map({ Double($0) }).contains(deg) ? 6 : 4
                let x1   = c.x + r * cos(rad)
                let y1   = c.y + r * sin(rad)
                let x2   = c.x + (r - len) * cos(rad)
                let y2   = c.y + (r - len) * sin(rad)
                var path = Path()
                path.move(to: CGPoint(x: x1, y: y1))
                path.addLine(to: CGPoint(x: x2, y: y2))
                ctx.stroke(path, with: .color(color), lineWidth: 1)
            }
        }
    }
}

// MARK: - Waveform

struct WaveformView: NSViewRepresentable {
    let denoiseValue: Double
    let sharpenValue: Double
    let theme: AppTheme

    func makeNSView(context: Context) -> WaveformNSView {
        let v = WaveformNSView()
        v.denoiseValue = denoiseValue
        v.sharpenValue = sharpenValue
        v.dimColor     = NSColor(theme.lcdDim)
        v.brightColor  = NSColor(theme.lcdBright)
        return v
    }

    func updateNSView(_ nsView: WaveformNSView, context: Context) {
        nsView.denoiseValue = denoiseValue
        nsView.sharpenValue = sharpenValue
        nsView.dimColor     = NSColor(theme.lcdDim)
        nsView.brightColor  = NSColor(theme.lcdBright)
    }
}

class WaveformNSView: NSView {
    var denoiseValue: Double = 60
    var sharpenValue: Double = 30
    var dimColor:    NSColor = .gray
    var brightColor: NSColor = .green
    private var t: Double = 0
    private var timer: Timer?

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.t += 0.05
            self?.needsDisplay = true
        }
    }

    override func removeFromSuperview() {
        timer?.invalidate()
        super.removeFromSuperview()
    }

    override func draw(_ dirtyRect: NSRect) {
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }
        let W = bounds.width, H = bounds.height, mid = H / 2

        // Noisy line
        ctx.setStrokeColor(dimColor.cgColor)
        ctx.setLineWidth(1)
        ctx.beginPath()
        for x in stride(from: 0, to: W, by: 1) {
            let noise = CGFloat.random(in: -1...1) * CGFloat(1 - denoiseValue / 100) * 8
            let y = mid + noise
            x == 0 ? ctx.move(to: CGPoint(x: x, y: y)) : ctx.addLine(to: CGPoint(x: x, y: y))
        }
        ctx.strokePath()

        // Clean wave
        ctx.setStrokeColor(brightColor.cgColor)
        ctx.setLineWidth(1.5)
        ctx.beginPath()
        for x in stride(from: 0, to: W, by: 1) {
            let wave = sin((Double(x) / Double(W)) * .pi * 4 + t) * (sharpenValue / 200) * Double(H / 2)
            let y = mid + CGFloat(wave)
            x == 0 ? ctx.move(to: CGPoint(x: x, y: y)) : ctx.addLine(to: CGPoint(x: x, y: y))
        }
        ctx.strokePath()
    }
}

// MARK: - LCD Status Bar

struct LCDStatusBar: View {
    let message: String
    let theme: AppTheme

    var body: some View {
        HStack {
            Text(message)
                .font(.system(size: 9, design: .monospaced))
                .foregroundColor(theme.lcdBright.opacity(0.7))
                .tracking(1)
                .lineLimit(1)
            Spacer()
        }
        .padding(.top, 8)
        .overlay(Divider().background(theme.lcdDim).opacity(0.3), alignment: .top)
    }
}

// MARK: - Theme Switcher

struct ThemeSwitcher: View {
    @Binding var selectedIndex: Int

    var body: some View {
        HStack(spacing: 10) {
            ForEach(Array(AppTheme.all.enumerated()), id: \.offset) { i, theme in
                Circle()
                    .fill(AppTheme.themeColors[i])
                    .frame(width: 24, height: 24)
                    .overlay(
                        Circle().stroke(Color.white.opacity(selectedIndex == i ? 0.8 : 0), lineWidth: 3)
                    )
                    .scaleEffect(selectedIndex == i ? 1.15 : 1.0)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3)) {
                            selectedIndex = i
                        }
                    }
            }
        }
    }
}

// MARK: - Main DialControl Panel

struct DialControlPanel: View {
    @Binding var denoiseStrength: Double
    @Binding var sharpenStrength: Double
    @Binding var detailStrength: Double
    @AppStorage("themeIndex") private var themeIndex: Int = 0
    @State private var statusMessage: String = "SYS OK >> DRAG DIALS TO ADJUST >> TAP CENTER TO RESET"
    @State private var modeName: String = "PORTRAIT"

    private var theme: AppTheme { AppTheme.all[themeIndex] }

    var body: some View {
        VStack(spacing: 8) {

            // Theme label + switcher
            Text(theme.name)
                .font(.system(size: 9, design: .monospaced))
                .foregroundColor(theme.accentColor)
                .tracking(3)

            ThemeSwitcher(selectedIndex: $themeIndex)

            // Dials
            HStack(spacing: 36) {
                RotaryDial(label: "DENOISE", value: $denoiseStrength, defaultValue: 60, theme: theme)
                RotaryDial(label: "SHARPEN", value: $sharpenStrength, defaultValue: 30, theme: theme)
                RotaryDial(label: "DETAIL",  value: $detailStrength,  defaultValue: 80, theme: theme)
            }

            // LCD Panel
            VStack(spacing: 10) {

                // Header
                HStack {
                    Text("IRO DENOISE AI")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(theme.lcdTitle)
                        .tracking(3)
                    Spacer()
                    Text("■■■□ 75%")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(theme.lcdDim)
                }
                .padding(.bottom, 4)
                .overlay(Divider().background(theme.lcdDim).opacity(0.3), alignment: .bottom)

                // Waveform
                WaveformView(
                    denoiseValue: denoiseStrength,
                    sharpenValue: sharpenStrength,
                    theme: theme
                )
                .frame(height: 32)
                .background(theme.lcdBg)

                // Meters
                HStack(spacing: 12) {
                    meterView("DENOISE", value: denoiseStrength)
                    meterView("SHARPEN", value: sharpenStrength)
                    meterView("DETAIL",  value: detailStrength)
                }

                // Readout
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(String(format: "%03d", Int(denoiseStrength)))
                            .font(.system(size: 28, design: .monospaced))
                            .foregroundColor(theme.accentColor)
                        Text("STRENGTH")
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(theme.lcdBright.opacity(0.7))
                            .tracking(1)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(modeName)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(theme.lcdDim)
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .overlay(RoundedRectangle(cornerRadius: 2).stroke(theme.lcdDim.opacity(0.4)))
                        Text("READY")
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(theme.lcdDim.opacity(0.6))
                    }
                }

                // Buttons
                HStack(spacing: 6) {
                    lcdButton("▶ RUN", primary: true) {
                        setStatus("PROCESSING...")
                    }
                    lcdButton("PORTRAIT", small: true) { setPreset("PORTRAIT", 70, 40, 60) }
                    lcdButton("LANDSCAPE", small: true) { setPreset("LANDSCAPE", 60, 30, 80) }
                    lcdButton("NIGHT", small: true) { setPreset("NIGHT", 90, 20, 50) }
                    lcdButton("RESET", small: true) { resetAll() }
                }

                LCDStatusBar(message: statusMessage, theme: theme)
            }
            .padding(14)
            .background(theme.lcdBg)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(theme.lcdBorder, lineWidth: 2))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                // Scanline overlay
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.clear)
                    .overlay(ScanlineView().opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .allowsHitTesting(false)
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(theme.bodyBg)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func meterView(_ label: String, value: Double) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label)
                .font(.system(size: 9, design: .monospaced))
                .foregroundColor(theme.lcdBright.opacity(0.7))
                .tracking(1)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(theme.lcdBg)
                        .overlay(RoundedRectangle(cornerRadius: 2).stroke(theme.lcdDim.opacity(0.3)))
                    RoundedRectangle(cornerRadius: 2)
                        .fill(theme.lcdBright)
                        .frame(width: geo.size.width * value / 100)
                }
            }
            .frame(height: 6)
        }
        .frame(maxWidth: .infinity)
    }

    private func lcdButton(_ label: String, primary: Bool = false, small: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: small ? 10 : 11, design: .monospaced))
                .foregroundColor(primary ? theme.accentColor : theme.lcdBright.opacity(0.85))
                .tracking(1)
                .padding(.horizontal, small ? 8 : 10)
                .padding(.vertical, 7)
        }
        .buttonStyle(.plain)
        .background(primary ? theme.lcdBright.opacity(0.12) : theme.lcdBg)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(primary ? theme.accentColor.opacity(0.9) : theme.lcdBright.opacity(0.35))
        )
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }

    private func setStatus(_ msg: String) {
        statusMessage = msg
        if msg == "PROCESSING..." {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                statusMessage = "COMPLETE >> OUTPUT SAVED"
            }
        }
    }

    private func setPreset(_ name: String, _ d: Double, _ s: Double, _ det: Double) {
        modeName = name
        withAnimation(.spring(response: 0.4)) {
            denoiseStrength = d
            sharpenStrength = s
            detailStrength  = det
        }
        statusMessage = "PRESET: \(name) >> LOADED"
    }

    private func resetAll() {
        setPreset("CUSTOM", 60, 30, 80)
        statusMessage = "ALL DIALS >> RESET TO DEFAULT"
    }
}

// MARK: - Scanline

struct ScanlineView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let v = NSView()
        v.wantsLayer = true
        return v
    }
    func updateNSView(_ nsView: NSView, context: Context) {}
}
