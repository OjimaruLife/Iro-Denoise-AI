# Iro Denoise AI

**AI-powered noise reduction for photographers. Mac only. Free.**

写真家のための AI ノイズ除去ツール。Mac 専用。無料。

![Platform](https://img.shields.io/badge/Platform-macOS%2013%2B-blue)
![License](https://img.shields.io/badge/License-MIT-green)
![Architecture](https://img.shields.io/badge/Apple%20Silicon-Optimized-orange)

---

## Overview / 概要

Iro Denoise AI is a free, local AI noise reduction app for macOS.  
No subscription. No cloud upload. Your photos never leave your Mac.

Iro Denoise AI は、Mac 上でローカル動作する無料の AI ノイズ除去アプリです。  
サブスクリプション不要。クラウドへのアップロードなし。写真データは外部に送信されません。

---

## Features / 機能

- **AI Noise Reduction** — Powered by NAFNet (width64), optimized with Apple CoreML
- **Before/After Comparison** — Drag the slider to compare original and processed images
- **Batch Processing** — Process multiple images at once
- **Custom Output Folder** — Choose where to save processed files
- **Format Support** — JPEG, PNG, TIFF, RAW (ARW, CR3, NEF, DNG)
- **100% Local** — All processing happens on your Mac

---

## Honest Note / 正直なところ

This app uses a lightweight AI model (NAFNet-SIDD-width64) trained primarily on smartphone images.  
Results are best on **indoor, portrait, and moderate ISO shots**.  
For extreme low-light or high-ISO camera noise, results may be limited.

本アプリはスマートフォン画像データセット（SIDD）で学習した軽量モデルを使用しています。  
**室内・ポートレート・中程度の ISO** での効果が最も高く出ます。  
夜景や極端な高 ISO のノイズには効果が限定的な場合があります。

---

## Requirements / 動作環境

- macOS 13 Ventura 以降
- Apple Silicon（M1 以降）推奨
- Intel Mac でも動作しますが、処理速度が遅くなる場合があります

---

## Download / ダウンロード

[Releases](https://github.com/OjimaruLife/Iro-Denoise-AI/releases) から最新の `.dmg` をダウンロードしてください。

---

## Usage / 使い方

1. 画像をドラッグ＆ドロップ、または「画像を開く」から読み込む
2. 強度スライダーで除去の強さを調整（推奨：60〜80%）
3. 「ノイズ除去」ボタンを押して処理を実行
4. Before/After スライダーで効果を確認
5. 「保存」で JPEG または PNG として書き出し

---

## Open Source Credits / 使用 OSS

| Library | License |
|---|---|
| [NAFNet](https://github.com/megvii-research/NAFNet) | MIT License |
| [coremltools](https://github.com/apple/coremltools) | BSD 3-Clause |

---

## License / ライセンス

MIT License — © 2026 OJIMARU

---

## Links / リンク

- 🌐 [ojimaru.com](https://ojimaru.com)
- 📺 [YouTube: OJIMARU LIFE](https://www.youtube.com/@ojimaru_life)
- 🐦 [X (Twitter): @ojimaru_life](https://x.com/ojimaru_life)
