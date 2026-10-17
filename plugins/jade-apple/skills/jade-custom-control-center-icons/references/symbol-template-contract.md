# SF Symbols v4 Template Contract (Custom Symbols)

> This data and these behaviors come from existing practice; the original environment versions were not fully recorded. They are not a guarantee for every OS version. Treat the values as starting points and revalidate them on the target SDK, host, and device. Run commands from the installed skill root.

> This document expands Step 4 of [SKILL.md](../SKILL.md). All conclusions come from the measured behavior of `actool`,
> not from copying Apple's documentation — Apple has **not** published the rule that "only Template Version 4 is rendered by Control Center".

## 1. Why the Template Skeleton Determines Everything

The same glyph path, with only the outer skeleton changed:

| Skeleton | `actool` accepts | Artifact `Template Version` | macOS AppKit | iOS 18+ Control Center |
|------|---------------|------------------------|--------------|------------------|
| Hand-rolled "minimal skeleton" (`<style>` + Baseline/Capline + one `Regular-M`) | ✅ | **0** | ✅ Normal | ❌ **Does not render** |
| Official v4 skeleton (`Notes` version declaration + full `Guides` + S/M/L glyph groups + margin per scale) | ✅ | **4** | ✅ Normal | ✅ Renders |

**Inference**: `actool` reporting no error, macOS being able to render, and the in-app test page looking normal — **none of these three things can prove** that Control Center can display it.
Compilation evidence includes the `Template Version` in the artifact; end-to-end still needs confirmation on a real device (see [verification.md](verification.md) for how to read it).

## 2. Canvas and Coordinate System

| Item | Value |
|----|-----|
| Canvas | `width="3300" height="2200"` (SVG user units) |
| y axis | **Downward** (standard SVG); inside a glyph group, **negative y is above the baseline** |
| Typesetting reference | The template itself states `Typeset at 100 points` |
| Unit conversion | **1 unit = 1 pt at a 100 pt design**; at compile time it is scaled proportionally by `Reference Point Size` |
| Cap height | `70.459` units |
| Weight/scale column | The official Regular column origin is `x = 1392.62` |

The unit conversion is verifiable: `70.459 × (17/100) = 11.97803`, which matches the `Capline: 11.97803` in the `actool` artifact
(`Reference Point Size: 17`) exactly. **Do not** treat it as `1/100 pt` — that would make the glyph two orders of magnitude too small.

## 3. Required Structure Checklist

| Element | Requirement | Purpose | What happens when missing |
|------|--------|------|--------------|
| `<style>` classes for the three rendering modes | Required | Determines the fill color in each rendering mode | Layers have no fill color in non-monochrome modes |
| `<text id="template-version">Template v.4.0</text>` inside `<g id="Notes">` | **Required (the most critical item)** | **The source of `Template Version = 4`** | Falls back to v0 → Control Center does not render |
| `<text id="descriptive-name">` | Recommended | Affects only metadata/readability | No functional effect |
| `<line id="Baseline-{S,M,L}">` / `Capline-{S,M,L}` | Required | Typesetting guides | `missing a baseline guide for Baseline-S` |
| `<g id="Regular-{S,M,L}">` glyph groups | Required | Glyphs for each scale | `must have a glyph for Regular weight Medium size` |
| `<line id="left/right-margin-Regular-{S,M,L}">` | Required | **v4's fixed margins** | `missing margin guides: … fixed margins on Regular-M or Regular-S are required` |
| Layer `<path class="monochrome-1 multicolor-1:tintColor hierarchical-1:primary">` | Required | The three rendering modes | Some modes render empty |

### Grid Constants (identical to the official template)

```
Regular column origin x        = 1392.62          → also the x of the left margin guide
Baseline-S / M / L     = 696 / 1126 / 1556
Capline-S / M / L      = 625.541 / 1055.54 / 1485.54   (Baseline − 70.459)
margin guide half-height       = 59.67             → y1 = Baseline − 59.67, y2 = Baseline + 59.67
right margin x         = 1392.62 + glyph bounding box width
```

The glyph group's `transform` places the **local origin** at `(1392.62, Baseline-{S,M,L})`, and the `<path d="...">`
is written in local coordinates.

> ⚠️ **Do not assume that "margin simply equals origin + graphic width" and that everything is therefore fine**. The official convention is: the left guide falls on the glyph group's
> local origin, and the right guide falls on the glyph's right boundary — this holds only when **the graphic has already been normalized to `minX = 0`**.
> If the graphic is offset in x (for example `minX = −2.7`), the margin is computed from **outside** the graphic,
> and the horizontal typesetting boundary disagrees with the actual graphic. **Add a "visible bounding box normalization" step in the generator** (`minX → 0`,
> recomputing the margins at the same time); do not make up for it by hand-tuning guide positions.

### What to Do When the Reference Symbol File Is Gone: Measure the System Symbol Directly

SF Symbols.app's `Export Symbol` writes the SVG to `TemporaryItems`, and **that directory is cleaned up by the system at any time**;
a path the user referenced with `@` is very likely already invalid. Do not get stuck because of that — **just measure the system symbol itself**;
what you get is the same geometry, and it is closer to "how the system actually draws it":

1. Fetch the symbol with `NSImage(systemSymbolName:) + .withSymbolConfiguration(pointSize:)`;
2. Draw onto a **white-background** bitmap (a dark background inverts the threshold decision; this was hit in practice);
3. Scan the ink runs row by row / column by column, and convert pixels back into template units (`k = 100 / pointSize`);
4. `img.alignmentRect.minY` gives the baseline position, so every y can be written as "relative to the baseline".

After measuring, extra scans can be combined to estimate: outer frame size, edge thickness, corner radius, badge center/radius/gap, and the center and radius of each part.
These extra scan results are not columns that the bundled measurement tool outputs directly in full. Scanning a few key y values once more confirms curved outlines such as **rounded shoulders / slanted edges** (for example, the viewfinder's widths at y=83/79/75/73
are 26.8 / 39.7 / 46.9 / 50.9 respectively → the shoulders are round, not pointed).

> When no vector file is available, **do not estimate by eye**: the same set of scan numbers is enough to quantify a difference that
> determines how it looks, such as "rounded square vs rounded-shoulder trapezoid". For stroked shapes, prefer
> `roundedPolylinePath(_:cornerRadius:)` + `copy(strokingWithWidth:lineJoin: .round)`,
> and do not use sharp-cornered trapezoids — sharp points are extremely harsh at small sizes.

## 3.1 Vertical Direction: the Visible Center Must Land on the **Cap Box Center**

What goes wrong more easily than margins is the **vertical position**. The system places the graphic into the control using the symbol's **alignment rectangle**
(`alignmentRect`, always the cap box, **70.459** high), **not** the path origin. Therefore:

> **The center of the visible bounding box must land on `capHeight / 2`.** Otherwise the icon sits as a whole too high or too low inside the control.

This one produces no error, and `actool` does not warn either — it is visible only on a real device. Measured case: the visible center of a hand-made camera symbol
landed at **−16.45** (**below** the baseline), 51.7 units away from the cap box center, and a device screenshot showed it **sank by 17.9% of the circle diameter**;
while the notes symbol from the same batch had its visible center at +32.85 (only 2.4 from the center) and looks centered.

**Recommended approach**: in the generator, **after all Boolean combinations are complete**, apply one unified layout transform (do not translate part by part):

```text
x′ = s × (x − visibleCenterX) + s × visibleWidth / 2      // also normalizes minX to 0
y′ = s × (y − visibleCenterY) + capHeight / 2
```

This way scaling **does not** push the graphic away from the target center again; pair it with an assertion (visible center = capHeight/2) to pin it down.
When previewing, draw the cap box and the baseline so that centered or not is visible at a glance.

### 3.2 Geometric Centering ≠ Looking Centered: Leave "Visual Weight Compensation" for Badged Symbols

**Geometric centering is achievable, but a composition such as "main body + small lower-right badge" still looks shifted left** —
the main body fills the left ~82%, the right side holds only a smaller badge, and the upper-right corner is left empty.
Measured: the ink-mass center of `camera.badge.ellipsis` is **+2.5% to the right** of the bounding box center,
and that of `text.pad.header.badge.plus` is **−1.7%** — **Apple tuned each one by eye**, and this cannot be derived geometrically.

Approach: shift the graphic **right by `2Δ`** inside the typesetting box (Δ = `bias × graphic width`), so that the graphic center ends up Δ to the right of the box center.
It lands on the **margin**: the typesetting box = `[left guide, right guide]`, the graphic's right edge presses against the right guide, and `2Δ` is left over on the left side.

> ⚠️ Therefore the argument to `marginLines` must be **the right edge `maxX`**, and must not be "the width":
> once the graphic is not at `minX = 0`, the right guide computed from the width falls **inside the graphic**.
> Empirical value `bias ≈ 0.04` (4% of the width); at the same time, use an assertion to pin down "compensation present but not excessive".

## 4. Margin Is a Hard v4 Requirement, and It Must Match the Glyph

- Left guide `x = 1392.62` (the glyph group origin).
- Right guide `x = 1392.62 + glyph maxX`; this equals origin plus width only when `minX = 0`.
- All three scales are required, but supply margins **only for weights that actually exist**.

`actool`'s two corresponding errors:

```
missing margin guides: interpolatable margins on Ultralight-S, Regular-S, and Black-S,
                       or fixed margins on Regular-M or Regular-S are required
has interpolatable margin guides for missing glyphs: margins on Ultralight-S, Regular-S,
                       and Black-S but glyphs are missing
```

The second one is exactly the pitfall of "referencing the official template's Ultralight/Black margins without drawing those weights".

## 5. Paths and Fills: nonzero Winding + True Boolean

**Symbol templates fill by nonzero winding, and `fill-rule="evenodd"` is ignored (measured).**

Therefore:

- "Cut-outs" can only be expressed through **subpath winding**: outer contour counterclockwise, holes clockwise.
- **Do not** use the implicit-erasure trick of "starting another reversed path to erase the element beneath it". It relies on the undocumented behavior that "multiple independent `<path>`
  elements get merged when their winding is computed".
- **Use a true Boolean for the difference** (`CGPath.subtracting(_:)`, macOS 13+ / iOS 16+); do not merely merge the subtrahend's outline in reverse:

  > Once the subtrahend **extends beyond the host**, that region has winding ∓1 ≠ 0 under the nonzero rule and is **filled solid instead**.
  > The typical victim is the cut-out that "slices a notch along the edge of the graphic" (clear plate) — it must cross the edge band to cut the notch.
  > Symptoms: a solid slanted band / round blob appears beside the graphic, or a glyph that should be solid is hollowed into a hole.

- The original generator's path combination concatenates while preserving winding; this is not a general Boolean union. Use Boolean operations when a truly merged boundary is required.
- **Do not re-orient the winding of Boolean results or font glyphs by "nesting depth"**:
  - A Boolean result already has the correct winding (measured: outer CCW / hole CW);
  - **Font glyphs are overlapping contours** — the strokes of one character may consist of several same-direction, partially overlapping contours,
    and depth-based classification gets their parity wrong; one forward and one reverse exactly cancel the overlap region into a hole;
  - **Preserving the winding** when reading a path in is enough.
- If depth classification really is required, the representative point must be taken as a point "**tight against the boundary and inside this contour's material**".
  Taking the centroid fails: for a ring (outer frame with the inner frame cut out), the outer contour's centroid falls exactly in the inner hole, both contours are classified at the same depth,
  and after normalization **the whole ring is filled solid**.
- Add **generation-time sampling self-checks**: assert at key positions that "what should be filled is filled and what should be empty is empty" (ring band center, clear region, badge center).
  Abort on failure and write no file. This layer catches geometry errors that the compiler cannot catch.
- Each layer ultimately emits only **one** `<path>`; there is no implicit erasure across elements.

## 6. Build a Symbol with [the Template](../assets/symbol-template.svg)

The skeleton file has three placeholders:

| Placeholder | What to fill in |
|--------|--------|
| `{{SYMBOL_NAME}}` | The symbol name (also the `.symbolset` directory name and the name used by `Image("...")`) |
| `{{GLYPH_PATH_DATA}}` | The glyph path's `d` data, in **local coordinates** (origin at the left end of the baseline, negative y upward); identical in all three places |
| `{{RIGHT_MARGIN_X}}` | `1392.62 + glyph maxX` (equal to the width when normalized to minX = 0); identical in all three places (both x1 and x2 of every right margin must be replaced) |

Then store the result as `<shared resource directory>/Xxx.xcassets/<symbol name>.symbolset/<symbol name>.svg`,
together with a Contents.json:

```json
{
  "info" : { "author" : "xcode", "version" : 1 },
  "symbols" : [ { "filename" : "<symbol name>.svg", "idiom" : "universal" } ]
}
```

Note that it is the **`symbols`** array (Symbol Image Set), not `images` (an ordinary imageset).

> Once the project has a generation script, write this logic into the script, and **do not** hand-edit the SVG on disk — hand-editing bypasses the sampling self-checks in Section 5.

## 7. What the Official Template Also Allows (as Needed, Do Not Fill It Out Mechanically)

- At most **9 weights × 3 scales**. The checker bundled with this skill supports only the Regular single-layer profile and does not cover every legal multi-weight or layered layout. Do only the weights you need; any extra weight you add must also supply its corresponding margin, otherwise it triggers the second error in Section 4.
- The scales may be **the same geometry** (when there is no derivable optical variant, reusing it proportionally is enough), but all three scales must be present.
- Layering is possible for hierarchical / multicolor: just give different `<path>` elements different `hierarchical-N` / `multicolor-N:tintColor`
  classes. With only one layer, `-1` is enough.
- Positive/negative shapes: in `<style>`, the `-0` class carries `opacity:0` + `-sfsymbols-clear-behind:true`, used for layers that "erase the background".

## 8. `actool` Errors → Fixes Quick Reference

| Error | Cause | Fix |
|------|------|------|
| `missing a baseline guide for Baseline-S` | Missing Baseline-S/M/L or Capline-S/M/L | Add all six guides |
| `must have a glyph for Regular weight Medium size` | Missing the `Regular-M` glyph group | Add `Regular-{S,M,L}` |
| `missing margin guides: … fixed margins on Regular-M or Regular-S are required` | Missing margin guides | Add `left/right-margin-Regular-{S,M,L}` for each scale |
| `has interpolatable margin guides for missing glyphs: … but glyphs are missing` | Margins do not match **the glyphs actually supplied** | Keep only the margins for weights you actually drew |
| No error but Control Center is blank | The artifact is `Template Version 0` | Complete the `Notes` block (especially `template-version`) → recompile → recheck the artifact's version number |
| The graphic becomes a solid block / the badge smears into a blob | Subpath winding is wrong, or `fill-rule` is ignored | Switch to true Boolean + sampling self-checks (Section 5) |
| A solid slanted band / round blob appears beside the graphic | The difference used a fake Boolean of "merging the subtrahend's outline in reverse", and the part protruding outside the host was filled solid by nonzero | Switch to `CGPath.subtracting` (Section 5) |
| A glyph that should be solid is hollowed into a hole | The winding of a glyph with **overlapping contours** was re-oriented by nesting depth | Preserve the winding when reading the path in (Section 5) |
| The ring (outer frame cut out) is filled solid as a whole | The depth decision used the contour's **centroid**, and the centroid falls into the inner hole | Change the representative point to sit tight against the boundary (Section 5) |
| The icon is noticeably smaller/larger than system icons in the same row | The geometry was estimated by eye and not converted into template units | Reverse-engineer the system symbol with Section 9 |

## 9. Reverse-Engineer System Symbol Geometry into Template Units (the Only Way to Make It "the Same Size as a System Symbol")

A hand-made symbol that "looks too big/too small" cannot be tuned by eye. The reliable approach is to **convert the reference system symbol's geometry into template units** and then compare.

**① Obtain reference geometry.** Use it only as a measurement reference; do not redistribute restricted artwork. The SVG exported by SF Symbols.app → `Export Symbol` is an ordinary SVG, and the coordinates in it are the "reference units".

**② Determine the ratio.** Render the same symbol, measure the ink box, and divide it by the SVG's ink box (measured values are often integers, such as 5.0):

```swift
let symbol = NSImage(systemSymbolName: "doc.text", accessibilityDescription: nil)!
    .withSymbolConfiguration(.init(pointSize: 1600, weight: .regular, scale: .medium))!
// Draw onto a white canvas → measure the ink box (points); ratio = ink box (points) / ink box (reference units)
```

**③ Determine the baseline (the key step).** For a symbol image, `NSImage.alignmentRect` gives exactly the **alignment rectangle**:
its height is always the cap height, **70.459 template units**, and **its bottom edge is the baseline**.

```swift
let baselineFromBottom = symbol.alignmentRect.minY * (100 / pointSize)  // template units
let capline = (symbol.alignmentRect.minY + symbol.alignmentRect.height) * (100 / pointSize)
// ink box bottom − baseline = descender; ink box top − baseline = ascent
```

Hence `template units = reference units × ratio`; record vertically as "baseline = 0, y upward", and negate y when writing out the SVG.

> Identity for validation: `Capline / ReferencePointSize` is always `0.70459` (the cap height ratio).
> Measuring `long.text.page.and.pencil` (Regular / Medium) with this method gives:
> ink box **107.1 × 122.6**, ascender **87.58**, descender **35.0**,
> page box **82.12 × 104.66**, border thickness 7.85, outer corner radius 15.2, pencil **50°**.

**④ Produce a comparison image, then adjust.** Draw the hand-made graphic and the system symbol into same-size canvases at the **same baseline and the same ratio**;
then produce one extra side-by-side image "rendered at the real point size" — Control Center is actually only 17–20pt, and an enlarged image hides blur at small sizes.

**⑤ Do not render only the in-memory object.** The preview must render **the SVG path data that will actually be written to disk**, otherwise divergences such as
"the preview looks good but the artifact is wrong" stay hidden.

**⑥ When you want a decorative element to "occlude" the glyph, first work out clearly whether that is achievable.**
"Glyph centered" and "occluded by the neighboring element" are frequently **mutually exclusive**: occlusion happens at the glyph's edge, and the edge is usually
**tangent** to the occlusion boundary, so only an extremely thin sliver can be shaved off; and if you move the glyph toward the occluder, the area the cut removes cannot compensate for the displacement
(the visible bounding box center shifts monotonically with the displacement). Do not judge "is it obvious enough" by eye — measure three numbers:
the shaved region's **span along the boundary direction**, its **maximum lateral depth**, and the **area fraction** removed.
Then write "must cut this deep" as a **generation-time hard constraint** (such as "the deepest point extends ≥ 3 units past the boundary"), otherwise the next parameter change silently reverts it to the original.
