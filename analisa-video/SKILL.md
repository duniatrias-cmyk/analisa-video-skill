---
name: analisa-video
description: |
  Analisa video TikTok / Instagram Reels / video pendek dengan memecahnya jadi frame + transkrip audio,
  lalu membaca keduanya. Pakai saat pengguna mengunggah video, menempel link video, atau meminta
  "analisa video ini", "bedah konten ini", "kenapa video ini works", atau riset konten kompetitor/referensi.
---

# Analisa Video

Claude tidak menonton video. Skill ini mengubah video jadi bahan yang bisa dibaca: frame JPG per detik, transkrip dengan timestamp, dan tabel frame ke detik.

## Langkah 1: Dapatkan videonya

| Situasi | Cara |
|---|---|
| Pengguna mengunggah file video ke chat | Lanjut ke Langkah 2. |
| Pengguna menempel link TikTok / Instagram / YouTube | Chat biasanya tidak bisa mengunduh. Minta pengguna mengunduh videonya lalu mengunggah ke chat. Di Claude Code atau terminal dengan `yt-dlp`, script bisa mengunduh sendiri. |
| Hanya ada screenshot atau frame | Lewati script, langsung ke Langkah 3 dan analisa dari gambar itu. |

Video Instagram yang private atau butuh login tidak bisa diunduh otomatis. Minta pengguna unggah file-nya.

## Langkah 2: Pecah jadi frame dan transkrip

Jalankan script (butuh `ffmpeg`; `whisper-cli` opsional untuk transkrip):

```bash
bash scripts/analisa-video.sh "<path-video-atau-link>" [fps] [folder-output]
```

- fps default 1. Video lebih dari 90 detik otomatis turun ke 0.5. Naikkan ke 2-4 hanya untuk menilai animasi teks atau cut cepat.
- Output: `frames/`, `transcript.txt`, `transcript.srt`, `daftar-frame.md`.
- Kalau `ffmpeg` tidak tersedia di lingkungan chat, katakan apa adanya dan minta pengguna menempelkan screenshot beberapa momen kunci (detik 0-3, tengah, akhir) plus transkrip atau caption.
- Kalau `whisper-cli` tidak ada, transkrip dilewati. Minta pengguna menempel transkrip atau subtitle kalau audio penting untuk analisa.
- Pasang di komputer sendiri: `brew install ffmpeg yt-dlp whisper-cpp` (macOS). Model whisper (~470 MB) diunduh otomatis pada run pertama.

## Langkah 3: Baca bahan

1. `daftar-frame.md` dan `transcript.srt` (kalau ada).
2. Frame, paralel dalam satu blok. Batas wajar 30 frame per analisa. Kalau lebih, jalankan ulang dengan fps lebih rendah atau ambil tiap frame ke-2 atau ke-3.
3. Kalau transkrip kosong atau hanya lirik lagu, katakan videonya tanpa narasi. Jangan mengarang isi audio.

## Langkah 4: Tulis analisa

Isi minimal, urut:

1. **Isi:** apa yang tampak (visual, teks di layar, audio). Hanya yang terlihat di frame atau terbaca di transkrip.
2. **Struktur:** hook (3 detik pertama), pacing dan jumlah cut, alur pesan, CTA. Sebut detiknya.
3. **Implikasi:** apa yang bisa ditiru atau dihindari untuk audiens dan brand pengguna, dan format apa yang bisa direplikasi tim. Kalau konteks brand belum diketahui, tanyakan satu kali: siapa audiensnya dan apa tujuan kontennya.

Aturan:
- Jangan menilai performa (views, likes, save). Script tidak membaca metrik. Kalau pengguna punya angkanya, minta.
- Sebut keterbatasan sampling hanya kalau relevan (animasi lebih cepat dari satu frame per detik tidak terlihat).
- Tulis dengan bahasa pengguna, lugas, tanpa rekap di akhir. Tutup dengan satu pertanyaan atau satu langkah lanjut.

## Membandingkan beberapa video

Jalankan script per video, baca masing-masing, lalu bandingkan dalam satu tabel: hook, durasi, jumlah cut, jenis teks, CTA, tone.
