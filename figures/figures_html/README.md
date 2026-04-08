# HTML Figures for Reveal.js

This folder stores reveal.js / Quarto figures that are built from HTML and SVG
instead of static image exports.

## Folder layout

- `icons/`: reusable SVG icons and small visual assets
- `components/`: reusable HTML snippets that can appear in multiple figures
- `examples/`: complete figure examples that can be included as one block

## Icon naming

Store one object per file and use short, stable names. For example:

- `cow.svg`
- `fox.svg`
- `candle.svg`
- `pineapple.svg`

This keeps figure code easy to read because the file name matches the object
shown on the slide.

## Recommended workflow

1. Put small reusable assets in `icons/`.
2. Put repeated visual blocks in `components/`.
3. Build one figure in `slides.qmd` by including several components.
4. If a whole figure becomes stable, save it in `examples/` and include it as
   one file.

## Important path rule

When an HTML file in `components/` or `examples/` references an image with
`src=`, write the path relative to the Quarto source file that includes it.

For example, because `presentation/slides.qmd` includes these files, image paths
inside the HTML snippets should usually start with:

```html
../figures/figures_html/...
```

## Include examples

Include a reusable component:

```markdown
{{< include ../figures/figures_html/components/object-card-blue.html >}}
```

Include a complete figure:

```markdown
{{< include ../figures/figures_html/examples/exp1_trial_overview.html >}}
```
