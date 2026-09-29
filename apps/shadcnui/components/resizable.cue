// omnishell--resizable: two panes whose widths are a column.
//
// A splitter is a bounded continuous value, and this vocabulary already has one
// control for that — so the keyboard APG asks a separator for is the range's
// own, arrows and Home and End and the page keys, before the page loads and
// with no chart stating any of it (./slider.cue's argument, one screen on).
//
// The panes size themselves off a bound custom property. What keeps that safe
// is the WRITER: a range hands the leaf a number the browser has already
// clamped, and a column a reader could type into has no business reaching a
// `style`. The screen carries the rest of the argument.
package components

import (
	omni "bonisoft.org/plugins/omnishell/components"
	terminal "bonisoft.org/plugins/omnishell:terminal"
)

#Resizable: R={
	collection: string
	row:        *"the" | string
	key:        *"rs" | string
	field:      *"state" | string
	state:      *"sizing" | string
	// The column the reader moves: the first pane's width, as a percentage.
	value: *"split" | string
	label: string
	// The ends. Neither pane may reach zero: a pane with no width is one whose
	// content has nowhere to go, and the handle would be the only thing left.
	min:   *15 | int & >=1
	max:   *85 | int & <=99
	// The entity's constraint, generated from the same numbers the control
	// carries — one declaration, so the gate and the schema cannot drift
	// (decision-24's rule, one screen on).
	splitCel: "this >= \(R.min) && this <= \(R.max)"
	start: int & >=R.min & <=R.max
	panes: [#ResizablePane, #ResizablePane]

	_input: "\(R.key)-handle"

	// One state, one targetless arrow: it acts and stays, which is how a single
	// state records a continuously changing value (decision-23).
	machine: terminal.#Machine & {
		field:   R.field
		initial: R.state
		context: {(R.value): R.start}
		states: (R.state): on: (("input@" + R._input)): {
			assign: {(R.value): {type: "event", params: {field: "valueAsNumber"}}}
		}
	}

	// A <div> and not a <section>: a named section is a region landmark, and two
	// landmarks for demo filler is ceremony the heading already does without.
	_pane: [for i, p in R.panes {"""
		      <div class="rs-pane">
		        <h3 class="rs-pane-title">\(p.title)</h3>
		        <p class="rs-pane-body">\(p.body)</p>
		      </div>
		"""}]

	// No data-empty-row: the machine is the writer of the initial fact
	// (decision-07). The group carries the binding because the panes size
	// themselves against it and a custom property inherits.
	markup: """
		<omnishell--resizable>
		  <div class="rs" data-live="\(R.collection)" data-filter="id=eq.\(R.row)"
		       data-machine='\((omni.#attrJSON & {in: R.machine}).out)'>
		    <div class="rs-group" style="--split: {\(R.value)}">
		\(_pane[0])
		      <div class="rs-bar" role="presentation"></div>
		\(_pane[1])
		    </div>
		    <label class="rs-label" for="\(R._input)">\(R.label)</label>
		    <input type="range" id="\(R._input)" class="rs-handle"
		           min="\(R.min)" max="\(R.max)" step="1" value="{\(R.value)}">
		    <code class="rs-readout" aria-hidden="true" data-text="\(R.value): {\(R.value)}%">\(R.value): \(R.start)%</code>
		  </div>
		</omnishell--resizable>
		"""
}

#ResizablePane: {
	title: string
	body:  string
}
