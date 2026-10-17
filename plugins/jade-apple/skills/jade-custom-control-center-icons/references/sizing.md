# Sizing: how to draw a custom symbol at the "correct size"

> The data and behavior come from prior practice; the original environment versions were not fully recorded, and this is not a guarantee for every OS version. Treat the values as a starting point, and revalidate them on the target SDK, host, and device. Run the commands from the installed skill root.

> This reference answers "**how big to draw**". For placement (centering, optical-center compensation), see
> [symbol-template-contract.md](symbol-template-contract.md) §3.1 / §3.2;
> for geometric back-solving, see §9 of the same file. These three things are independent of each other — do not adjust them mixed together.

## 0. The Principle in One Sentence

**In this template workflow, do not rely on the Control Center host to auto-fit resources and repair the resource geometry.**

```
rendered size = design units × pointSize / 100
```

So "size" is **entirely determined by geometry**; do not rely on host-side modifiers to compensate for problems in the resource. Conversely, if you want the icon to get bigger or smaller, **change the geometry first**. (Prior practice compiled it into a real bundle with `actool` and measured it through the same pipeline the system uses: the ink bounds rendered by the custom symbol matched the reference symbol item by item — 107.10 × 122.74 vs 107.16 × 122.50.)

## 1. First, Disprove Four Common Misconceptions

| Misconception | Reality |
|------|------|
| "The system will scale the symbol into the control, so drawing it smaller does not matter" | **It will not.** There is no fit-to-box: the size you draw is the size you get |
| "You can set the size with `.font()` / `.imageScale()` / a fixed frame" | Control Center buttons are rendered by the **system**; these do not take effect |
| "You can compensate with `.scaleEffect` / `.offset`" | **Do not** use host-side transforms to fix problems inside the resource: the same symbol also appears in other hosts such as the Lock Screen and Action Button, and it drifts again there. If you need to change it, change the geometry |
| "Eyeballing 'about the same size' is good enough" | Eyeballing between two icons of different shape complexity is completely unreliable (see §4). You can only **compare geometry** against a reference symbol |

> Conclusion: set the size in the generator first, then measure it with a tool. **Do not** look for a workaround on the SwiftUI side.

## 2. The Correct Method: Four Steps

**Step 1 — Choose a reference.** Pick an Apple symbol of the **same kind** (same shape kind, same complexity kind: outline with outline, solid with solid).
§3 of this document provides a measured table you can consult directly.

**Step 2 — Measure the reference.** Use [scripts/measure-symbol.swift](../scripts/measure-symbol.swift):

```bash
swift scripts/measure-symbol.swift \
  system camera camera.badge.ellipsis text.pad.header.badge.plus
```

**Step 3 — Draw your own geometry into that magnitude.** Use **one** scale knob (for example `overallScale`), and scale uniformly in the **final layout step**. For the three "musts", see §7.

**Step 4 — Measure the product and compare side by side.** Compile it into a real bundle, then measure once more to confirm where it lands:

```bash
PROBE_ROOT="$(mktemp -d)"
mkdir -p "$PROBE_ROOT/compiled" "$PROBE_ROOT/Probe.bundle/Contents/Resources"
xcrun actool --target-device mac --minimum-deployment-target 15.0 --platform macosx \
  --compile "$PROBE_ROOT/compiled" <catalog.xcassets>
cp "$PROBE_ROOT/compiled/Assets.car" "$PROBE_ROOT/Probe.bundle/Contents/Resources/"
cat > "$PROBE_ROOT/Probe.bundle/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleIdentifier</key><string>example.symbol-probe</string>
<key>CFBundleName</key><string>Probe</string>
<key>CFBundlePackageType</key><string>BNDL</string>
</dict></plist>
PLIST
swift scripts/measure-symbol.swift bundle "$PROBE_ROOT/Probe.bundle" ExampleNewNote ExamplePhotoNote
```

Then produce a side-by-side image at the **same pointSize / same weight / same scale** (use the project's existing preview tooling; this skill ships no artwork generator or preview command).

> Why measure the "product" instead of the "source file": you must inspect the product metadata as well, and only that exposes failures such as a wrong template version, a missing scale, or a mismatched margin —
> failures that "look fine in the source". Measuring only the source is not enough to accept the result; measuring a bundle on macOS also does not prove that the iOS extension is packaged correctly.

## 3. Reference Size Table (Measured Apple System Symbols, Template Units)

`pointSize 1600`, `weight .regular`, `scale .medium`. **1 unit = 1pt at a 100pt design size.**

| Symbol | Ink width | Ink height | Visible center − cap center | Coverage | Ink area |
|------|-------:|-------:|-----------------:|-------:|-------:|
| `square` | 89.94 | 89.88 | 0.0% | 31% | 2472 |
| `circle` | 99.56 | 99.50 | +0.1% | 24% | 2373 |
| `plus` | 80.62 | 80.50 | 0.0% | 20% | 1300 |
| `plus.circle.fill` | 99.56 | 99.50 | +0.1% | **72%** | 7084 |
| `pencil` | 77.75 | 77.19 | −0.2% | 19% | 1137 |
| `doc.text` | 82.19 | 104.62 | 0.0% | 40% | 3411 |
| `text.page` | 82.19 | 104.62 | 0.0% | 37% | 3217 |
| `text.pad.header` | 97.38 | 89.88 | −0.1% | 53% | 4658 |
| `long.text.page.and.pencil` | 107.12 | 122.50 | **−12.7%** | 31% | 4027 |
| `square.and.pencil` | 96.56 | 96.38 | **+4.8%** | 30% | 2766 |
| `camera` | 119.94 | 93.00 | +2.2% | 36% | 4069 |
| `camera.fill` | 119.94 | 93.00 | +2.2% | **80%** | 8904 |
| `photo` | 115.12 | 89.88 | 0.0% | 57% | 5920 |
| `camera.viewfinder` | 95.62 | 95.56 | −0.1% | 40% | 3645 |
| `camera.circle` | 99.56 | 99.50 | +0.1% | 46% | 4519 |
| `camera.badge.ellipsis` | 144.19 | 102.19 | **−4.3%** | 36% | 5354 |
| `text.pad.header.badge.plus` | 118.25 | 99.00 | **−6.5%** | 49% | 5689 |
| `flashlight.on.fill` | 47.88 | 115.38 | +0.1% | 58% | 3182 |
| `timer` | 99.56 | 99.50 | +0.1% | 27% | 2630 |
| `magnifyingglass` | 95.44 | 96.25 | 0.0% | 25% | 2261 |
| `qrcode` | 89.94 | 89.88 | −0.1% | 43% | 3497 |
| `wifi` | 108.62 | 79.88 | +0.8% | 37% | 3191 |
| `bolt.fill` | 68.75 | 108.94 | +0.6% | 35% | 2632 |

**How to use this table:**

- **Width magnitude**: the vast majority fall in **80–120 units**; those with a badge in the lower-right corner are **20–45** wider (the badge outline).
  `flashlight.on.fill` at 47.9 is a narrow, tall counterexample — width is not the only criterion; look at the shape type.
- **Height magnitude**: **77–122 units**.
- **Visible center − cap center**: **symbols without a badge are almost uniformly 0.0%**; those with a lower-right badge are uniformly offset by 4–13%.
  This is the root cause of "copying a badged reference pulls the icon off-center" — its geometry is itself not centered.
  → When using a badged symbol as the reference, **you may copy the size, but you must re-normalize the placement yourself** (see symbol-template-contract §3.1).
- Paired symbols of the "same name, different fill" kind such as `doc.text` / `text.page` and `camera` / `camera.fill` have **exactly the same ink bounds**,
  differing only in coverage — which shows that Apple swaps the fill on **one and the same geometry** rather than drawing a separate set for each. We should do the same when we swap the fill.

## 4. Bounding Box ≠ Visual Weight

The ink bounds of `camera` and `camera.fill` are **exactly identical** (119.94 × 93.00), yet:

| | Coverage | Ink area |
|---|---:|---:|
| `camera` (outline) | 36% | 4069 |
| `camera.fill` (solid) | 80% | **8904 (2.2×)** |

**Therefore:**

- for an outline icon to "look the same size" as a solid icon, it must be **drawn larger**;
- "balancing the visual weight" between two icons compares **ink area**, not width and height;
- conversely, when you think your icon "looks small", measure the ink area first — it may simply be that **the strokes are too thin**, not that the size is too small.

Reference coverage ranges: outline **19–43%**, partially solid **43–60%**, solid **72–80%**.

## 5. Control Center Is a **Circular** Control: Set the Final Size by Fraction of the Circle

Do not look only at absolute units — what is measured here is a circular Control Center button, and it does not represent every control shape or size. Measured from a device screenshot (circle diameter **198px @3x ≈ 66pt**):

| Icon | Ink bounding box | Fraction of circle diameter |
|------|-----------|---------|
| Dazz camera (third party, looks "full") | 100 × 101 px | **50.5% × 51%** |
| DockKit (third party, rather narrow and tall) | 42 × 84 px | 21% × 42% |
| Prior practice `ExampleNewNote` (final) | 147.69 units → about 98 px | **about 49%** |
| Prior practice `ExamplePhotoNote` (final) | 158.56 units → about 105 px | **about 53%** |

**Empirical target: ink width ≈ 48%–52% of the circle diameter.** Conversion relation (at @3x, with Control Center rendering at about 20pt):

```
pixel width ≈ template units × pointSize / 100 × 3
```

The more robust approach is to **measure a device screenshot directly** (see §8); do not rely on the calculation.

> **Shape also affects how large the icon appears**: at the same height, a shape that is **close to square** fills the circle more than a narrow tall shape.
> `long.text.page.and.pencil` is a 107 × 122.5 narrow tall shape, and in a circular control it inherently occupies less area —
> this is part of why "copying it still looked small" early on.

## 6. The Glyph in a Badge Has a **Readability Floor**

At small sizes, a stroke that is less than one pixel is just a blur, **regardless of the "overall size"**:

| Parameter | Empirical floor (measured at 17pt) | In template units |
|------|----------------|---------------|
| Glyph cap height | ≥ 5.4pt | **≥ 32 units** |
| Stroke thickness | ≥ 1pt | **≥ 6 units** |

**Counterexample (a real failure in prior practice)**: the B inside the badge measured only 18 × 24 units = **3.1 × 4.1pt**, and the `.bold` stroke was about **0.5pt** — on the device it "shrank into a blob".
The overall size at that time was in fact about the same as the system camera (width 84 vs 120), so **the problem was not the size at all**.

> **What to do**: write the floor as a **hard constraint at generation time** (`fatalError` if it is not satisfied, and do not write the file),
> do not judge by eye in the preview image — the preview is a 6× enlargement, which happens to hide this problem.
> The corresponding constraint in prior practice: `badge B too small: cap … units, at least 32`.

## 7. Where Scaling Must Be Implemented: Three "Musts"

1. **You must scale uniformly after all Boolean combinations.**
   Scaling part by part changes all of their **relative positions** (holes no longer align with their hosts).
2. **You must scale from the "visible bounding box center"**, and merge it with "aligning to the cap box center" into **one and the same transform**:

   ```text
   x′ = s × (x − visibleCenterX) + s × visibleWidth / 2 (+ optical bias)
   y′ = s × (y − visibleCenterY) + capHeight / 2
   ```

   Multiplying only at the origin by `s` **also changes where the shape sits relative to the baseline** — the larger the scale, the larger the drift.
3. **The geometry self-check runs in base units, and the final readability constraints must additionally run after scaling.**
   Proportions and relative occlusion are checked before scaling; the final minimum glyph and stroke sizes must be re-verified against the actual scale factor and pointSize.

## 8. Final Acceptance: Measure a Device Screenshot

This is the direct way to confirm the "fraction of the circle":

1. Find the diameter of the circular control in the screenshot (the connected region of the dark gray tile);
2. Measure the bounding box of the icon's dark/light pixels;
3. Compute the **fraction** (width/height ÷ diameter) and the **offset** (icon center − circle center, divided by the diameter).

Prior practice found two real problems precisely through this step:

- the camera icon **sank by 17.9% of the circle diameter** (its geometric visible center is not at the cap box center; see symbol-template-contract §3.1);
- the camera icon **occupied only 41% × 35% of the circle**, whereas the reference third-party icon was 50.5% × 51% (the size really was too small).

When measuring, watch the threshold: when the icon is a white outline, thin strokes get **eroded** by the threshold, and the measured width and height come out slightly smaller than the true values —
so **height** is usually more reliable than width (the two ends across the width are often thin tips).

## 9. Anti-Patterns

| Anti-pattern | Why it is wrong |
|--------|----------|
| Using `.scaleEffect` / `.offset` / `.padding` to patch size problems inside the resource | Moving to another host such as the Lock Screen or Action Button drifts again; the problem should be solved in the generator |
| Only adjusting the host-side font size/weight to "change the size" | Control Center is rendered by the system; these do not take effect |
| Eyeballing "about the same size" | Completely unreliable across shape complexity; compare ink area with [measure-symbol.swift](../scripts/measure-symbol.swift) |
| Comparing only bounding boxes, not ink area | The visual weight of outline and solid can differ by 2.2× |
| Looking only at a small-size preview image | The preview is enlarged, which happens to hide "sub-pixel strokes blurring into a blob" |
| Sizing the badge glyph by "it looks like it fits" | There is a readability floor (cap ≥ 32 units, stroke ≥ 6 units); write it as a hard constraint |
| Scaling/translating part by part to reach the size | Relative positions change; apply one uniform transform after all Boolean combinations |
| Multiplying the scale factor at the origin | It also changes the position relative to the baseline; the larger the scale, the larger the drift |
| Comparing "visible center" against a badged reference symbol | Such a reference is itself offset by 4–13%; the size can be copied, but the placement must be normalized yourself |

## 10. Ordinary imageset Icons (macOS Menu Bar): the Same Method, a Different Unit System

Menu bar status icons go through an **ordinary `imageset`** (a template SVG + `template-rendering-intent: template`),
**not** a symbolset. Therefore:

- the unit is simply **pt**: there are no template units, no cap box, and no `alignmentRect` — the table in §3 **does not apply**;
- but the **method is exactly the same**: first measure a same-screen reference, then set the geometry, and finally measure the **packaged product**.

**Size baseline (measured)**: you can take **16 × 16pt** as the starting point for a similar composition.
A same-screen third-party icon measured **32×32px @2x = 16×16pt** on 2026-10-07; this is not a system-mandated size for every menu bar icon.

**Prior design targets (not system requirements)**:

| Item | Value | Note |
|----|----|------|
| Glyph outer frame | **16 × 16pt square** | Draw the canvas at 18×18pt, leaving 1pt on each side |
| Canvas occupancy | **≥ 88%** | "Fill the area you can fill" |
| Corner radius | side length × **22.5%** | ≈ the macOS squircle look; when the side length changes the radius must follow, so do not hardcode it |
| Border | side length × **11.25%** | Same as above; give it proportionally |

**Counterexample (a real failure)**: one version drew the glyph as a **13.80 × 15.20pt** tall narrow rectangle (aspect ratio 0.91, occupying only 77% × 84% of the 18pt canvas), and on the device it looked "not filling the area, too thin".
**The normalization math was not wrong** (`fittedRect`'s contain/centering unit tests were all green); what was wrong was **the glyph geometry itself**.

> ⚠️ **Correct normalization math ≠ correct glyph size.** The former keeps the icon from jittering and its footprint constant; the latter keeps the icon looking good —
> they are two different things, and **each needs its own test**. This time the problem slipped all the way to the device precisely because the tests covered only `fittedRect`, and the glyph geometry went unchecked.
> The assertions added later: square / side ≈16pt / centered / occupies at least 88% of the canvas.

**Acceptance command** (take the image from the **packaged App**, not from the source SVG):

```swift
let bundle = Bundle(path: "…/Example.app")!
let image = bundle.image(forResource: "MenuBarIcon")!   // use this API for a named image from the asset catalog
// then draw once more through the same contain logic as MenuBarIconCanvas.fittedRect, and measure the final visible glyph
```

> **Do not** touch a fixed canvas (such as 20×18pt) — it keeps the menu bar footprint from jittering; the only thing to change is **the glyph inside** the canvas.
