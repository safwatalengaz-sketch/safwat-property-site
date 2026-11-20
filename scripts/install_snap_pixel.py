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
    rendered = source.replace("</head>", tag + "</head>")
    if not route:
        if rendered.count("</body>") != 1:
            raise SystemExit(f"Unexpected website link insertion point: {page}")
        web_link = (
            '<a href="/safwat-property-site/contact/" '
            'style="position:fixed;inset-inline-end:10px;top:68px;z-index:1000;'
            'padding:6px 10px;border:1px solid #ddd;border-radius:8px;'
            'background:#fff;color:#132638;font:13px system-ui;text-decoration:none" '
            'dir="rtl">فتح نسخة الموقع</a>'
        )
        rendered = rendered.replace("</body>", web_link + "\n</body>")
    page.write_text(rendered, encoding="utf-8")
