// omnishell--command: shadcn's Command — a list filtered by typed text, over
// two collections. The keystroke's table must not be the table the options
// read: an interpolated filter re-resolves when its parent's row moves, so a
// region reading what the keystroke wrote would race its own wake.
//
// The screen carries the arguments — why the caret and the choice are two
// columns, why the list is one tab stop, and what one flat list costs.
package components

import (
	omni "bonisoft.org/plugins/omnishell/components"
	terminal "bonisoft.org/plugins/omnishell:terminal"
)

#Command: C={
	// The collection holding the one row the reader types into.
	queries: string
	// The collection the commands are rows of.
	items: string
	row:   *"the" | string
	field: *"state" | string
	// Prefixes every id this component emits.
	key:         *"command" | string
	label:       string
	placeholder: string
	hint:        string
	// The label of the control that runs what the caret stands on.
	run: string
	// What the panel says when the filter answers nothing.
	none: string
	// How long the typed query may be. One number, emitted as the control's
	// `maxlength` and exported as the column's constraint, so the gate a reader
	// meets and the schema a device- or server-tier consumer would enforce
	// cannot drift apart (decision-16).
	maxLen:   *64 | int & >=1
	queryCel: "this.size() <= \(C.maxLen)"
	// The palette, in the order it reads. `group` is a column rather than a
	// second region, so that grouping cannot break the walk: the projection
	// answers `next` within one read.
	commands: [...{name: =~"^[a-z]+$", title: string, group: string}] & [_, ...]

	// Both regions must read the same set — the head of the visible list and the
	// head the first arrow lands on are the same row — so the filter and the
	// order are stated here and interpolated twice.
	_filter: "label=ilike.*{query}*"
	_order:  "pos.asc"
	_endOrder: "pos.desc"

	_input: "\(C.key)-query"
	_list:  "\(C.key)-list"
	// The form Enter commits. It carries the caret's own column, so the key
	// needs no binding of its own — ROVING_KEYS admits the arrows and Home and
	// End, never Enter, and a form holding a text input and a submit button is
	// submitted by Enter natively. The button is that same statement for a
	// pointer, and having one is also why this form does not submit on `change`.
	_form: "\(C.key)-run"

	// The rows the terminal writes when it first opens the collection. `pos` is
	// the order the arrows walk, which is the order they are stated in.
	seed: [for i, c in C.commands {
		id:    c.name
		label: c.title
		group: c.group
		pos:   i + 1
	}]

	// One state, one targetless arrow: it acts and stays, which is how a single
	// state records a continuously changing value.
	machine: terminal.#Machine & {
		field:   C.field
		initial: "typing"
		context: {query: "", active: "", chosen: ""}
		states: typing: on: ("input@" + C._input): {
			assign: {
				query: {type: "event", params: field: "value"}
				// The caret cannot outlive the read it was standing in: an
				// option the filter dropped is not rendered, so its move forms
				// are not there for an arrow to name.
				active: ""
			}
		}
	}

	// The machine's initial world as a row: the entity seeds it and the machine
	// states it, one value, so decision-07's agreement is by construction. The
	// seeding is also what gives the outer region a row to STAMP, which a nested
	// region needs before it hydrates at all — the listbox is nested.
	querySeed: {
		id:        C.row
		(C.field): C.machine.initial
		for k, v in C.machine.context {(k): v}
	}
	// `act` is the caret and `sel` is the choice: two answers over the same
	// rows, because the option a reader is standing on is not the one they ran.
	_project: (omni.#attrJSON & {in: {
		act: eq: ["id", "{active}"]
		sel: eq: ["id", "{chosen}"]
		nxt: "next"
		prv: "prev"
		// Unpartitioned: the palette is one flat list, so both ends of the lane
		// are both ends of the set — and of whatever the filter has left of it.
		fst: "first"
		lst: "last"
	}}).out

	_keys: (omni.#attrJSON & {in: {
		ArrowDown: "\(C.key)-nx-{active}"
		ArrowUp:   "\(C.key)-pv-{active}"
		Home:      "\(C.key)-fs-{active}"
		End:       "\(C.key)-ls-{active}"
	}}).out

	// A move form states one column of the query row: two hidden inputs and no
	// control, submitted by `data-key` the way a buttonless form submits on
	// change.
	#move: M={
		id: string
		to: string
		out: """
			                <form role="none" id="\(M.id)" data-form="\(C.key)-move"
			                      data-entity="\(C.queries)" data-action="upsert">
			                  <input type="hidden" name="id" data-value="\(C.row)">
			                  <input type="hidden" name="active" data-value="\(M.to)">
			                </form>
			"""
	}

	_next:  (#move & {id: "\(C.key)-nx-{id}", to: "{nxt}"}).out
	_prev:  (#move & {id: "\(C.key)-pv-{id}", to: "{prv}"}).out
	_first: (#move & {id: "\(C.key)-fs-{id}", to: "{fst}"}).out
	_last:  (#move & {id: "\(C.key)-ls-{id}", to: "{lst}"}).out
	// The empty caret's own set. `{active}` resolves to nothing before the first
	// key, so these are the ids the keys reach then. Three land on the head of
	// whatever the filter is answering now — entering a list at the top is what
	// ArrowDown, ArrowUp and Home all mean with nothing chosen.
	_enterNext:  (#move & {id: "\(C.key)-nx-", to: "{id}"}).out
	_enterPrev:  (#move & {id: "\(C.key)-pv-", to: "{id}"}).out
	_enterFirst: (#move & {id: "\(C.key)-fs-", to: "{id}"}).out
	// End is the one that does not, so it takes its own read: the same filter
	// and limit under the reverse order, whose single row is the last one.
	_enterLast: (#move & {id: "\(C.key)-ls-", to: "{id}"}).out

	// THE TEMPLATES ARE NAMED, AND THAT IS LOAD-BEARING. A region's render
	// sweeps every child that is not one of its rows, `<template>` included, and
	// this list re-hydrates on every keystroke because its filter interpolates
	// the query. A re-hydration finding no template reads the region as a slot,
	// which for a projection is a ProjectionError. A named template lives in the
	// screen's own map, which no render sweeps (decision-33).
	_optionTemplate: """
		            <template data-item data-name="\(C.key)-option">
		              <li class="cmd-item" role="none">
		                <form role="none" id="\(C.key)-pick-{id}" data-form="\(C.key)-pick"
		                      data-entity="\(C.queries)" data-action="upsert">
		                  <input type="hidden" name="id" data-value="\(C.row)">
		                  <input type="hidden" name="chosen" data-value="{id}">
		                  <input type="hidden" name="active" data-value="{id}">
		                  <button type="submit" class="cmd-option" id="{id}"
		                          role="option" tabindex="-1" aria-selected="{sel}"
		                          data-active="{act}"><span class="cmd-option-label"
		                          data-text="{label}"></span><span class="cmd-option-group"
		                          data-text="{group}"></span></button>
		                </form>
		\(C._next)
		\(C._prev)
		\(C._first)
		\(C._last)
		              </li>
		            </template>
		"""

	_entryTemplate: """
		            <template data-item data-name="\(C.key)-entry"><div class="cmd-enter">
		\(C._enterNext)
		\(C._enterPrev)
		\(C._enterFirst)
		            </div></template>
		            <template data-item data-name="\(C.key)-end"><div class="cmd-enter">
		\(C._enterLast)
		            </div></template>
		"""

	markup: """
		<omnishell--command>
		  <div class="cmd" data-live="\(C.queries)" data-filter="id=eq.\(C.row)"
		       data-machine='\((omni.#attrJSON & {in: C.machine}).out)'>
		    <template data-item>
		      <div class="cmd-hold">
		        <form class="cmd-run" id="\(C._form)" data-form="\(C._form)"
		              data-entity="\(C.queries)" data-action="upsert">
		          <input type="hidden" name="id" data-value="\(C.row)">
		          <input type="hidden" name="chosen" data-value="{active}">
		          <label class="cmd-label" for="\(C._input)">\(C.label)</label>
		          <input class="cmd-input" id="\(C._input)" type="search" value="{query}"
		                 role="combobox" aria-expanded="true" aria-controls="\(C._list)"
		                 aria-activedescendant="{active}"
		                 data-key='\(C._keys)'
		                 placeholder="\(C.placeholder)" autocomplete="off" spellcheck="false"
		                 maxlength="\(C.maxLen)" aria-describedby="\(C.key)-hint">
		          <button type="submit" class="cmd-go">\(C.run)</button>
		        </form>
		        <p class="cmd-hint" id="\(C.key)-hint">\(C.hint)</p>
		        <p class="cmd-none">\(C.none)</p>
		        <ul class="cmd-list" id="\(C._list)" role="listbox" aria-label="\(C.label)"
		            data-live="\(C.items)" data-order="\(C._order)"
		            data-filter="\(C._filter)" data-project='\(C._project)'
		            data-template="\(C.key)-option"></ul>
		        <div class="cmd-entry" hidden data-live="\(C.items)" data-order="\(C._order)"
		             data-filter="\(C._filter)&amp;limit=1"
		             data-template="\(C.key)-entry"></div>
		        <div class="cmd-entry" hidden data-live="\(C.items)" data-order="\(C._endOrder)"
		             data-filter="\(C._filter)&amp;limit=1"
		             data-template="\(C.key)-end"></div>
		        <code class="cmd-readout" data-text="id: {id} · query: {query} · active: {active} · chosen: {chosen}"></code>
		      </div>
		    </template>
		  </div>
		\(C._optionTemplate)
		\(C._entryTemplate)
		</omnishell--command>
		"""
}
