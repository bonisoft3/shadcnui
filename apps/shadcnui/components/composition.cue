// omnishell--item, omnishell--input-group, omnishell--button-group: three of
// shadcn's components that hold nothing and arrange something. Each is exactly
// one relationship, and each has a contract a careless expansion breaks:
//
// The roster's fourth arrangement, Field, is ./form.cue's and predates it: a
// control, its label and its help text as one unit, with the three ids unified
// from one so the association cannot drift. A second definition here would be
// one relationship declared twice.
//
//   Item        three slots in a row, and the whole of it is which element the
//               title is — a heading inside a list of them, a link where the
//               row goes somewhere, and neither where it does not.
//   Input Group an addon inside the control's box, which is a lie the
//               stylesheet tells: the box is the group's and the ring has to be
//               moved there, or a keyboard reader loses the control's edge.
//   ButtonGroup a shared border over N independent actions — and NOT a choice,
//               which is ./one-of.cue's and wears aria-checked.
package components

import (
	"strings"

	omni "bonisoft.org/plugins/omnishell/components"
	terminal "bonisoft.org/plugins/omnishell:terminal"
)

#Item: I={
	title:       string
	description: string
	// Where the row goes, if anywhere. A row that goes nowhere is a <div> and
	// not a link with no href, which is a control a keyboard cannot reach and a
	// reader is told about anyway.
	route:   *"" | string
	variant: *"default" | "outline" | "muted"
	// Two letters, drawn rather than fetched.
	media: string
	// The trailing slot. Empty is the common case: an action per row is what
	// makes a list of them a toolbar nobody asked for.
	action: *"" | string

	_tag:  [if I.route != "" {"a"}, "div"][0]
	_attr: [if I.route != "" {" data-route=\"\(I.route)\""}, ""][0]
	_action: [if I.action != "" {"\n    <span class=\"item-actions\"><span class=\"item-action\">\(I.action)</span></span>"}, ""][0]

	markup: """
		<omnishell--item>
		  <\(I._tag) class="item" data-variant="\(I.variant)"\(I._attr)>
		    <span class="item-media" aria-hidden="true">\(I.media)</span>
		    <span class="item-content">
		      <span class="item-title">\(I.title)</span>
		      <span class="item-note">\(I.description)</span>
		    </span>\(I._action)
		  </\(I._tag)>
		</omnishell--item>
		"""
}

#InputGroup: G={
	key:   =~"^[a-z0-9_-]+$"
	label: string
	// The column the control writes, so this one is not a specimen.
	value: string
	// What sits inside the box, before and after the control.
	lead:   *"" | string
	button: *"" | string

	_lead: [if G.lead != "" {"\n      <span class=\"ig-text\">\(G.lead)</span>"}, ""][0]
	_button: [
		if G.button != "" {"\n      <button type=\"button\" class=\"ig-button\" id=\"\(G.key)-clear\">\(G.button)</button>"},
		"",
	][0]

	markup: """
		<omnishell--input-group>
		  <div class="ig-holder">
		    <label class="ig-label" for="\(G.key)">\(G.label)</label>
		    <div class="ig">\(G._lead)
		      <input class="ig-input" id="\(G.key)" type="text" value="{\(G.value)}"
		             autocomplete="off" spellcheck="false">\(G._button)
		    </div>
		  </div>
		</omnishell--input-group>
		"""
}

// N independent actions under one border. NOT a choice: a group whose buttons
// are one answer is ./one-of.cue's, and wears aria-checked and a tab stop.
#ButtonGroup: B={
	label: string
	buttons: [...{name: =~"^[a-z0-9_]+$", label: string}] & [_, _, ...]
	key: *"bg" | string

	_id: {for b in B.buttons {(b.name): "\(B.key)-\(b.name)"}}
	_buttons: strings.Join([for b in B.buttons {
		"      <button type=\"button\" class=\"bg-button\" id=\"\(B._id[b.name])\">\(b.label)</button>"
	}], "\n")

	markup: """
		<omnishell--button-group>
		  <div class="bg" role="group" aria-label="\(B.label)">
		\(B._buttons)
		  </div>
		</omnishell--button-group>
		"""
}

// The one chart this screen runs, and it is what keeps its controls from being
// dead: the group's buttons act, and the field records what they did.
#CompositionDemo: D={
	collection: string
	row:        *"the" | string
	field:      *"phase" | string
	state:      *"live" | string
	search:     #InputGroup
	group:      #ButtonGroup

	_empty: {(D.search.value): "", last: "nothing yet"}
	// What the readout binds before anything is typed: the machine's context,
	// emitted twice from one value.
	emptyRow: (omni.#attrJSON & {in: {id: D.row, (D.field): D.state, for k, v in D._empty {(k): v}}}).out

	machine: terminal.#Machine & {
		field:   D.field
		initial: D.state
		context: D._empty
		states: (D.state): on: {
			("input@\(D.search.key)"): assign: (D.search.value): {type: "event", params: field: "value"}
			("click@\(D.search.key)-clear"): assign: (D.search.value): ""
			for b in D.group.buttons {
				("click@\(D.group._id[b.name])"): assign: last: b.label
			}
		}
	}

	markup: """
		<div class="composition-live" data-live="\(D.collection)" data-filter="id=eq.\(D.row)"
		     data-machine='\((omni.#attrJSON & {in: D.machine}).out)'>
		\(D.search.markup)
		\(D.group.markup)
		  <p class="composition-said">Last action: <b data-text="{last}">nothing yet</b></p>
		</div>
		"""
}
