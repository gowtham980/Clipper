#!/usr/bin/env python3
"""Generate docs/images/project.png — Clipper social/README card."""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "docs" / "images" / "project.png"

W, H = 1280, 720


def font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    candidates = []
    if bold:
        candidates += [
            "/System/Library/Fonts/SFNS.ttf",
            "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
            "/Library/Fonts/Arial Bold.ttf",
        ]
    candidates += [
        "/System/Library/Fonts/SFNS.ttf",
        "/System/Library/Fonts/Supplemental/Arial.ttf",
        "/Library/Fonts/Arial.ttf",
        "/System/Library/Fonts/Helvetica.ttc",
    ]
    for path in candidates:
        try:
            return ImageFont.truetype(path, size=size)
        except OSError:
            continue
    return ImageFont.load_default()


def rounded_rect(draw: ImageDraw.ImageDraw, xy, radius: int, fill) -> None:
    draw.rounded_rectangle(xy, radius=radius, fill=fill)


def main() -> None:
    OUT.parent.mkdir(parents=True, exist_ok=True)

    img = Image.new("RGB", (W, H), "#0B1220")
    draw = ImageDraw.Draw(img)

    # Soft gradient blobs (no stock photos)
    overlay = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    od = ImageDraw.Draw(overlay)
    od.ellipse((-120, -80, 520, 420), fill=(56, 120, 255, 55))
    od.ellipse((780, 280, 1400, 820), fill=(20, 184, 166, 50))
    od.ellipse((500, -100, 980, 280), fill=(99, 102, 241, 40))
    img = Image.alpha_composite(img.convert("RGBA"), overlay).convert("RGB")
    draw = ImageDraw.Draw(img)

    title_f = font(72, bold=True)
    pitch_f = font(30)
    body_f = font(22)
    small_f = font(18)
    mono_f = font(16)

    draw.text((72, 72), "Clipper", font=title_f, fill="#F8FAFC")
    draw.text(
        (72, 160),
        "Secret-aware developer clipboard for macOS",
        font=pitch_f,
        fill="#94A3B8",
    )

    # Popover sketch
    px, py = 72, 230
    pw, ph = 420, 400
    rounded_rect(draw, (px, py, px + pw, py + ph), 18, "#111827")
    rounded_rect(draw, (px + 14, py + 16, px + pw - 14, py + 58), 10, "#1F2937")
    draw.text((px + 28, py + 28), "Search clipboard", font=body_f, fill="#64748B")

    rows = [
        ("stack trace … UserService.swift:42", "2m", False),
        ("[redacted github_pat]", "5m", True),
        ("{ \"ok\": true, \"items\": […] }", "12m", False),
        ("Image", "1h", False),
    ]
    ry = py + 78
    for label, when, secret in rows:
        rounded_rect(draw, (px + 14, ry, px + pw - 14, ry + 58), 10, "#0F172A")
        color = "#FBBF24" if secret else "#E2E8F0"
        draw.text((px + 28, ry + 12), label[:42], font=body_f, fill=color)
        draw.text((px + 28, ry + 34), when, font=small_f, fill="#64748B")
        # pin glyph
        draw.ellipse((px + pw - 48, ry + 20, px + pw - 32, ry + 36), outline="#475569", width=2)
        ry += 68

    draw.text((px + 28, py + ph - 36), "4 clips  ·  skipped 3 secrets", font=small_f, fill="#94A3B8")

    # Feature cards
    cards = [
        ("Skip secrets", "AWS · PEM · JWT · ghp_\nHigh-entropy blobs"),
        ("Transforms", "JSON pretty · Base64\nURL encode · Trim"),
        ("Local only", "No cloud · No telemetry\nMenu bar · ⌘⇧V"),
    ]
    cx = 540
    cy = 230
    for title, body in cards:
        rounded_rect(draw, (cx, cy, cx + 660, cy + 110), 16, "#111827")
        draw.text((cx + 28, cy + 22), title, font=pitch_f, fill="#F8FAFC")
        draw.text((cx + 28, cy + 62), body, font=body_f, fill="#94A3B8")
        cy += 128

    draw.text((72, H - 48), "github.com/gowtham980/Clipper  ·  MIT", font=mono_f, fill="#475569")

    img.save(OUT, "PNG", optimize=True)
    print(f"Wrote {OUT} ({img.size[0]}x{img.size[1]})")


if __name__ == "__main__":
    main()
