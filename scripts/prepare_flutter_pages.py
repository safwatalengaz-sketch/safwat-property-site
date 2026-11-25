"""Keep existing ad URLs as entry points to the same Flutter web application."""

from hashlib import sha256
from html import escape
from pathlib import Path
import re

SITE = "https://safwatalengaz-sketch.github.io/safwat-property-site/"
ROUTES = {
    "": ("صفوة الإنجاز العقارية", "عقارات في المدينة المنورة. شاهد تفاصيل العقار والصور والجولات وتواصل معنا."),
    "works": ("عقار", "استعرض الشقق والعمائر وتفاصيل العقارات والجولات المصورة."),
    "apartments": ("الشقق المعروضة للبيع", "شقة أرضية بمساحة ١٨٥ م² في حي الملك فهد بالمدينة المنورة."),
    "buildings": ("العمائر السكنية", "عمارة سكنية من ثلاثة أدوار تضم ست شقق في حي الملك فهد."),
    "properties": ("تفاصيل العقار", "تعرف على مواصفات العقار وصوره وطرق التواصل في المدينة المنورة."),
    "properties/king-fahd-building": ("عمارة سكنية في حي الملك فهد", "تفاصيل عمارة سكنية من ثلاثة أدوار تضم ست شقق في المدينة المنورة."),
    "properties/mb-246": ("شقق حي السلام | MB:246", "ثلاث شقق فاخرة في حي السلام بالمدينة المنورة. شاهد الصور والجولة وتفاصيل الأدوار."),
    "tours": ("الجولات العقارية المصورة", "شاهد مقاطع فيديو العقار في حي الملك فهد."),
    "about": ("من نحن", "تعرف على صفوة الإنجاز العقارية وخدماتها في المدينة المنورة."),
    "contact": ("التواصل والاستفسارات", "تواصل مع صفوة الإنجاز العقارية بالهاتف أو واتساب."),
    "privacy": ("الخصوصية والقياس", "راجع خيارات القياس الإعلاني واختر ما يناسبك."),
}

output = Path("flutter_app/build/web")
shell = (output / "index.html").read_text(encoding="utf-8")
bootstrap = output / "flutter_bootstrap.js"
main = output / "main.dart.js"
versioned_main = f"main.{sha256(main.read_bytes()).hexdigest()[:12]}.dart.js"
bootstrap.write_text(
    bootstrap.read_text(encoding="utf-8").replace('"main.dart.js"', f'"{versioned_main}"'),
    encoding="utf-8",
)
# Keep the standard file available while older bootstraps are still cached.
(output / versioned_main).write_bytes(main.read_bytes())
for script in ("marketing-config.js", "marketing.js", "flutter_bootstrap.js"):
    version = sha256((output / script).read_bytes()).hexdigest()[:12]
    shell = shell.replace(f'src="{script}"', f'src="{script}?v={version}"')

# Existing installations still update their old worker from this URL.
(output / "flutter_service_worker.js").write_text(
    'self.addEventListener("install", event => event.waitUntil(self.skipWaiting()));\n'
    'self.addEventListener("activate", event => event.waitUntil(self.registration.unregister()));\n',
    encoding="utf-8",
)

for route, (title, description) in ROUTES.items():
    folder = output / route
    folder.mkdir(exist_ok=True)
    canonical = SITE + (route + "/" if route else "")
    title = escape(title + (" | صفوة الإنجاز" if route else ""))
    description = escape(description)
    page = re.sub(r"<title>[^<]*</title>", f"<title>{title}</title>", shell)
    for attribute, key, value in (
        ("name", "description", description),
        ("property", "og:title", title),
        ("property", "og:description", description),
        ("property", "og:image", SITE + "safwat-share.png"),
    ):
        page = re.sub(
            rf'<meta {attribute}="{key}" content="[^"]*">',
            f'<meta {attribute}="{key}" content="{value}">',
            page,
        )
    page = page.replace(
        "</head>",
        f'  <link rel="canonical" href="{canonical}">\n'
        f'  <meta property="og:url" content="{canonical}">\n</head>',
    )
    (folder / "index.html").write_text(page, encoding="utf-8")
