// omnishell--bar-chart: shadcn's Chart, and the one component in this catalog
// whose name collides with the word everything else here uses for a statechart.
// The screen says so; the definition is spelled bar-chart so the code cannot be
// misread.
//
// Three things make it a component rather than a picture.
//
// The GEOMETRY is a column reaching a stylesheet: each bar carries
// `style="--v: {value}"` and the frame carries the domain, so a length is
// calc() over two numbers and no arithmetic happens in the markup. That is
// ./resizable.cue's binding, doing the thing it was refused for — and the
// writer here is the PROGRAM, which is the narrower half of that rule kept
// rather than widened.
//
// The DOMAIN is the program's and not the rows'. `list.Max` runs where the rows
// are stated, so the scale is a compile-time fact about a stated set. Deriving
// it at runtime would be an aggregate — the thing this platform has two seats
// for and no clause — and it would move every bar in the picture whenever one
// row arrived, which makes two readings of one chart incomparable.
//
// The CHART IS ITS OWN TABLE. A picture's accessible alternative is the data it
// draws, so rather than shipping both and keeping them in step, the data ships
// and the stylesheet draws it: a row header per category, a cell per value, and
// the bar is the cell's own button.
package components

import (
	"list"

	omni "bonisoft.org/plugins/omnishell/components"
)

#BarChart: C={
	// The collection the points are rows of, and the one holding the caret. Two,
	// for the reason /command's are two: a region's projection is re-resolved
	// when the row it is nested in moves, so the table a keystroke writes must
	// not be the table the points are read from.
	points:  string
	cursors: string
	row:     *"the" | string
	// Prefixes every id this component emits.
	key:     *"chart" | string
	caption: string
	// What a value counts, for the name a reader hears on each bar.
	unit: string
	bars: [...{name: =~"^[a-z0-9]+$", label: string, value: int & >=0}] & [_, _, ...]
	// Which bar the caret opens on. A member of `bars`, so the first key press
	// has a neighbour to name.
	opensOn: string
	_opensOnIsABar: true & list.Contains([for b in C.bars {b.name}], C.opensOn)

	// The scale, computed where the rows are stated. Emitted once, onto the
	// frame the bars inherit it through, and printed on the screen beside them
	// so a reader can see what the lengths are against.
	max: list.Max([for b in C.bars {b.value}])

	// The rows the terminal writes when it first opens the collection, and the
	// caret's own, which is why this screen has no arrival state.
	//
	// `nxt_pos` and `nxt_value` are the line's, and they are the whole of what a
	// line costs a platform that binds per row: a bar is a length this row's own
	// number decides, while a segment reaches from this row to the NEXT one, and
	// a binding cannot see the neighbour. A projection names that neighbour but
	// answers ids and positions rather than its columns — so the value is
	// carried, and the program states it here because the program states the
	// rows. The last point's neighbour is itself, which draws a segment of zero
	// length rather than a special case.
	seed: [for i, b in C.bars {
		id:        b.name
		label:     b.label
		value:     b.value
		pos:       i + 1
		nxt_pos:   [if i + 1 < len(C.bars) {i + 2}, i + 1][0]
		nxt_value: [if i + 1 < len(C.bars) {C.bars[i+1].value}, b.value][0]
	}]
	cursorSeed: {id: C.row, active: C.opensOn}

	_plot: "\(C.key)-plot"
	// Both templates are NAMED. Each of these regions re-resolves when the caret
	// moves — the plot's projection interpolates it, the readout's filter is it
	// — and a render sweeps every child of a region that is not one of its rows,
	// the <template> included (decision-33).
	_barTemplate:  "\(C.key)-bar"
	_readTemplate: "\(C.key)-read"
	_segTemplate:  "\(C.key)-seg"

	// Two answers over the points and the four ends of the walk. `act` is the
	// caret; the rest are the neighbours a key lands on.
	_project: (omni.#attrJSON & {in: {
		act: eq: ["id", "{active}"]
		nxt: "next"
		prv: "prev"
		fst: "first"
		lst: "last"
	}}).out

	// The axis the bars are drawn on is the axis the keys walk: these are
	// stacked, so a reader presses Down and not Right, and the two keys a
	// column chart would answer are absent because nobody would press them.
	_keys: (omni.#attrJSON & {in: {
		ArrowDown: "\(C.key)-nx-{active}"
		ArrowUp:   "\(C.key)-pv-{active}"
		Home:      "\(C.key)-fs-{active}"
		End:       "\(C.key)-ls-{active}"
	}}).out

	// A move form states one column of the cursor row: two hidden inputs and no
	// control, submitted by `data-key` the way a buttonless form submits on
	// change.
	#move: M={
		id: string
		to: string
		out: """
			              <form role="none" id="\(M.id)" data-form="\(C.key)-step"
			                    data-entity="\(C.cursors)" data-action="upsert">
			                <input type="hidden" name="id" data-value="\(C.row)">
			                <input type="hidden" name="active" data-value="\(M.to)">
			              </form>
			"""
	}
	_next:  (#move & {id: "\(C.key)-nx-{id}", to: "{nxt}"}).out
	_prev:  (#move & {id: "\(C.key)-pv-{id}", to: "{prv}"}).out
	_first: (#move & {id: "\(C.key)-fs-{id}", to: "{fst}"}).out
	_last:  (#move & {id: "\(C.key)-ls-{id}", to: "{lst}"}).out

	// The bar is a submit button, so the pointer's gesture writes the same
	// column the keys do and the caret cannot come to mean two things. Its
	// accessible name carries the category and the value, because a button whose
	// content is a number is a name a reader cannot place — and the number is
	// inside the name, so what is seen is part of what is said.
	barTemplate: """
		    <template data-item data-name="\(C._barTemplate)">
		      <tr class="chart-row">
		        <th scope="row" class="chart-cat" data-text="{label}"></th>
		        <td class="chart-cell">
		          <form role="none" id="\(C.key)-pick-{id}" data-form="\(C.key)-pick"
		                data-entity="\(C.cursors)" data-action="upsert">
		            <input type="hidden" name="id" data-value="\(C.row)">
		            <input type="hidden" name="active" data-value="{id}">
		            <button type="submit" class="chart-bar" id="\(C.key)-bar-{id}"
		                    style="--v: {value}" data-rove="{act}" aria-current="{act}"
		                    aria-label="{label}: {value} \(C.unit)"
		                    data-text="{value}"></button>
		          </form>
		\(C._next)
		\(C._prev)
		\(C._first)
		\(C._last)
		        </td>
		      </tr>
		    </template>
		"""

	// The line, as one element per row, and NOT as SVG. A `<template>`'s content
	// is parsed as HTML, so an `<svg>` filled from one gets elements with the
	// wrong namespace: they are in the tree, they carry every attribute the
	// binding wrote, and no engine draws them. linkedom renders the same markup
	// happily, which is what made the browser tier the place this was seen.
	//
	// So a segment is a box with its own two numbers in it, and the shape is a
	// clip: a quadrilateral from this row's height to its neighbour's. Which
	// keeps the claim the bars make — a length is calc() over a bound value and
	// a bound domain — and needs no trigonometry, because the horizontal step is
	// the box itself.
	_lineTemplate: """
		    <template data-item data-name="\(C._segTemplate)">
		      <div class="chart-seg" style="--v: {value}; --n: {nxt_value}"></div>
		    </template>
		"""

	// The tooltip, restated. shadcn's follows the pointer and states a fact
	// about the pointer; this one is the row the caret names, so a keyboard
	// reader has it too and it is on the screen rather than over it.
	readTemplate: """
		    <template data-item data-name="\(C._readTemplate)">
		      <p class="chart-read"><b data-text="{label}"></b> <span data-text="{value} \(C.unit)"></span></p>
		    </template>
		"""

	markup: """
		<omnishell--bar-chart>
		  <figure class="chart" data-live="\(C.cursors)" data-filter="id=eq.\(C.row)">
		    <template data-item>
		      <div class="chart-frame" style="--chart-max: \(C.max)">
		        <figcaption class="chart-title">\(C.caption)</figcaption>
		        <table class="chart-plot" id="\(C._plot)" data-live="\(C.points)"
		               data-order="pos.asc" data-project='\(C._project)'
		               data-key='\(C._keys)' data-template="\(C._barTemplate)">
		        </table>
		        <!-- The same points as a line, and the same rows: the table above is
		             what a reader hears, so this one is decoration and says so. -->
		        <div class="chart-line" aria-hidden="true" data-live="\(C.points)"
		             data-order="pos.asc" data-template="\(C._segTemplate)"></div>
		        <div class="chart-tip" data-live="\(C.points)" data-filter="id=eq.{active}"
		             data-template="\(C._readTemplate)"></div>
		        <p class="chart-scale">0 – \(C.max) \(C.unit)</p>
		      </div>
		    </template>
		  </figure>
		\(C.barTemplate)
		\(C.readTemplate)
		\(C._lineTemplate)
		</omnishell--bar-chart>
		"""
}
