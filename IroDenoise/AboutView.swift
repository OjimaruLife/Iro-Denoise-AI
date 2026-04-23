import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // Header
                HStack {
                    if let icon = NSImage(named: "AppIcon") {
                        Image(nsImage: icon)
                            .resizable()
                            .frame(width: 80, height: 80)
                            .cornerRadius(18)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Iro Denoise AI")
                            .font(.system(size: 24, weight: .semibold))
                        Text("Version 1.0.0")
                            .foregroundStyle(.secondary)
                        Text("© 2026 OJIMARU")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.leading, 12)
                }

                Divider()

                // 使い方
                section(title: "使い方") {
                    VStack(alignment: .leading, spacing: 8) {
                        usage(step: "1", text: "画像をドラッグ＆ドロップ、または「画像を開く」から読み込む")
                        usage(step: "2", text: "強度スライダーで除去の強さを調整（推奨：60〜80%）")
                        usage(step: "3", text: "「ノイズ除去」ボタンを押して処理を実行")
                        usage(step: "4", text: "Before/Afterスライダーで効果を確認")
                        usage(step: "5", text: "「保存」でJPEGまたはPNGとして書き出し")
                    }
                }

                Divider()

                // バッチ処理
                section(title: "バッチ処理") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("右上の「バッチモード」ボタンで複数画像の一括処理が可能です。")
                        usage(step: "1", text: "「バッチモード」に切り替え")
                        usage(step: "2", text: "複数の画像をドロップ、または「ファイルを選択」")
                        usage(step: "3", text: "「保存先」で出力フォルダを指定（省略時は元のフォルダ）")
                        usage(step: "4", text: "「一括ノイズ除去」で処理開始")
                        Text("処理済みファイルは元のファイル名に「_denoised」が付いて保存されます。")
                            .foregroundStyle(.secondary)
                            .font(.system(size: 12))
                    }
                }

                Divider()

                // 対応フォーマット
                section(title: "対応ファイル形式") {
                    HStack(spacing: 12) {
                        ForEach(["JPEG", "PNG", "TIFF", "RAW (ARW/CR3/NEF)"], id: \.self) { fmt in
                            Text(fmt)
                                .font(.system(size: 12, weight: .medium))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.accentColor.opacity(0.12))
                                .clipShape(Capsule())
                        }
                    }
                }

                Divider()

                // 注意事項
                section(title: "注意事項") {
                    VStack(alignment: .leading, spacing: 6) {
                        note("本アプリは軽量AIモデル（NAFNet width64）を使用しています。")
                        note("高ISO夜景など極端にノイズが多い画像では効果が限定的な場合があります。")
                        note("すべての処理はお使いのMac上でローカルに実行されます。画像データが外部に送信されることはありません。")
                        note("処理結果の品質を保証するものではありません。")
                    }
                }

                Divider()

                // OSSライセンス
                section(title: "使用しているオープンソースソフトウェア") {
                    VStack(alignment: .leading, spacing: 10) {
                        licenseRow(
                            name: "NAFNet",
                            license: "MIT License",
                            url: "https://github.com/megvii-research/NAFNet"
                        )
                        licenseRow(
                            name: "coremltools",
                            license: "BSD 3-Clause License",
                            url: "https://github.com/apple/coremltools"
                        )
                    }
                }

                Divider()

                // リンク
                section(title: "リンク") {
                    HStack(spacing: 16) {
                        Link("OJIMARU公式サイト", destination: URL(string: "https://ojimaru.com")!)
                        Link("YouTube: OJIMARU LIFE", destination: URL(string: "https://www.youtube.com/@ojimaru_life")!)
                        Link("X (Twitter)", destination: URL(string: "https://x.com/ojimaru_life")!)
                    }
                    .font(.system(size: 13))
                }
            }
            .padding(32)
        }
        .frame(width: 560, height: 640)
    }

    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
            content()
        }
    }

    private func usage(step: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(step)
                .font(.system(size: 12, weight: .bold))
                .frame(width: 22, height: 22)
                .background(Color.accentColor)
                .foregroundColor(.white)
                .clipShape(Circle())
            Text(text)
                .font(.system(size: 13))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func note(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Text("•")
                .foregroundStyle(.secondary)
            Text(text)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func licenseRow(name: String, license: String, url: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.system(size: 13, weight: .medium))
                Text(license)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Link("GitHub", destination: URL(string: url)!)
                .font(.system(size: 12))
        }
        .padding(10)
        .background(Color(nsColor: .windowBackgroundColor))
        .cornerRadius(8)
    }
}
