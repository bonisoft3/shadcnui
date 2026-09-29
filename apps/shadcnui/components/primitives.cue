// omnishell--badge / omnishell--card / omnishell--alert: the three shadcn
// components with no behavior — no machine, no row, no state. What a
// definition holds at this tier is the variant→token map, and holding it as
// data is what lets the screen print it in the pane where a stateful
// component prints its machine JSON. Each row carries the selector chain the
// screen's stylesheet paints that part with, so the suite folds the chain out
// of the stylesheet and refuses a cell the rules do not set, a declaration no
// cell lists, and a variant on the screen with no row at all
// (accept-primitives-token-map).
//
// Tokens are named here, never valued: each name is already one light-dark()
// pair, so a value written down a second time is the palette forked. That is
// why the destructive variants need no white literal — `surface` is the
// readable foreground on `danger` in BOTH appearances, near-white on the
// light red and near-black on the dark one.
package components

import (
	"encoding/json"
	"strings"
)

// 16×16 line icons, given as the svg's inner markup; the wrapper, its stroke
// and aria-hidden="true" belong to the component. Decoration only — a
// variant's meaning is in its text, never in the icon or the colour.
icons: {
	info:  #"<circle cx="8" cy="8" r="6.25"/><path d="M8 7.4v4.2M8 4.5h.01"/>"#
	warn:  #"<path d="M8 1.9 1.4 13.4h13.2L8 1.9Z"/><path d="M8 6.2v3.4M8 11.6h.01"/>"#
	check: #"<circle cx="8" cy="8" r="6.25"/><path d="m5.3 8.2 1.9 1.9 3.5-4"/>"#
	tick:  #"<path d="m3.4 8.6 2.9 2.9L12.6 4"/>"#
	dot:   #"<circle cx="8" cy="8" r="3.2" fill="currentColor" stroke="none"/>"#
}

// The complete statement of what these three components do, as the data the
// screen's stylesheet resolves: one row per (part, variant), naming the token
// that paints each surface. An em dash is "this variant paints none". `css` is
// the row's selector chain in cascade order, the screen-class prefix implied;
// it rides the emitted row as data-css, never a cell, because it is the handle
// the suite folds the stylesheet through rather than something to read.
primitiveTokens: [
	{part: "badge", variant: "default", css: [".badge", ".badge-default"], background: "accent", foreground: "surface", edge: "accent"},
	{part: "badge", variant: "secondary", css: [".badge", ".badge-secondary"], background: "surface-muted", foreground: "primary", edge: "surface-muted"},
	{part: "badge", variant: "destructive", css: [".badge", ".badge-destructive"], background: "danger", foreground: "surface", edge: "danger"},
	{part: "badge", variant: "outline", css: [".badge", ".badge-outline"], background: "—", foreground: "primary", edge: "border"},
	{part: "card", variant: "—", css: [".card"], background: "surface", foreground: "primary", edge: "border"},
	{part: "card description", variant: "—", css: [".card-description"], background: "—", foreground: "secondary", edge: "—"},
	{part: "alert", variant: "default", css: [".alert"], background: "surface", foreground: "primary", edge: "border"},
	{part: "alert", variant: "destructive", css: [".alert", ".alert-destructive"], background: "surface", foreground: "danger", edge: "danger"},
	{part: "alert description", variant: "default", css: [".alert-description"], background: "—", foreground: "secondary", edge: "—"},
	{part: "alert description", variant: "destructive", css: [".alert-description", ".alert-destructive .alert-description"], background: "—", foreground: "danger", edge: "—"},
]

_tokenCell: {
	in:  string
	out: [if in == "—" {"—"}, "<code>--\(in)</code>"][0]
}

// The table above as the screen's rows, printed the way the other screens
// print their machine JSON: the component's whole content, as data.
tokenRows: strings.Join([for r in primitiveTokens {
	"        <tr data-css='\(json.Marshal(r.css))'><td>\(r.part)</td><td>\(r.variant)</td>" +
	"<td>\((_tokenCell & {in: r.background}).out)</td>" +
	"<td>\((_tokenCell & {in: r.foreground}).out)</td>" +
	"<td>\((_tokenCell & {in: r.edge}).out)</td></tr>"
}], "\n")

#Badge: B={
	variant: *"default" | "secondary" | "destructive" | "outline"
	label:   string
	icon?:   string

	_inner: [
		if B.icon != _|_ {
			#"<svg class="badge-icon" viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">"# + B.icon + "</svg>" + B.label
		},
		B.label,
	][0]

	// A badge carries no role: it is a label, not a live region, and a status
	// it alone conveys must be in this text (WCAG 1.4.1). Interactive, it
	// would be a button and would stop being a badge.
	markup: """
		<omnishell--badge><span class="badge badge-\(B.variant)">\(B._inner)</span></omnishell--badge>
		"""
}

#Card: C={
	// Distinguishes instances on one screen; ids must be unique per screen.
	key:         string
	title:       string
	description: string
	body:        string
	action?:     string
	footer?:     string

	_titleId: "card-title-\(C.key)"
	_action: [if C.action != _|_ {"\n      <div class=\"card-action\">" + C.action + "</div>"}, ""][0]
	_footer: [if C.footer != _|_ {"\n    <footer class=\"card-footer\">" + C.footer + "</footer>"}, ""][0]

	// The title is a real heading, diverging from shadcn's div: a card grid
	// built from divs leaves the document with no outline, and the divergence
	// costs one element name. <article> carries an implicit role a screen
	// reader announces on entry, so the same heading names that boundary;
	// role="region" would promise a landmark a card is not.
	markup: """
		<omnishell--card>
		  <article class="card" aria-labelledby="\(C._titleId)">
		    <header class="card-header">
		      <h3 class="card-title" id="\(C._titleId)">\(C.title)</h3>
		      <p class="card-description">\(C.description)</p>\(C._action)
		    </header>
		    <div class="card-content">\(C.body)</div>\(C._footer)
		  </article>
		</omnishell--card>
		"""
}

#Alert: A={
	variant: *"default" | "destructive"
	// role="alert" is assertive and interrupts; role="status" is its polite
	// twin; a callout already on the screen when it paints announced nothing
	// and gets neither. shadcn hard-codes role="alert" on every variant, so
	// here the live region is asked for and defaults off.
	live:        *"none" | "polite" | "assertive"
	title:       string
	description: string
	icon?:       string

	_role: {none: "", polite: #" role="status""#, assertive: #" role="alert""#}[A.live]
	_icon: [
		if A.icon != _|_ {
			"\n    " + #"<svg class="alert-icon" viewBox="0 0 16 16" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">"# + A.icon + "</svg>"
		},
		"",
	][0]

	markup: """
		<omnishell--alert>
		  <div class="alert alert-\(A.variant)"\(A._role)>\(A._icon)
		    <h3 class="alert-title">\(A.title)</h3>
		    <p class="alert-description">\(A.description)</p>
		  </div>
		</omnishell--alert>
		"""
}
