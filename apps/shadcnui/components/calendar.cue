// omnishell--calendar and omnishell--date-picker.
//
// The one screen in the catalog that names a Jessie module, and the line runs
// where decision-38 puts it: a chart may name a leaf for a VALUE it cannot
// compute, and nowhere else. A month away from a month is that value. Every
// other fact here is the ARIA projection answering over rows the region
// already holds — which cell is selected, which cells belong to the visible
// month, where a cell sits in its week, and which cell each arrow key moves
// to.
//
// The day cells are ROWS, and they are SEEDED. They cannot be minted: a
// machine writes one row, its own, so no arrow can produce a grid's
// forty-two. That is what bounds the app's months — the seed's extent is the
// chart's window, carried as two literals in the leaf's params and clamped
// there, so an arrow at either end names the month it is already on
// (decision-39).
//
// No aria-current="date". Today is a clock reading; a leaf's compartment
// endows nothing, the terminal's clock reaches a machine's `after` delay and
// a form's {now} hidden value, and neither is a date a chart can read.
//
// The keyboard panes on the screen carry the rest: why the caret and the
// chosen date are two columns, why the grid is one tab stop, why the vertical
// arrows need a second read of the same rows, and why Home and End are absent.
package components

import (
	"list"
	"strings"

	omni "bonisoft.org/plugins/omnishell/components"
	terminal "bonisoft.org/plugins/omnishell:terminal"
)

// One grid's worth of arithmetic, stated rather than computed: a comprehension
// turns it into forty-two cells, and the numbers themselves are what a
// calendar cannot derive from its key without a clock or a library.
#CalendarMonth: {
	key:   =~"^[0-9]{4}-[0-9]{2}$"
	// The weekday the 1st falls on, 0 = Sunday: where the month starts in its
	// first row of seven.
	first: int & >=0 & <=6
	len:   int & >=28 & <=31
	prev: {key: =~"^[0-9]{4}-[0-9]{2}$", len: int & >=28 & <=31}
	next: {key: =~"^[0-9]{4}-[0-9]{2}$"}
}

#pad2: P={
	in:  int
	out: [if P.in < 10 {"0\(P.in)"}, "\(P.in)"][0]
}

// The forty-two rows of one grid. Six weeks of seven, so every week row is
// full and a cell's position in its week IS its aria-colindex; the days at
// either end belong to the neighbouring months and say so through their own
// `month` column, which is the column the projection compares.
#GridCells: G={
	month: #CalendarMonth
	out: [
		for i in list.Range(0, 42, 1)
		let d = i - G.month.first
		let before = d < 0
		let after = d >= G.month.len
		let num = [if before {G.month.prev.len + d + 1}, if after {d - G.month.len + 1}, d + 1][0]
		let owner = [if before {G.month.prev.key}, if after {G.month.next.key}, G.month.key][0] {
			id:    "\(G.month.key)-p\((#pad2 & {in: i + 1}).out)"
			grid:  G.month.key
			month: owner
			week:  "w\((i div 7) + 1)"
			dow:   "d\(i mod 7)"
			pos:   i + 1
			// Down each weekday column, then across: the order the vertical
			// arrows read, where the neighbour is a week away. The order alone
			// is not the lane — `dow` is what partitions it, or the foot of one
			// column would name the head of the next.
			colpos: (i mod 7) * 10 + (i div 7)
			day:    "\(num)"
			date:   "\(owner)-\((#pad2 & {in: num}).out)"
		},
	]
}

// One month step, as the three columns it moves. Every value is the same leaf
// under different params, which is what params are for: the window's ends are
// data in the chart, so one module serves both arrows and both instances.
#MonthStep: M={
	module: string
	by:     int
	min:    string
	max:    string
	_ref: {
		emit: string
		out: {type: M.module, params: {by: M.by, min: M.min, max: M.max, "emit": emit}}
	}
	out: {
		month:  (M._ref & {emit: "month"}).out
		label:  (M._ref & {emit: "label"}).out
		active: (M._ref & {emit: "cell"}).out
	}
}

#Calendar: C={
	// The row the visible month and the pick live on, and the collection the
	// day cells are rows of. Two collections, because a filter interpolating
	// the enclosing row is re-resolved when that row moves: the table a pick
	// writes must not be the table the cells are read from.
	collection: *"calendar_demo" | string
	cells:      *"calendar_cell" | string
	row:        *"the" | string
	field:      *"state" | string
	// Prefixes every id this component emits; two instances on one screen.
	key: *"cal" | string
	// The seeded window's ends, which are also the chart's.
	firstMonth: =~"^[0-9]{4}-[0-9]{2}$"
	lastMonth:  =~"^[0-9]{4}-[0-9]{2}$"
	// Where a visit opens: the grid, its name, and the cell — the caret and the
	// chosen date start on the same one.
	month:      =~"^[0-9]{4}-[0-9]{2}$"
	monthLabel: string
	value:      =~"^[0-9]{4}-[0-9]{2}-p[0-9]{2}$"
	module:     *"month-step" | string
	// Sunday first, seven of them: the column headers, and the only place the
	// week's shape is written down.
	weekdays: [...{short: string, name: string}] & [_, _, _, _, _, _, _]
	chosenLabel: *"Chosen" | string

	// The entity name the surface declares the two forms under; the markup
	// carries the table's, as every data-entity does.
	entity: *"CalendarDemo" | string

	pickForm: "\(C.key)-pick"
	moveForm: "\(C.key)-move"

	// Declared here rather than beside the screen, so the form the markup
	// carries and the form the program states are one statement. A move writes
	// `active` alone — the cell a projection named as a neighbour. A pick writes
	// both columns, because choosing a date is also standing on it.
	forms: [
		{id: C.pickForm, entity: C.entity, action: "upsert", fields: [
			{name: "id", control: "hidden", value: C.row},
			{name: "value", control: "hidden"},
			{name: "active", control: "hidden"},
		]},
		{id: C.moveForm, entity: C.entity, action: "upsert", fields: [
			{name: "id", control: "hidden", value: C.row},
			{name: "active", control: "hidden"},
		]},
	]

	_grid:  "\(C.key)-grid"
	_title: "\(C.key)-title"

	// One state and two arrows, both targetless: a month step acts and stays,
	// and a calendar branches on nothing. The entity prints that admission the
	// way /slider's does, as a one-member enum — what is left once the field
	// holds no branch is the three columns each arrow writes.
	machine: terminal.#Machine & {
		field:   C.field
		initial: "browsing"
		context: {
			month:  C.month
			label:  C.monthLabel
			value:  C.value
			active: C.value
		}
		states: browsing: on: {
			("click@\(C.key)-prev"): {assign: (#MonthStep & {module: C.module, by: -1, min: C.firstMonth, max: C.lastMonth}).out}
			("click@\(C.key)-next"): {assign: (#MonthStep & {module: C.module, by: 1, min: C.firstMonth, max: C.lastMonth}).out}
		}
	}

	// The seeded row, and it IS the machine's stated initial world:
	// {...context, id, field: initial} is exactly what a machine region with no
	// item template synthesizes for itself. The grid is a region WITH one and
	// renders only rows that exist, so the same world is written as well as
	// synthesized — one statement here, emitted twice.
	seedRow: {id: C.row} & C.machine.context & {(C.field): C.machine.initial}

	_keys: (omni.#attrJSON & {in: {
		ArrowRight: "\(C.key)-nx-{active}"
		ArrowLeft:  "\(C.key)-pv-{active}"
		ArrowDown:  "\(C.key)-dn-{active}"
		ArrowUp:    "\(C.key)-up-{active}"
		Home:       "\(C.key)-hm-{active}"
		End:        "\(C.key)-en-{active}"
	}}).out

	_project: (omni.#attrJSON & {in: {
		// The three answers a day cell owes, none of them a stored column: it
		// belongs to the grid's own month, it is the one the reader picked, and
		// it sits at this position in its week.
		inmonth: eq: ["month", "{month}"]
		sel: eq: ["id", "{value}"]
		colindex: "index"
	}}).out

	_heads: strings.Join([for i, w in C.weekdays {
		"          <div role=\"columnheader\" class=\"cal-wd\" aria-colindex=\"\(i + 1)\"><abbr title=\"\(w.name)\">\(w.short)</abbr></div>"
	}], "\n")

	// THESE TEMPLATES ARE NAMED, AND THAT IS LOAD-BEARING. A region's render
	// sweeps every child that is not one of its rows, the `<template>`
	// included; the week rows and the lanes below re-hydrate on every month
	// step, because their filter interpolates it — and a re-hydration finding
	// no template reads the region as a SLOT, which for these is a
	// ProjectionError, a projection being a statement about a set. A named
	// template lives in the screen's own map, which no render sweeps
	// (decision-33). Naming them also states each shape once where six week
	// rows would otherwise carry six copies.
	//
	// The cell's `tabindex="-1"` is not decoration: a <button> is focusable
	// without asking, and aria-activedescendant is honoured only while the grid
	// itself holds the focus.
	_cellTemplate: """
		  <template data-item data-name="\(C.key)-cell">
		    <div role="gridcell" class="cal-cell" id="\(C.key)-cell-{id}"
		         aria-colindex="{colindex}" aria-selected="{sel}" data-inmonth="{inmonth}">
		      <form class="cal-pick" data-form="\(C.pickForm)"
		            data-entity="\(C.collection)" data-action="upsert">
		        <input type="hidden" name="id" data-value="\(C.row)">
		        <input type="hidden" name="value" data-value="{id}">
		        <input type="hidden" name="active" data-value="{id}">
		        <button type="submit" class="cal-day" tabindex="-1" data-text="{day}"></button>
		      </form>
		    </div>
		  </template>
		"""

	_weeks: strings.Join([for i in list.Range(0, 6, 1) {"""
		        <div role="row" class="cal-week" aria-rowindex="\(i + 2)"
		             data-live="\(C.cells)" data-filter="grid=eq.{month}&week=eq.w\(i + 1)"
		             data-order="pos.asc" data-template="\(C.key)-cell"
		             data-project='\(C._project)'></div>
		"""}], "\n")

	// One region per ORDER, because a region declares one: the cell an arrow
	// key lands on is the neighbour in that region's reading, and the form each
	// cell carries is what the key submits. Nothing here computes a position.
	#Lane: L={
		name:  string
		fwd:   string
		back:  string
		order: string
		// The column the WALK runs within, where it runs within one. Absent, the
		// lane is the whole grid: a month's days are continuous, so walking off
		// the end of a week is walking into the next one and only the grid's
		// own ends name themselves. Present, an end of the partition names
		// itself instead — the foot of a weekday column is the last cell of
		// that column and not the head of the one after it.
		by?: string
		// The column whose ends Home and End reach, where the lane names them
		// at all. Separate from `by` because the two answers differ on the same
		// lane: arrows walk the month, and Home is the start of the WEEK.
		ends?: string

		_lane: {nxt: _, prv: _, ...}
		if L.by == _|_ {_lane: {nxt: "next", prv: "prev"}}
		if L.by != _|_ {_lane: {nxt: next: L.by, prv: prev: L.by}}
		if L.ends != _|_ {_lane: {fst: first: L.ends, lst: last: L.ends}}

		_endForms: string
		if L.ends == _|_ {_endForms: ""}
		if L.ends != _|_ {
			_endForms: """

				      <form id="\(C.key)-hm-{id}" data-form="\(C.moveForm)"
				            data-entity="\(C.collection)" data-action="upsert">
				        <input type="hidden" name="id" data-value="\(C.row)">
				        <input type="hidden" name="active" data-value="{fst}">
				      </form>
				      <form id="\(C.key)-en-{id}" data-form="\(C.moveForm)"
				            data-entity="\(C.collection)" data-action="upsert">
				        <input type="hidden" name="id" data-value="\(C.row)">
				        <input type="hidden" name="active" data-value="{lst}">
				      </form>
				"""
		}

		template: """
			  <template data-item data-name="\(C.key)-\(L.name)">
			    <div class="cal-lane-forms">
			      <form id="\(C.key)-\(L.fwd)-{id}" data-form="\(C.moveForm)"
			            data-entity="\(C.collection)" data-action="upsert">
			        <input type="hidden" name="id" data-value="\(C.row)">
			        <input type="hidden" name="active" data-value="{nxt}">
			      </form>
			      <form id="\(C.key)-\(L.back)-{id}" data-form="\(C.moveForm)"
			            data-entity="\(C.collection)" data-action="upsert">
			        <input type="hidden" name="id" data-value="\(C.row)">
			        <input type="hidden" name="active" data-value="{prv}">
			      </form>\(L._endForms)
			    </div>
			  </template>
			"""
		region: """
			      <div hidden class="cal-lane" data-live="\(C.cells)" data-filter="grid=eq.{month}"
			           data-order="\(L.order)" data-template="\(C.key)-\(L.name)"
			           data-project='\((omni.#attrJSON & {in: L._lane}).out)'></div>
			"""
	}

	_across: #Lane & {name: "across", fwd: "nx", back: "pv", order: "pos.asc", ends: "week"}
	_down:   #Lane & {name: "down", fwd:   "dn", back: "up", order: "colpos.asc", by: "dow"}

	// The chosen date, read off the cell the pick named: the row holds the
	// cell's key, and the date is that cell's own column. A SLOT rather than a
	// list, because the filter pins a pk — and because a list's own render
	// sweeps the template it contains, which a re-read on every pick would
	// then find missing.
	//
	// The machine's initial and every pick name a seeded cell, so the rowless
	// treatment a nested slot has to declare is `data-empty=""` — nothing.
	// Both readouts below are that slot.
	_chosen: """
		      <p class="cal-chosen">
		        <span class="cal-chosen-label">\(C.chosenLabel)</span>
		        <span class="cal-chosen-slot" data-live="\(C.cells)" data-filter="id=eq.{value}"
		              data-empty=""><output class="cal-chosen-date" data-text="{date}"></output></span>
		      </p>
		"""

	// The header is the MACHINE's region and the grid is a list region over the
	// same row, for the reason /table's two are two: a machine region with no
	// item template binds its row in place, and a region with one hydrates the
	// nested regions the grid is made of. The frame's own template needs no
	// name — its filter is a literal, so it is hydrated once and never again.
	markup: """
		<omnishell--calendar>
		\(C._cellTemplate)
		\(C._across.template)
		\(C._down.template)
		  <div class="cal-card">
		    <div class="cal-head" data-live="\(C.collection)" data-filter="id=eq.\(C.row)"
		         data-machine='\((omni.#attrJSON & {in: C.machine}).out)'>
		      <button type="button" id="\(C.key)-prev" class="cal-step" aria-label="Previous month">
		        <svg width="24" height="24" viewBox="0 0 24 24" aria-hidden="true"><path d="M14 7l-5 5 5 5"
		          fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round"
		          stroke-linejoin="round"/></svg>
		      </button>
		      <h3 class="cal-title" id="\(C._title)" data-text="{label}" aria-live="polite">\(C.monthLabel)</h3>
		      <button type="button" id="\(C.key)-next" class="cal-step" aria-label="Next month">
		        <svg width="24" height="24" viewBox="0 0 24 24" aria-hidden="true"><path d="M10 7l5 5-5 5"
		          fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round"
		          stroke-linejoin="round"/></svg>
		      </button>
		    </div>
		    <div class="cal-frame" data-live="\(C.collection)" data-filter="id=eq.\(C.row)">
		      <template data-item>
		        <div class="cal-body">
		          <div role="grid" id="\(C._grid)" class="cal-grid" tabindex="0"
		               aria-labelledby="\(C._title)" aria-rowcount="7" aria-colcount="7"
		               aria-activedescendant="\(C.key)-cell-{active}"
		               data-key='\(C._keys)'>
		            <div role="row" class="cal-week cal-wds" aria-rowindex="1">
		\(C._heads)
		            </div>
		\(C._weeks)
		          </div>
		\(C._across.region)
		\(C._down.region)
		\(C._chosen)
		        </div>
		      </template>
		    </div>
		  </div>
		</omnishell--calendar>
		"""
}

// The popover is the platform's and the calendar is the component's: nothing
// between them holds state, which is why this definition is a composition and
// not a third machine. The surface carries role="dialog" and a name, because
// the trigger's aria-haspopup promises one and every other invoker in this
// catalog is paired with the role it names. The trigger prints the date it opens onto, through the
// same two reads the calendar's own readout makes — the row holds a cell's
// key, and the date is that cell's column.
#DatePicker: D={
	calendar: #Calendar
	trigger:  string
	label:    string
	_pop:     "\(D.calendar.key)-pop"

	// The date the trigger opens onto, through the same two reads the calendar's
	// own readout makes: the calendar row holds a cell's key, and the date is
	// that cell's column. The outer region is a LIST of the one pinned row
	// rather than a slot, because a region nested in a slot is never hydrated;
	// the inner one is the slot, and it is not the item's root element, which is
	// the other thing a nested region has to be. Its template is NAMED, so the
	// outer region's own render cannot sweep it away (decision-33).
	_readout: """
		      <p class="dp-chosen">
		        <span class="dp-chosen-label">\(D.label)</span>
		        <span data-live="\(D.calendar.collection)" data-filter="id=eq.\(D.calendar.row)"
		              data-template="\(D.calendar.key)-chosen"></span>
		      </p>
		"""

	markup: """
		<omnishell--date-picker>
		  <template data-item data-name="\(D.calendar.key)-chosen">
		    <span class="dp-chosen-value"><span class="dp-chosen-slot" data-live="\(D.calendar.cells)"
		          data-filter="id=eq.{value}" data-empty=""><output class="dp-chosen-date"
		          data-text="{date}"></output></span></span>
		  </template>
		  <div class="dp">
		    <div class="dp-bar">
		      <button type="button" id="\(D.calendar.key)-open" class="dp-trigger"
		              commandfor="\(D._pop)" command="toggle-popover" aria-haspopup="dialog">\(D.trigger)</button>
		\(D._readout)
		    </div>
		    <div id="\(D._pop)" class="dp-pop" popover role="dialog"
		         aria-label="\(D.trigger)">
		\(D.calendar.markup)
		    </div>
		  </div>
		</omnishell--date-picker>
		"""
}

// The seeded world: five grids, and the numbers a grid cannot derive from its
// own key. `first` is the weekday the 1st falls on, so the comprehension above
// knows where the month starts in its first row of seven; `prev.len` is what
// the days before it count back from.
//
// Five is the window the chart clamps to, and it is DATA — five months as
// chart states would be five states and eight arrows, restated every time a
// month is seeded. Two literals in the leaf's params are the same fact once.
calendarGrids: [
	#CalendarMonth & {key: "2026-07", first: 3, len: 31, prev: {key: "2026-06", len: 30}, next: key: "2026-08"},
	#CalendarMonth & {key: "2026-08", first: 6, len: 31, prev: {key: "2026-07", len: 31}, next: key: "2026-09"},
	#CalendarMonth & {key: "2026-09", first: 2, len: 30, prev: {key: "2026-08", len: 31}, next: key: "2026-10"},
	#CalendarMonth & {key: "2026-10", first: 4, len: 31, prev: {key: "2026-09", len: 30}, next: key: "2026-11"},
	#CalendarMonth & {key: "2026-11", first: 0, len: 30, prev: {key: "2026-10", len: 31}, next: key: "2026-12"},
]

calendarCells: list.FlattenN([for m in calendarGrids {(#GridCells & {month: m}).out}], 1)
