// omnishell--table, omnishell--scroll-area, omnishell--aspect-ratio.
//
// The first component here whose content is a region of MANY rows: the `<tr>`
// is a `<template data-item>` like any other item. The semantics are the
// elements' — a `<caption>`, `<th scope="col">`, `<th scope="row">` — and not
// one `aria-*`, a table saying role="table" repeating its own tag name.
//
// The rows are the reader's: this collection declares no `seed:`, so the
// minting form ships with the component. Seeding is available — the terminal
// writes a tab entity's seed rows when it first opens the collection — and
// /data-table is the screen that takes it. The columns are stated ONCE and
// emitted three times — header row, row template, minting controls — so a
// column reaching one and not the others cannot exist.
//
// THE ROW TEMPLATE IS NAMED, AND THAT IS LOAD-BEARING. A region's first render
// sweeps every child that is not one of its rows, the `<template>` included; a
// nested region re-hydrates whenever the column its filter interpolates moves,
// and a re-hydration finding no template treats the region as a slot, which
// throws on the second matching row. A named template lives in the screen's
// map rather than the region and survives every re-hydration (decision-33).
//
// Sorting is expressible and is refused for its price. `data-order` is read
// raw, so no column interpolates into it and no machine writes it — but a
// `sort` column fanned out through `data-when`, each arm carrying a `<tbody>`
// whose `data-order` is that arm's literal, needs no interpolation at all. It
// costs one stamped copy of the table per order and moves the affordance off
// the column headers, which is why this component draws none and the order is
// the author's, stated in the caption.
package components

import (
	"list"
	"strings"

	omni "bonisoft.org/plugins/omnishell/components"
	terminal "bonisoft.org/plugins/omnishell:terminal"
)

// One column, in every place a column appears.
#TableColumn: {
	// The row's column, and the minting control's `name`.
	col:  =~"^[a-z_]+$"
	head: string
	// What the minting form offers for it. A `select` carries its own options;
	// a `text` carries a placeholder.
	control: "text" | "select"
	options?: [...string]
	placeholder?: string
	// A number reads down its own edge, so it is set against it.
	numeric: *false | bool
}

#ScrollArea: A={
	// The accessible name — a scroll box is a tab stop, and an unnamed tab stop
	// is a region a reader arrives in with nothing said. `name` is the text of
	// it, unless `carriedBy` says it is the id of the element already stating
	// it: one field and a flag rather than two fields to hold apart, because
	// one attribute is emitted either way and a box named twice is one fact in
	// two spellings.
	name:      string
	carriedBy: *false | bool
	_attr: [
		if A.carriedBy {"aria-labelledby=\"\(A.name)\""},
		"aria-label=\"\(A.name)\"",
	][0]
	// Which way the box scrolls. How far is the stylesheet's.
	axis: "x" | "y"
	body: string

	markup: """
		<omnishell--scroll-area>
		  <div class="scroll-area scroll-\(A.axis)" tabindex="0" role="region" \(A._attr)>
		\(A.body)
		  </div>
		</omnishell--scroll-area>
		"""
}

#AspectRatio: R={
	// A closed vocabulary, so no instance carries a length of its own — the
	// rule #Skeleton's shapes follow, one component on.
	ratio: "16-9" | "4-3" | "1-1"
	body:  string

	markup: """
		<omnishell--aspect-ratio>
		  <div class="aspect aspect-\(R.ratio)">
		\(R.body)
		  </div>
		</omnishell--aspect-ratio>
		"""
}

#Table: T={
	// The collection the rows live in: one row of the table is one row of it.
	collection: string
	// The collection the filter is typed into. Two collections, for the reason
	// /command's are two: an interpolated filter is re-resolved when its
	// parent's row moves, so the table a keystroke writes must not be the table
	// the rows are read from.
	queries: string
	row:     *"the" | string
	field:   *"state" | string
	// Prefixes every id this component emits.
	key: *"table" | string
	// A caption states what the rows are and the order they are in, because the
	// order is the author's and a reader has no way to ask for another.
	caption: string
	// The region's order clause. A literal: `data-order` is read raw, so a
	// placeholder here would reach the store as a column name.
	order: *"id.asc" | string
	// The column the filter narrows on, under `ilike`.
	filterColumn: string
	filterLabel:  string
	placeholder:  string
	hint:         string
	// What stands where the rows would be, before the first one is minted and
	// when the filter matches none.
	none: string
	// How long the typed query may be: the control's `maxlength` and the
	// column's constraint from one number.
	maxLen:   *48 | int & >=1
	queryCel: "this.size() <= \(T.maxLen)"
	// Stated once, emitted three times: the header row, the row template, and
	// the minting form's controls. The first column is the row header, and its
	// column is the collection's pk.
	columns: [...#TableColumn] & [_, _, ...]
	mintForm:    string
	mintLegend:  string
	mintButton:  string
	mintHint:    string
	mintInvalid: string

	// The row header names the row, and what names a row in the store is its
	// pk — so the first column is `id` and the minting form's first control
	// carries the key the upsert writes under.
	_pkFirst: true & (T._head.col == "id")

	_input:    "\(T.key)-filter"
	_caption:  "\(T.key)-caption"
	_template: "\(T.key)-row"
	_head:     T.columns[0]
	_rest: [for i, c in T.columns if i > 0 {c}]

	// Two states, and both are load-bearing. `pending` states the query row on
	// the terminal's own clock — the arrival arrow a screen draws when nothing else can state its row, here
	// aimed at the row the TABLE's frame hangs off, because a table has to be
	// on the screen before anyone types. `typing` then records what the reader
	// types through a targetless arrow that acts and stays (decision-23,
	// decision-24). The arrow narrows to the field's id: a control carrying no
	// `value` declines it rather than writing something it never showed.
	machine: terminal.#Machine & {
		field:   T.field
		initial: "pending"
		context: query: ""
		states: {
			pending: after: "0": "typing"
			typing: on: ("input@" + T._input): {
				assign: query: {type: "event", params: field: "value"}
			}
		}
	}

	_cells: strings.Join(list.Concat([
		["          <th scope=\"row\" data-text=\"{\(T._head.col)}\"></th>"],
		[for c in T._rest {
			"          <td\((#numeric & {in: c, prefix: "tbl"}).out) data-text=\"{\(c.col)}\"></td>"
		}],
	]), "\n")

	_headCells: strings.Join([for c in T.columns {
		"            <th scope=\"col\"\((#numeric & {in: c, prefix: "tbl"}).out)>\(c.head)</th>"
	}], "\n")

	_mintCells: strings.Join([for c in T.columns {"""
		        <div class="tbl-mint-cell">
		          <label class="tbl-mint-label" for="\(T.key)-mint-\(c.col)">\(c.head)</label>
		\((#mintControl & {key: T.key, "col": c}).out)
		        </div>
		"""}], "\n")

	_table: """
		    <table class="tbl">
		      <caption class="tbl-caption" id="\(T._caption)">\(T.caption)</caption>
		      <thead>
		        <tr>
		\(T._headCells)
		        </tr>
		      </thead>
		      <template data-item data-name="\(T._template)"><tr class="tbl-row">
		\(T._cells)
		      </tr></template>
		      <tbody class="tbl-body" data-live="\(T.collection)"
		             data-filter="\(T.filterColumn)=ilike.*{query}*" data-order="\(T.order)"
		             data-template="\(T._template)"></tbody>
		    </table>
		"""

	_scroll: #ScrollArea & {axis: "x", name: T._caption, carriedBy: true, body: T._table}

	// The caption's id is inside an item template, and unique because the
	// region above it pins one row with `eq` — which is also why the machine's
	// event key may name a literal id: a template stamped twice would carry
	// two elements answering to it.
	markup: """
		<omnishell--table>
		  <form class="tbl-mint" data-form="\(T.mintForm)"
		        data-entity="\(T.collection)" data-action="upsert">
		    <fieldset class="tbl-mint-set">
		      <legend class="tbl-mint-legend">\(T.mintLegend)</legend>
		      <div class="tbl-mint-grid">
		\(T._mintCells)
		      </div>
		      <button type="submit" class="tbl-mint-button">\(T.mintButton)</button>
		      <p class="tbl-hint" id="\(T.key)-mint-hint">\(T.mintHint)</p>
		      <p class="invalid" id="\(T.key)-mint-invalid" hidden>\(T.mintInvalid)</p>
		    </fieldset>
		  </form>
		  <div class="tbl-field" data-live="\(T.queries)" data-filter="id=eq.\(T.row)"
		       data-machine='\((omni.#attrJSON & {in: T.machine}).out)'>
		    <label class="tbl-label" for="\(T._input)">\(T.filterLabel)</label>
		    <input class="tbl-input" id="\(T._input)" type="search" value="{query}"
		           placeholder="\(T.placeholder)" autocomplete="off" spellcheck="false"
		           maxlength="\(T.maxLen)" aria-describedby="\(T.key)-hint">
		    <p class="tbl-hint" id="\(T.key)-hint">\(T.hint)</p>
		  </div>
		  <div class="tbl-frame" data-live="\(T.queries)" data-filter="id=eq.\(T.row)">
		    <template data-item>
		      <div class="tbl-hold">
		\(T._scroll.markup)
		        <p class="tbl-none">\(T.none)</p>
		      </div>
		    </template>
		  </div>
		</omnishell--table>
		"""
}

// The one class a cell carries, and only where a column asked for it. The
// prefix is the caller's, because two components own two stylesheets and
// neither prefix is derivable from a component's `key`.
#numeric: N={
	in:     {numeric: bool, ...}
	prefix: string
	out: [if N.in.numeric {" class=\"\(N.prefix)-num\""}, ""][0]
}

#mintControl: M={
	key: string
	col: #TableColumn
	_id: "\(M.key)-mint-\(M.col.col)"
	_options: strings.Join([for o in M.col.options {
		"            <option value=\"\(o)\">\(o)</option>"
	}], "\n")
	out: [
		if M.col.control == "select" {"""
			          <select class="tbl-mint-input" id="\(M._id)" name="\(M.col.col)" required>
			            <option value="" disabled selected>\(M.col.head)…</option>
			\(M._options)
			          </select>
			"""},
		"""
			          <input class="tbl-mint-input" id="\(M._id)" name="\(M.col.col)" type="text"
			                 required autocomplete="off" placeholder="\(M.col.placeholder)">
			""",
	][0]
}
