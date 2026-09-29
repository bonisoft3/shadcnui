// omnishell--checkbox, omnishell--toggle, omnishell--collapsible: three of
// shadcn's controls out of one generator. The switch's two-state machine is
// not a switch — it is the shape of every binary control, and the only thing
// that differs across these three is which ARIA attribute the field spells:
// aria-checked, aria-pressed, aria-expanded. That is decision-03 carried to
// its conclusion, so what a component chooses is the attribute, and nothing
// about the chart moves with it.
//
// _#Binary is that shape: one `click@<trigger>` arrow per state, narrowed to
// the affordance's own id, targeting the state `next` names. The key set of
// `next` IS the state set, so a state no value names has no incoming arrow —
// which is how the checkbox's "mixed" ships as a fact about a world outside
// the row rather than something a click produces.
//
// Keyboard: native button activation, whole. Space and Enter press a button,
// so APG's required contract for checkbox, button and disclosure is complete
// with no tabindex and no key handling — none of the three patterns asks for
// a key the platform does not already deliver, which is what these three have
// and tabs, toggle-group and accordion do not.
package components

import (
	"strings"

	omni "bonisoft.org/plugins/omnishell/components"
	terminal "bonisoft.org/plugins/omnishell:terminal"
)

_#Binary: B={
	field:   string
	initial: string
	// The id every arrow is narrowed to (decision-13). `from` resolves to the
	// nearest ancestor carrying an id, so an unnarrowed click would fire from
	// whatever content the affordance wraps or sits beside.
	trigger: string
	// What the trigger's click makes true next, per state.
	next: [string]: string
	// The other columns each state implies: merged into every arrow targeting
	// that state, and into `context` for the initial one. Empty where the
	// field is the whole fact, which is every two-state case here.
	implies: {for s, _ in B.next {(s): [string]: string}}

	machine: terminal.#Machine & {
		field:   B.field
		initial: B.initial
		if len(B.implies[B.initial]) > 0 {context: B.implies[B.initial]}
		states: {for s, t in B.next {
			(s): on: {("click@\(B.trigger)"): [
				if len(B.implies[t]) > 0 {{target: t, assign: B.implies[t]}},
				t,
			][0]}
		}}
	}
}

#Checkbox: C={
	collection: string
	row:        *"the" | string
	field:      *"checked" | string
	// Distinguishes instances sharing a screen; the default keeps the row's
	// name, which is already what separates two checkboxes on one collection.
	key:   =~"^[a-z0-9_]+$" & (*C.row | string)
	label: string
	_trigger: "cb-\(C.key)-trigger"
	_gen: _#Binary & {
		field:   C.field
		initial: "false"
		trigger: C._trigger
		next: {"false": "true", "true": "false"}
		implies: {}
	}
	machine: _gen.machine

	markup: """
		<omnishell--checkbox>
		  <div class="checkbox" data-live="\(C.collection)" data-filter="id=eq.\(C.row)"
		       data-machine='\((omni.#attrJSON & {in: C.machine}).out)'>
		    <button type="button" role="checkbox" id="\(C._trigger)" class="cb-control"
		            aria-checked="{\(C.field)}"><span class="cb-box" aria-hidden="true"></span><span class="cb-label">\(C.label)</span></button>
		  </div>
		</omnishell--checkbox>
		"""
}

// omnishell--select-all: the checkbox whose value is a FUNCTION of the
// checkboxes under it — which is the one thing a machine's FIELD cannot be.
//
// decision-18 named two ways to hold that function and refused both: a machine
// whose states are the item subsets, at 2^N of them, and a cross-row read that
// row closure forbids. There is a third, and it is the move ./slider.cue
// already made for a value with no states: the header's value stops being a
// state and becomes a COLUMN an arrow assigns off a leaf. No exponent, no
// second row — the leaf reads the same row the chart is closed over, which is
// the closure working rather than being worked around.
//
// So `mixed` is reachable, and this is the only control in the catalog whose
// ARIA value nothing decides: every click writes what the items add up to, and
// a reader gets back to mixed by unchecking one of three.
#SelectAll: S={
	collection: string
	row:        *"all" | string
	// One state, because there is nothing to be in: what this control is
	// showing is a value, and a value has no states (decision-23).
	field: *"phase" | string
	state: *"live" | string
	// The column the header binds, and the prefix the items' columns share —
	// the leaf reads the row by it, so the items need no list of their own.
	value:  *"checked" | string
	prefix: *"inc_" | string
	key:    =~"^[a-z0-9_]+$" & (*S.row | string)
	label:  string
	items: [...{name: =~"^[a-z0-9_]+$", label: string, initial: "true" | "false"}] & [_, _, ...]

	_trigger: "sa-\(S.key)-trigger"
	_id: {for i in S.items {(i.name): "sa-\(S.key)-item-\(i.name)"}}
	_col: {for i in S.items {(i.name): "\(S.prefix)\(i.name)"}}

	// The world the row opens in, stated once: the items the program seeds and
	// the value they add up to, computed here so the two cannot disagree
	// (decision-07's agreement, by construction).
	_checked: [for i in S.items if i.initial == "true" {i}]
	context: {
		(S.value): [if len(S._checked) == len(S.items) {"true"}, if len(S._checked) == 0 {"false"}, "mixed"][0]
		for i in S.items {(S._col[i.name]): i.initial}
	}

	// The row this control opens in, for the readout beside it: the machine's
	// own context, emitted twice from one value.
	emptyRow: (omni.#attrJSON & {in: {id: S.row, (S.field): S.state, for k, v in S.context {(k): v}}}).out

	machine: terminal.#Machine & {
		field:   S.field
		initial: S.state
		context: S.context
		states: (S.state): on: {
			// The header, and APG's own cycle: a partially checked select-all
			// checks everything, and from there it is the two-cycle. One leaf
			// serves both that cycle and an item's plain flip, because an item
			// is never mixed and the third case never arises there.
			("click@\(S._trigger)"): assign: {
				(S.value): {type: "flip-of", params: {col: S.value}}
				for i in S.items {(S._col[i.name]): {type: "flip-of", params: {col: S.value}}}
			}
			// One arrow per item, and not one guard among them: what the items
			// add up to is a computation and not a branch, so it is assigned
			// rather than targeted — which is also why this chart has no state
			// per subset.
			for i in S.items {
				("click@\(S._id[i.name])"): assign: {
					(S._col[i.name]): {type: "flip-of", params: {col: S._col[i.name]}}
					(S.value): {type: "roll-up", params: {prefix: S.prefix, col: S._col[i.name]}}
				}
			}
		}
	}

	// Each item is a checkbox of its own, so each carries its own id: `from`
	// resolves to the nearest ancestor with one, and items sharing the header's
	// would every one of them fire the header's arrow.
	_lines: strings.Join([for i in S.items {
		"""
			        <li><button type="button" role="checkbox" id="\(S._id[i.name])" class="cb-control cb-item"
			                aria-checked="{\(S._col[i.name])}"><span class="cb-box" aria-hidden="true"></span><span class="cb-label">\(i.label)</span></button></li>
			"""
	}], "\n")

	markup: """
		<omnishell--select-all>
		  <div class="select-all" data-live="\(S.collection)" data-filter="id=eq.\(S.row)"
		       data-machine='\((omni.#attrJSON & {in: S.machine}).out)'>
		    <button type="button" role="checkbox" id="\(S._trigger)" class="cb-control"
		            aria-checked="{\(S.value)}"><span class="cb-box" aria-hidden="true"></span><span class="cb-label">\(S.label)</span></button>
		    <ul class="cb-items">
		\(S._lines)
		    </ul>
		  </div>
		</omnishell--select-all>
		"""
}

// The same chart under aria-pressed. shadcn's Toggle is a button that stays
// down, and `pressed` is what a button's down-ness is called — so the field
// renames and nothing else does.
#Toggle: T={
	collection: string
	row:        *"the" | string
	field:      *"pressed" | string
	key:        =~"^[a-z0-9_]+$" & (*T.row | string)
	label:      string

	_trigger: "tgl-\(T.key)-trigger"
	_gen: _#Binary & {
		field:   T.field
		initial: "false"
		trigger: T._trigger
		next: {"false": "true", "true": "false"}
		implies: {}
	}
	machine: _gen.machine

	// The region IS the affordance here, as it is on the switch, and the arrow
	// is narrowed anyway: the id costs one attribute and the narrowing then
	// holds for a caller who wraps this in something clickable.
	markup: """
		<omnishell--toggle>
		  <button type="button" id="\(T._trigger)" class="toggle"
		          aria-pressed="{\(T.field)}"
		          data-live="\(T.collection)" data-filter="id=eq.\(T.row)"
		          data-machine='\((omni.#attrJSON & {in: T.machine}).out)'>\(T.label)</button>
		</omnishell--toggle>
		"""
}

// The same chart under aria-expanded, which is the accordion's multiple arm
// with one item: the same trigger, the same panel keyed on the trigger's own
// aria-expanded, the same two-state machine narrowed to one id. What it drops
// is the item set and the group wrapper, and that is the whole difference.
#Collapsible: L={
	collection: string
	row:        *"the" | string
	field:      *"open" | string
	key:        =~"^[a-z0-9_]+$" & (*L.row | string)
	label:      string
	body:       string

	_trigger: "col-\(L.key)-trigger"
	_panel:   "col-\(L.key)-panel"
	_gen: _#Binary & {
		field:   L.field
		initial: "false"
		trigger: L._trigger
		next: {"false": "true", "true": "false"}
		implies: {}
	}
	machine: _gen.machine

	markup: """
		<omnishell--collapsible>
		  <div class="collapsible" data-live="\(L.collection)" data-filter="id=eq.\(L.row)"
		       data-machine='\((omni.#attrJSON & {in: L.machine}).out)'>
		    <button type="button" id="\(L._trigger)" class="col-trigger"
		            aria-expanded="{\(L.field)}" aria-controls="\(L._panel)"><span class="col-title">\(L.label)</span><span class="col-chevron" aria-hidden="true"></span></button>
		    <div class="col-panel" role="region" id="\(L._panel)"
		         aria-labelledby="\(L._trigger)"><p>\(L.body)</p></div>
		  </div>
		</omnishell--collapsible>
		"""
}
