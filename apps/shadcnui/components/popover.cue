// omnishell--popover: the surface three screens in this catalog already open
// and none of them names. Openness, the top layer, a press outside, Escape and
// the invoker's expanded state all arrive with two attributes — `popover` on
// the surface, `commandfor`/`command` on the button — so this definition
// carries no #Machine and mounts no region. What it holds is the pairing of one
// trigger with one surface and the area that surface asks for.
//
// The screen carries the two arguments a reader of this file may want: what
// `popover="manual"` withdraws and why the catalog spends a stage measuring it,
// and the placement vocabulary as a table of rules.
package components

import (
	"strings"
)

// The whole placement vocabulary this component offers, as the data the screen
// prints and the suite folds the screen's stylesheet through. The fallback is
// derived from the place's own name: an axis written twice is an axis that can
// disagree with itself.
placements: [for p in ["block-start", "block-end", "inline-start", "inline-end"] {
	place:    p
	fallback: "flip-" + strings.Split(p, "-")[0]
	says:     _placeNotes[p]
}]

_placeNotes: {
	"block-start":  "above the trigger; below it where above will not hold the surface"
	"block-end":    "below the trigger, and the default, because a dropped surface is what a reader expects of a button"
	"inline-start": "before the trigger in the reading direction, so it mirrors under a right-to-left document without a second rule"
	"inline-end":   "after the trigger in the reading direction; the placement the fallback stage above is anchored at the column's edge to break"
}

// The table above as the screen's rows. Each carries the place it describes, so
// the suite reads the stylesheet's rule for that place rather than matching on
// a cell a reader could reword.
placementRows: strings.Join([for r in placements {
	"        <tr data-place=\"\(r.place)\"><td><code>\(r.place)</code></td>" +
	"<td><code>position-area: \(r.place)</code></td>" +
	"<td><code>\(r.fallback)</code></td><td>\(r.says)</td></tr>"
}], "\n")

#Popover: P={
	// Distinguishes instances on one screen; ids must be unique per screen, and
	// this one names both halves of the pair the stylesheet anchors.
	key:   string
	label: string
	body: string

	place: *"block-end" | "block-start" | "inline-start" | "inline-end"

	// popover="manual" is the same element with light dismiss, Escape and a
	// place in the UA's stack of open popovers all withdrawn.
	manual: *false | bool
	// The label of the surface's own way out.
	dismiss: *"" | string
	if P.manual {dismiss: !=""}

	_id:   "pop-\(P.key)"
	_open: "pop-open-\(P.key)"
	_kind: [if P.manual {"manual"}, "auto"][0]

	_dismiss: [if P.dismiss != "" {"\n      <button type=\"button\" class=\"pop-dismiss\" popovertarget=\"\(P._id)\" popovertargetaction=\"hide\" commandfor=\"\(P._id)\" command=\"hide-popover\">\(P.dismiss)</button>"}, ""][0]

	// aria-expanded is written nowhere: the UA supplies it for a popover
	// invoker. Neither is aria-haspopup — the surface claims no role, so there
	// is no kind of popup to promise, and a promise of "dialog" would be one
	// this surface neither keeps nor needs.
	markup: """
		<omnishell--popover>
		  <span class="pop">
		    <button type="button" id="\(P._open)" class="pop-trigger"
		            popovertarget="\(P._id)" commandfor="\(P._id)" command="toggle-popover">\(P.label)</button>
		    <div id="\(P._id)" class="pop-surface" data-place="\(P.place)" popover="\(P._kind)">
		\(P.body)\(P._dismiss)
		    </div>
		  </span>
		</omnishell--popover>
		"""
}
