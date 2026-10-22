# Frederick Abalo — engineering and MUSA portfolio

[Published site](https://freddie999.github.io/MUSA-5080-portfolio/)

A Quarto website presenting professional geospatial engineering experience, personal engineering demonstrations, and MUSA 5080 coursework. Project descriptions distinguish implemented public examples from proprietary work and academic analyses.

## Featured academic projects

- **When blood takes a shortcut:** JavaScript/Leaflet geographic storytelling about medical-delivery accessibility in Rwanda.
- **Land-cover classification:** five CNN configurations on EuroSAT RGB, with held-out evaluation and error analysis.
- **Philadelphia poverty change:** ACS sampling uncertainty and policy interpretation.
- **Philadelphia housing values:** a team regression study with Vincent Bio Bediako and Emmanuel Sampson.

See [Projects](https://freddie999.github.io/MUSA-5080-portfolio/projects.html) for the case studies, source links, and limitations.

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
uv run --no-project --managed-python --python 3.14 python scripts/check_site.py docs
quarto preview --no-render
```

Python is only used for the optional standard-library link checker; use your project's uv-managed interpreter where applicable. Quarto/R remain the site's build tools. Existing course computations retain their original execution settings and dependencies (`tidyverse`, `tidycensus`, `sf`, `gt`, and packages declared in individual notes).

The project keeps `freeze: auto`. Week 4 explicitly disables freezing and uses the committed `week04-data/*.rds` snapshots when present. A fresh data refresh may need Census credentials and network access as documented in that note; never commit `.Renviron` or API keys. Do not substitute synthetic data into academic results.

After rendering, inspect `git diff` and commit the intended source, asset, frozen-result, and `docs/` changes. Avoid committing unrelated local notebook or R-session output. The checker verifies local links, anchors, asset references, and image alt attributes; it does not validate external services or the statistical methods.

## Deployment

Existing behavior is preserved: **GitHub Pages serves `/docs` on `main`**. Pushing changes to main publishes the committed rendered website. No new deployment workflow is introduced.

Edit weekly-note sources in `weekly-notes/`. The project builds every `.qmd` in that folder, so new weeks appear in the listing as rendered HTML pages. Give each note YAML front matter with a title, description, and date. Run `quarto render` from the project root, or render a source such as `quarto render weekly-notes/week-06.qmd`; the resulting pages and assets belong in `docs/`. Generated output should not contain copied `.qmd` pages. The link checker rejects navigation to unrendered Quarto sources, even if an accidental copy makes the file exist.

Assignment and weekly-note source paths and published URLs are unchanged. The Coursework dropdown groups their existing index pages without moving them.

## Evidence and attribution

The API and terrain screenshots were captured from the running public portfolio demonstrations. They show synthetic GeoJSON and illustrative routes with public elevation data. Terrain source and basemap attribution appear in the demo, screenshot, and Projects page. The poverty-change figure is reused from the existing Assignment 3 frozen output; results were not newly estimated for the portfolio rewrite.

Geomersive's main application remains private. The public tile library is linked separately, and pending PR work is labeled. Zipline source code, internal screenshots, and operational data are not included.

`filters/coursework-image-alt.lua` supplies source-backed descriptions for existing course figures that lacked image alt attributes. This changes rendered accessibility metadata, not the analysis code or visible captions. Existing descriptions take precedence. Update its filename mappings if course figures are renamed.

## Updating project presentation

Render only the changed presentation pages when the analyses have not changed:

```sh
quarto render index.qmd --no-execute
quarto render projects.qmd --no-execute
quarto render coursework.qmd --no-execute
quarto render assignments/index.qmd --no-execute
```

Keep the existing executed assignment and weekly-note HTML and figures. Completed Assignments 2–4 are included in both the project render list and the assignments listing; preserve their published URLs when curating coursework. Unfinished assignment instructions are excluded from the published listing. The housing report is an existing self-contained team report with publication and accessibility adjustments; its input course dataset is not redistributed.
