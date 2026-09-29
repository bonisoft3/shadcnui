// omnishell--empty, omnishell--spinner, omnishell--kbd: the tier below a
// machine, below a row, and below a projection — markup and tokens, and
// nothing else. Three definitions for four of shadcn's entries, because the
// fourth is Typography, which is the design block's type scale and has no
// markup to expand into.
//
// What makes them worth a screen is that three of those four are things this
// platform ALREADY HAS under another name. A region whose read answers nothing
// renders `data-empty`, and a route declares an `empty` state; a `<kbd>` is the
// element the menu screen's shortcuts already use; the type scale is the design
// block every screen resolves against. So each definition here is a SKIN over
// something the terminal or the platform owns, and the screen's job is to say
// which is which — a component that claims a fact the platform holds is one
// that can disagree with it.
package components

import (
	"strings"
)

#Empty: E={
	// The glyph is drawn rather than named: an icon font is a second asset and
	// an <img> is a request, where a box the stylesheet fills is neither.
	glyph:       *"folder" | "search" | "alert"
	title:       string
	description: string
	// The way out, which is what makes this different from a paragraph saying
	// nothing is here. Empty and no action is a dead end a reader has to leave
	// by the browser's own controls.
	action: *"" | string
	route:  *"" | string
	if E.action != "" {route: !=""}

	_action: [if E.action != "" {"\n      <a class=\"empty-action\" data-route=\"\(E.route)\">\(E.action)</a>"}, ""][0]

	markup: """
		<omnishell--empty>
		  <div class="empty" data-glyph="\(E.glyph)">
		    <span class="empty-media" aria-hidden="true"></span>
		    <p class="empty-title">\(E.title)</p>
		    <p class="empty-note">\(E.description)</p>\(E._action)
		  </div>
		</omnishell--empty>
		"""
}

// A wait a reader can see, and the one thing it may not depend on: its own
// animation. `prefers-reduced-motion` collapses the spin to nothing, so what is
// left has to carry the fact by itself — which is why the label is not
// decoration and role="status" is not optional.
#Spinner: S={
	label: string
	size:  *"md" | "sm" | "lg"

	markup: """
		<omnishell--spinner>
		  <span class="spinner" role="status" data-size="\(S.size)">
		    <span class="spinner-ring" aria-hidden="true"></span>
		    <span class="sr-only">\(S.label)</span>
		  </span>
		</omnishell--spinner>
		"""
}

// The element, wearing the tokens. <kbd> is what a keystroke IS in HTML, and
// this catalog already uses it — the menu screen prints its shortcuts in one —
// so the component is a class and a rule, and a chord is two elements rather
// than a string with a plus in it.
#Kbd: K={
	// Each key as its own element: "Ctrl+K" in one box is one key with a
	// strange name, and a reader hears it that way too.
	keys: [...string] & [_, ...]

	_keys: strings.Join([for k in K.keys {"<kbd class=\"kbd\">\(k)</kbd>"}], "<span class=\"kbd-plus\" aria-hidden=\"true\">+</span>")

	markup: """
		<omnishell--kbd><span class="kbd-set">\(K._keys)</span></omnishell--kbd>
		"""
}
