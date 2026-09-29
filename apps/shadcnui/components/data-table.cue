// omnishell--data-table: what a table becomes once its rows can be stated by
// the program and a region can state facts about them.
//
// The rows are `seed:`. A tab entity has no migration to render into, so the
// terminal writes the rows itself when it first opens the collection
// (plugins/pronto/schema.cue). No minting form ships, and the chart has no
// arrival state: the cursor row is seeded too, from the machine's own initial
// world — one CUE value emitted three times, as the seed, as the machine's
// context and as the readout's data-empty-row, so the three cannot disagree.
//
// Selection is a derived column, which is why no machine here writes one, and
// it is the only ARIA state a row carries. The screen's panes carry the rest:
// the closed clause set, the four positional attributes refused, and why Home
// and End do not ship.
//
// The arrow that records a keystroke also clears the cursor: a selection the
// filter has removed is one nothing can name, its row being unrendered. The
// empty cursor is a real spelling — the entry region owns the ids it resolves
// to and writes the first row of the current read. That region is a LIST under
// a cap and not a slot, because a slot's filter must witness one row and a cap
// is not a witness (interpreter/lint.ts unwitnessedSlot); the cap is also what
// keeps its ids to one copy.
//
// A read that matches nothing renders no entry pair, and an arrow naming a
// form that is not on the screen is a program error the terminal throws. What
// keeps that unreachable is the stylesheet: with `.dt-body` empty the grid is
// not drawn, so it is not a tab stop and no key can land on it. That is the
// same `:empty` the render sweep strips whitespace to keep honest.
package components

import (
	"list"
	"strings"

	omni "bonisoft.org/plugins/omnishell/components"
	terminal "bonisoft.org/plugins/omnishell:terminal"
)

// One column, in both places a column appears. No control field: nothing here
// mints a row, so a column's whole job is to be read.
#DataColumn: {
	col:  =~"^[a-z_]+$"
	head: string
	// A number reads down its own edge, so it is set against it.
	numeric: *false | bool
	// Whether a reader can ask for this column's order. Two commands rather
	// than one toggle, which is shadcn's own header menu: a toggle would have
	// to know which order it is already in and answer differently, and that is
	// a conditional no binding states. Two literals need no such answer.
	sortable: *false | bool
}

#DataTable: D={
	// The rows the grid renders: one row of the collection is one row of it.
	collection: string
	// Where the query and the cursor live. Two collections for the reason
	// /table's are two: an interpolated filter is re-resolved when its parent's
	// row moves, so the table a keystroke writes must not be the table the rows
	// are read from.
	cursors: string
	row:     *"the" | string
	field:   *"state" | string
	// Prefixes every id this component emits.
	key:     *"data-table" | string
	caption: string
	// Which order the grid opens in — a key of the map below, not a clause.
	// Every order the grid can be read in is stated here, in the file, and a
	// column picks among them: an order interpolated whole would let a row name
	// a COLUMN, and the reads this screen has would stop being enumerable.
	opensSorted:  string
	filterColumn: string
	filterLabel:  string
	placeholder:  string
	hint:         string
	// What stands where the rows would be when the filter matches none.
	none: string
	// How long the typed query may be: the control's `maxlength` and the
	// column's constraint from one number.
	maxLen:   *48 | int & >=1
	queryCel: "this.size() <= \(D.maxLen)"
	// Stated once, emitted twice: the header row and the row template. The
	// first column is the row header, and its column is the collection's pk.
	columns: [...#DataColumn] & [_, _, ...]
	// The rows the program states. The pk is the row header a reader reads and
	// the id aria-activedescendant points at, so it must be a valid DOM id.
	rows: [...{id: =~"^[A-Za-z][A-Za-z0-9_-]*$", ...}]
	// Which row the grid opens on. A member of `rows`, or the grid opens with
	// nothing chosen and the first arrow enters at the top.
	opensOn: string
	pickForm:   string
	stepForm:   string
	sortForm:   string
	// The verb in the pick button's accessible name. Its text is the invoice
	// number, so without this a row header reads as a command with none.
	pickLabel: string

	_input:   "\(D.key)-filter"
	_caption: "\(D.key)-caption"
	// Both regions here re-hydrate whenever the query moves, and a render
	// sweeps every child of a region that is not one of its rows — the
	// <template data-item> included. So both point at a NAMED template, which
	// lives in the screen's own map and survives every re-hydration
	// (decision-33).
	_template: "\(D.key)-row"
	_entry:    "\(D.key)-entry"
	_grid:     "\(D.key)-grid"
	_head:     D.columns[0]
	_rest: [for i, c in D.columns if i > 0 {c}]

	// The row header names the row, and what names a row in the store is its
	// pk — so the first column is `id`.
	_pkFirst: true & (D._head.col == "id")
	_opensOnIsARow: true & list.Contains([for r in D.rows {r.id}], D.opensOn)

	_sortable: [for c in D.columns if c.sortable {c}]
	_dirs: [{k: "asc", aria: "ascending", label: "ascending"}, {k: "desc", aria: "descending", label: "descending"}]
	// key → clause. The keys are what a row holds and the clauses what the
	// store reads, so nothing outside this map can name an order.
	_orderMap: {for c in D._sortable for d in D._dirs {"\(c.col)_\(d.k)": "\(c.col).\(d.k)"}}
	_order: (omni.#attrJSON & {in: {by: "{sort}", of: D._orderMap}}).out
	_opensSortedIsAKey: true & list.Contains([for k, _ in D._orderMap {k}], D.opensSorted)

	// aria-sort is per COLUMN and the order is one fact, so the header needs the
	// comparison already made: one column per sortable header, moving together
	// as literals of whichever form was pressed. The projection cannot answer
	// here — a header row is not a row of the collection.
	_sortCol: {for c in D._sortable {(c.col): "srt_\(c.col)"}}
	// One sentence behind the map and the column's constraint, so a key the
	// region could not read is a value the store refuses.
	sortCel:      "this in [" + strings.Join([for k, _ in D._orderMap {"'\(k)'"}], ", ") + "]"
	sortStateCel: "this in ['ascending', 'descending', 'none']"
	_sortState: {for c in D._sortable for d in D._dirs {
		"\(c.col)_\(d.k)": {for o in D._sortable {(D._sortCol[o.col]): [if o.col == c.col {d.aria}, "none"][0]}}
	}}

	// One state, one targetless arrow: the machine records what the reader
	// types and stays (decision-23, decision-24). /table's `pending` state and
	// its after: {"0": …} exist only to state a row nothing else could write;
	// the seed states this one, so there is no arrival to draw.
	machine: terminal.#Machine & {
		field:   D.field
		initial: "typing"
		context: {
			query:  ""
			cursor: D.opensOn
			sort:   D.opensSorted
			for col, v in D._sortState[D.opensSorted] {(col): v}
		}
		states: typing: on: ("input@" + D._input): {
			assign: {
				query: {type: "event", params: field: "value"}
				// A cursor the filter has removed names a row that is not
				// rendered: no form to submit, no element to point at.
				cursor: ""
			}
		}
	}

	// The machine's initial world as a row. The entity seeds it, the readout
	// falls back to it, and the machine states it — one value, so decision-07's
	// agreement is by construction rather than by review.
	cursorSeed: {
		id:         D.row
		(D.field):  D.machine.initial
		for k, v in D.machine.context {(k): v}
	}
	emptyRow: (omni.#attrJSON & {in: D.cursorSeed}).out

	// No index or count: the attributes they would land on are the ones the
	// closing pane refuses, so asking for the clauses would compute an answer
	// with nowhere to go.
	_project: (omni.#attrJSON & {in: {
		chosen: eq: ["id", "{cursor}"]
		nxt:    "next"
		prv:    "prev"
		fst:    "first"
		lst:    "last"
	}}).out

	// Ctrl, because APG says so for a grid: Home and End move within a ROW and
	// the chord moves to the grid's ends. This grid's caret is a row and its
	// cells are static text (decision-35), so there is no row to move within and
	// the bare keys would name a movement the widget does not have.
	_keys: (omni.#attrJSON & {in: {
		ArrowDown:  "\(D.key)-next-{cursor}"
		ArrowUp:    "\(D.key)-prev-{cursor}"
		"Ctrl+Home": "\(D.key)-first-{cursor}"
		"Ctrl+End":  "\(D.key)-last-{cursor}"
	}}).out

	// A sortable header is a th carrying aria-sort and two submit buttons, each
	// its own form stating the whole order in literals. No control here toggles:
	// pressing "ascending" twice states the same row twice.
	_sortForms: {for c in D._sortable {(c.col): strings.Join([for d in D._dirs {
		"""
			                  <form id="\(D.key)-sort-\(c.col)-\(d.k)" data-form="\(D.sortForm)"
			                        data-entity="\(D.cursors)" data-action="upsert">
			                    <input type="hidden" name="id" data-value="\(D.row)">
			                    <input type="hidden" name="sort" data-value="\(c.col)_\(d.k)">
			\(strings.Join([for col, v in D._sortState["\(c.col)_\(d.k)"] {
				"                    <input type=\"hidden\" name=\"\(col)\" data-value=\"\(v)\">"
			}], "\n"))
			                    <button type="submit" class="dt-sort" tabindex="-1"
			                            aria-label="Sort by \(c.head), \(d.label)">\((#sortGlyph & {dir: d.k}).out)</button>
			                  </form>
			"""
	}], "\n")}}

	_headCells: strings.Join([for c in D.columns {
		[
			if c.sortable {
				"""
					                <th scope="col"\((#numeric & {in: c, prefix: "dt"}).out) aria-sort="{\(D._sortCol[c.col])}">
					                  <span class="dt-head">\(c.head)</span>
					                  <span class="dt-sorts">
					\(D._sortForms[c.col])
					                  </span>
					                </th>
					"""
			},
			"                <th scope=\"col\"\((#numeric & {in: c, prefix: "dt"}).out)>\(c.head)</th>",
		][0]
	}], "\n")

	_cells: strings.Join([for c in D._rest {
		"                <td\((#numeric & {in: c, prefix: "dt"}).out) data-text=\"{\(c.col)}\"></td>"
	}], "\n")

	_step: {form: D.stepForm, entity: D.cursors, pk: D.row}
	_next:  (#dataStep & _step & {id: "\(D.key)-next-{id}", to: "{nxt}"}).out
	_prev:  (#dataStep & _step & {id: "\(D.key)-prev-{id}", to: "{prv}"}).out
	_first: (#dataStep & _step & {id: "\(D.key)-first-{id}", to: "{fst}"}).out
	_last:  (#dataStep & _step & {id: "\(D.key)-last-{id}", to: "{lst}"}).out
	// The empty cursor's own pair: `{cursor}` resolves to nothing, so these are
	// the ids the arrow keys reach when no row is chosen.
	_enterNext: (#dataStep & _step & {id: "\(D.key)-next-", to: "{id}"}).out
	_enterPrev: (#dataStep & _step & {id: "\(D.key)-prev-", to: "{id}"}).out
	// Ctrl+Home from no cursor is the head, which is the row this limit=1 read
	// already holds. Ctrl+End has no counterpart here and none is emitted: the
	// last row is the head of the REVERSED order, and this table's order is a
	// closed map, so reversing it means a second map rather than one literal.
	// With a cursor the projection answers both, so the chord that is missing is
	// the one from an empty caret alone.
	_enterFirst: (#dataStep & _step & {id: "\(D.key)-first-", to: "{id}"}).out

	// The grid is a tab stop and its rows are not: the reader's focus stays on
	// the container and `aria-activedescendant` names the row, which is APG's
	// own answer for a widget whose items nothing calls focus() on. The pick
	// button is therefore out of the tab sequence — reachable by pointer,
	// reached by arrow for everyone else.
	_table: """
		        <table class="dt" id="\(D._grid)" role="grid" tabindex="0"
		               aria-labelledby="\(D._caption)" aria-activedescendant="{cursor}"
		               data-key='\(D._keys)'>
		          <caption class="dt-caption" id="\(D._caption)">\(D.caption)</caption>
		          <thead>
		            <tr>
		\(D._headCells)
		            </tr>
		          </thead>
		          <template data-item data-name="\(D._template)"><tr class="dt-row" id="{id}"
		              aria-selected="{chosen}">
		            <th scope="row" class="dt-rowhead">
		              <form id="\(D.key)-pick-{id}" data-form="\(D.pickForm)"
		                    data-entity="\(D.cursors)" data-action="upsert">
		                <input type="hidden" name="id" data-value="\(D.row)">
		                <input type="hidden" name="cursor" data-value="{id}">
		                <button type="submit" class="dt-pick" tabindex="-1"
		                        aria-label="\(D.pickLabel) {id}" data-text="{id}"></button>
		              </form>
		              <div class="dt-steps" hidden>
		\(D._next)
		\(D._prev)
		\(D._first)
		\(D._last)
		              </div>
		            </th>
		\(D._cells)
		          </tr></template>
		          <tbody class="dt-body" data-live="\(D.collection)"
		                 data-filter="\(D.filterColumn)=ilike.*{query}*" data-order='\(D._order)'
		                 data-template="\(D._template)" data-project='\(D._project)'></tbody>
		        </table>
		"""

	_scroll: #ScrollArea & {axis: "x", name: D._caption, carriedBy: true, body: D._table}

	markup: """
		<omnishell--data-table>
		  <div class="dt-field" data-live="\(D.cursors)" data-filter="id=eq.\(D.row)"
		       data-machine='\((omni.#attrJSON & {in: D.machine}).out)'>
		    <label class="dt-label" for="\(D._input)">\(D.filterLabel)</label>
		    <input class="dt-input" id="\(D._input)" type="search" value="{query}"
		           placeholder="\(D.placeholder)" autocomplete="off" spellcheck="false"
		           maxlength="\(D.maxLen)" aria-describedby="\(D.key)-hint">
		    <p class="dt-hint" id="\(D.key)-hint">\(D.hint)</p>
		  </div>
		  <div class="dt-frame" data-live="\(D.cursors)" data-filter="id=eq.\(D.row)">
		    <template data-item>
		      <div class="dt-hold">
		\(D._scroll.markup)
		        <p class="dt-none">\(D.none)</p>
		        <template data-item data-name="\(D._entry)"><div class="dt-enter">
		\(D._enterNext)
		\(D._enterPrev)
		\(D._enterFirst)
		        </div></template>
		        <div class="dt-entry" hidden data-live="\(D.collection)"
		             data-filter="\(D.filterColumn)=ilike.*{query}*&amp;limit=1"
		             data-order='\(D._order)' data-template="\(D._entry)"></div>
		      </div>
		    </template>
		  </div>
		</omnishell--data-table>
		"""
}

// A step form states one column of one row, so it is two hidden inputs and no
// control: `data-key` submits it, the way a form with no button submits on
// change. `to` is where the key is going — a neighbour the projection named.
#dataStep: S={
	id:     string
	to:     string
	form:   string
	entity: string
	pk:     string
	out: """
		                <form id="\(S.id)" data-form="\(S.form)"
		                      data-entity="\(S.entity)" data-action="upsert">
		                  <input type="hidden" name="id" data-value="\(S.pk)">
		                  <input type="hidden" name="cursor" data-value="\(S.to)">
		                </form>
		"""
}

// The glyph a sort command shows. Out of the accessibility tree: the button is
// named by its aria-label, and a caret joining that name would read as part of
// the command.
#sortGlyph: G={
	dir: "asc" | "desc"
	_d:  [if G.dir == "asc" {"M5 12l5-5 5 5"}, "M5 8l5 5 5-5"][0]
	out: """
		<svg width="14" height="14" viewBox="0 0 20 20" aria-hidden="true"><path d="\(G._d)" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg>
		"""
}
