// omnishell--questionnaire: shadcn's multi-step form, and the first chart in
// this catalog whose STATES are the screen's own steps rather than a control's.
//
// Everything else about it is vocabulary this app already has. An answer is a
// column each option's arrow states as a literal (./one-of.cue's shape, in a
// chart of the screen rather than of a widget). Which question is showing is
// the field, so the panels are a projection off `data-state` — Radix's own
// contract, and the same one the tabs use. And the progress is a RULE keyed on
// that field rather than a column: a number computed from where you are is a
// second spelling of where you are.
//
// The one thing it adds is the shape of a step: Next is blocked until the
// question is answered, and that block is a COLUMN rather than a guard —
// ./otp.cue's rule, which this screen follows rather than deciding the same
// fact twice. Skip is the arrow with no such column, which is what "skippable"
// means once the difference is stated in a chart.
package components

import (
	"strings"

	omni "bonisoft.org/plugins/omnishell/components"
	terminal "bonisoft.org/plugins/omnishell:terminal"
)

#Questionnaire: Q={
	collection: string
	row:        *"the" | string
	field:      *"step" | string
	key:        *"quiz" | string
	title:      string
	// The steps, in order. Each names the column its answer lands in, and the
	// last one may be freeform — which is a value rather than a choice, so it
	// arrives off the event (decision-24).
	steps: [...{
		name:     =~"^[a-z0-9]+$"
		ask:      string
		col:      =~"^[a-z0-9_]+$"
		freeform: *false | bool
		skippable: *false | bool
		options: [...{name: =~"^[a-z0-9_]+$", label: string}]
		if freeform {options: []}
		if !freeform {options: [_, _, ...]}
	}] & [_, _, ...]
	done: string

	_last: Q.steps[len(Q.steps)-1]
	_next: {for i, s in Q.steps {(s.name): [if i+1 < len(Q.steps) {Q.steps[i+1].name}, "done"][0]}}
	_prev: {for i, s in Q.steps if i > 0 {(s.name): Q.steps[i-1].name}}

	_optId: {for s in Q.steps {(s.name): {for o in s.options {(o.name): "\(Q.key)-\(s.name)-\(o.name)"}}}}
	// A column per option, because `aria-pressed` speaks true and false and not
	// the answer's own words — the same per-option spelling ./one-of.cue uses,
	// and the reason a chosen option can be styled by its own attribute rather
	// than by a rule comparing two of them.
	_sel: {for s in Q.steps {(s.name): {for o in s.options {(o.name): "sel_\(s.name)_\(o.name)"}}}}
	_selOff: {for s in Q.steps {(s.name): {for o in s.options {(Q._sel[s.name][o.name]): "false"}}}}
	_note:    "\(Q.key)-note"
	_nextId:  "\(Q.key)-next"
	_backId:  "\(Q.key)-back"
	_skipId:  "\(Q.key)-skip"
	_againId: "\(Q.key)-again"

	// Blocked until the question is answered — and WHICH answer is two leaves,
	// because a step arrow and a keystroke read two different things. A step
	// arrow reads the row: the destination's answer is what decides whether the
	// reader is asked again. A keystroke reads the event: the row still holds
	// the answer before this one, so a leaf reading it would be a keystroke
	// behind, always.
	//
	// Not one leaf preferring the event: every click carries a `value` — a
	// button's own, which is the empty string — so the arrows would all read as
	// unanswered.
	#block: K={col: string, out: {type: "unless-answered", params: {col: K.col}}}
	_typedBlock: {type: "unless-typed", params: {}}

	// The world a first visit and a restart both land in: no answer, every
	// option unpressed, and Next blocked. One value, emitted as the machine's
	// context and as the arrow out of `done`.
	_empty: {
		for s in Q.steps {(s.col): ""}
		for s in Q.steps for k, v in Q._selOff[s.name] {(k): v}
	}

	_context: {blocked: "disabled", for k, v in Q._empty {(k): v}}
	// What the readout binds before the first answer: the machine's context,
	// emitted twice from one value.
	emptyRow: (omni.#attrJSON & {in: {id: Q.row, (Q.field): Q.steps[0].name, for k, v in Q._context {(k): v}}}).out

	machine: terminal.#Machine & {
		field:   Q.field
		initial: Q.steps[0].name
		context: Q._context
		states: {
			for i, s in Q.steps {
				(s.name): on: {
					// The answer, and the block it lifts, in one write.
					for o in s.options {
						("click@\(Q._optId[s.name][o.name])"): assign: {
							(s.col): o.label
							// Every other option's, and then this one's: two
							// writes of one column would be a conflict rather
							// than an override, which is CUE saying the same
							// thing the row would.
							for k, v in Q._selOff[s.name] if k != Q._sel[s.name][o.name] {(k): v}
							(Q._sel[s.name][o.name]): "true"
							"blocked":                ""
						}
					}
					if s.freeform {
						("input@\(Q._note)"): assign: {
							(s.col):   {type: "event", params: field: "value"}
							"blocked": Q._typedBlock
						}
					}
					("click@\(Q._nextId)"): {
						target: Q._next[s.name]
						if Q._next[s.name] != "done" {
							assign: blocked: (#block & {col: Q.steps[i+1].col}).out
						}
					}
					if s.skippable {
						("click@\(Q._skipId)"): {
							target: Q._next[s.name]
							assign: {
								(s.col): "Skipped"
								if Q._next[s.name] != "done" {
									blocked: (#block & {col: Q.steps[i+1].col}).out
								}
							}
						}
					}
					if i > 0 {
						("click@\(Q._backId)"): {
							target: Q._prev[s.name]
							assign: blocked: (#block & {col: Q.steps[i-1].col}).out
						}
					}
				}
			}
			done: on: ("click@\(Q._againId)"): {
				target: Q.steps[0].name
				assign: {blocked: "disabled", for k, v in Q._empty {(k): v}}
			}
		}
	}

	_panels: strings.Join([for s in Q.steps {
		"""
			      <fieldset class="q-step" data-step="\(s.name)">
			        <legend class="q-ask">\(s.ask)</legend>
			\(_choices[s.name])
			      </fieldset>
			"""
	}], "\n")

	_choices: {for s in Q.steps {
		(s.name): [
			if s.freeform {"""
				        <label class="q-note-label" for="\(Q._note)">Your answer</label>
				        <input class="q-note" id="\(Q._note)" type="text" value="{\(s.col)}"
				               autocomplete="off" maxlength="80" placeholder="A sentence is plenty">
				"""},
			strings.Join([for o in s.options {
				"""
					        <button type="button" class="q-choice" id="\(Q._optId[s.name][o.name])"
					                aria-pressed="{\(Q._sel[s.name][o.name])}">\(o.label)</button>
					"""
			}], "\n"),
		][0]
	}}

	// Progress is a rule keyed on the field rather than a column: a number
	// computed from where you are is a second spelling of where you are, and
	// two spellings drift.
	markup: """
		<omnishell--questionnaire>
		  <section class="quiz" data-live="\(Q.collection)" data-filter="id=eq.\(Q.row)"
		           data-state="{\(Q.field)}"
		           data-machine='\((omni.#attrJSON & {in: Q.machine}).out)'>
		    <h2 class="q-title">\(Q.title)</h2>
		    <p class="q-progress" aria-hidden="true"><span class="q-progress-bar"></span></p>
		\(Q._panels)
		    <div class="q-done">
		      <p class="q-done-note">\(Q.done)</p>
		      <button type="button" class="q-again" id="\(Q._againId)">Start again</button>
		    </div>
		    <div class="q-acts">
		      <button type="button" class="q-back" id="\(Q._backId)">Back</button>
		      <button type="button" class="q-skip" id="\(Q._skipId)">Skip</button>
		      <button type="button" class="q-next" id="\(Q._nextId)" disabled="{blocked}">Next</button>
		    </div>
		  </section>
		</omnishell--questionnaire>
		"""
}
