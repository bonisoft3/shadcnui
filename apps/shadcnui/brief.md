---
pronto: alpha
name: omnishell-shadcn-ui
business: the shadcn/ui catalog reimplemented as pronto components — machines and markup, no runtime library
stage: first two components (switch, tabs)
team: studio
cluster: mecha
terminal: omnishell
loop: sayt
build: bayt
---

# omnishell/ui — shadcn, recompiled

shadcn/ui's thesis is "this is not a component library — it's code you own."
pronto's thesis is the same sentence with a compiler behind it: everything an
app ships is source someone can read, emitted from declarations someone
reviewed. This app takes shadcn's catalog — the most copied component
vocabulary of its generation — and restates it in omnishell's native terms:
**a component is a tag that expands to markup, a design-token stylesheet, and
a state machine that is data.** No React, no Radix, no runtime library, no
`customElements.define`. The gallery you browse is the test suite, and the
state you click is rows you can watch.

Three convergences make this a reimplementation rather than an imitation:

- **Radix's observable contract is `data-state`.** Every Radix primitive
  communicates with CSS by stamping `data-state="checked"`,
  `data-state="active"`, `data-state="open"` onto its parts. Omnishell's
  binding vocabulary renders row fields into attributes and styles them with
  CSS — `data-state="{state}"` *is* the platform. The wire format survives;
  the engine changes.
- **shadcn's theming is CSS variables.** `--background`, `--foreground`,
  `--primary`, `--muted`, `--destructive`, `--radius` map one-to-one onto a
  `#Design` preset, with dark mode as `light-dark()` twins instead of a
  `.dark` class fork. This app contributes the `shadcn` preset upstream.
- **The behavior layer has become browser primitives plus machines**
  (`plugins/omnishell/docs/terminal.md`). Popover, dialog/inert, anchor
  positioning and `commandfor` cover dismissal, top-layer and placement with
  zero script. What remains is state, and state is a finite machine over one
  row field — data the terminal executes, validated by CUE, visualizable as
  XState.

## Data

Everything is `path: "tab"` — component state is the sitting's, not the
server's. One collection per component family, one row per demo instance on a
screen; the machine's field is the component's `data-state`, and
`data-empty-row` is synthesized from the machine's `initial:` and the
region's pk filter. No auth, no pipelines, no migrations: this app emits no
server surface at all.

The rows are the product's honesty: every gallery screen shows the live row
beside the rendered component. Click the switch, watch `checked` flip;
reload, watch `tab` state die and `device` state survive — the
durability ladder demonstrated rather than documented. `?seed=` and
`?clock=manual` replay a session, because every transition rides the
terminal's event machinery.

## The component idiom

- Components are authored in CUE and used in screens as tags prefixed
  `omnishell--` (custom-element grammar, so the hyphen is load-bearing):
  `<omnishell--switch>`, `<omnishell--tabs>`. The emitter expands each tag
  into the existing binding vocabulary; the tag survives in the served HTML
  as an inert semantic wrapper — visible to devtools, CSS and visual lint,
  registered with nothing.
- Behavior is a `#Machine` (the XState-JSON data subset: `field`, `initial`,
  `states`, `on`, with guards, actions, `entry`/`exit`, and nested and
  parallel states; `close()`d — a key outside the subset fails to unify). A
  machine authored through a component is valid by construction; hand-written
  `data-machine` JSON is vetted against the published definition at lint.
- **State names are the ARIA attribute's values.** The switch's states are
  `"true"` and `"false"` because `aria-checked` speaks that vocabulary, and
  one field binds both `aria-checked="{checked}"` and the styling hook.
  Style the semantics; never carry two spellings of one fact.
- Zero-script primitives are used bare wherever they suffice: `popover` +
  `anchor-name` for dropdown/tooltip surfaces, `<dialog>` for modals,
  `commandfor` for triggers. A component earns a machine only when it has
  state the platform doesn't hold.
- No shadow DOM, ever: the interpreter's walkers, the keyed reconciler and
  the design tokens assume one light tree, and encapsulation is precisely
  what a reviewable screen does not want.

## Screens

A gallery in shadcn's own shape: one screen per component family, each
showing the component's variants, its states as storyboard frames, its live
row, and its machine rendered as the JSON it is (paste it into a statechart
visualizer — it's valid XState config). A strip screen indexes the catalog
and carries the theme switch (the `shadcn` preset's light/dark twins) — the
gallery must read perfectly in both appearances, since appearance is a token
resolution, never a state.

## First two components

**`<omnishell--switch>`** — the smallest complete machine, and the whole
idiom in one control:

```json
{"field": "checked", "initial": "false", "states": {
  "false": {"on": {"click": "true"}},
  "true":  {"on": {"click": "false"}}}}
```

Expansion: a `role="switch"` button in a singleton region,
`aria-checked="{checked}"`, thumb and track styled off the ARIA attribute
with motion tokens. ARIA contract (WAI-ARIA APG switch): `role="switch"`,
`aria-checked`, toggles on click and on Space/Enter (native button
behavior). Done when the switch demo screen needs zero app JavaScript, zero
`data-empty-row`, and replays under `?seed=`.

**`<omnishell--tabs>`** — the third-case component, chosen *because* it
forces the one open grammar question: N triggers share one machine, so
transitions must say which trigger fired. The event already carries `from`;
the discrimination spelling is **component-generated, never hand-written** —
the expansion writes one transition per trigger, and whatever grammar it
emits (`"click@trigger-billing"` or its successor) is an implementation
detail of the component, not vocabulary an author learns. Panels are pure
projection: the root binds `data-state="{active}"` and CSS shows the
matching `[data-panel]`, exactly Radix's `data-state="active"` contract.
ARIA contract phased honestly: `role="tablist"/"tab"/"tabpanel"`,
`aria-selected`, click activation first; roving tabindex and arrow-key
navigation land with the region-projection work
(`plugins/omnishell/docs/accessibility.md`), not as ad-hoc script.

Immediately behind these, in order: **toggle-group** (segmented control, a
sibling of tabs),
**accordion** (per-item open state — the first multi-row machine question),
**dialog** and **tooltip** (zero-script exercises, no machine at all), **badge /
card / alert** (pure token styling, cheapest catalog breadth). The
**combobox stays deliberately last**: its virtual-focus behavior is the one
part with no declarative precedent.

## Graduation

Components prove themselves here, then publish into the terminal's roster —
`terminal.cue`'s advertised vocabulary — replacing the three row-backed
widget kinds that have never mounted. This app is the forcing consumer the
machine-and-components design has been waiting for: `#Machine`, the
expansion mechanism, and the `omnishell--` namespace all land with their
first real user, per the tree's deferral doctrine. When a component
graduates, other apps use the tag; this gallery remains its acceptance
suite.

## Behavior

- **No DOM event is ever handed to app code.** No screen carries a
  `data-on-*` binding or a `<script>`: behaviour is the chart, always. A Jessie
  module may exist only where a chart cannot compute the value it needs, and
  only as a leaf the chart names — the calendar's month arithmetic is the first
  and, so far, the only one. A module reachable any other way is a design
  failure surfaced early.
- **Zero network after statics.** All state is `tab`; the offline test is
  the same one truco passes.
- **Every state reachable by keyboard**, per each component's APG pattern,
  at the phase the component declares.
- **Both appearances from one declaration** — every screen's storyboard
  carries `-dark` frames; a color that exists in only one appearance is a
  build error, not a bug report.
- **Reduced motion collapses to instant** via the motion tokens; no
  component may depend on an animation having nonzero length.
- **A session replays.** `?seed=` and `?clock=manual` reproduce any
  reported state; a component whose state cannot be replayed does not ship.
