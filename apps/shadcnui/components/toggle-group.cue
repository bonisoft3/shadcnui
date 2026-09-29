// APG's radio group rather than a bag of aria-pressed buttons: #OneOf's field
// holds exactly one state name and its assigns move every chk_ column
// together, so neither two checked members nor none is reachable. aria-pressed
// would admit an all-off state a one-field machine reaches only by inventing
// one.
//
// The tabstop is the chosen option's, which is what APG asks of a radio group:
// data-rove binds the same column aria-checked does, so one write moves the
// selection, the tab order and the reader's focus together and they cannot
// disagree.
package components

import (
	"strings"

	omni "bonisoft.org/plugins/omnishell/components"
)

#ToggleGroup: G={
	collection: string
	row:        *"the" | string
	field:      *"value" | string
	label:      string
	// Distinguishes instances sharing one collection: every id is
	// tg-<key>-item-<name>. Neither part admits a hyphen, so the separator is
	// unreachable from either side and two groups on one screen occupy
	// disjoint namespaces — neither group's button can fire the other's arrow.
	key: =~"^[a-z0-9_]+$" & (*G.collection | string)
	items: [...{name: =~"^[a-z0-9_]+$", label: string}] & [_, _, ...]

	_id: {for i in G.items {(i.name): "tg-\(G.key)-item-\(i.name)"}}

	_choice: #OneOf & {
		walk:   true
		field:  G.field
		prefix: "chk_"
		names: [for i in G.items {i.name}]
		id: G._id
	}
	machine: _choice.machine

	// The id sits on the button and on nothing inside it: `from` resolves to
	// the nearest ancestor carrying an id, so a nested one would shadow the
	// trigger's and the arrow would never match.
	_items: strings.Join([for i in G.items {
		"""
			      <button type="button" role="radio" id="\(G._id[i.name])" class="tg-item"
			              data-rove="{\(G._choice.col[i.name])}"
			              aria-checked="{\(G._choice.col[i.name])}">\(i.label)</button>
			"""
	}], "\n")

	// data-state on the root is Radix's observable contract, not a projection
	// driver: the per-option fact is per-option, and aria-checked carries it.
	markup: """
		<omnishell--toggle-group>
		  <div class="toggle-group" data-live="\(G.collection)" data-filter="id=eq.\(G.row)"
		       data-state="{\(G.field)}"
		       data-machine='\((omni.#attrJSON & {in: G.machine}).out)'>
		    <div role="radiogroup" aria-label="\(G.label)" class="tg-set">
		\(G._items)
		    </div>
		  </div>
		</omnishell--toggle-group>
		"""
}
