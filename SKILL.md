---
name: ocr-image-text-extract
description: Extract text from images using Tesseract OCR with ImageMagick preprocessing. Use when asked to OCR, recognize, or extract text from an image, screenshot, or photo of a document. Handles Chinese (simplified) and English. The preprocessing step (grayscale + contrast + sharpen + despeckle + 2x upscale) significantly improves recognition accuracy for photos of product pages, receipts, documents, and other real-world images.
---

# OCR Image Text Extract

## Quick Usage

```bash
bash <skill>/scripts/preprocess_ocr.sh <image_path> [lang]
```

- `image_path`: 任意图片格式（jpg/png/webp等）
- `lang`: 语言参数，默认 `chi_sim+chi_tra+eng`（简体中文+繁体中文+英文）
- 输出：识别后的纯文本到 stdout

## 预处理流程

ImageMagick 管道（顺序执行）：

| 步骤 | 作用 |
|------|------|
| `-colorspace gray` | 转灰度，消除颜色干扰 |
| `-level 20%,80%,1.5` | 增强对比度，压暗阴影，提亮高光 |
| `-sharpen 0x2` | 锐化，恢复模糊文字边缘 |
| `-despeckle` | 去噪点，减少干扰 |
| `-resize 200%` | 放大200%，Tesseract 对大图识别率更高 |

Tesseract 参数：

| 参数 | 值 | 作用 |
|------|-----|------|
| `--oem 3` | LSTM 神经网络引擎 | 最新、最高精度引擎 |
| `--psm 6` | 均匀文本块分割 | 适合商品页、文档等段落文本 |

## 环境依赖

- **ImageMagick 7** (`magick` 命令)
- **Tesseract 5** (`tesseract` 命令)

安装命令（macOS）:
```bash
# 安装核心组件
brew install imagemagick tesseract

# 附件语言包（中英文）: https://github.com/tesseract-ocr/tessdata_fast

# 列出已安装的语言包
tesseract --list-langs
```
 

## 示例

```bash
# 提取图片文字（默认简体中文+繁体中文+英文）
bash scripts/preprocess_ocr.sh ~/photo.jpg

# 指定语言
bash scripts/preprocess_ocr.sh ~/receipt.png eng
bash scripts/preprocess_ocr.sh ~/chinese_doc.jpg chi_sim
```

## 已知限制

- 竖排文字识别效果较差
- 艺术字体、手写体识别率低
- 图片过小（<200px宽）或严重压缩会明显影响效果

## 提示
如果MacOS系统太老，请提示用户使用MacPort代替Homebrew来安装组件
