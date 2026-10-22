"""Check a rendered Quarto site without external dependencies or network calls.

Run: python3 scripts/check_site.py [docs-directory]
"""
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import unquote, urlsplit
import sys


class Page(HTMLParser):
    def __init__(self, path):
        super().__init__(convert_charrefs=True)
        self.ids = set()
        self.links = []
        self.unrendered_page_links = []
        self.images_without_alt = []
        self.feed(path.read_text())

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if "id" in attrs:
            self.ids.add(attrs["id"])
        if tag == "a" and "name" in attrs:
            self.ids.add(attrs["name"])
        if tag == "a" and "href" in attrs and "download" not in attrs:
            parsed = urlsplit(attrs["href"])
            if not (parsed.scheme or parsed.netloc) and Path(unquote(parsed.path)).suffix.lower() in {".qmd", ".rmd"}:
                self.unrendered_page_links.append(attrs["href"])
        for key in ("href", "src"):
            if key in attrs:
                self.links.append(attrs[key])
        if tag == "img" and "alt" not in attrs:
            self.images_without_alt.append(attrs.get("src", "unknown")[:100])


def check(root):
    root = Path(root).resolve()
    pages = {p.resolve(): Page(p) for p in root.rglob("*.html")}
    errors = []
    for source, page in pages.items():
        for link in page.unrendered_page_links:
            errors.append(f"{source.relative_to(root)}: unrendered page link {link}; link to its rendered HTML page instead")
        for link in page.links:
            parsed = urlsplit(link)
            if parsed.scheme or parsed.netloc or not (parsed.path or parsed.fragment):
                continue
            path = unquote(parsed.path)
            if path.startswith("/MUSA-5080-portfolio/"):
                target = root / path.removeprefix("/MUSA-5080-portfolio/")
            elif path.startswith("/"):
                target = root / path.lstrip("/")
            else:
                target = source.parent / path if path else source
            if target.is_dir():
                target /= "index.html"
            target = target.resolve()
            if not target.exists():
                errors.append(f"{source.relative_to(root)}: missing {link}")
            elif parsed.fragment and target in pages:
                if unquote(parsed.fragment) not in pages[target].ids:
                    errors.append(f"{source.relative_to(root)}: missing anchor {link}")
        for image in page.images_without_alt:
            errors.append(f"{source.relative_to(root)}: image missing alt attribute: {image}")
    print(f"Checked {len(pages)} HTML pages; {len(errors)} local link/image issues.")
    for error in sorted(set(errors)):
        print(error)
    return bool(errors)


if __name__ == "__main__":
    raise SystemExit(check(Path(sys.argv[1] if len(sys.argv) > 1 else "docs").resolve()))
