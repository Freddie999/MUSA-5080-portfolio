# Frederick Abalo — engineering and MUSA portfolio

[Published site](https://freddie999.github.io/MUSA-5080-portfolio/)

A Quarto website presenting professional geospatial engineering experience, personal engineering demonstrations, and MUSA 5080 coursework. Project descriptions distinguish implemented public examples from proprietary work and academic analyses.

## Structure

- `index.qmd`: engineering introduction and selected projects
- `projects.qmd`: evidence-backed case studies, links, and limitations
- `coursework.qmd`: course overview
- `about.qmd`: background, skills, and contact details
- `assignments/` and `weekly-notes/`: existing coursework pages and automatic listings
- `assets/projects/`: verified screenshots and an existing assignment chart
- `styles.scss`: shared responsive styling
- `docs/`: committed rendered website, served by GitHub Pages
- `_freeze/`: committed execution results used by Quarto

## Render and validate

The portfolio update was rendered with Quarto 1.10.18 and the existing local R environment.

```sh
quarto render
python3 scripts/check_site.py docs
quarto preview --no-render
```

Python is only used for the optional standard-library link checker; use your project's uv-managed interpreter where applicable. Quarto/R remain the site's build tools. Existing course computations retain their original execution settings and dependencies (`tidyverse`, `tidycensus`, `sf`, `gt`, and packages declared in individual notes).

The project keeps `freeze: auto`. Week 4 explicitly disables freezing and uses the committed `week04-data/*.rds` snapshots when present. A fresh data refresh may need Census credentials and network access as documented in that note; never commit `.Renviron` or API keys. Do not substitute synthetic data into academic results.

After rendering, inspect `git diff` and commit the intended source, asset, frozen-result, and `docs/` changes. Avoid committing unrelated local notebook or R-session output. The checker verifies local links, anchors, asset references, and image alt attributes; it does not validate external services or the statistical methods.

## Deployment

Existing behavior is preserved: **GitHub Pages serves `/docs` on `main`**. Feature branches and pull requests are for review; pushing this branch does not publish the site. Merge only after review. No new deployment workflow is introduced.

Assignment and weekly-note source paths and published URLs are unchanged. The Coursework dropdown groups their existing index pages without moving them.

## Evidence and attribution

The API and terrain screenshots were captured from the running public portfolio demonstrations. They show synthetic GeoJSON and illustrative routes with public elevation data. Terrain source and basemap attribution appear in the demo, screenshot, and Projects page. The poverty-change figure is reused from the existing Assignment 3 frozen output; results were not newly estimated for the portfolio rewrite.

Geomersive's main application remains private. The public tile library is linked separately, and pending PR work is labeled. Zipline source code, internal screenshots, and operational data are not included.

`filters/coursework-image-alt.lua` supplies source-backed descriptions for 19 existing course figures that lacked image alt attributes. This changes rendered accessibility metadata, not the analysis code or visible captions. Existing descriptions take precedence. Update its filename mappings if course figures are renamed.
