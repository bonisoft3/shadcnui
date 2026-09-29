---
preset: "press"
colors:
  neutral: "#FAFAFA"
  surface: "#FFFFFF"
  surface-muted: "#F4F4F5"
  border: "#E4E4E7"
  primary: "#09090B"
  secondary: "#52525B"
  accent: "#18181B"
  danger: "#DC2626"
dark:
  neutral: "#09090B"
  surface: "#18181B"
  surface-muted: "#27272A"
  border: "#3F3F46"
  primary: "#FAFAFA"
  secondary: "#A1A1AA"
  accent: "#E4E4E7"
  danger: "#EF4444"
rounded:
  sm: "6px"
  md: "10px"
  full: "999px"
---

# omnishell/ui — the reference, not a brand

The identity is **the absence of one**, held deliberately: this gallery
reimplements shadcn/ui, whose entire visual position is a neutral,
typographic, zinc-grey restraint that disappears behind the product built on
it. A component reference with a personality would be measuring its
components against the wrong background.

## What the eight names carry, and what they cannot

shadcn's palette is not a taste; it is a contract thousands of interfaces
already build on, and the frontmatter above is its zinc palette spelled on
the token contract — the program reads that block and restates none of it.
Six of its names land on the token vocabulary directly:
`--background` is `neutral`, `--card` is `surface`, `--muted` is
`surface-muted`, `--muted-foreground` is `secondary`, `--primary` (the
near-black action colour) is `accent`, `--destructive` is `danger`. One value
is not shadcn's: light `secondary` is zinc-600, a step below its zinc-500
`--muted-foreground`, because zinc-500 on `surface-muted` is 4.40:1 and the
text-contrast floor is 4.5:1; zinc-600 clears it at 7.03:1, and the dark twin
stays zinc-400, which clears every dark ground.

The contract is eight names wide and shadcn's is not, so the rest of its
roster is spelled here as something else, and the substitutions are the honest
record of the fidelity this gallery reaches:

- **The `*-foreground` pairs have no equivalent at all.** There is no on-colour
  token, so a component painting `background: var(--accent)` has no
  theme-safe ink for the text on top of it. Sixteen blocks write
  `color: var(--surface)` — the *card* colour, borrowed as an on-accent ink.
  It reads correctly because this accent is a near-black and its twin a
  near-white; it is the one substitution that would not survive a palette
  whose accent is light in the light appearance.
- **`--ring` is `accent`.** Seventy-six focus rings paint the action colour,
  where shadcn publishes a separate, lighter ring hue.
- **`--input` is `border`.** One hundred and fifty-four rules spell an edge
  with the single border role; shadcn separates a field's edge from a card's.
- **`--card` and `--popover` are both `surface`**, and **the five `--chart-*`
  series are three ink roles** — chart.css draws with `primary`, `accent` and
  `secondary`. **The eight `--sidebar-*` names are the page's own roles**; the
  rail in navigation.css paints with `surface` and `border`.

So the claim this file can make is narrower than "nothing needed a new token
name", and more useful: **eight roles express a single identity faithfully and
express a theme system not at all.** The missing dimension is a role, not a
rung — an on-colour ink is a decision about legibility, and no ladder of
values supplies one.

## Dark is a twin, not a theme

shadcn ships dark mode as a `.dark` class fork. Here the `dark` map is the
`light-dark()` twin of each name in `colors`, never a fork (ir decision-05):
the near-black action colour's twin is near-white,
the page ground inverts, borders lift one step. There is no toggle in the app
— appearance is a token resolution the reader's system decides, and the
storyboard's `-dark` frames are where the twin palette is reviewed. A colour
that exists in only one appearance cannot be expressed at all, which is the
guarantee the fork never gave.

The guarantee covers elevation on the same terms. The seven `shadow-ink-*`
roles come from press unchanged and are twinned like every other colour, so a
shadow lifts off a dark surface instead of disappearing into it — which a
hand-written `rgb(0 0 0 / 12%)` cannot do in either direction.

## Elevation is an order, not a shadow

Thirteen surfaces lift, and the rung says only how far off the page each one
sits. The order is the whole of the decision, so it is stated here rather than
left to be inferred from thirteen stylesheets:

| rung | what sits there | screens |
|---|---|---|
| `--shadow-1` | a selected segment lifted off its own track | tabs, toggle-group |
| `--shadow-2` | a popup anchored to the control that opened it | tooltip, picker, calendar |
| `--shadow-3` | a floating surface carrying its own content | menu, navigation menu, hover card, popover, toast |
| `--shadow-4` | a modal surface over a backdrop | dialog, edge dialog, sheet |

Peers share a rung, and that is the property to check when a screen is added: a
sheet is a dialog, so it cannot outrank one; a toast floats where a popover
floats. Rungs 5 and 6 are unused, because nothing in a component reference
sits above a modal, and a surface that would sit between two rungs is a
surface whose class is wrong.

## Two namespaces: what this app picks, and what it only spells in

A **role** is word-shaped and carries an argument. A **rung** is number-shaped
and means only "the Nth one". The frontmatter above is roles: every value in it
is one this app chose, and every role it leaves out is press's, accepted.
The rung vocabulary — 122 names, Open Props 1.7.23 under its own names plus the
terminal's measured touch floor — has no app seam at all and appears in no
frontmatter: it is identical in all eight apps by construction, so naming it
here would be restating the platform.

Three picks are worth the argument:

**Radius is a role and stays one.** 6px on insets, 10px on cards and controls,
full on pills and the switch track — shadcn's current default. Open Props'
radius ladder is 2/5/16/32/64/128px and contains neither 6 nor 10, which is
why no rung ladder for radius is admitted: this dimension was already named
correctly, and 185 uses against not one raw literal is the evidence.

**The control roles are press's, accepted rather than restated.** `h: 36px`,
`h-sm: 32px`, `h-lg: 40px`, `h-xs: 28px` are shadcn's `h-9`, `h-8`, `h-10`,
`h-7`; that press arrived at the same four heights for an editorial surface is
a coincidence, and accepting it is cheaper than forking a role to say the same
number. `pad-x` is `var(--sp-md)` — a role pointing at a role, 16px, which is
shadcn's `px-4`. Forty control heights and twenty-five control insets now name
one of these instead of repeating a number.

**The frontmatter names no `measures`, and that is a recorded gap rather than
a position.**
Eighteen screens open with a bare `max-width: 720px`, and no vocabulary
contains 720px — a page measure is identity, so it can only be a role, and
this app has not declared one. The same is true of the sheet's 420/360px, the
tooltip's 260px, the command palette's 254px and the chart's 5.5rem gutter.
Until they are roles they are copies, and the token lint cannot see them: it
refuses a literal only where a step exists, and by design it never reads
`width`, `min-*` or `max-*`, because a control's geometry is a decision it has
no standing to police.

## What the vocabulary still cannot say

Named here because a hole a reader can find is not debt, and one they cannot
is. Every count is a live measurement of `shell/screens` and `shell/shared`:

| what has no name | sites | the role it wants |
|---|---|---|
| a control's vertical inset, 6px | 38 | `control.pad-y` |
| the same inset on a 28px control, 5px | 4 | `control.pad-y-sm` |
| the state-matrix footer cell, `6px 10px` | 10 | `control.cell-pad-x`, value kept |
| a bubble's and a trigger's 12px x-inset | 9 | a role, or the 16px inset |
| the tab and toggle inset, 14px | 4 | a tab-inset role |
| the page measure, 720px | 18 | `measures.page` |
| the dialog, sheet, tip and palette measures | 10 | `measures.*` |
| a decorative media box, 40px | 8 | not a control height; a role or a rung |
| the kbd badge floor, 22px | 2 | `control.badge-min`, value kept |
| the switch track, 44px (`w-11`) | 1 | a design role; a screen-private token today |

None of these is a lint finding, and that is deliberate: the rule fires only
where the scale already publishes the value, so extending the vocabulary is
what extends the rule. A ladder with rungs two pixels apart would have made
every one of these lines pass while naming nothing.

`meta.design.pendingLiterals` is `0`: no declaration in this app wears
`/* pronto-literal: pending */`, so nothing above is excused — it is
unadjudicated, which is a different and more honest state.

## Type and shape

System type only, at shadcn's own scale: quiet weights, tight headings,
muted supporting text. Typography carries no scale and no lint — 334
`font-size` lengths over 25 spellings, `.875rem` and `0.875rem` among them —
and a ladder nothing lands on is worse than none, because the rule would have
nothing to refuse toward. Motion keeps the press preset's timings —
the switch thumb travels in `--motion-fast`, and under reduced motion it simply
arrives.

## What a component may paint with

Tokens, and nothing else. A component's structure ships with its CUE
definition; its skin is the demo screen's stylesheet, scoped under the
screen class, keying on the ARIA attribute the machine writes
(`[aria-checked="true"]`) — never on a class that restates state. A screen
redeclaring a token has forked the system, and the fact-store join says so; so
does a screen writing a length the shared layer already publishes under a name.

Two rules of reading, because they are the only places the two namespaces can
be confused. Where a role and a rung carry the same value, reach for the role:
`--sp-sm` and `--size-2` are both 8px here, and an 8px gap means "one spacing
step", not "the second rung". The rung is what is left over — a drawn box
measured at 8px, a dot or a chevron or a tick, is a length rather than a gap
and stays `--size-2`. And a number two idioms share is not a token they share:
a 2px backdrop blur and a 2px rule are `blur(2px)` and `--border-size-2`, and a
1px `sr-only` box is not a hairline, while a separator drawn as an element is
one.
