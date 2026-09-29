// omnishell--select: the native control, bound to rows — the answer for a
// select that predates every machine in this gallery and needs no component
// tier at all.
//
// The <optgroup> IS the region, so the prompt option and the authored group
// survive its sweep; the select's `name` feeds the form directly, with no
// hidden field and no widget. The form holds no <button>, so a pick fires
// `change` and `change` submits it.
//
// No machine, and none is reachable: a machine's states are literals, and half
// this control's options do not exist until a row is written. What that buys
// is everything the UA owns — the whole keyboard contract, typeahead, and the
// platform's own mobile presentation. What it spends is the binding: a form
// resets on success, so after a pick the control shows its prompt again and
// the row is where the choice lives. The picker is a bound state; this is a
// committed act, and the two are answers to different questions.
//
// The option collection declares no `seed:`, so the option rows are the
// reader's: the minting form ships with the control, and the grammar an option
// id takes
// is stated once — a length and the shared alphabet #Combobox declares, from
// which the mint input's `pattern` and `maxlength`, the two `cel`s this
// exports, the bound on `authored` and the refusal a reader sees are all
// derived.
package components

import (
	"strings"
)

#Select: S={
	// The collection the pick writes: one row, one column.
	collection: string
	// The collection the live option group reads. Its pk is the option's value
	// AND its text, because an <option> carries nothing else and a form's one
	// input derives no second column.
	options: string
	row:     *"the" | string
	field:   *"choice" | string
	// Prefixes the screen's ids; the single-instance default is the tag's name.
	key:    *"select" | string
	label:  string
	prompt: string
	// Options an author knows at build time — the set a machine could also
	// have held, printed beside the set it could not. Held to the same grammar
	// a reader's is: an authored option a reader could not have minted would be
	// one the pick column refuses.
	authored: [...string & =~"^\(S.pattern)$"] & [_, _, ...]
	authoredLabel: string
	liveLabel:     string
	hint:          string
	// The #Form ids this markup realizes, so the program and the markup name
	// the same two forms.
	pickForm: string
	mintForm: string
	mintLabel:       string
	mintPlaceholder: string
	mintButton:      string
	mintHint:        string
	// The refusal, spelled from the grammar it reports rather than beside it.
	mintInvalid: *"A letter or a digit first, then letters, digits, spaces and . + # - up to \(S.maxLen)." | string

	// How long an option id may be. The one number, and everything that has to
	// agree with it is written from here: the control's `maxlength`, the
	// `pattern`'s repetition, both `cel`s and the refusal a reader reads.
	maxLen: *24 | int & >=2
	// One grammar for an option id, gating the control and constraining the
	// column: `_optionHead` first, then `_optionClass` to `maxLen`.
	pattern: "[\(_optionHead)][\(_optionClass)]{0,\(S.maxLen-1)}"
	cel:     "this.size() >= 1 && this.size() <= \(S.maxLen)"
	// What the pick column admits: every authored value and every option id a
	// reader can mint, which is a length and nothing more. A picker's column
	// enumerates its options; this one cannot, and that is the difference
	// between the two controls stated in the schema.
	choiceCel: "this.size() <= \(S.maxLen)"

	_authored: strings.Join([for o in S.authored {
		"        <option value=\"\(o)\">\(o)</option>"
	}], "\n")

	markup: """
		<omnishell--select>
		  <form class="select-pick" data-form="\(S.pickForm)"
		        data-entity="\(S.collection)" data-action="upsert">
		    <input type="hidden" name="id" data-value="\(S.row)">
		    <label class="select-label" for="\(S.key)-choice">\(S.label)</label>
		    <!-- The prompt is disabled, so the only value that can reach the
		         store is an option: no `required`, because nothing is left for
		         it to refuse. -->
		    <select class="select-control" id="\(S.key)-choice" name="\(S.field)"
		            aria-describedby="\(S.key)-hint">
		      <option value="" disabled selected>\(S.prompt)</option>
		      <optgroup label="\(S.authoredLabel)">
		\(S._authored)
		      </optgroup>
		      <optgroup class="select-live" label="\(S.liveLabel)"
		                data-live="\(S.options)" data-order="id.asc">
		        <template data-item><option value="{id}" data-text="{id}"></option></template>
		      </optgroup>
		    </select>
		    <p class="select-hint" id="\(S.key)-hint">\(S.hint)</p>
		  </form>
		  <form class="select-mint" data-form="\(S.mintForm)"
		        data-entity="\(S.options)" data-action="upsert">
		    <label class="select-label" for="\(S.key)-mint">\(S.mintLabel)</label>
		    <div class="select-mint-line">
		      <input class="select-mint-input" id="\(S.key)-mint" name="id" type="text"
		             required autocomplete="off" pattern="\(S.pattern)" maxlength="\(S.maxLen)"
		             placeholder="\(S.mintPlaceholder)" aria-describedby="\(S.key)-mint-hint">
		      <button type="submit" class="select-mint-button">\(S.mintButton)</button>
		    </div>
		    <p class="select-hint" id="\(S.key)-mint-hint">\(S.mintHint)</p>
		    <p class="invalid" id="\(S.key)-mint-invalid" hidden>\(S.mintInvalid)</p>
		  </form>
		</omnishell--select>
		"""
}
