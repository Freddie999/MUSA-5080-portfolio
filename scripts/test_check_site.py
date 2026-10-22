"""Regression checks for links that incorrectly point to Quarto sources."""
from contextlib import redirect_stdout
from io import StringIO
from pathlib import Path
from tempfile import TemporaryDirectory
import unittest

from check_site import check


class SourceLinkTests(unittest.TestCase):
    def check_fixture(self, markup):
        with TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "index.html").write_text(markup)
            (root / "week-06.qmd").write_text("---\ntitle: Week 6\n---\n")
            (root / "week-06.html").write_text('<h1 id="notes">Week 6</h1>')
            messages = StringIO()
            with redirect_stdout(messages):
                failed = check(root)
            return failed, messages.getvalue()

    def test_existing_source_is_not_a_rendered_page(self):
        failed, messages = self.check_fixture('<a href="week-06.qmd">Week 6</a>')
        self.assertTrue(failed)
        self.assertIn("unrendered page link week-06.qmd", messages)

    def test_rendered_page_link_and_anchor_are_valid(self):
        failed, _ = self.check_fixture('<a href="week-06.html#notes">Week 6</a>')
        self.assertFalse(failed)

    def test_explicit_source_download_is_valid(self):
        failed, _ = self.check_fixture('<a href="week-06.qmd" download>Download source</a>')
        self.assertFalse(failed)


if __name__ == "__main__":
    unittest.main()
