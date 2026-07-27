"""Erzeugt das BOOS-Agenda-App-Icon als saubere Vektor-Rasterung.

Motiv (nach Ingos Vorlage): Ring aus vier Quadranten in den BOOS-Farben
(Teal / Schwarz / Blau / Schwarz) mit einem Häkchen in der Mitte.

Bewusst OHNE eigene abgerundete Ecken und ohne Schlagschatten — iOS und
Android maskieren das Icon selbst; eingebrannte Ecken ergäben doppelte
Rundungen.
"""

import math
import os

from PIL import Image, ImageDraw

TEAL = (16, 143, 162)
BLACK = (12, 12, 14)
BLUE = (5, 61, 112)
BG = (247, 247, 248)

SS = 4  # Supersampling
SIZE = 1024


def build(size: int = SIZE) -> Image.Image:
    s = size * SS
    im = Image.new("RGB", (s, s), BG)
    d = ImageDraw.Draw(im)

    cx = cy = s / 2
    outer = s * 0.415
    inner = s * 0.255
    gap_deg = 2.6  # Lücke zwischen den Quadranten (weiß)

    # Vier Quadranten, beginnend oben-links: Teal, Schwarz, Blau, Schwarz.
    # Winkel in PIL: 0° = 3 Uhr, im Uhrzeigersinn.
    quadrants = [
        (180, 270, TEAL),    # oben links
        (270, 360, BLACK),   # oben rechts
        (0, 90, BLUE),       # unten rechts
        (90, 180, BLACK),    # unten links
    ]
    box_o = [cx - outer, cy - outer, cx + outer, cy + outer]
    for start, end, color in quadrants:
        d.pieslice(
            box_o,
            start + gap_deg / 2,
            end - gap_deg / 2,
            fill=color,
        )

    # Innenfläche freistellen (Ring).
    d.ellipse([cx - inner, cy - inner, cx + inner, cy + inner], fill=BG)

    # Häkchen in Blau, mit runden Enden.
    w = s * 0.052
    p1 = (cx - inner * 0.52, cy + inner * 0.02)
    p2 = (cx - inner * 0.14, cy + inner * 0.40)
    p3 = (cx + inner * 0.56, cy - inner * 0.40)
    d.line([p1, p2, p3], fill=BLUE, width=int(w), joint="curve")
    for p in (p1, p2, p3):
        d.ellipse(
            [p[0] - w / 2, p[1] - w / 2, p[0] + w / 2, p[1] + w / 2],
            fill=BLUE,
        )

    return im.resize((size, size), Image.LANCZOS)


if __name__ == "__main__":
    out = os.environ.get("OUT", "icon_1024.png")
    build().save(out, optimize=True)
    print("geschrieben:", out)
