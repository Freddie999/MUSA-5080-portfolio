-- Add descriptions to existing course figures at render time, without changing
-- analysis code, numerical results, or visible captions. Descriptions follow
-- the plotted variables and titles in the original .qmd sources.
local descriptions = {
  ["week7-adjusted-age-curve-1.png"] = "Adjusted relationship between age and the modeled outcome, holding other predictors fixed.",
  ["week7-age-pattern-1.png"] = "Observed age pattern compared with fitted model relationships.",
  ["week7-district-coefficients-1.png"] = "Estimated district coefficients and their uncertainty intervals.",
  ["week7-income-histograms-1.png"] = "Income distributions shown on original and logarithmic scales.",
  ["week7-model-comparison-plot-1.png"] = "Cross-validation errors for the candidate regression models.",
  ["week7-residual-maps-1.png"] = "Geographic patterns of residuals for the compared regression models.",
  ["week7-ring-exploration-1.png"] = "Exploratory comparison of observations across geographic distance rings.",
  ["week-03_files/figure-html/unnamed-chunk-5-1.png"] = "New York county poverty-count estimates plotted against their relative margins of error.",
  ["week-03_files/figure-html/unnamed-chunk-6-1.png"] = "New York county poverty-count estimates versus relative margins of error, colored by reliability category.",
  ["week-03_files/figure-html/unnamed-chunk-7-1.png"] = "The same county poverty estimates and relative margins of error, with all points colored blue to illustrate fixed styling.",
  ["week-03_files/figure-html/unnamed-chunk-8-1.png"] = "Poverty-count estimates for New York counties, with error bars showing ACS margins of error.",
  ["week-03_files/figure-html/unnamed-chunk-9-1.png"] = "Poverty-count estimates with error bars for the 15 New York counties with the largest relative margins of error.",
  ["week-03_files/figure-html/unnamed-chunk-10-1.png"] = "County poverty-count estimates versus relative margins of error, split into panels by reliability category.",
  ["week-03_files/figure-html/unnamed-chunk-17-1.png"] = "New York county poverty-count changes between 2014–2018 and 2019–2023, showing significant changes with uncertainty intervals.",
  ["fig-significant-change-1.png"] = "Philadelphia census tracts with significant poverty-rate increases or decreases between 2006–2010 and 2013–2017; bars show percentage-point changes and 90% uncertainty intervals.",
  ["income-map-1.png"] = "Philadelphia census tracts shaded by median household income in the 2019–2023 ACS; gray denotes missing estimates.",
  ["stations-map-1.png"] = "Indego station points over Philadelphia census tract boundaries using the saved station snapshot.",
  ["spatial-operation-diagram-1.png"] = "Two overlapping circles illustrating spatial set operations; colored areas show each result against the original gray outlines.",
  ["nearest-distance-map-1.png"] = "Philadelphia tracts shaded by straight-line distance from their centroid to the nearest Indego station; white points mark stations.",
  ["station-buffer-1.png"] = "Dissolved half-mile buffers around Indego stations over Philadelphia tract boundaries.",
  ["coverage-map-1.png"] = "Philadelphia tracts shaded by the proportion of their area within half a mile of an Indego station; area coverage does not measure residents served.",
  ["challenge-map-1.png"] = "Low-income Philadelphia tracts with centroids more than half a mile from Indego, highlighted in orange with stations in blue.",
  ["farthest-low-income-chart-1.png"] = "Up to 15 low-income tracts ranked by distance to the nearest Indego station, with color indicating income-estimate reliability.",
  ["compare-access-definitions-1.png"] = "Counts of low-income tracts without access under different spatial definitions, showing how the chosen rule changes the count.",
  ["fig-income-rent-1.png"] = "Invented practice data plotting monthly rent against annual household income, with a fitted regression line.",
  ["fig-residual-check-1.png"] = "Residuals versus fitted monthly rents for the invented practice data, with a horizontal zero-reference line."
}

function Image(image)
  if image.attributes["fig-alt"] or image.attributes["alt"] then return image end
  for suffix, description in pairs(descriptions) do
    if image.src:sub(-#suffix) == suffix then
      image.attributes["fig-alt"] = description
      return image
    end
  end
  return image
end
