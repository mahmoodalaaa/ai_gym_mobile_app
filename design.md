# Design System Specification: Kinetic High-End Fitness

## 1. Overview & Creative North Star
This design system is built to transform a standard fitness utility into a premium, editorial experience. We are moving away from the "cluttered dashboard" trope and toward a philosophy we call **"The Focused Athlete."**

The **Creative North Star** for this system is **High-Octane Minimalism.** This is achieved through extreme typographic contrast, a palette that mimics a high-end darkened gym environment, and a layout strategy that favors "breathing room" over information density. We break the traditional grid through intentional asymmetry—using large-scale display type that overlaps background imagery and container-less lists that rely on negative space for structure.

## 2. Colors
Our palette is rooted in a deep, nocturnal base to minimize eye strain and maximize the "pop" of our signature action color.

* **Background & Surface:** The core is `#131313` (Background). We create depth by layering.
* **Primary Action:** `#FF6B00` (represented in `primary_container`). This is our "Heat" color. Use it sparingly to guide the eye toward the single most important action on the screen.
* **The "No-Line" Rule:** Under no circumstances should 1px solid borders be used to section off content. Boundaries must be defined through background shifts. For example, a card sitting on the `surface` (`#131313`) should use `surface_container_low` (`#1c1b1b`) to create a soft, natural edge.
* **The "Glass & Gradient" Rule:** To provide a "soul" to the UI, use subtle linear gradients on primary CTAs (transitioning from `primary` to `primary_container`). For floating elements like navigation bars or status overlays, apply **Glassmorphism**: use `surface_container_high` at 60% opacity with a 20px-30px backdrop blur.
* **Surface Hierarchy:**
* **Lowest:** Base background.
* **Low:** Secondary sections (e.g., list backgrounds).
* **High/Highest:** Interactive cards and active state containers.

## 3. Typography
We use **Manrope** for its technical precision and modern, athletic feel. The hierarchy is designed for "Editorial Impact."

* **Display & Headline:** These are your "Statement" tiers. Use `display-lg` for achievement numbers or motivational headers. Allow these to be bold and aggressive.
* **Title:** Used for workout names and navigation headers. It provides the "functional" structure.
* **Body:** `body-md` is our workhorse. Ensure ample line-height (1.5x) to maintain the premium, "airy" feel.
* **Contrast as Utility:** Use `on_surface_variant` (the muted tone) for secondary information like "12 Tutorials" or "60 Minutes" to ensure the `on_surface` (white/off-white) titles remain the focal point.

## 4. Elevation & Depth
In this design system, depth is a feeling, not a shadow.

* **Tonal Layering:** Instead of "raising" a card with a shadow, "sink" the background. Place a `surface_container_lowest` card inside a `surface_container` section. The subtle shift in charcoal tones creates a more sophisticated sense of hierarchy than a traditional drop shadow.
* **Ambient Shadows:** If a "floating" element (like a FAB or a modal) requires a shadow, it must be a "Glow Shadow." Use the `primary` color at 10% opacity with a blur radius of 40px. This mimics the light of a screen in a dark room rather than a physical object casting a shadow.
* **The "Ghost Border":** If accessibility requires a container edge, use the `outline_variant` token at 15% opacity. It should be barely felt, only perceived.
* **Glassmorphism:** Use for persistent elements (Bottom Nav). It allows the vibrant workout imagery to bleed through the UI, making the app feel like a single, cohesive environment rather than a series of disconnected screens.

## 5. Components

### Buttons
* **Primary:** Filled with `primary_container` (#FF6B00). Use `xl` (1.5rem) corner radius. Typography: `title-sm` (Bold).
* **Secondary:** Glass-style. `surface_variant` at 20% opacity with a `title-sm` label in `on_surface`.
* **Tertiary:** No container. Use `primary` text with an icon.

### Cards
* **Editorial Cards:** Use large imagery with a `surface_container_highest` overlay at the bottom.
* **Stat Cards:** Use `surface_container_low`. No borders. Use `display-md` for the primary metric to create a clear "data-first" hierarchy.
* **Roundedness:** All cards must use `xl` (1.5rem) or `lg` (1rem) rounding. Avoid sharp corners to maintain the "premium tech" aesthetic.

### Lists & Navigation
* **List Items:** Forbid the use of divider lines. Use `spacing.6` (2rem) between list items to let the content breathe.
* **Bottom Navigation:** Use a Glassmorphic blur container. The "Active" state should use the `primary_container` color for the icon, with a subtle 4px "active" dot below it.

### Input Fields
* **Text Inputs:** Use `surface_container_highest` as the fill. The label should be `label-md` floating above the input in `on_surface_variant`. Avoid boxes; use a bottom-only "Ghost Border" to maintain a minimal footprint.

## 6. Do's and Don'ts

### Do:
* **Use Intentional Asymmetry:** Let a headline run onto two lines even if it fits on one, creating a more editorial, rhythmic feel.
* **Embrace Negative Space:** If a screen feels crowded, remove a container rather than shrinking the text.
* **Use Imagery as Texture:** High-quality, desaturated photography of athletes should be used as a backdrop for `surface` elements.

### Don't:
* **Don't use pure black (#000000):** Use our `background` (#131313). Pure black feels "dead" and loses the depth of our tonal layering.
* **Don't use 1px dividers:** They clutter the "Focused Athlete" experience. Use vertical space.
* **Don't over-use the Orange:** If everything is orange, nothing is important. Reserve #FF6B00 for the final "Commit" or "Start" actions.
* **Don't use "Standard" Shadows:** Avoid the muddy grey drop shadows found in default UI kits.