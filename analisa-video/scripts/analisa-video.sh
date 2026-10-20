#!/usr/bin/env bash
# analisa-video.sh — pecah video TikTok/Instagram jadi frame + transkrip, siap dibaca AI.
#
# Pakai:
#   ./analisa-video.sh <link-atau-file> [fps] [folder-output]
#   ./analisa-video.sh https://www.tiktok.com/@akun/video/123 1
#   ./analisa-video.sh ~/Downloads/video.mp4 2
#
# fps default 1 (1 frame per detik). Video > 90 detik otomatis diturunkan supaya frame tidak terlalu banyak.
# Link Google Drive didukung lewat gdown (hanya file yang dibagikan publik).
# Hasil: <output>/frames/, transcript.txt, transcript.srt, daftar-frame.md

set -euo pipefail

INPUT="${1:-}"
FPS="${2:-1}"
BASE_OUT="${3:-./analisa-video}"
MODEL_DIR="$HOME/.cache/whisper-cpp"
MODEL="$MODEL_DIR/ggml-small.bin"   # multilingual, cukup akurat untuk Bahasa Indonesia

if [[ -z "$INPUT" ]]; then
  sed -n '2,11p' "$0" | sed 's/^# \{0,1\}//'
  exit 1
fi

# --- cek dependensi ---
missing=()
for c in ffmpeg ffprobe; do command -v "$c" >/dev/null || missing+=("$c"); done
HAS_WHISPER=0; command -v whisper-cli >/dev/null && HAS_WHISPER=1
if [[ "$INPUT" =~ drive\.google\.com ]]; then
  command -v gdown >/dev/null || missing+=("gdown")
elif [[ "$INPUT" =~ ^https?:// ]]; then
  command -v yt-dlp >/dev/null || missing+=("yt-dlp")
fi
if (( ${#missing[@]} )); then
  echo "Belum terpasang: ${missing[*]}"
  echo "Pasang dengan: brew install ffmpeg yt-dlp whisper-cpp   (link Drive: pipx install gdown)"
  exit 1
fi

# --- folder kerja ---
STAMP="$(date +%Y%m%d-%H%M%S)"
OUT="$BASE_OUT/$STAMP"
mkdir -p "$OUT/frames"

# --- ambil video ---
if [[ "$INPUT" =~ drive\.google\.com ]]; then
  echo "→ Mengunduh dari Google Drive (file harus dibagikan 'siapa saja dengan link')..."
  gdown --fuzzy -q -O "$OUT/video.mp4" "$INPUT"
  VIDEO="$OUT/video.mp4"
elif [[ "$INPUT" =~ ^https?:// ]]; then
  echo "→ Mengunduh video..."
  yt-dlp -q --no-warnings -f "mp4/best" -o "$OUT/video.%(ext)s" "$INPUT"
  VIDEO="$(ls "$OUT"/video.* | head -1)"
else
  [[ -f "$INPUT" ]] || { echo "File tidak ditemukan: $INPUT"; exit 1; }
  VIDEO="$INPUT"
fi

DUR="$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$VIDEO")"
DUR_INT="${DUR%.*}"
if (( DUR_INT > 90 )) && [[ "$FPS" == "1" ]]; then
  FPS="0.5"
  echo "→ Video ${DUR_INT} detik, fps diturunkan ke 0.5"
fi

# --- frame ---
echo "→ Ekstrak frame (fps=$FPS)..."
ffmpeg -v error -i "$VIDEO" -vf "fps=$FPS,scale=720:-2" -q:v 3 "$OUT/frames/frame_%04d.jpg"

# --- audio + transkrip ---
if (( HAS_WHISPER == 0 )); then
  echo "→ whisper-cli tidak ada, transkrip dilewati (analisa visual saja, atau minta pengguna menempel transkrip)."
else
echo "→ Transkripsi audio..."
if [[ ! -f "$MODEL" ]]; then
  mkdir -p "$MODEL_DIR"
  echo "  Mengunduh model whisper small (~470 MB, sekali saja)..."
  curl -L --fail -o "$MODEL" "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-small.bin"
fi
ffmpeg -v error -i "$VIDEO" -vn -ar 16000 -ac 1 "$OUT/audio.wav"
whisper-cli -m "$MODEL" -f "$OUT/audio.wav" -l auto -otxt -osrt -of "$OUT/transcript" >/dev/null 2>&1 || \
  echo "  (transkrip kosong atau gagal, video mungkin tanpa suara)"
rm -f "$OUT/audio.wav"
fi

# --- daftar frame + timestamp ---
{
  echo "# Analisa video"
  echo
  echo "- Sumber: $INPUT"
  echo "- Durasi: ${DUR_INT} detik"
  echo "- FPS ekstrak: $FPS"
  echo
  echo "| Frame | Detik ke- |"
  echo "|---|---|"
  i=0
  for f in "$OUT"/frames/frame_*.jpg; do
    t="$(awk -v i="$i" -v fps="$FPS" 'BEGIN{printf "%.1f", i/fps}')"
    echo "| $(basename "$f") | $t |"
    i=$((i+1))
  done
} > "$OUT/daftar-frame.md"

echo
echo "Selesai: $OUT"
echo "Kirim path folder itu ke Claude untuk dianalisa."
