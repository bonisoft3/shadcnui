// omnishell--otp: shadcn's InputOTP, and the one component here whose whole
// argument is what NOT to build.
//
// The famous shape is N boxes, each holding one character, with focus chasing
// the reader across them. That is `data-focus` in a costume, and it costs the
// three things a one-time code is for: a paste of six digits arrives as six
// events into six fields, `autocomplete="one-time-code"` names one control and
// so fills the first box alone, and Backspace at the head of a box has to be
// taught what the platform already knows. So the control is ONE input, the
// caret is the browser's, and the boxes are drawn under it by the stylesheet.
//
// What is left is a chart, and the chart's job is the fact the platform will
// not hold: whether what has been typed is a code. `pattern` plus `:valid`
// would style it and tell nobody — a fact only CSS knows is one no row holds,
// no test reads and no reviewer can sign, which is the same trade /form makes
// when it turns the UA's own validation off.
package components

import (
	omni "bonisoft.org/plugins/omnishell/components"
	terminal "bonisoft.org/plugins/omnishell:terminal"
)

#Otp: O={
	collection: string
	row:        *"the" | string
	field:      *"state" | string
	// Prefixes every id this component emits.
	key:   *"otp" | string
	label: string
	hint:  string
	// How many digits the code is. One number: the control's `maxlength`, the
	// guard's param, the column's constraint and the stylesheet's track count
	// all come from it, so the boxes a reader sees and the length that admits
	// them cannot drift (decision-16's rule).
	digits:  *6 | int & >=4 & <=8
	codeCel: "this.size() <= \(O.digits)"

	verify: string
	again:  string
	done:   string

	_input:  "\(O.key)-code"
	_verify: "\(O.key)-verify"
	_reset:  "\(O.key)-reset"

	// The empty world, stated once and emitted three times — as the machine's
	// context, as the arrow that clears it, and as the fallback the readout
	// beside this control binds before anything is typed (decision-07).
	_empty: {code: "", invalid: "false", blocked: "disabled"}
	emptyRow: (omni.#attrJSON & {in: {id: O.row, (O.field): "typing", for k, v in O._empty {(k): v}}}).out

	// What a keystroke can mean, as three arrows asked in turn. Every one of
	// them writes the column, which is what keeps the control and the row from
	// disagreeing: an arrow that declined to write would leave the input
	// showing text the row does not have, and no wake to correct it with.
	//
	// Every one of them is GUARDED, and the last two partition every string
	// between them — so the list is exhaustive without a candidate that catches
	// what the others declined. That is what a guardless arrow would have been,
	// and it would have been the one arrow here nothing could drive: an event
	// with no value stated is the control holding whatever it last held, which
	// is a stimulus a walk cannot name.
	//
	// `value` is what each arrow's guard ADMITS, and the module never reads it:
	// a param named after an event field is the chart saying which event
	// satisfies the arrow, so a chart-derived walk can type it rather than
	// guessing a string out of a module's name (test/walker.ts).
	_typed: [
		{
			guard:  {type: "is-code", params: {digits: O.digits, value: "148203"}}
			target: "complete"
			assign: {code: {type: "event", params: field: "value"}, invalid: "false", blocked: ""}
		},
		{
			guard:  {type: "is-digits", params: {value: "1482"}}
			target: "typing"
			assign: {code: {type: "event", params: field: "value"}, invalid: "false", blocked: "disabled"}
		},
		{
			// Where a keystroke lands that can never be part of a code. The row
			// records what was typed and says it is wrong; nothing is swallowed,
			// because a control that ate a keystroke would be one whose state a
			// reader cannot see.
			guard:  {type: "has-nondigit", params: {value: "148x"}}
			target: "typing"
			assign: {code: {type: "event", params: field: "value"}, invalid: "true", blocked: "disabled"}
		},
	]

	machine: terminal.#Machine & {
		field:   O.field
		initial: "typing"
		context: O._empty
		states: {
			typing: on: (("input@" + O._input)): O._typed
			complete: on: {
				(("input@" + O._input)): O._typed
				// Reachable from here alone, and not because a guard says so:
				// the button is disabled everywhere else, and what disables it
				// is a column this chart writes.
				(("click@" + O._verify)): target: "verified"
			}
			verified: on: {
				(("input@" + O._input)): O._typed
				(("click@" + O._reset)): {target: "typing", assign: O._empty}
			}
		}
	}

	// `data-state` is Radix's contract and the whole of this component's
	// styling hook: which boxes are drawn filled is the value's own doing, and
	// which of the two buttons is in the Tab sequence is the state's.
	markup: """
		<omnishell--otp>
		  <div class="otp" data-live="\(O.collection)" data-filter="id=eq.\(O.row)"
		       data-state="{\(O.field)}"
		       data-machine='\((omni.#attrJSON & {in: O.machine}).out)'>
		    <label class="otp-label" for="\(O._input)">\(O.label)</label>
		    <div class="otp-field" style="--otp-digits: \(O.digits)">
		      <!-- The boxes are the stylesheet's and carry no data: a slot per
		           digit, drawn under the one control rather than being it. -->
		      <div class="otp-boxes" aria-hidden="true"></div>
		      <input class="otp-code" id="\(O._input)" type="text" value="{code}"
		             inputmode="numeric" autocomplete="one-time-code" maxlength="\(O.digits)"
		             spellcheck="false" autocorrect="off"
		             aria-invalid="{invalid}" aria-describedby="\(O.key)-hint">
		    </div>
		    <p class="otp-hint" id="\(O.key)-hint">\(O.hint)</p>
		    <div class="otp-acts">
		      <button type="button" class="otp-verify" id="\(O._verify)"
		              disabled="{blocked}">\(O.verify)</button>
		      <button type="button" class="otp-reset" id="\(O._reset)">\(O.again)</button>
		    </div>
		    <p class="otp-done" role="status">\(O.done)</p>
		  </div>
		</omnishell--otp>
		"""
}
