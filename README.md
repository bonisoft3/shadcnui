# shadcn/ui

Pronto's oracle for component fidelity, reimplementing the
[shadcn/ui](https://ui.shadcn.com/) catalog in native markup, design tokens, and
declarative state machines. The upstream components supply an external visual
and interaction reference; the implementation exercises Pronto's own machinery.

It exercises **input → state-machine transition → collection state → rendered
attributes and styles**. The gallery makes state observable beside the widget,
so checked, active, disabled, and focus behavior can be assessed together with
light/dark token resolution and the component's appearance.

Its scope starts with switches and tabs. Expanding the gallery should preserve
the upstream contract for each supported component, with any departures stated
explicitly. W3C ARIA provides the complementary accessibility oracle; this app
adds fidelity to a particular component vocabulary and design system.

The current contract uses tab-local state and no server surface. It therefore
exercises component compilation and browser behavior, not persistence or
backend synchronization. The [[brief.md|brief]] defines the component idiom and
supported scope.
