# Skill: analisa-video

Skill Claude untuk membedah video pendek (TikTok, Reels, Shorts): hook, pacing, struktur pesan, CTA, dan implikasi untuk brand kita. Claude tidak menonton video, jadi skill ini memecahnya jadi frame per detik + transkrip lalu membacanya.

## Install di Claude chat (claude.ai / aplikasi desktop)

1. Unduh `analisa-video.zip` dari halaman [Releases](../../releases/latest) (atau klik "Code" > "Download ZIP" lalu zip ulang folder `analisa-video/`).
2. Buka **Settings > Capabilities > Skills** (atau **Customize > Skills**) > **Upload skill**, pilih zip-nya.
3. Aktifkan skill `analisa-video`.
4. Pakai: unggah video ke chat lalu ketik "analisa video ini".

Syarat: fitur Skills dan code execution aktif di akun/organisasi. Kalau lingkungan chat tidak punya `ffmpeg`, Claude akan meminta screenshot momen kunci dan transkrip.

## Install di Claude Code

```bash
git clone <url-repo-ini> /tmp/analisa-video-skill
cp -R /tmp/analisa-video-skill/analisa-video ~/.claude/skills/
brew install ffmpeg yt-dlp whisper-cpp
```

Di Claude Code, link TikTok/Instagram bisa langsung ditempel; script mengunduh dengan `yt-dlp`.

## Isi

- `analisa-video/SKILL.md` — instruksi skill
- `analisa-video/scripts/analisa-video.sh` — pemecah video (ffmpeg, whisper opsional)
