#!/usr/bin/env bash
# OCR Image Preprocessor + Tesseract Runner
# Usage: ./preprocess_ocr.sh <image_path> [lang]
#   image_path : path to input image (jpg/png/webp etc.)
#   lang       : tesseract languages, default: chi_sim+eng
# Output: OCR text to stdout

set -euo pipefail

INPUT="$1"
LANG="${2:-chi_sim+eng}"

# Verify input exists
if [[ ! -f "$INPUT" ]]; then
  echo "Error: file not found: $INPUT" >&2
  exit 1
fi

# Verify required tools
for cmd in magick tesseract; do
  if ! command -v $cmd &>/dev/null; then
    echo "Error: '$cmd' not found. Install ImageMagick and tesseract first." >&2
    exit 1
  fi
done

# Determine output path
TMPDIR="${TMPDIR:-/tmp}"
PREP_FILE="$TMPDIR/ocr_prep_$$_$(basename "$INPUT").jpg"

# Cleanup on exit
trap "rm -f '$PREP_FILE'" EXIT

# Preprocessing pipeline:
# 1. Convert to grayscale
# 2. Increase contrast (level: shadows=20%, highlights=80%, gamma=1.5)
# 3. Sharpen to recover blurry text edges
# 4. Despeckle to remove noise
# 5. Scale up 200% for better OCR accuracy
magick "$INPUT" \
  -colorspace gray \
  -level 20%,80%,1.5 \
  -sharpen 0x2 \
  -despeckle \
  -resize 200% \
  "$PREP_FILE" 2>/dev/null || {
    echo "Error: ImageMagick failed to process image" >&2
    exit 1
  }

# Run Tesseract OCR with LSTM engine (--oem 3) and auto page segmentation (--psm 6)
tesseract "$PREP_FILE" stdout \
  -l "$LANG" \
  --psm 6 \
  --oem 3 \
  2>/dev/null
