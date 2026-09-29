// omnishell--breadcrumb / omnishell--avatar / omnishell--separator /
// omnishell--skeleton: four of shadcn's catalog with no state and no variants.
// None of them holds a field, so none is even a candidate for a #Machine, and
// there is no variant→token map to print either: what each one is entirely
// made of is the accessibility tree it emits. That map is held here as data,
// so the screen can print it in the pane where a stateful component prints its
// machine JSON, and the suite folds the emitted markup through it — refusing a
// node a row describes and the markup does not carry, an attribute a row names
// and the node lacks, and any role, aria-* or image alt on the screen no row
// lists (accept-breadcrumb-tree). The fold is over the whole screen, so the
// chrome every route wears has a row of its own beneath the four.
//
// The same question decides three of the four: is this element content, or a
// picture of something the markup already states? A breadcrumb's separator, a
// decorative rule and a skeleton bar are all the second, and all three answer
// with aria-hidden rather than role="presentation" — which strips the role and
// leaves the subtree in the tree.
package components

import (
	"encoding/json"
	"strings"
)

// The placeholder standing in for a photograph, inlined so the screen still
// makes no request. Its colours are the picture's own, as a photograph's would
// be: the token contract governs the frame around an image, never its bytes.
_portrait: "data:image/svg+xml,%3Csvg%20xmlns='http://www.w3.org/2000/svg'%20viewBox='0%200%2080%2080'%3E%3Crect%20width='80'%20height='80'%20fill='%2352525B'/%3E%3Ccircle%20cx='40'%20cy='31'%20r='14'%20fill='%23D4D4D8'/%3E%3Cpath%20d='M8%2080c0-19%2014-30%2032-30s32%2011%2032%2030z'%20fill='%23D4D4D8'/%3E%3C/svg%3E"

// What each part of these four tells a reader, and why that is the answer. One
// row per node kind: `sel` is the selector the row describes, `says` the exact
// attributes that node carries in the order they are written, and an empty
// `says` is the statement that the element is already what it is and declares
// nothing. A `v` of "*" is a value the instance supplies. `sel` and `says` ride
// the emitted row as data-sel and data-attrs, never as cells, because they are
// the handles the suite folds the markup through.
ariaParts: [
	{
		part: "breadcrumb · the nav"
		sel:  ".breadcrumb"
		says: [{k: "aria-label", v: "Breadcrumb"}]
		why:  "A navigation landmark announced by no name is announced as \"navigation\", which is the one thing a reader already knows about it."
	},
	{
		part: "breadcrumb · an ancestor"
		sel:  ".breadcrumb-link"
		says: []
		why:  "An <code>&lt;a href&gt;</code> is already a link to somewhere that exists. Nothing to add."
	},
	{
		part: "breadcrumb · the current page"
		sel:  ".breadcrumb-current"
		says: [{k: "aria-current", v: "page"}]
		why:  "Text, not a link, and not shadcn's <code>role=\"link\" aria-disabled=\"true\"</code>: that announces a control the reader cannot use, where the page they are on is no control at all."
	},
	{
		part: "breadcrumb · a separator"
		sel:  ".breadcrumb-sep"
		says: [{k: "aria-hidden", v: "true"}]
		why:  "The glyph restates the order the list already carries. <code>role=\"presentation\"</code> would drop the item and leave the glyph's text behind."
	},
	{
		part: "avatar · standing alone"
		sel:  ".avatar[role=img]"
		says: [{k: "role", v: "img"}, {k: "aria-label", v: "*"}]
		why:  "One image node named by the person it stands for, whether the image paints or not."
	},
	{
		part: "avatar · beside the name"
		sel:  ".avatar[aria-hidden]"
		says: [{k: "aria-hidden", v: "true"}]
		why:  "The name is already text next to it, so the picture is decoration and saying it twice is worse than saying it once."
	},
	{
		part: "avatar · the image"
		sel:  ".avatar-image"
		says: [{k: "alt", v: ""}]
		why:  "The name sits on the wrapper instead, so it cannot move depending on whether the bytes arrived."
	},
	{
		part: "avatar · the initials"
		sel:  ".avatar-fallback"
		says: []
		why:  "<code>role=\"img\"</code> makes its whole subtree presentational, so an <code>aria-hidden</code> here would be one fact written twice."
	},
	{
		part: "separator · semantic, horizontal"
		sel:  "hr.separator"
		says: []
		why:  "<code>&lt;hr&gt;</code> is the element whose implicit role is separator, and horizontal is that role's own default."
	},
	{
		part: "separator · semantic, vertical"
		sel:  ".separator[role=separator]"
		says: [{k: "role", v: "separator"}, {k: "aria-orientation", v: "vertical"}]
		why:  "<code>&lt;hr&gt;</code> is a break in the flow and has no vertical spelling, so the role is declared and the orientation with it."
	},
	{
		part: "separator · decorative"
		sel:  ".separator[aria-hidden]"
		says: [{k: "aria-hidden", v: "true"}]
		why:  "A line drawn where a heading already states the boundary is a picture of the grouping, not the grouping."
	},
	{
		part: "skeleton · a bar"
		sel:  ".skeleton"
		says: [{k: "aria-hidden", v: "true"}]
		why:  "A placeholder is the shape of content that is not here yet; announcing it would announce nothing."
	},
	{
		part: "the screen · the way back"
		sel:  ".up-arrow"
		says: [{k: "aria-hidden", v: "true"}]
		why:  "Not one of the four: the chrome every screen wears is on this one too, and the fold refuses whatever it does not list. The arrow is a picture of the word beside it."
	},
]

_ariaSays: {
	in: [...{k: string, v: string}]
	_cells: [for a in in {"<code>\(a.k)=\"\([if a.v == "*" {"…"}, a.v][0])\"</code>"}]
	out: [if len(_cells) == 0 {"—"}, strings.Join(_cells, " ")][0]
}

// The table above as the screen's rows, printed the way a stateful screen
// prints its chart: the component's whole content, as data.
ariaRows: strings.Join([for r in ariaParts {
	"        <tr data-sel='\(json.Marshal(r.sel))' data-attrs='\(json.Marshal(r.says))'>" +
	"<td>\(r.part)</td><td>\((_ariaSays & {in: r.says}).out)</td><td>\(r.why)</td></tr>"
}], "\n")

#Breadcrumb: B={
	// The ancestors, in order, each a link to a route that exists; the page the
	// reader is on is text and is the shape's last member by construction, so a
	// trail cannot be authored with two current pages or none.
	trail: [...{text: string, route: string}]
	current: string

	_items: strings.Join([for c in B.trail {
		"""
		      <li class="breadcrumb-item"><a class="breadcrumb-link" data-route="\(c.route)">\(c.text)</a></li>
		      <li class="breadcrumb-sep" aria-hidden="true">/</li>
		"""
	}], "\n")

	markup: """
		<omnishell--breadcrumb>
		  <nav class="breadcrumb" aria-label="Breadcrumb">
		    <ol class="breadcrumb-list">
		\(B._items)
		      <li class="breadcrumb-item"><span class="breadcrumb-current" aria-current="page">\(B.current)</span></li>
		    </ol>
		  </nav>
		</omnishell--breadcrumb>
		"""
}

#Avatar: A={
	name:      string
	initials:  string
	src?:      string
	// Whether the avatar stands alone — and must then carry the name — or sits
	// beside the name as text, where a second announcement of it is noise.
	decorative: *false | bool

	// The image paints over the initials rather than replacing them, so the
	// fallback needs no error event to appear: an image that never paints
	// leaves what is underneath visible. What that costs is stated on the
	// screen — nothing observes the failure, so nothing can act on it.
	_image: [
		if A.src != _|_ {
			"\n    <img class=\"avatar-image\" src=\"\(A.src)\" alt=\"\" width=\"40\" height=\"40\" decoding=\"async\">"
		},
		"",
	][0]
	_names: [if A.decorative {" aria-hidden=\"true\""}, " role=\"img\" aria-label=\"\(A.name)\""][0]

	markup: """
		<omnishell--avatar>
		  <span class="avatar"\(A._names)>
		    <span class="avatar-fallback">\(A.initials)</span>\(A._image)
		  </span>
		</omnishell--avatar>
		"""
}

#Separator: S={
	// A separator is decorative when the boundary is already stated by the
	// markup around it, and semantic when the line is the only thing stating it.
	decorative:  *true | bool
	orientation: *"horizontal" | "vertical"

	// A focusable separator — APG's window splitter, with aria-valuenow moved
	// by a drag — is refused for the reason the carousel's swipe is: a drag is
	// a distance across several events, and neither an event nor an assign
	// carries one.
	if S.decorative {
		markup: """
			<omnishell--separator><span class="separator" data-orientation="\(S.orientation)" aria-hidden="true"></span></omnishell--separator>
			"""
	}
	if !S.decorative && S.orientation == "horizontal" {
		markup: """
			<omnishell--separator><hr class="separator" data-orientation="horizontal"></omnishell--separator>
			"""
	}
	if !S.decorative && S.orientation == "vertical" {
		markup: """
			<omnishell--separator><span class="separator" data-orientation="vertical" role="separator" aria-orientation="vertical"></span></omnishell--separator>
			"""
	}
}

#Skeleton: K={
	// A closed shape vocabulary, so the measurements stay in the stylesheet and
	// no instance carries a length of its own.
	shape: "circle" | "line" | "line-short" | "block"

	// aria-busy is not written here: it belongs on the element whose content
	// has not arrived, which only the caller knows.
	markup: """
		<omnishell--skeleton><span class="skeleton skeleton-\(K.shape)" aria-hidden="true"></span></omnishell--skeleton>
		"""
}
