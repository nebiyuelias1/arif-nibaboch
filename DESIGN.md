---
name: LitLoop
description: A warm, literary operating system for book clubs.
colors:
  ink-navy: "#22324a"
  primary-contrast: "#ffffff"
  bookplate-gold: "#d39a3e"
  accent-contrast: "#1a202c"
  parchment: "#f7f3ee"
  paper-white: "#ffffff"
  iron-gall: "#1f2430"
  soft-graphite: "#4b5563"
  faded-marginalia: "#6b7280"
  deckle-edge: "#e4ded6"
typography:
  display:
    fontFamily: "Playfair Display, Georgia, serif"
    fontSize: "2.5rem"
    fontWeight: 400
    lineHeight: 1.1
  headline:
    fontFamily: "Noto Sans Ethiopic, Inter, sans-serif"
    fontSize: "1.5rem"
    fontWeight: 700
    lineHeight: 1.25
    letterSpacing: "-0.01em"
  title:
    fontFamily: "Noto Sans Ethiopic, Inter, sans-serif"
    fontSize: "1.25rem"
    fontWeight: 700
    lineHeight: 1.25
    letterSpacing: "-0.01em"
  body:
    fontFamily: "Noto Sans Ethiopic, Inter, sans-serif"
    fontSize: "1rem"
    fontWeight: 400
    lineHeight: 1.5
  label:
    fontFamily: "Noto Sans Ethiopic, Inter, sans-serif"
    fontSize: "0.75rem"
    fontWeight: 600
    lineHeight: 1
    letterSpacing: "0.05em"
rounded:
  lg: "8px"
  xl: "12px"
  "2xl": "16px"
  "3xl": "24px"
  full: "9999px"
spacing:
  xs: "4px"
  sm: "8px"
  md: "16px"
  lg: "24px"
  xl: "32px"
  "2xl": "48px"
components:
  button-primary:
    backgroundColor: "{colors.ink-navy}"
    textColor: "{colors.primary-contrast}"
    rounded: "{rounded.lg}"
    padding: "8px 16px"
  button-primary-hover:
    backgroundColor: "#1d2b3f"
  button-secondary:
    backgroundColor: "transparent"
    textColor: "{colors.ink-navy}"
    rounded: "{rounded.lg}"
    padding: "8px 12px"
  input-field:
    backgroundColor: "{colors.paper-white}"
    textColor: "{colors.iron-gall}"
    rounded: "{rounded.lg}"
    height: "40px"
    padding: "8px 12px"
  search-field:
    backgroundColor: "{colors.paper-white}"
    textColor: "{colors.iron-gall}"
    rounded: "{rounded.full}"
    height: "48px"
    padding: "14px 16px 14px 56px"
  card-reading:
    backgroundColor: "{colors.paper-white}"
    textColor: "{colors.iron-gall}"
    rounded: "{rounded.3xl}"
    padding: "16px"
  card-book:
    backgroundColor: "{colors.paper-white}"
    textColor: "{colors.iron-gall}"
    rounded: "{rounded.2xl}"
    padding: "16px"
  badge-status:
    backgroundColor: "{colors.parchment}"
    textColor: "{colors.soft-graphite}"
    rounded: "{rounded.lg}"
    padding: "4px 8px"
  nav-bottom:
    backgroundColor: "{colors.paper-white}"
    textColor: "{colors.soft-graphite}"
    height: "64px"
---

# Design System: LitLoop

## Overview

**Creative North Star: "The Circulating Library"**

LitLoop reads as a small circulating library that happens to run itself: a parchment ground, white catalogue cards, ink-navy structure, and a single gold stamp. The library metaphor is functional rather than decorative. Books are catalogued, clubs are registered, and every read is stamped with a date and a place. The mood is warm, literary, and quietly social; the interface never performs bookishness with props.

Density is moderate and task-led. An organizer should see the live read, its meetup, and its RSVP state without hunting, while a reader should feel invited into the next gathering rather than dropped into a feed. Warmth comes from the palette, the Ethiopic-first type, the humane rounding, and real covers. Navy carries structure. Gold marks the read that is currently alive.

This system is explicitly not a generic SaaS dashboard, not corporate library software, not sepia cosplay, and not a social feed. The scheduled read outranks the metric tile, the engagement badge, and the infinite scroll.

**Key Characteristics:**
- Parchment page ground, Paper White sheet surfaces, Ink Navy structure.
- One Bookplate Gold accent, used sparingly as a stamp and a live-read signal.
- Ethiopic-first humanist sans; Playfair Display held in reserve for editorial display.
- Soft radius ladder (8/12/16/24px) with hairline Deckle Edge borders.
- Tonal depth, not shadow-based hierarchy; shadows belong to floating layers.
- Reading-first columns and a mobile bottom navigation built for thumbs.
- Real book covers and club identity carry the imagery.

## Colors

A warm paper-and-ink palette with a single brass-gold accent: quiet enough for everyday club administration, distinctive enough to feel literary.

### Primary
- **Ink Navy** (`ink-navy`): Navigation chrome, primary actions, links, active tab underlines, and structural borders. It is the ink of the system, not its atmosphere.
- **Primary Contrast** (`primary-contrast`): Text and icons on Ink Navy; never used as a page surface.

### Secondary
- **Bookplate Gold** (`bookplate-gold`): The live-read signal. Metadata icons on reading cards, club names in card headers, capacity bars, hover emphasis, and small section labels. It is a stamp, not a wash.
- **Accent Contrast** (`accent-contrast`): Text placed on a solid Bookplate Gold field.

### Neutral
- **Parchment** (`parchment`): The page ground, empty states, inset panels, and quiet wells. Never replace it with pure white for a page background.
- **Paper White** (`paper-white`): Cards, dialogs, dropdowns, inputs, and any surface that should read as a sheet laid on the parchment.
- **Iron Gall** (`iron-gall`): Primary body and heading text. It is a blue-black ink, softer than pure black.
- **Soft Graphite** (`soft-graphite`): Secondary text, authors, descriptions, and supporting metadata.
- **Faded Marginalia** (`faded-marginalia`): Tertiary hints, placeholders, disabled metadata, and empty-state icons.
- **Deckle Edge** (`deckle-edge`): Hairline borders, dividers, table rules, and input outlines.

### Named Rules
**The One Gold Accent Rule.** Bookplate Gold is a stamp, not a surface. Keep it under roughly 10% of any screen. Use it for the live read, small emphasis, metadata icons, and hover; never as a large background fill.

**The Parchment Ground Rule.** Pages sit on Parchment. Sheets, cards, and inputs sit on Paper White. That contrast is the primary depth cue; do not flatten it by making the page white.

**The Navy Is Structure Rule.** Ink Navy carries navigation, primary actions, and links. Body copy stays Iron Gall so the page reads as text first and chrome second.

## Typography

**Display Font:** Playfair Display (with Georgia, serif)
**Body Font:** Noto Sans Ethiopic (with Inter, sans-serif)
**Label Font:** Noto Sans Ethiopic / Inter, same as body, at label scale

**Character:** The interface is set in a humanist, Ethiopic-first sans that stays legible across scripts and feels more like a well-printed catalogue than a startup UI. Playfair Display is declared as the editorial register but is not yet applied in the product; when used, it should feel like a title page, not a costume.

### Hierarchy
- **Display** (400, 2.5rem, 1.1): Editorial moments and future title pages only. Not for interface headings, controls, or body copy.
- **Headline** (700, 1.5rem, 1.25, -0.01em): Page titles such as Discover Books, a club name, a read title, and dialog headings.
- **Title** (700, 1.25rem, 1.25, -0.01em): Card titles, section headings, and reading-session names. The 1rem `title-sm` step is used inside compact cards.
- **Body** (400, 1rem, 1.5): Descriptions, questions, and long-form reading. Secondary body drops to 0.875rem; metadata and hints drop to 0.75rem.
- **Label** (600, 0.75rem, 1, 0.05em, uppercase): Micro-headings such as Meetup Details, club names in card headers, and status labels. Keep uppercase labels short.

### Named Rules
**The Ethiopic-First Rule.** Every sans stack leads with Noto Sans Ethiopic, then Inter. Never reorder the stack or substitute a Latin-first fallback; the multilingual product depends on this order.

**The Two-Register Rule.** Interface text uses the humanist sans. Playfair Display is reserved for display and editorial moments. Never set body copy, controls, or metadata in the serif.

## Layout

The page shell is a centered container with `16px` gutters on small screens, `24px` at `sm`, and `32px` at `lg`, plus `24px` vertical padding. Reading surfaces stay narrow: the home stream uses a `56rem` column, club pages `42rem`, book-read pages `56rem`, and forms `28rem`. The search hero maxes out at `900px`. The page should feel like a reading room, not a full-bleed dashboard.

The desktop header is sticky, `64px` tall, with a `1px` Ink Navy bottom border and a parchment background. Below `640px`, primary navigation moves to a fixed `64px` bottom bar with four equal thumb targets; the top bar reduces to brand and account. Main content reserves `64px` of bottom padding on mobile so the bar never covers the last action.

Card and section rhythm is built on a `4px` base: `8px` inside labels, `16px` card padding, `24px` between related blocks, `32px` between sections, and `48px` between major streams. The catalogue grid runs one column, then two at `450px`, three at `768px`, four at `1024px`, and five at `1280px`, with `24px` gaps. Club carousels use `320px` items. Dense admin tables keep `16px` row padding by default and `12px` in compact mode.

### Named Rules
**The Reading Column Rule.** Club and read surfaces stay between `42rem` and `56rem` wide. Do not stretch a reading page to the full viewport; line length and focus matter more than filling the screen.

**The Thumb Zone Rule.** Below `640px`, primary navigation lives in the fixed bottom bar. Do not duplicate the full desktop menu into a cramped top row.

## Elevation & Depth

Depth is tonal. The parchment page, the white sheet surface, and the `1px` Deckle Edge border do the work that shadows would do in another system. Cards are flat at rest. Menus, dialogs, popovers, and toasts are the only layers allowed to detach, and they use a soft, large-radius shadow to signal that they float above the page.

Observed card shadows (`shadow-xs`, `shadow-sm`, `shadow-card`) are residual softness from the incumbent implementation, not an elevation hierarchy. New work should not add shadow-based rank to cards, panels, or sections; if a shadow is removed and the hierarchy survives, the hierarchy is correct.

### Shadow Vocabulary
- **Overlay lift** (`0 20px 25px -5px rgb(0 0 0 / 0.1), 0 8px 10px -6px rgb(0 0 0 / 0.1)`): Dropdowns, dialogs, popovers, and toasts only.
- **Residual card softness** (`0 1px 2px rgb(0 0 0 / 0.05)`): Existing cards and buttons. Keep it subtle; do not extend it to new surfaces.

### Named Rules
**The Tonal Depth Rule.** Separate surfaces with parchment/surface contrast and hairline borders. Do not introduce shadow-based hierarchy.

**The Overlay Exception Rule.** Shadows belong only to floating layers, where they signal detachment from the page. A card is not a floating layer.

## Shapes

The form language is soft but not bubbly: a deliberate radius ladder rather than one global value. Controls use `8px` (rounded-lg), small cards and chips `12px` (rounded-xl), standard cards and inputs with a card frame `16px` (rounded-2xl), and reading panels, dialogs, and hero banners `24px` (rounded-3xl). Full pills are reserved for the search field, avatars, status dots, and compact filter tabs.

Borders are hairlines in Deckle Edge, never black or high-contrast. Images are clipped to their containers with `object-cover`; covers zoom slightly on hover while the card frame stays still. There are no hard outlines, heavy strokes, or ornamental corner devices.

### Named Rules
**The Soft Corner Rule.** Use the `8/12/16/24px` ladder. Reserve full pills for search, avatars, dots, and compact tabs; do not pill every control.

**The No Hard Outline Rule.** Borders are `1px` Deckle Edge. Dividers use the same hairline. Never introduce black rules or heavy structural strokes.

## Components

### Buttons
- **Character:** Tactile and confident. Buttons press, not bounce; the motion is a small acknowledgement, not a performance.
- **Shape:** `8px` radius (rounded-lg), `1px` transparent border, `8px 16px` padding, `14px` medium label, `0 1px 2px` softness.
- **Primary:** Ink Navy fill with Primary Contrast text. Hover darkens to `#1d2b3f`; active scales to `0.98`; focus-visible shows a `2px` Ink Navy outline with `2px` offset.
- **Secondary:** Transparent fill, Ink Navy text, muted Ink Navy border. Hover shifts the label to Bookplate Gold.
- **Ghost / Icon:** DaisyUI ghost treatment for icon-only controls, with the same focus outline. Negative actions use an error-tinted outline, never a solid red fill.
- **Width:** Forms default to full width; card actions are full width inside the card. Use the `lg` size (`48px` height) for the single primary action on auth forms.

### Inputs / Fields
- **Character:** Calm and legible. A field is a sheet with a hairline edge, not a glowing control.
- **Style:** DaisyUI fieldset with a `14px` medium label, optional `12px` Required marker in error color, Paper White field, `8px` radius, `1px` Deckle Edge border, `40px` height.
- **Focus:** Border shifts to Ink Navy with a `2px` primary ring at 20% opacity. The ring is always visible on keyboard focus.
- **Hints / Errors:** `12px` Faded Marginalia hint below the field; `12px` error text in the semantic error color. Password fields get a quiet eye toggle at 70% opacity.
- **Select / Textarea:** Same field shell. Select uses the native chevron and keeps the same radius and focus ring; textarea uses relaxed line height and a `16px` radius when framed as a card.

### Cards / Containers
- **Book card:** Paper White, `16px` radius, `1px` Deckle Edge border, `16px` padding. A `176-192px` cover sits above the title, with a year badge in the top-right. Hover deepens the border and lifts the title to Ink Navy while the cover zooms to `1.05` over `500ms`.
- **Club card:** Paper White, `16px` radius, `128px` cover band, `16px` body padding. A stretched link makes the whole card clickable at `z-10`; membership buttons sit above it at `z-20`.
- **Reading card:** Paper White, `24px` radius, `16px` padding, `112px` cover, Bookplate Gold metadata icons, and a capacity bar when the read has a maximum. This is the signature container; it should feel like a catalogue card with a live stamp.
- **Panel:** Paper White or Parchment, `16-24px` radius, `1px` Deckle Edge border, `24-32px` internal padding. Section dividers use the same hairline.

### Chips / Tabs
- **Status badge:** `8px` radius, `4px 8px` padding, `12px` medium text. Neutral badges use Parchment with Soft Graphite text; club privacy badges use a Bookplate Gold tint at 15% with a 40% gold border.
- **Section tabs:** Underline tabs with a `2px` active border in Iron Gall, `14px` medium labels, and a quiet Bookplate Gold count pill. They are not boxed.
- **Filter tabs:** DaisyUI `tabs-box` for My Clubs / All Clubs, using the theme's selector radius and a clear active state.

### Navigation
- **Desktop header:** Parchment, sticky, `64px`, `1px` Ink Navy bottom border. The logo is the primary brand element; links use `14px` medium text, Ink Navy default, Bookplate Gold hover, and solid icons when active.
- **Dropdowns:** Paper White, `16px` radius, `1px` Ink Navy border, `20px` overlay shadow. Menu items use `14px` text with `16px` icon slots.
- **Mobile bottom nav:** Paper White, `64px`, `1px` Deckle Edge top border, four equal columns. Icons are `24px`; labels are `11-12px`. Active is Ink Navy with a semibold label and solid icon; inactive is Soft Graphite with a Bookplate Gold hover.
- **Footer:** Parchment with a `1px` Ink Navy top border. Logo at `24px` height, `14px` links, Ink Navy default, Bookplate Gold hover.

### Dialogs / Overlays
- **Shape:** Bottom sheet on mobile, centered on desktop, Paper White, `16px` radius, `1px` Deckle Edge border, `24px` padding, max height `85vh`.
- **Header / Footer:** Title is `16-18px` bold Iron Gall; close control is a ghost circle. Footers separate with a `1px` Deckle Edge rule.
- **Behavior:** The body scrolls inside the dialog while the header and footer stay fixed. The backdrop is the DaisyUI modal backdrop, not a custom blur.

### Signature Components
**The Reading Card.** The system's central object: cover, club name in gold uppercase, title, author, meetup time and location with gold icons, RSVP action, and a gold capacity bar. It is a catalogue card made live. Every read surface should echo this hierarchy even when the layout changes.

**The Search Hero.** A full pill (`9999px`) on Paper White, `48px` tall, with a `24px` search icon inset at `20px` and a soft focus shadow. It is the one place where a pill is allowed to dominate.

## Do's and Don'ts

### Do:
- **Do** start pages on Parchment and place Paper White sheets on top.
- **Do** keep Ink Navy for structure and actions, and Bookplate Gold for the live read and small emphasis.
- **Do** set all interface text in the Ethiopic-first sans stack.
- **Do** use the radius ladder: `8px` controls, `12px` small cards, `16px` cards, `24px` panels and dialogs, full pills for search and avatars.
- **Do** use `1px` Deckle Edge borders and tonal contrast for depth.
- **Do** preserve the `42-56rem` reading column for club and read pages.
- **Do** give every interactive element a visible Ink Navy focus ring.
- **Do** use real book covers and club images; keep placeholders quiet and icon-led.
- **Do** keep uppercase for short labels and micro-headings only.

### Don't:
- **Don't** use pure white page backgrounds or pure black text.
- **Don't** add shadow-based elevation to cards, panels, or sections.
- **Don't** use gradients beyond the hero fallback and the profile banner.
- **Don't** introduce new brand hues; success, error, and warning colors are semantic only.
- **Don't** use sepia paper textures, script fonts, leather-and-candle imagery, or faux-vintage props.
- **Don't** turn the product into a dashboard of metric tiles or an infinite social feed.
- **Don't** set body copy, controls, or metadata in Playfair Display.
- **Don't** pill every button; pills are for search, avatars, dots, and status chips.
- **Don't** nest a button inside a card anchor; use a stretched link with controls above it.
