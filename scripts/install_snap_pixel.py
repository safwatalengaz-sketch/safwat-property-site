from pathlib import Path

output = Path("public")
routes = ("apartments", "buildings", "properties", "tours", "about", "contact")
for route in ("", *routes):
    page = output / route / "index.html"
    source = page.read_text(encoding="utf-8")
    if source.count("</head>") != 1 or "snap-pixel.js" in source:
        raise SystemExit(f"Unexpected Snap Pixel injection point: {page}")
    src = "../shared/snap-pixel.js" if route else "shared/snap-pixel.js"
    flutter = "" if route else " data-flutter"
    tag = f'  <script defer src="{src}"{flutter}></script>\n'
    page.write_text(source.replace("</head>", tag + "</head>"), encoding="utf-8")
