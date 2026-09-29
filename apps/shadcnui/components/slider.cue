// omnishell--slider, omnishell--progress: a value a reader sets and a value a
// reader reads.
//
// A machine's `field` is a STATE column — `initial` must name one of `states`'
// keys, a finite closed set — and a position on a scale is not one. So the
// value is a SECOND column the same transition assigns, lifted off the event by
// the terminal's leaf, leaving one state and one targetless arrow. What that
// makes the machine is decision-23's subject.
//
// A control carrying no `valueAsNumber` declines the transition rather than
// writing NaN, so narrowing the arrow to the range's id (decision-13) is what
// keeps it addressed to that control and nothing else.
//
// The range binds the `value` CONTENT attribute, and an <input type=range> is
// in value mode: the reader's first interaction sets the dirty value flag,
// after which the thumb stops tracking what the binder writes. A row can paint
// a bar forever and can move this control only until it is first touched, so a
// consumer that gives the column a second writer cannot roll a refused write
// back where the reader sees it.
//
// Both controls are the platform's own element, dressed rather than rebuilt, so
// neither writes an `aria-*` and each is named by a `<label for>`.
package components

import (
	omni "bonisoft.org/plugins/omnishell/components"
	terminal "bonisoft.org/plugins/omnishell:terminal"
)

#Slider: S={
	collection: string
	row:        *"the" | string
	// Distinguishes instances sharing a screen; every id this component emits
	// carries it.
	key: =~"^[a-z0-9_]+$"
	// The state column. One state, so this column is a constant — which is the
	// chart's own admission that it draws no branch, and the entity's cel
	// prints it as a one-member enum.
	field: *"phase" | string
	state: *"live" | string
	// The column the reader moves.
	value: string
	label: string
	min:   *0 | int
	max:   *100 | int
	step:  *1 | int
	start: int & >=S.min & <=S.max

	_input: "slider-\(S.key)-input"

	machine: terminal.#Machine & {
		field:   S.field
		initial: S.state
		context: {(S.value): S.start}
		states: {
			(S.state): on: {
				(("input@" + S._input)): {
					assign: {(S.value): {type: "event", params: {field: "valueAsNumber"}}}
				}
			}
		}
	}

	// The row the terminal synthesizes for this region — {...context, id,
	// field: initial}. Published so a pane or a bar reading the same row states
	// the same opening world rather than a second copy of it.
	fallback: {id: S.row, (S.field): S.state, (S.value): S.start}

	// No data-empty-row: the machine is the writer of the initial fact
	// (decision-07). The readout is aria-hidden because the control already
	// announces its own value, and a second copy in the accessibility tree is
	// the same number said twice.
	markup: """
		<omnishell--slider>
		  <div class="slider" data-live="\(S.collection)" data-filter="id=eq.\(S.row)"
		       data-machine='\((omni.#attrJSON & {in: S.machine}).out)'>
		    <label class="slider-label" for="\(S._input)">\(S.label)</label>
		    <input type="range" id="\(S._input)" class="slider-input"
		           min="\(S.min)" max="\(S.max)" step="\(S.step)" value="{\(S.value)}">
		    <span class="slider-readout" aria-hidden="true" data-text="{\(S.value)}">\(S.start)</span>
		  </div>
		</omnishell--slider>
		"""
}

#Progress: P={
	collection: string
	row:        *"the" | string
	key:        =~"^[a-z0-9_]+$"
	// The column the bar paints. Which collection it lives in is the whole of
	// what makes one bar follow a control and another stand still.
	field: string
	label: string
	// `<progress>` has no min — its scale starts at zero — so the scale is one
	// number and nothing restates it.
	max: *100 | int
	// The row to paint before the collection has one. A bar has no writer of
	// its own, so this is the row's actual writer's opening world — #Slider
	// publishes its `fallback` for exactly this.
	empty: {[string]: string | int}

	_bar: "progress-\(P.key)-bar"

	markup: """
		<omnishell--progress>
		  <div class="progress" data-live="\(P.collection)" data-filter="id=eq.\(P.row)"
		       data-empty-row='\((omni.#attrJSON & {in: P.empty}).out)'>
		    <label class="progress-label" for="\(P._bar)">\(P.label)</label>
		    <progress class="progress-bar" id="\(P._bar)" max="\(P.max)" value="{\(P.field)}"></progress>
		  </div>
		</omnishell--progress>
		"""
}
