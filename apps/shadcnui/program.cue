// The machine rung of apps/omnishell-shadcn-ui: a pronto.#App compiled from
// ir.html (pinned below). Nobody reviews this; it must merely be checkable —
// cue vet, the ir bijection, and the emitted surface are the contract.
//
// Every entity takes the `tab` path (ir decision-01): a gallery's state is
// the visit's, so this program emits no migration, no policy, no publication
// and no pipeline. The component screens are CUE-authored (#Screen.markup,
// composed in ./components); the catalog stays an assembly file.
@extern(embed)

package shadcnui

import (
	pronto "bonisoft.org/plugins/pronto"

	components "bonisoft.org/apps/shadcnui/components"
)

_designMd: _ @embed(file="DESIGN.md", type=text)

code: pronto.#App & {
	state: {
		entities: {
			SwitchDemo: {
				id: "0xcb4579e6dd7063cb"
				table: "switch_demo"
				durability: "tab"
				fields: [
					{ordinal: 1, name: "id", type: "string", pk: true, cel: "this.size() <= 64"},
					{ordinal: 2, name: "checked", type: "string", cel: "this in ['true', 'false']"},
				]
			}
			TabsDemo: {
				id: "0xcbddef1e72659775"
				table: "tabs_demo"
				durability: "tab"
				fields: [
					{ordinal: 1, name: "id", type: "string", pk: true, cel: "this.size() <= 64"},
					{ordinal: 2, name: "active", type: "string", cel: "this in ['account', 'password']"},
					{ordinal: 3, name: "sel_account", type: "string", cel: "this in ['true', 'false']"},
					{ordinal: 4, name: "sel_password", type: "string", cel: "this in ['true', 'false']"},
					{ordinal: 5, name: "tab_account", type: "string", cel: "this in ['0', '-1']"},
					{ordinal: 6, name: "tab_password", type: "string", cel: "this in ['0', '-1']"},
				]
			}
			PickerDemo: {
				id: "0x81ddda075765a099"
				table: "picker_demo"
				durability: "tab"
				fields: [
					{ordinal: 1, name: "id", type: "string", pk: true, cel: "this.size() <= 64"},
					{ordinal: 2, name: "choice", type: "string", cel: "this in ['apple', 'banana', 'cherry']"},
					{ordinal: 3, name: "label", type: "string", cel: "this.size() <= 24"},
					{ordinal: 4, name: "sel_apple", type: "string", cel: "this in ['true', 'false']"},
					{ordinal: 5, name: "sel_banana", type: "string", cel: "this in ['true', 'false']"},
					{ordinal: 6, name: "sel_cherry", type: "string", cel: "this in ['true', 'false']"},
				]
			}
			ToggleGroupDemo: {
				id: "0x9cab1a9302ed5291"
				table: "toggle_group_demo"
				durability: "tab"
				fields: [
					{ordinal: 1, name: "id", type: "string", pk: true, cel: "this.size() <= 64"},
					{ordinal: 2, name: "value", type: "string", cel: "this in ['left', 'center', 'right']"},
					{ordinal: 3, name: "chk_left", type: "string", cel: "this in ['true', 'false']"},
					{ordinal: 4, name: "chk_center", type: "string", cel: "this in ['true', 'false']"},
					{ordinal: 5, name: "chk_right", type: "string", cel: "this in ['true', 'false']"},
					{ordinal: 6, name: "tab_left", type: "string", cel: "this in ['0', '-1']"},
					{ordinal: 7, name: "tab_center", type: "string", cel: "this in ['0', '-1']"},
					{ordinal: 8, name: "tab_right", type: "string", cel: "this in ['0', '-1']"},
				]
			}
			AccordionSingleDemo: {
				id: "0x8348aaaf29af748f"
				table: "accordion_single_demo"
				durability: "tab"
				fields: [
					{ordinal: 1, name: "id", type: "string", pk: true, cel: "this.size() <= 64"},
					{ordinal: 2, name: "open", type: "string", cel: "this in ['none', 'shipping', 'returns', 'support']"},
					{ordinal: 3, name: "exp_shipping", type: "string", cel: "this in ['true', 'false']"},
					{ordinal: 4, name: "exp_returns", type: "string", cel: "this in ['true', 'false']"},
					{ordinal: 5, name: "exp_support", type: "string", cel: "this in ['true', 'false']"},
					{ordinal: 6, name: "caret", type: "string", cel: "this in ['shipping', 'returns', 'support']"},
					{ordinal: 7, name: "cur_shipping", type: "string", cel: "this in ['true', 'false']"},
					{ordinal: 8, name: "cur_returns", type: "string", cel: "this in ['true', 'false']"},
					{ordinal: 9, name: "cur_support", type: "string", cel: "this in ['true', 'false']"},
				]
			}
			// The pk carries the item set the other entities carry on a field:
			// at this arity the collection's rows ARE the accordion's items.
			AccordionMultiDemo: {
				id: "0xed447960798677ca"
				table: "accordion_multi_demo"
				durability: "tab"
				fields: [
					{ordinal: 1, name: "id", type: "string", pk: true, cel: "this in ['shipping', 'returns', 'support']"},
					{ordinal: 2, name: "open", type: "string", cel: "this in ['true', 'false']"},
				]
			}
			ComboboxDemo: {
				id: "0x9b69f9a818b2542e"
				table: "combobox_demo"
				durability: "tab"
				fields: [
					{ordinal: 1, name: "id", type: "string", pk: true, cel: "this.size() <= 64"},
					// Generated from the component's option list, which also
					// generates the datalist and the input's pattern — the
					// store-side constraint and the control-side gate are one
					// declaration (ir decision-16).
					{ordinal: 2, name: "choice", type: "string", cel: components.combobox.cel},
				]
			}
			// Two rows, one per instance on the screen: the pk carries the
			// instance set, as AccordionMultiDemo's does. The state column
			// speaks all three of aria-checked's values because the entity
			// serves both arms; the two-state instance draws no arrow to the
			// third (ir decision-18).
			CheckboxDemo: {
				id: "0x84d949fe4db94d38"
				table: "checkbox_demo"
				durability: "tab"
				fields: [
					{ordinal: 1, name: "id", type: "string", pk: true, cel: "this in ['terms']"},
					{ordinal: 2, name: "checked", type: "string", cel: "this in ['true', 'false']"},
				]
			}
			// The select-all's row, and the shape decision-47 turns on: `phase`
			// is the field and holds one value, while `checked` — the column
			// aria-checked binds — is what the items add up to, assigned by
			// every arrow and decided by none.
			SelectAllDemo: {
				id: "0xe6552e0edb88a82d"
				table: "select_all_demo"
				durability: "tab"
				fields: [
					{ordinal: 1, name: "id", type: "string", pk: true, cel: "this in ['all']"},
					{ordinal: 2, name: "phase", type: "string", cel: "this in ['live']"},
					{ordinal: 3, name: "checked", type: "string", cel: "this in ['true', 'false', 'mixed']"},
					{ordinal: 4, name: "inc_docs", type: "string", cel: "this in ['true', 'false']"},
					{ordinal: 5, name: "inc_images", type: "string", cel: "this in ['true', 'false']"},
					{ordinal: 6, name: "inc_archive", type: "string", cel: "this in ['true', 'false']"},
				]
			}
			ToggleDemo: {
				id: "0xe323f6f02a10fbe4"
				table: "toggle_demo"
				durability: "tab"
				fields: [
					{ordinal: 1, name: "id", type: "string", pk: true, cel: "this.size() <= 64"},
					{ordinal: 2, name: "pressed", type: "string", cel: "this in ['true', 'false']"},
				]
			}
			CollapsibleDemo: {
				id: "0xa845b2178aae0397"
				table: "collapsible_demo"
				durability: "tab"
				fields: [
					{ordinal: 1, name: "id", type: "string", pk: true, cel: "this.size() <= 64"},
					{ordinal: 2, name: "open", type: "string", cel: "this in ['true', 'false']"},
				]
			}
			// ToggleGroupDemo's shape with the option set renamed: the two
			// components run one generated machine (ir decision-19), so their
			// rows differ only in what the options are called.
			RadioGroupDemo: {
				id: "0xcbd88f134d486212"
				table: "radio_group_demo"
				durability: "tab"
				fields: [
					{ordinal: 1, name: "id", type: "string", pk: true, cel: "this.size() <= 64"},
					{ordinal: 2, name: "value", type: "string", cel: "this in ['starter', 'pro', 'team']"},
					{ordinal: 3, name: "chk_starter", type: "string", cel: "this in ['true', 'false']"},
					{ordinal: 4, name: "chk_pro", type: "string", cel: "this in ['true', 'false']"},
					{ordinal: 5, name: "chk_team", type: "string", cel: "this in ['true', 'false']"},
					{ordinal: 6, name: "tab_starter", type: "string", cel: "this in ['0', '-1']"},
					{ordinal: 7, name: "tab_pro", type: "string", cel: "this in ['0', '-1']"},
					{ordinal: 8, name: "tab_team", type: "string", cel: "this in ['0', '-1']"},
				]
			}
			// One aria-current column per page, because N positions share one
			// field; the token vocabulary the attribute takes is the column's
			// constraint, so "page" appears in the schema rather than a boolean
			// someone translates (ir decision-20).
			PaginationDemo: {
				id: "0xb804cc1641ae503b"
				table: "pagination_demo"
				durability: "tab"
				fields: [
					{ordinal: 1, name: "id", type: "string", pk: true, cel: "this.size() <= 64"},
					{ordinal: 2, name: "page", type: "string", cel: "this in ['p1', 'p2', 'p3', 'p4', 'p5']"},
					{ordinal: 3, name: "cur_p1", type: "string", cel: "this in ['page', 'false']"},
					{ordinal: 4, name: "cur_p2", type: "string", cel: "this in ['page', 'false']"},
					{ordinal: 5, name: "cur_p3", type: "string", cel: "this in ['page', 'false']"},
					{ordinal: 6, name: "cur_p4", type: "string", cel: "this in ['page', 'false']"},
					{ordinal: 7, name: "cur_p5", type: "string", cel: "this in ['page', 'false']"},
					// The empty string is what the binder removes, so it is the
					// enabled value; the schema admits exactly the two.
					{ordinal: 8, name: "dis_prev", type: "string", cel: "this in ['', 'disabled']"},
					{ordinal: 9, name: "dis_next", type: "string", cel: "this in ['', 'disabled']"},
				]
			}
			CarouselDemo: {
				id: "0x8507b287f8e02005"
				table: "carousel_demo"
				durability: "tab"
				fields: [
					{ordinal: 1, name: "id", type: "string", pk: true, cel: "this.size() <= 64"},
					{ordinal: 2, name: "slide", type: "string", cel: "this in ['s1', 's2', 's3', 's4']"},
					{ordinal: 3, name: "cur_s1", type: "string", cel: "this in ['true', 'false']"},
					{ordinal: 4, name: "cur_s2", type: "string", cel: "this in ['true', 'false']"},
					{ordinal: 5, name: "cur_s3", type: "string", cel: "this in ['true', 'false']"},
					{ordinal: 6, name: "cur_s4", type: "string", cel: "this in ['true', 'false']"},
					{ordinal: 7, name: "dis_prev", type: "string", cel: "this in ['', 'disabled']"},
					{ordinal: 8, name: "dis_next", type: "string", cel: "this in ['', 'disabled']"},
				]
			}
			// No column for the deadline: the wait is the terminal's, and a
			// row that carried it would be a second store of the same fact
			// (ir decision-21).
			ToastDemo: {
				id: "0xad9fb886c6b8ff70"
				table: "toast_demo"
				durability: "tab"
				fields: [
					{ordinal: 1, name: "id", type: "string", pk: true, cel: "this.size() <= 64"},
					{ordinal: 2, name: "state", type: "string", cel: "this in ['closed', 'open']"},
				]
			}
			// Two columns, because a machine's field is a STATE column and a
			// position on a scale is not a state name. `phase` is the field and
			// its cel is a one-member enum — the chart admitting it draws no
			// branch; `volume` is what the reader moves, assigned off the event
			// (ir decision-23).
			SliderDemo: {
				id: "0xffbbbfc23ba57b81"
				table: "slider_demo"
				durability: "tab"
				fields: [
					{ordinal: 1, name: "id", type: "string", pk: true, cel: "this.size() <= 64"},
					{ordinal: 2, name: "phase", type: "string", cel: "this in ['live']"},
					{ordinal: 3, name: "volume", type: "int32", cel: "this >= 0 && this <= 100"},
				]
			}
			// A bar's row, with no state column at all: the component has no
			// machine and no affordance, so nothing about it is ever in a state
			// and the whole row is the value someone else wrote.
			ProgressDemo: {
				id: "0x94082e6b913c00fe"
				table: "progress_demo"
				durability: "tab"
				fields: [
					{ordinal: 1, name: "id", type: "string", pk: true, cel: "this.size() <= 64"},
					{ordinal: 2, name: "done", type: "int32", cel: "this >= 0 && this <= 100"},
				]
			}
			// A column a stylesheet reads. Its only writer is a range, so the
			// browser has clamped it before the leaf ever sees it (ir
			// decision-40).
			ResizableDemo: {
				id: "0xd41d32bff7eb7078"
				table: "resizable_demo"
				durability: "tab"
				fields: [
					{ordinal: 1, name: "id", type: "string", pk: true, cel: "this.size() <= 64"},
					{ordinal: 2, name: "state", type: "string", cel: "this == 'sizing'"},
					{ordinal: 3, name: "split", type: "int32", cel: components.resizableDemo.splitCel},
				]
			}
			// What the reader typed, and one state to hold it in: the arrow is
			// targetless, so the machine records the value and stays. Nothing
			// bounds the query but a length, and the control carries that same
			// length as its maxlength — one declaration in #Command, so the
			// gate and the constraint cannot drift (ir decision-24).
			CommandDemo: {
				id: "0xcecfa9704ebe761e"
				table: "command_demo"
				durability: "tab"
				fields: [
					{ordinal: 1, name: "id", type: "string", pk: true, cel: "this.size() <= 64"},
					{ordinal: 2, name: "state", type: "string", cel: "this == 'typing'"},
					{ordinal: 3, name: "query", type: "string", cel: components.commandDemo.queryCel},
					// The caret and the choice, which are not one column: the
					// option a reader stands on is not the one they ran.
					{ordinal: 4, name: "active", type: "string", cel: "this.size() <= 32"},
					{ordinal: 5, name: "chosen", type: "string", cel: "this.size() <= 32"},
				]
				seed: [components.commandDemo.querySeed]
			}
			// The palette, one row per command, seeded (ir decision-25). It is
			// a second collection because an interpolated filter is re-resolved
			// when its parent's row moves: the table a keystroke writes must not
			// be the table the options read (ir decision-24).
			CommandItem: {
				id: "0xa4ec7e6b17f3234f"
				table: "command_item"
				durability: "tab"
				fields: [
					{ordinal: 1, name: "id", type: "string", pk: true, cel: "this.size() <= 32"},
					{ordinal: 2, name: "label", type: "string", cel: "this.size() <= 32"},
					{ordinal: 3, name: "group", type: "string", cel: "this.size() <= 32"},
					{ordinal: 4, name: "pos", type: "int32", cel: "this >= 1"},
				]
				seed: components.commandDemo.seed
			}
			// The one state column in the app that enumerates nothing: half the
			// options this control admits are rows a reader mints, so what the
			// constraint can say is a length (ir decision-26).
			SelectDemo: {
				id: "0x9108c3b500c0bae2"
				table: "select_demo"
				durability: "tab"
				fields: [
					{ordinal: 1, name: "id", type: "string", pk: true, cel: "this.size() <= 64"},
					{ordinal: 2, name: "choice", type: "string", cel: components.selectDemo.choiceCel},
				]
			}
			// One column, and it is the pk: an <option> carries a value and its
			// text and nothing else, and the minting form's one input derives no
			// second column. The constraint is the same grammar the input's
			// generated pattern gates on.
			SelectOption: {
				id: "0xcec334bf6ba02549"
				table: "select_option"
				durability: "tab"
				fields: [
					{ordinal: 1, name: "id", type: "string", pk: true, cel: components.selectDemo.cel},
				]
			}
			// One row per checkbox menu item. Two items share this collection
			// and neither shares a row, which is the switch screen's pair
			// wearing menuitemcheckbox (ir decision-29).
			// One row for the surface: a caret crosses items, so the items
			// share the row it lives on and each takes a column where it once
			// took a row of its own.
			MenuOptionDemo: {
				id: "0xa0b6976fd3a58d45"
				table: "menu_option_demo"
				durability: "tab"
				fields: [
					{ordinal: 1, name: "id", type: "string", pk: true, cel: "this.size() <= 64"},
					{ordinal: 2, name: "chk_bookmarks", type: "string", cel: "this in ['true', 'false']"},
					{ordinal: 3, name: "chk_urls", type: "string", cel: "this in ['true', 'false']"},
					{ordinal: 4, name: "caret", type: "string", cel: "this in ['bookmarks', 'urls']"},
					{ordinal: 5, name: "cur_bookmarks", type: "string", cel: "this in ['true', 'false']"},
					{ordinal: 6, name: "cur_urls", type: "string", cel: "this in ['true', 'false']"},
					{ordinal: 7, name: "prefix", type: "string", cel: "this.size() <= 32"},
				]
			}
			// The Go menu holds no item state at all — three links — so its row
			// is the caret and nothing else.
			MenuGoDemo: {
				id: "0xe162d3dd6198217a"
				table: "menu_go_demo"
				durability: "tab"
				fields: [
					{ordinal: 1, name: "id", type: "string", pk: true, cel: "this.size() <= 64"},
					{ordinal: 2, name: "caret", type: "string", cel: "this in ['tabs', 'accordion', 'toast']"},
					{ordinal: 3, name: "cur_tabs", type: "string", cel: "this in ['true', 'false']"},
					{ordinal: 4, name: "cur_accordion", type: "string", cel: "this in ['true', 'false']"},
					{ordinal: 5, name: "cur_toast", type: "string", cel: "this in ['true', 'false']"},
					{ordinal: 6, name: "prefix", type: "string", cel: "this.size() <= 32"},
				]
			}
			// The bar's own tab stop, which APG gives it one of. No buffer: a
			// menubar's letters open a menu rather than walking the bar, and
			// this bar does not claim that.
			MenubarDemo: {
				id: "0xb63233e52cf47513"
				table: "menubar_demo"
				durability: "tab"
				fields: [
					{ordinal: 1, name: "id", type: "string", pk: true, cel: "this.size() <= 64"},
					{ordinal: 2, name: "caret", type: "string", cel: "this in ['view', 'go']"},
					{ordinal: 3, name: "cur_view", type: "string", cel: "this in ['true', 'false']"},
					{ordinal: 4, name: "cur_go", type: "string", cel: "this in ['true', 'false']"},
					{ordinal: 5, name: "tab_view", type: "string", cel: "this in ['0', '-1']"},
					{ordinal: 6, name: "tab_go", type: "string", cel: "this in ['0', '-1']"},
				]
			}
			// The right-click menu's one row: whether it stands, and where the
			// pointer was inside the target when it did. x and y are FRACTIONS
			// of that element's own box in parts per thousand — never viewport
			// pixels — so the point means the same thing in any window, and the
			// range is the column's own constraint rather than a comment.
			ContextMenuDemo: {
				id: "0xebdd7b970cae9382"
				table: "context_menu_demo"
				durability: "tab"
				fields: [
					{ordinal: 1, name: "id", type: "string", pk: true, cel: "this.size() <= 64"},
					{ordinal: 2, name: "open", type: "string", cel: "this in ['true', 'false']"},
					{ordinal: 3, name: "x", type: "int32", cel: "this >= 0 && this <= 1000"},
					{ordinal: 4, name: "y", type: "int32", cel: "this >= 0 && this <= 1000"},
					{ordinal: 5, name: "caret", type: "string", cel: "this in ['popover', 'sheet', 'overlays']"},
					{ordinal: 6, name: "cur_popover", type: "string", cel: "this in ['true', 'false']"},
					{ordinal: 7, name: "cur_sheet", type: "string", cel: "this in ['true', 'false']"},
					{ordinal: 8, name: "cur_overlays", type: "string", cel: "this in ['true', 'false']"},
					{ordinal: 9, name: "prefix", type: "string", cel: "this.size() <= 32"},
				]
			}
			MenuProfileDemo: {
				id: "0xe80290da8a951a37"
				table: "menu_profile_demo"
				durability: "tab"
				fields: [
					{ordinal: 1, name: "id", type: "string", pk: true, cel: "this.size() <= 64"},
					{ordinal: 2, name: "profile", type: "string", cel: "this in ['andy', 'benoit', 'luis']"},
					{ordinal: 3, name: "chk_andy", type: "string", cel: "this in ['true', 'false']"},
					{ordinal: 4, name: "chk_benoit", type: "string", cel: "this in ['true', 'false']"},
					{ordinal: 5, name: "chk_luis", type: "string", cel: "this in ['true', 'false']"},
					{ordinal: 6, name: "caret", type: "string", cel: "this in ['switch', 'checkbox', 'radio_group', 'andy', 'benoit', 'luis']"},
					{ordinal: 7, name: "cur_switch", type: "string", cel: "this in ['true', 'false']"},
					{ordinal: 8, name: "cur_checkbox", type: "string", cel: "this in ['true', 'false']"},
					{ordinal: 9, name: "cur_radio_group", type: "string", cel: "this in ['true', 'false']"},
					{ordinal: 10, name: "cur_andy", type: "string", cel: "this in ['true', 'false']"},
					{ordinal: 11, name: "cur_benoit", type: "string", cel: "this in ['true', 'false']"},
					{ordinal: 12, name: "cur_luis", type: "string", cel: "this in ['true', 'false']"},
					{ordinal: 13, name: "prefix", type: "string", cel: "this.size() <= 32"},
				]
			}
			// The one row a form edits, and the two ways a column can be
			// bounded: the handle's constraint is the sentence its control's
			// `pattern` is generated from, so what the gate refuses and what
			// the column admits are one statement; the bio's is a length,
			// because `maxlength` truncates and there is nothing left for a
			// submit to be turned down for (ir decision-32).
			FormDemo: {
				id: "0xeab5d2f0ca33fe36"
				table: "form_demo"
				durability: "tab"
				fields: [
					{ordinal: 1, name: "id", type: "string", pk: true, cel: "this.size() <= 64"},
					{ordinal: 2, name: "handle", type: "string", cel: components.formDemo.handle.control.cel},
					{ordinal: 3, name: "bio", type: "string", cel: components.formDemo.bio.control.cel},
				]
			}
			// The table's rows, and they are rows: a table is the one component
			// here whose content is a collection, so collapsing them into the
			// columns of one row — /command's answer to an empty collection —
			// is what this entity exists not to do (ir decision-33).
			// Every row is one a reader minted; the money column is text
			// because nothing here computes with it and the form submits what
			// was typed.
			TableRow: {
				id: "0xa7c6c2b724ee48d8"
				table: "table_row"
				durability: "tab"
				fields: [
					{ordinal: 1, name: "id", type: "string", pk: true, cel: "this.size() >= 1 && this.size() <= 24"},
					{ordinal: 2, name: "payer", type: "string", cel: "this.size() <= 48"},
					{ordinal: 3, name: "status", type: "string", cel: "this in ['Paid', 'Pending', 'Unpaid']"},
					{ordinal: 4, name: "amount", type: "string", cel: "this.size() <= 12"},
				]
			}
			// What the reader typed into the table's filter, and the state the
			// chart is in while typing it. A second collection, because an
			// interpolated filter is re-resolved when its parent's row moves:
			// the table a keystroke writes must not be the table the rows are
			// read from (ir decision-24).
			TableQuery: {
				id: "0xe6e2932ebb764e26"
				table: "table_query"
				durability: "tab"
				fields: [
					{ordinal: 1, name: "id", type: "string", pk: true, cel: "this.size() <= 64"},
					{ordinal: 2, name: "state", type: "string", cel: "this in ['pending', 'typing']"},
					{ordinal: 3, name: "query", type: "string", cel: components.tableDemo.queryCel},
				]
			}
			// The first seeded collection in the app, and the correction three
			// notes above needed: a `tab` entity has no migration to render
			// seed rows into, so the terminal writes them itself when it first
			// opens the collection (ir decision-35). The rows are the same
			// shape TableRow's are, minted by nobody.
			DataRow: {
				id: "0xefeb7d3267749a9a"
				table: "data_row"
				durability: "tab"
				seed:  components.dataTable.rows
				fields: [
					{ordinal: 1, name: "id", type: "string", pk: true, cel: "this.size() >= 1 && this.size() <= 24"},
					{ordinal: 2, name: "payer", type: "string", cel: "this.size() <= 48"},
					{ordinal: 3, name: "status", type: "string", cel: "this in ['Paid', 'Pending', 'Unpaid']"},
					{ordinal: 4, name: "amount", type: "string", cel: "this.size() <= 12"},
				]
			}
			// What the reader typed and which row they chose, on one row of a
			// second collection — TableQuery's shape with the cursor added,
			// and seeded rather than stated by an arrival arrow. The seed IS
			// the machine's initial world, emitted from the same CUE value, so
			// decision-07's agreement holds by construction. The cursor
			// column's constraint is a length because half its values are the
			// empty string: a choice the filter removed is cleared.
			DataCursor: {
				id: "0x91cb003a6b376546"
				table: "data_cursor"
				durability: "tab"
				seed: [components.dataTable.cursorSeed]
				fields: [
					{ordinal: 1, name: "id", type: "string", pk: true, cel: "this.size() <= 64"},
					{ordinal: 2, name: "state", type: "string", cel: "this == 'typing'"},
					{ordinal: 3, name: "query", type: "string", cel: components.dataTable.queryCel},
					{ordinal: 4, name: "cursor", type: "string", cel: "this.size() <= 24"},
					// Which of the orders the header offers the grid is read
					// in. A KEY of the map the markup states, never a clause:
					// one sentence generates the constraint and the map, so a
					// value the region could not read is unstorable.
					{ordinal: 5, name: "sort", type: "string", cel: components.dataTable.sortCel},
					// aria-sort, one column per sortable header. The order is
					// one fact and the attribute is per column, so the
					// comparison is made where the write is — literals of
					// whichever form was pressed, moving as one row.
					{ordinal: 6, name: "srt_id", type: "string", cel: components.dataTable.sortStateCel},
					{ordinal: 7, name: "srt_amount", type: "string", cel: components.dataTable.sortStateCel},
				]
			}
			// The rail's items, and the first item set in this app that is data
			// rather than a CUE-time list: a `tab` entity has no migration to
			// render `seed:` into, so the terminal writes these rows when it
			// first opens the collection (ir decision-36). The position is a
			// column because the region's order is a literal reading one, and
			// the route is a screen name the binder composes an address from.
			NavRailItem: {
				id: "0xfb2ca9da79abf89c"
				table: "nav_rail_item"
				durability: "tab"
				fields: [
					{ordinal: 1, name: "id", type: "string", pk: true, cel: "this.matches('^[a-z-]{1,32}$')"},
					{ordinal: 2, name: "label", type: "string", cel: "this.size() <= 32"},
					{ordinal: 3, name: "route", type: "string", cel: "this.matches('^[a-z-]{1,32}$')"},
					{ordinal: 4, name: "pos", type: "int32", cel: "this >= 1 && this <= 99"},
				]
				seed: [
					{id: "switch", label: "Switch", route: "switch", pos: 1},
					{id: "tabs", label: "Tabs", route: "tabs", pos: 2},
					{id: "menu", label: "Menu", route: "menu", pos: 3},
					{id: "navigation", label: "Navigation", route: "navigation", pos: 4},
					{id: "table", label: "Table", route: "table", pos: 5},
				]
			}
			// The parameter the rail's projection compares each item against.
			// It is a row rather than a literal in the markup because `eq`
			// reads its value off the enclosing row; it is SEEDED rather than
			// derived because a screen is handed only the params its path
			// declares and a static route declares none, so which route is
			// open is a fact the program states (ir decision-36).
			NavState: {
				id: "0xd9e0e80a2c49d64e"
				table: "nav_state"
				durability: "tab"
				fields: [
					{ordinal: 1, name: "id", type: "string", pk: true, cel: "this.size() <= 64"},
					{ordinal: 2, name: "current", type: "string", cel: "this.matches('^[a-z-]{1,32}$')"},
				]
				seed: [{id: "the", current: "navigation"}]
			}
			// The disclosure over the rail: one field, and the same two values
			// aria-expanded speaks that CollapsibleDemo carries.
			NavSidebarDemo: {
				id: "0xafdf1434e4e64c96"
				table: "nav_sidebar_demo"
				durability: "tab"
				fields: [
					{ordinal: 1, name: "id", type: "string", pk: true, cel: "this.size() <= 64"},
					{ordinal: 2, name: "open", type: "string", cel: "this in ['true', 'false']"},
				]
			}
			// The calendar's own row, and the one row on the screen anything
			// writes: the grid being shown, that grid's name, the cell the caret
			// is on and the cell the reader chose. The month arrow moves the
			// first three together, out of one leaf (ir decision-38); a pick
			// writes the last two. `active` and `value` are two columns because
			// they answer two ARIA states — aria-activedescendant and
			// aria-selected — and a column is named for the state it answers.
			// `state` enumerates one
			// member and says so — a calendar's chart branches on nothing, which
			// is the admission /slider's entity already prints (decision-23).
			//
			// Two rows, one per instance on the screen, and the seed states them:
			// what it writes is each machine's own initial world, so the row a
			// region renders and the row a machine would synthesize are one
			// declaration in the component (ir decision-39).
			// One row, four columns, and only one of them is a state name: what
			// has been typed is a value, so it is a column the arrows assign
			// (ir decision-23's split, one screen on). `invalid` and `blocked`
			// are the same keystroke's other two answers, carried as columns
			// because an ARIA attribute and a `disabled` want values rather
			// than state names (ir decision-44).
			OtpDemo: {
				id: "0xe9f4ef323c648a3f"
				table: "otp_demo"
				durability: "tab"
				fields: [
					{ordinal: 1, name: "id", type: "string", pk: true, cel: "this.size() <= 64"},
					{ordinal: 2, name: "state", type: "string", cel: "this in ['typing', 'complete', 'verified']"},
					{ordinal: 3, name: "code", type: "string", cel: components.otpDemo.codeCel},
					{ordinal: 4, name: "invalid", type: "string", cel: "this in ['true', 'false']"},
					{ordinal: 5, name: "blocked", type: "string", cel: "this in ['', 'disabled']"},
				]
			}
			// The points a chart draws, and they are the PROGRAM's: `seed`
			// carries them, `list.Max` over the same list carries the scale,
			// and neither is a fact the terminal derives (ir decision-46).
			ChartPoint: {
				id: "0xc4365336f0e4f6ee"
				table: "chart_point"
				durability: "tab"
				fields: [
					// The pk is a DOM id: it interpolates into the bar's own id,
					// and into the four form ids the arrow keys submit.
					{ordinal: 1, name: "id", type: "string", cel: "this.size() <= 16", pk: true},
					{ordinal: 2, name: "label", type: "string", cel: "this.size() <= 24"},
					{ordinal: 3, name: "value", type: "int32", cel: "this >= 0"},
					{ordinal: 4, name: "pos", type: "int32", cel: "this >= 1 && this <= 24"},
					// The line's, and the whole of what a segment costs: it
					// reaches from this row to the next, and a binding cannot
					// see the neighbour (ir decision-46).
					{ordinal: 5, name: "nxt_value", type: "int32", cel: "this >= 0"},
				]
				seed: components.chartDemo.seed
			}
			// The caret, in a collection of its own: a region's projection is
			// re-resolved when the row it is nested in moves, so the table a
			// keystroke writes must not be the table the points are read from.
			ChartCursor: {
				id: "0xe132b74ac76aa2d4"
				table: "chart_cursor"
				durability: "tab"
				fields: [
					{ordinal: 1, name: "id", type: "string", pk: true, cel: "this.size() <= 64"},
					{ordinal: 2, name: "active", type: "string", cel: "this.size() <= 16"},
				]
				seed: [components.chartDemo.cursorSeed]
			}
			// One collection for a whole screen of components that hold
			// nothing: two of the four have something to write, and this is
			// where it goes (ir decision-49).
			CompositionDemo: {
				id: "0xa9e851830b2fc897"
				table: "composition_demo"
				durability: "tab"
				fields: [
					{ordinal: 1, name: "id", type: "string", pk: true, cel: "this.size() <= 64"},
					{ordinal: 2, name: "phase", type: "string", cel: "this in ['live']"},
					{ordinal: 3, name: "query", type: "string", cel: "this.size() <= 64"},
					{ordinal: 4, name: "last", type: "string", cel: "this.size() <= 32"},
				]
			}
			// A transcript, and the first collection in this app a READER
			// grows: the seed states six rows and the composer adds a seventh
			// (ir decision-50). The kind is a column rather than a second
			// collection — a marker is a row nobody said, not a message with
			// different styling.
			ChatRow: {
				id: "0xd92899defceca5b6"
				table: "chat_row"
				durability: "tab"
				fields: [
					{ordinal: 1, name: "id", type: "string", pk: true, cel: "this.size() <= 64"},
					{ordinal: 2, name: "kind", type: "string", cel: "this in ['message', 'marker', 'file']"},
					{ordinal: 3, name: "seat", type: "string", cel: "this in ['you', 'them', 'none']"},
					{ordinal: 4, name: "who", type: "string", cel: "this.size() <= 24"},
					{ordinal: 5, name: "initials", type: "string", cel: "this.size() <= 2"},
					{ordinal: 6, name: "body", type: "string", cel: "this.size() <= 120"},
					{ordinal: 7, name: "note", type: "string", cel: "this.size() <= 48"},
					// What a reader reads, beside what the region orders by: one
					// is a clock's answer and the other is a time of day, and a
					// binding cannot turn the first into the second.
					{ordinal: 8, name: "when", type: "string", cel: "this.size() <= 12"},
					{ordinal: 9, name: "at", type: "string", cel: "this.size() <= 32"},
					{ordinal: 10, name: "state", type: "string", cel: "this in ['done', 'uploading', 'error']"},
				]
				seed: components.chatSeed.seed
			}
			// The composer's own row, which is what gives the transcript a
			// region to be nested in: a list region hydrates nested regions and
			// a singleton does not.
			ChatDemo: {
				id: "0x93513d99f178f9b3"
				table: "chat_demo"
				durability: "tab"
				fields: [
					{ordinal: 1, name: "id", type: "string", pk: true, cel: "this.size() <= 64"},
				]
				seed: [{id: "the"}]
			}
			// A questionnaire's row: one column per answer, one per option
			// (aria-pressed speaks true and false, not the answer's words), and
			// the block that keeps Next from leaving an unanswered step. The
			// field is which question is showing (ir decision-51).
			QuizDemo: {
				id: "0xe2cca40ee4f97553"
				table: "quiz_demo"
				durability: "tab"
				fields: [
					{ordinal: 1, name: "id", type: "string", pk: true, cel: "this.size() <= 64"},
					{ordinal: 2, name: "step", type: "string", cel: "this in ['one', 'two', 'three', 'done']"},
					{ordinal: 3, name: "a_shape", type: "string", cel: "this.size() <= 32"},
					{ordinal: 4, name: "a_state", type: "string", cel: "this.size() <= 32"},
					{ordinal: 5, name: "a_note", type: "string", cel: "this.size() <= 80"},
					{ordinal: 6, name: "blocked", type: "string", cel: "this in ['', 'disabled']"},
					{ordinal: 7, name: "sel_one_markup", type: "string", cel: "this in ['true', 'false']"},
					{ordinal: 8, name: "sel_one_chart", type: "string", cel: "this in ['true', 'false']"},
					{ordinal: 9, name: "sel_one_library", type: "string", cel: "this in ['true', 'false']"},
					{ordinal: 10, name: "sel_two_row", type: "string", cel: "this in ['true', 'false']"},
					{ordinal: 11, name: "sel_two_dom", type: "string", cel: "this in ['true', 'false']"},
					{ordinal: 12, name: "sel_two_memory", type: "string", cel: "this in ['true', 'false']"},
				]
			}
			CalendarDemo: {
				id: "0x9812c340555a0af2"
				table: "calendar_demo"
				durability: "tab"
				fields: [
					{ordinal: 1, name: "id", type: "string", pk: true, cel: "this.size() <= 64"},
					{ordinal: 2, name: "state", type: "string", cel: "this in ['browsing']"},
					{ordinal: 3, name: "month", type: "string", cel: "this.size() == 7"},
					{ordinal: 4, name: "label", type: "string", cel: "this.size() <= 24"},
					{ordinal: 5, name: "value", type: "string", cel: "this.size() <= 16"},
					{ordinal: 6, name: "active", type: "string", cel: "this.size() <= 16"},
				]
				seed: components.calendarRows
			}
			// The day cells, and the first collection in this app that arrives
			// with rows in it. `seed:` renders into 900_seed.sql at a server
			// tier and this app has none, so the terminal writes them when it
			// first opens the collection — which is the answer /command and
			// /table could not give (ir decision-39). They are seeded rather
			// than minted because a machine writes one row, its own, and a grid
			// is forty-two.
			//
			// `month` is the month the DAY is in and `grid` the month it is
			// DRAWN in; a cell where the two disagree is a neighbouring month's,
			// which is the comparison the projection makes and no column holds.
			CalendarCell: {
				id: "0xaa32412758271c62"
				table: "calendar_cell"
				durability: "tab"
				fields: [
					{ordinal: 1, name: "id", type: "string", pk: true, cel: "this.size() <= 16"},
					{ordinal: 2, name: "grid", type: "string", cel: "this.size() == 7"},
					{ordinal: 3, name: "month", type: "string", cel: "this.size() == 7"},
					{ordinal: 4, name: "week", type: "string", cel: "this in ['w1', 'w2', 'w3', 'w4', 'w5', 'w6']"},
					// The weekday column a cell sits in, which is the lane the
					// vertical arrows walk WITHIN: the order alone would carry
					// the foot of one column into the head of the next.
					{ordinal: 5, name: "dow", type: "string", cel: "this in ['d0', 'd1', 'd2', 'd3', 'd4', 'd5', 'd6']"},
					{ordinal: 6, name: "pos", type: "int32", cel: "this >= 1 && this <= 42"},
					// Down each weekday column, then across: the second order
					// the vertical arrows read, where a neighbour is a week away.
					{ordinal: 7, name: "colpos", type: "int32", cel: "this >= 0 && this <= 65"},
					{ordinal: 8, name: "day", type: "string", cel: "this.size() <= 2"},
					{ordinal: 9, name: "date", type: "string", cel: "this.size() == 10"},
				]
				seed: components.calendarCells
			}
		}
		pipelines: {}
	}

	capabilities: {
		// No auth block: a component gallery gates nobody (ir decision-06).
		blobs: false
		hatches: {}
		vendored: {}
	}

	surface: {
		// `title` is a route's label wherever the terminal needs one; nothing
		// in this app renders it, since only the catalog is on the strip
		// (decision-28). A screen's heading lives in its own markup and the
		// catalog card is where a compound name reads in full.
		screens: {
			catalog: {
				title: "Components"
				route: "/"
				forms: []
				states: ["populated", "populated-dark"]
			}
			"switch": {
				title:  "Switch"
				route:  "/switch"
				markup: components.switchScreen.markup
				forms: []
				states: ["populated", "populated-dark"]
			}
			tabs: {
				title:  "Tabs"
				route:  "/tabs"
				markup: components.tabsScreen.markup
				forms: []
				states: ["populated", "populated-dark"]
			}
			picker: {
				title:  "Picker"
				route:  "/picker"
				markup: components.pickerScreen.markup
				forms: []
				states: ["populated", "populated-dark"]
			}
			"toggle-group": {
				title:  "Toggle group"
				route:  "/toggle-group"
				markup: components.toggleGroupScreen.markup
				forms: []
				states: ["populated", "populated-dark"]
			}
			accordion: {
				title:  "Accordion"
				route:  "/accordion"
				markup: components.accordionScreen.markup
				forms: []
				states: ["populated", "populated-dark"]
			}
			overlays: {
				title:  "Overlays"
				route:  "/overlays"
				markup: components.overlaysScreen.markup
				forms: []
				states: ["populated", "populated-dark"]
			}
			primitives: {
				title:  "Primitives"
				route:  "/primitives"
				markup: components.primitivesScreen.markup
				forms: []
				states: ["populated", "populated-dark"]
			}
			combobox: {
				title:  "Combobox"
				route:  "/combobox"
				markup: components.comboboxScreen.markup
				// A form, because a pick is a commit: a machine can carry typed
				// text, so what sends this write to a form is the gesture rather
				// than the value (ir decision-17).
				forms: [{
					id:     "pick-framework"
					entity: "ComboboxDemo"
					action: "upsert"
					flow:   "pick-framework"
					fields: [
						{name: "id", control: "hidden", value: "the"},
						{name: "choice", control: "text", required: true},
					]
				}]
				states: ["populated", "populated-dark", "validation-error"]
			}
			checkbox: {
				title:  "Checkbox"
				route:  "/checkbox"
				markup: components.checkboxScreen.markup
				forms: []
				states: ["populated", "populated-dark"]
			}
			"radio-group": {
				title:  "Radio group"
				route:  "/radio-group"
				markup: components.radioGroupScreen.markup
				forms: []
				states: ["populated", "populated-dark"]
			}
			pagination: {
				title:  "Pagination"
				route:  "/pagination"
				markup: components.paginationScreen.markup
				forms: []
				states: ["populated", "populated-dark"]
			}
			toast: {
				title:  "Toast"
				route:  "/toast"
				markup: components.toastScreen.markup
				forms: []
				states: ["populated", "populated-dark"]
			}
			slider: {
				title:  "Slider"
				route:  "/slider"
				markup: components.sliderScreen.markup
				forms: []
				states: ["populated", "populated-dark"]
			}
			resizable: {
				title:  "Resizable"
				route:  "/resizable"
				markup: components.resizableScreen.markup
				// No form: the position is a machine's assign off the range's
				// own input event, so nothing on this screen is submitted.
				forms: []
				// No `empty`: the machine is the writer of the initial fact, so
				// the region synthesizes its row and the panes have a width on
				// the first paint.
				states: ["populated", "populated-dark"]
			}
			command: {
				title:  "Command"
				route:  "/command"
				markup: components.commandScreen.markup
				// Three forms, and the split is the widget: a move states the
				// caret alone, a pick states the caret and the choice together,
				// and the field's own form is what Enter submits, carrying the
				// caret as the choice (ir decision-25). None carries a visible
				// control that can be refused, so the screen has no
				// validation-error state.
				forms: [{
					id:     "command-move"
					entity: "CommandDemo"
					action: "upsert"
					flow:   "command-choose"
					fields: [
						{name: "id", control: "hidden", value: "the"},
						{name: "active", control: "hidden"},
					]
				}, {
					id:     "command-pick"
					entity: "CommandDemo"
					action: "upsert"
					flow:   "command-choose"
					fields: [
						{name: "id", control: "hidden", value: "the"},
						{name: "chosen", control: "hidden"},
						{name: "active", control: "hidden"},
					]
				}, {
					id:     "command-run"
					entity: "CommandDemo"
					action: "upsert"
					flow:   "command-choose"
					fields: [
						{name: "id", control: "hidden", value: "the"},
						{name: "chosen", control: "hidden"},
					]
				}]
				// No `empty`: both collections are seeded, so the first read
				// answers rows and the frame has never been over a screen with
				// nothing on it.
				states: ["populated", "populated-dark"]
			}
			"select": {
				title:  "Select"
				route:  "/select"
				markup: components.selectScreen.markup
				// Two, because the control writes a row and its option set is
				// rows somebody has to write (ir decision-26). The pick form's
				// select declares no `options`: the emitted list is the authored
				// group plus whatever the collection holds.
				forms: [{
					id:     "select-pick"
					entity: "SelectDemo"
					action: "upsert"
					flow:   "select-pick"
					fields: [
						{name: "id", control: "hidden", value: "the"},
						{name: "choice", control: "select"},
					]
				}, {
					id:     "select-mint"
					entity: "SelectOption"
					action: "upsert"
					flow:   "select-mint"
					fields: [
						{name: "id", control: "text", required: true, maxLength: components.selectDemo.maxLen},
					]
				}]
				// `empty` is where the screen opens: both option regions are
				// top-level lists over a collection nothing seeds, so the live
				// group and the row list stand empty until a mint
				// (ir decision-26).
				states: ["populated", "populated-dark", "validation-error", "empty"]
			}
			breadcrumb: {
				title:  "Breadcrumb"
				route:  "/breadcrumb"
				markup: components.breadcrumbScreen.markup
				forms: []
				states: ["populated", "populated-dark"]
			}
			menu: {
				title:  "Menu"
				route:  "/menu"
				markup: components.menuScreen.markup
				forms: []
				states: ["populated", "populated-dark"]
			}
			sheet: {
				title:  "Sheet"
				route:  "/sheet"
				markup: components.sheetScreen.markup
				forms: []
				states: ["populated", "populated-dark"]
			}
			form: {
				title:  "Form"
				route:  "/form"
				markup: components.formScreen.markup
				// Both declared where the controls they gate are, so the
				// surface and the markup are one statement and the screen can
				// print it (ir decision-32).
				forms: [components.formDemo.saveForm, components.formDemo.clearForm]
				// Three beyond the pair, and every one of them the shell's own:
				// `validation-error` is where a refused submit lands,
				// `success` is the 600ms an accepted one flashes for, and
				// `empty` is where the screen opens, the delete affordance
				// being a list region over a row nothing has written yet.
				states: ["populated", "populated-dark", "validation-error", "success", "empty"]
			}
			table: {
				title:  "Table"
				route:  "/table"
				markup: components.tableScreen.markup
				// One, and it is how the rows exist at all: nothing seeds this
				// collection, so a table's contents are a reader's
				// (ir decision-33).
				forms: [{
					id:     "table-mint"
					entity: "TableRow"
					action: "upsert"
					flow:   "table-mint"
					fields: [
						{name: "id", control: "text", required: true, maxLength: 24},
						{name: "payer", control: "text", required: true, maxLength: 48},
						{name: "status", control: "select", required: true, options: ["Paid", "Pending", "Unpaid"]},
						{name: "amount", control: "text", required: true, maxLength: 12},
					]
				}]
				// `empty` is the frame every arrival meets: the table's frame is
				// a list region over a row the chart states on entry, so the
				// screen opens with nothing and the clock's arrow lands it in
				// populated. `validation-error` is the minting form's, since the
				// shell owns validation and a refused submit is a screen state.
				states: ["populated", "populated-dark", "empty", "validation-error"]
			}
			"data-table": {
				title:  "Data"
				route:  "/data-table"
				markup: components.dataTableScreen.markup
				// Two forms, one flow: choosing a row is one gesture read two
				// ways, by the pointer on a row's own button and by an arrow
				// key on the neighbour's form (ir decision-35). Neither form
				// carries a visible control, so neither can be refused: the
				// screen has no validation-error state.
				forms: [{
					id:     "dt-pick"
					entity: "DataCursor"
					action: "upsert"
					flow:   "dt-choose"
					fields: [
						{name: "id", control: "hidden", value: "the"},
						{name: "cursor", control: "hidden"},
					]
				}, {
					id:     "dt-step"
					entity: "DataCursor"
					action: "upsert"
					flow:   "dt-choose"
					fields: [
						{name: "id", control: "hidden", value: "the"},
						{name: "cursor", control: "hidden"},
					]
				}, {
					// One form per order the header offers, all of them this
					// declaration: each states the key and every aria-sort
					// column at once, so no two headers can claim an order.
					id:     "dt-sort"
					entity: "DataCursor"
					action: "upsert"
					flow:   "dt-order"
					fields: [
						{name: "id", control: "hidden", value: "the"},
						{name: "sort", control: "hidden"},
						{name: "srt_id", control: "hidden"},
						{name: "srt_amount", control: "hidden"},
					]
				}]
				// No `empty`: a read prepares its collection before it answers,
				// so the seeded rows are there for the first one and the frame
				// has never been over a row that did not exist.
				states: ["populated", "populated-dark"]
			}
			navigation: {
				title:  "Navigation"
				route:  "/navigation"
				markup: components.navigationScreen.markup
				forms: []
				// The pair alone: the two collections the rail reads are
				// seeded, and the disclosure's row is the machine's own initial
				// fact, synthesized from its pinned filter — so no region here
				// is ever empty and there is no arrival frame to draw, which is
				// the contrast with /table and /select, whose rows are a
				// reader's (ir decision-36).
				states: ["populated", "populated-dark"]
			}
			popover: {
				title:  "Popover"
				route:  "/popover"
				markup: components.popoverScreen.markup
				forms: []
				states: ["populated", "populated-dark"]
			}
			"input-otp": {
				title:  "Input OTP"
				route:  "/input-otp"
				markup: components.otpScreen.markup
				// No form: every write here is an arrow's, and the two buttons
				// are clicks the chart answers.
				forms: []
				// No `empty`: the machine is the writer of the initial fact and
				// synthesizes the row its filter pins (ir decision-07), so the
				// screen is never over a row that does not exist.
				states: ["populated", "populated-dark"]
			}
			"hover-card": {
				title:  "Hover card"
				route:  "/hover-card"
				markup: components.hoverCardScreen.markup
				forms: []
				// The third screen in this app to declare no entity at all: what
				// opens the surface is the terminal, and what closes it is the
				// element, so there is no row for a frame to be over
				// (ir decision-45).
				states: ["populated", "populated-dark"]
			}
			chart: {
				title:  "Chart"
				route:  "/chart"
				markup: components.chartScreen.markup
				// Two, and both write the caret's one column: the pointer's
				// carries the bar it is on, the keyboard's the neighbour the
				// projection named beside it (ir decision-46).
				forms: [{
					id:     "chart-pick"
					entity: "ChartCursor"
					action: "upsert"
					flow:   "chart-caret"
					fields: [
						{name: "id", control: "hidden", value: "the"},
						{name: "active", control: "hidden"},
					]
				}, {
					id:     "chart-step"
					entity: "ChartCursor"
					action: "upsert"
					flow:   "chart-caret"
					fields: [
						{name: "id", control: "hidden", value: "the"},
						{name: "active", control: "hidden"},
					]
				}]
				// Both collections are seeded, so the plot stands on the first
				// paint and there is no arrival frame to draw.
				states: ["populated", "populated-dark"]
			}
			atoms: {
				title:  "Empty · Spinner · Kbd · Typography"
				route:  "/atoms"
				markup: components.atomsScreen.markup
				forms: []
				// No entity and no chart: four components with nothing to hold,
				// three of them skins over a fact the platform already owns
				// (ir decision-48).
				states: ["populated", "populated-dark"]
			}
			composition: {
				title:  "Item · Input group · Button group"
				route:  "/composition"
				markup: components.compositionScreen.markup
				forms: []
				// No `empty`: the machine is the writer of the initial fact and
				// synthesizes the row its filter pins (ir decision-07).
				states: ["populated", "populated-dark"]
			}
			chat: {
				title:  "Message · Bubble · Marker · Attachment · Scroller"
				route:  "/chat"
				markup: components.chatScreen.markup
				// One, and it states every column: a row half stated is one the
				// bindings read as blank (ir decision-50).
				forms: [components.chatDemo.form]
				// Both collections are seeded, so the transcript stands on the
				// first paint and there is no arrival frame to draw.
				states: ["populated", "populated-dark"]
			}
			questionnaire: {
				title:  "Questionnaire"
				route:  "/questionnaire"
				markup: components.questionnaireScreen.markup
				forms: []
				// No `empty`: the machine is the writer of the initial fact and
				// synthesizes the row its filter pins (ir decision-07).
				states: ["populated", "populated-dark"]
			}
			calendar: {
				title:  "Calendar"
				route:  "/calendar"
				markup: components.calendarScreen.markup
				// Four, two per instance, and every one of them the same upsert
				// of the same one column: a pick carries the cell it is on, a
				// move carries the cell a projection named beside it. Declared
				// by the component, so the markup and the surface are one
				// statement (ir decision-38).
				forms: components.calendarForms
				// Two frames and no `empty`: both collections are seeded, so the
				// grid stands on the first paint and no arrival arrow is drawn.
				states: ["populated", "populated-dark"]
			}
			// Every screen, present and future, wears the same chrome, so a
			// route opened cold arrives dressed. The catalog is the only place
			// a reader starts from — every other screen is reached from a card
			// in its grid — so the strip carries the catalog alone, which is a
			// strip of one link and therefore none at all: the terminal draws
			// no nav below two routes. The link it would have drawn is the one
			// each screen carries in its own header, and shell/shared/chrome.css
			// is what dresses it (ir decision-28).
			[Name=_]: {
				files: shared: ["shell/shared/chrome.css"]
				if Name != "catalog" {strip: false}
			}
		}

		// One module, and it is the whole of the rule it instantiates: a chart
		// may name a Jessie leaf where it cannot compute the value it needs,
		// and nowhere else (ir decision-34, decision-38). What survives
		// unqualified is the part that mattered — no screen carries a
		// data-on-* binding or a script, so no DOM event is ever handed to app
		// code, and a module reachable any other way is a design failure the
		// brief promises to surface.
		handlers: {
			"has-prefix": {
				of:   "menu"
				src:  "shell/handlers/has-prefix.js"
				note: "whether the typeahead buffer holds anything: the timer that clears it arms on every state entry, and without this it would write an empty buffer over an empty one once a second per move — a write that changes nothing still wakes the store"
			}
			"starts-with": {
				of:   "menu"
				src:  "shell/handlers/starts-with.js"
				note: "whether the letters a reader has typed name this item, as one boolean per item: the chart draws an arrow to every destination and asks each in turn, so the inventory stays in the chart rather than in a module that would pick one"
			}
			"is-printable": {
				of:   "menu"
				src:  "shell/handlers/is-printable.js"
				note: "whether a keydown is a reader typing rather than reaching for a key the chart already answers — a single character is typing, and Tab, Escape, Enter, Home, End and the arrows are all longer and all somewhere else's arrow"
			}
			"type-into": {
				of:   "menu"
				src:  "shell/handlers/type-into.js"
				note: "the typeahead buffer with this keystroke on the end: an assign holds a literal or a leaf, and buffer plus key is neither, so the arrow stays in the chart and the string it writes comes from here"
			}
			"month-step": {
				of:   "calendar"
				src:  "shell/handlers/month-step.js"
				note: "the calendar's month arithmetic, called with the reduce's signature over the calendar row alone in a compartment endowed with nothing: it returns the stepped month's key, that month's name, or the same grid position inside it, and the window's ends ride in the chart as params, so the leaf clamps rather than deciding"
			}
			"is-code": {
				of:   "input-otp"
				src:  "shell/handlers/is-code.js"
				note: "whether what has been typed is a complete code — the length and the character class a transition grammar has neither of, with the number as a param so the guard, the control's maxlength and the column's constraint come from one declaration"
			}
			"is-digits": {
				of:   "input-otp"
				src:  "shell/handlers/is-digits.js"
				note: "whether what has been typed could still become one: the arrow below it is the one that calls a keystroke wrong, and a code half typed is not"
			}
			"has-nondigit": {
				of:   "input-otp"
				src:  "shell/handlers/has-nondigit.js"
				note: "whether what has been typed holds a character no code can hold: the exact negation of is-digits, and having both is what makes the three arrows on one event exhaustive without a guardless one — which would have been the arrow nothing could drive, an event with no value stated being the control holding whatever it last held"
			}
			"flip-of": {
				of:   "checkbox"
				src:  "shell/handlers/flip-of.js"
				note: "the value a column takes next: a machine's assign holds a literal or a leaf, and the opposite of what is there is neither — the chart can read the row and has no expression to write with. One leaf serves the header's three-valued cycle and an item's plain flip, because an item is never mixed"
			}
			"roll-up": {
				of:   "checkbox"
				src:  "shell/handlers/roll-up.js"
				note: "what a select-all's items add up to once the one being clicked has flipped: the value no field can hold, since a field is what a machine decides and this follows from the row — assigned in the same write as the item, so the two are never seen disagreeing"
			}
			"unless-answered": {
				of:   "questionnaire"
				src:  "shell/handlers/unless-answered.js"
				note: "whether a step's Next is blocked by the answer the ROW holds, which is what a step arrow means: the destination's answer decides whether a reader is asked again. It never reads the event, because every click carries a value — a button's own, which is the empty string — so a leaf preferring the event would read every Back as an unanswered question"
			}
			"unless-typed": {
				of:   "questionnaire"
				src:  "shell/handlers/unless-typed.js"
				note: "whether the freeform step's Next is blocked by the answer the KEYSTROKE just made: the row still holds the one before it, so a leaf reading the row here would be a keystroke behind, always"
			}
			"is-key": {
				of:   "toggle-group"
				src:  "shell/handlers/is-key.js"
				note: "which key a keydown carried, as the boolean a guard reads: a transition grammar has no literal comparison, and every arrow moving a roving tabstop differs from its siblings only in the key that selects it, so one leaf with the key as a param serves every arrow #OneOf draws for every group on the page"
			}
		}

		design: (pronto.#DesignMd & {text: _designMd}).design

		// Four, over three screens, and each of them a commit: a form writes
		// the row a gesture decides, a machine writes screen state as it
		// changes (ir decision-17). The delete beside the fourth realizes no
		// flow of its own: taking a row away is the same gesture read
		// backwards, and a row-scoped delete names none.
		// Four, over three screens, and each of them a commit: a form writes the
		// row a gesture decides, a machine writes screen state as it changes
		// (ir decision-17).
		flows: {
			"pick-framework": {of: "combobox", entity: "ComboboxDemo", action: "upsert"}
			"select-pick": {of: "select", entity: "SelectDemo", action: "upsert"}
			"select-mint": {of: "select", entity: "SelectOption", action: "upsert"}
			"form-save": {of: "form", entity: "FormDemo", action: "upsert"}
			"table-mint": {of: "table", entity: "TableRow", action: "upsert"}
			"dt-choose": {of: "data-table", entity: "DataCursor", action: "upsert"}
			"dt-order":  {of: "data-table", entity: "DataCursor", action: "upsert"}
			"chart-caret": {of: "chart", entity: "ChartCursor", action: "upsert"}
			"chat-say": {of: "chat", entity: "ChatRow", action: "create"}
		}
	}

	meta: {
		name:        "shadcnui"
		description: "shadcn's catalog recompiled: each component is a tag that expands to markup, design tokens, and a state machine."
		ir: {sha256: "c3ad38514c64ddfc8ec6e87b89050346dc3395132fb3d97c5bbbd95b597b642d"}
		targets: ["pages"]
		decisions: {
			"decision-01": {}
			"decision-02": {}
			"decision-03": {}
			"decision-04": {}
			"decision-05": {}
			"decision-06": {}
			"decision-07": {}
			"decision-09": {}
			"decision-08": {}
			"decision-10": {}
			"decision-11": {}
			"decision-12": {}
			"decision-13": {}
			"decision-14": {}
			"decision-15": {}
			"decision-16": {}
			"decision-17": {}
			"decision-18": {}
			"decision-19": {}
			"decision-20": {}
			"decision-21": {}
			"decision-22": {}
			"decision-23": {}
			"decision-24": {}
			"decision-25": {}
			"decision-26": {}
			"decision-28": {}
			"decision-27": {}
			"decision-29": {}
			"decision-30": {}
			"decision-31": {}
			"decision-32": {}
			"decision-33": {}
			"decision-34": {}
			"decision-35": {}
			"decision-36": {}
			"decision-37": {}
			"decision-38": {}
			"decision-39": {}
			"decision-40": {}
			"decision-41": {}
			"decision-42": {}
			"decision-43": {}
			"decision-44": {}
			"decision-45": {}
			"decision-46": {}
			"decision-47": {}
			"decision-48": {}
			"decision-49": {}
			"decision-50": {}
			"decision-51": {}
		}
		tests: {
			"test-picker-select": {
				of: "PickerDemo"
				says:  "an option's click writes the choice, its readout label and every option's aria-selected as one row, and the listbox is a popover the trigger commands"
				given: {choice: "apple"}
				when:  "the banana option is clicked"
				then:  "output.writes == [\"banana\"] && output.label == \"Banana\" && output.popover == true"
			}
			"test-tabs-activate": {
				of: "TabsDemo"
				says:  "a trigger's click writes the active tab and every trigger's aria-selected as one row, and the way back is its own drawn arrow"
				given: {active: "account"}
				when:  "the password trigger is clicked, then the account trigger"
				then:  "output.writes == [\"password\", \"account\"] && output.selected == [\"false\", \"true\"]"
			}
			"test-switch-cycles": {
				of: "SwitchDemo"
				says:  "a click writes the machine's target state as a row, and a second click writes the way back"
				given: {checked: "false", clicks: 2}
				when:  "the switch is clicked twice"
				then:  "output.writes == [\"true\", \"false\"] && output.rows == 1"
			}
			"test-switch-initial": {
				of: "SwitchDemo"
				says:  "before any row exists the control binds the machine's initial state, keyed by the filter's pinned id"
				given: {rows: 0}
				when:  "the screen hydrates"
				then:  "output.ariaChecked == \"false\" && output.firstWriteId == \"the\""
			}
			"test-switch-row": {
				of: "SwitchDemo"
				says:  "the row readout and the control bind the same field, so they can never disagree"
				given: {checked: "true"}
				when:  "the row changes"
				then:  "output.readout.contains(\"checked: true\") && output.ariaChecked == \"true\""
			}
			"test-zero-js": {
				of: "switch"
				says:  "the switch screen ships no Jessie: its route lists no handler module"
				given: {}
				when:  "the emitted shell.yaml is read"
				then:  "output.handlers.size() == 0"
			}
			"test-machine-visualizable": {
				of: "switch"
				says:  "the emitted data-machine is the published subset, so it pastes into a statechart visualizer as valid XState config"
				given: {}
				when:  "generate vets the emitted screens"
				then:  "output.vetFindings == 0"
			}
			"test-toggle-group-selects": {
				of: "ToggleGroupDemo"
				says:  "an option's click checks it and unchecks every other as one row, and the checked option has no arrow to draw"
				given: {value: "left"}
				when:  "the center option is clicked, then the center option again"
				then:  "output.writes == [\"center\"] && output.checked == [\"false\", \"true\", \"false\"]"
			}
			"test-accordion-single": {
				of: "AccordionSingleDemo"
				says:  "opening an item closes the one that was open, as one row, and seats the caret on the header the reader pressed; the open item's own trigger returns the group to none"
				given: {open: "none"}
				when:  "the shipping trigger is clicked, then the returns trigger, then the returns trigger again"
				then:  "output.writes == [\"shipping\", \"returns\", \"none\"] && output.rows == 1 && output.expanded == [\"false\", \"false\", \"false\"] && output.charts == 2"
			}
			"test-accordion-walk": {
				of: "AccordionSingleDemo"
				says:  "the caret chart walks the headers without opening one, and no header is stamped with a tabindex — APG keeps every one of them in the Tab sequence, which is why the caret is data-cur and not a roving tabstop"
				given: {caret: "shipping"}
				when:  "Down is pressed on the first header, then End, then Right, then the header the caret reached is clicked"
				then:  "output.caret == [\"false\", \"false\", \"true\"] && output.expanded == [\"false\", \"false\", \"true\"] && output.tabindex == 0 && output.rows == 1"
			}
			"test-data-table-ends": {
				of: "DataCursor"
				says:  "Ctrl+End names the grid's last row and Ctrl+Home its first, while the bare keys move nothing — APG gives a grid's bare Home and End a movement within a row, and a caret that is a row over static cells has none to make"
				given: {cursor: ""}
				when:  "Down enters the grid, then Ctrl+End, then Ctrl+Home, then Ctrl+End and a bare Home"
				then:  "output.chordEnds == true && output.bareMoves == false && output.rows == 1"
			}
			"test-menu-walk": {
				of: "MenuProfileDemo"
				says:  "the caret crosses every item kind, the letters jump to the item they name, and the buffer clears a second after the last keystroke without moving anyone — one row for the whole surface, and no tabindex on any item"
				given: {caret: "switch"}
				when:  "Down is pressed three times, then End, then Right, then b, then e, then a second passes"
				then:  "output.caret == \"benoit\" && output.tabindex == 0 && output.prefix == \"\" && output.rows == 1"
			}
			"test-accordion-multiple": {
				of: "AccordionMultiDemo"
				says:  "each item is its own region, its own row and its own machine, so opening one mints nothing for the others"
				given: {rows: 0}
				when:  "the shipping trigger is clicked, then the support trigger"
				then:  "output.writes == [\"true\", \"true\"] && output.rows == 2 && output.expanded == [\"true\", \"false\", \"true\"]"
			}
			"test-accordion-narrowed": {
				of: "AccordionMultiDemo"
				says:  "every arrow is narrowed to its trigger, so a click inside an open panel resolves to the panel's id and matches nothing"
				given: {rows: 0}
				when:  "the shipping trigger is clicked, then the paragraph inside the open shipping panel"
				then:  "output.writes == [\"true\"] && output.rows == 1"
			}
			"test-overlays-stateless": {
				of: "overlays"
				says:  "the tier-0 claim is counted, not asserted: the overlays screen mounts no region, no machine and no handler module"
				given: {}
				when:  "the emitted screen and its route are read"
				then:  "output.regions == 0 && output.machines == 0 && output.handlers.size() == 0"
			}
			"test-overlays-commands": {
				of: "overlays"
				says:  "every surface is opened and closed by the platform's own vocabulary, and the ARIA the UA supplies is written nowhere"
				given: {}
				when:  "the emitted screen is read"
				then:  "output.commands == [\"show-modal\", \"close\", \"toggle-popover\", \"hide-popover\", \"toggle-popover\"] && output.handWrittenAria == 0"
			}
			"test-primitives-stateless": {
				of: "primitives"
				says:  "the componentless tier is an absence the suite checks: the screen mounts no region, no machine and no handler module"
				given: {}
				when:  "the emitted screen and its route are read"
				then:  "output.regions == 0 && output.machines == 0 && output.handlers.size() == 0"
			}
			"test-primitives-alert-roles": {
				of: "primitives"
				says:  "the three live-region answers ship as three specimens: no role for the callout already on the screen, status for the change that can wait, alert for the one that cannot"
				given: {}
				when:  "the emitted alerts are read in document order"
				then:  "output.roles == [\"\", \"status\", \"alert\"]"
			}
			"test-primitives-tokens-only": {
				of: "primitives"
				says:  "the screen where the token system is on trial paints with token names alone, so every variant has a dark twin by construction"
				given: {}
				when:  "the screen's stylesheet is read"
				then:  "output.literalColours == 0"
			}
			"test-combobox-commits": {
				of: "ComboboxDemo"
				says:  "a form with no button submits on change, so picking a suggestion upserts the row and the readout follows it"
				given: {choice: "Next.js"}
				when:  "the input takes a listed value and changes"
				then:  "output.writes == [\"Nuxt\"] && output.rows == 1"
			}
			"test-combobox-refuses": {
				of: "ComboboxDemo"
				says:  "the pattern generated from the option list refuses a value outside it, so a half-typed value never reaches the store"
				given: {choice: "Next.js"}
				when:  "the input changes to a value the option list does not carry"
				then:  "output.writes == [] && output.state == \"validation-error\""
			}
			"test-combobox-boundary": {
				of: "combobox"
				says:  "the screen runs no machine and loads no module: the write is the form's, and the boundary pane prints the chart it declines beside the one wall that stands"
				given: {}
				when:  "the emitted screen is read"
				then:  "output.machines == 0 && output.handlers.size() == 0 && output.walls == 1"
			}
			"test-checkbox-one-shape": {
				of: "checkbox"
				says:  "erase the field name, the trigger id and the narrowing itself and one chart is left across all five binary controls; what differs on this screen is the attribute each binds"
				given: {}
				when:  "the emitted machines are read with their field, their trigger and their narrowing erased"
				then:  "output.charts.size() == 1 && output.controls == 5 && output.attributes == [\"aria-checked\", \"aria-pressed\", \"aria-expanded\"]"
			}
			"test-checkbox-tristate": {
				of: "SelectAllDemo"
				says:  "mixed is what the items add up to, so a reader reaches it as often as they like: the header's click carries every item with it, and an item's click writes the header in the same row"
				given: {checked: "mixed"}
				when:  "the header is clicked twice, then one item is unchecked"
				then:  "output.checked == [\"true\", \"false\", \"mixed\"] && output.states == 1 && output.rows == 1"
			}
			"test-checkbox-attributes": {
				of: "checkbox"
				says:  "one field, three attributes: each control flips its own and writes its own row on its own collection"
				given: {}
				when:  "each of the three controls is clicked once"
				then:  "output.checked == \"true\" && output.pressed == \"true\" && output.expanded == \"true\" && output.tables == 3"
			}
			"test-checkbox-narrowed": {
				of: "CollapsibleDemo"
				says:  "the collapsible's one arrow is narrowed to its trigger, so a click inside the open panel resolves to the panel's id and matches nothing"
				given: {rows: 0}
				when:  "the trigger is clicked, then the paragraph inside the open panel"
				then:  "output.writes == [\"true\"] && output.rows == 1"
			}
			"test-radio-group-selects": {
				of: "RadioGroupDemo"
				says:  "an option's click chooses it and unchooses every other as one row; the chosen option and every description have no arrow to draw"
				given: {value: "starter"}
				when:  "the pro option is clicked, then the pro option again, then pro's description"
				then:  "output.writes == [\"pro\"] && output.checked == [\"false\", \"true\", \"false\"] && output.rows == 1"
			}
			"test-radio-group-labelled": {
				of: "radio-group"
				says:  "the group is named by its visible legend and each option is described by a sibling that is not part of its name"
				given: {}
				when:  "the emitted screen is read"
				then:  "output.groupName == \"Plan\" && output.names == [\"Starter\", \"Pro\", \"Team\"] && output.described == 3 && output.tabindex == 0 && output.named == 0"
			}
			"test-radio-group-one-machine": {
				of: "radio-group"
				says:  "the radio group's chart and the segmented control's are one chart: canonicalized by option index they are equal"
				given: {}
				when:  "both emitted machines are canonicalized by option index"
				then:  "output.canonical.size() == 1 && output.arrows == 6"
			}
			"test-pagination-steps": {
				of: "PaginationDemo"
				says:  "Next is the absolute arrow the generator drew from the state the reader is in, so two presses walk two positions and each writes the whole row"
				given: {page: "p1"}
				when:  "the next step is pressed twice"
				then:  "output.writes == [\"p2\", \"p3\"] && output.current == [\"false\", \"false\", \"page\", \"false\", \"false\"] && output.rows == 1"
			}
			"test-pagination-ends": {
				of: "PaginationDemo"
				says:  "the first position draws no previous arrow and the button says so through a bound boolean the binder removes when it interpolates empty"
				given: {page: "p1"}
				when:  "the previous step is pressed at the first page, then the reader steps forward"
				then:  "output.writes == [\"p2\"] && output.disabledAtFirst == [\"prev\"] && output.disabledAtSecond == []"
			}
			"test-pagination-absolute": {
				of: "PaginationDemo"
				says:  "a numbered page is the same kind of arrow as a step, so it lands from anywhere and moves every column with it"
				given: {page: "p1"}
				when:  "page 4 is pressed, then page 2"
				then:  "output.writes == [\"p4\", \"p2\"] && output.disabledAtEnd == [] && output.rows == 1"
			}
			"test-pagination-carousel": {
				of: "CarouselDemo"
				says:  "the carousel is the same chart projected: the dot jumps absolutely, one slide is shown by the root's data-state, and the last position loses its next arrow"
				given: {slide: "s1"}
				when:  "the third dot is pressed, then the next step"
				then:  "output.writes == [\"s3\", \"s4\"] && output.shown == [\"s4\"] && output.disabledAtEnd == [\"next\"]"
			}
			"test-pagination-inventory": {
				of: "pagination"
				says:  "the printed census is the emitted charts counted, not a number written beside them"
				given: {}
				when:  "the screen's inventory table is folded through the emitted machines"
				then:  "output.mismatches == 0 && output.arrows == [28, 18]"
			}
			"test-toast-after": {
				of: "ToastDemo"
				says:  "the wait the state declares is performed by the terminal: one click in, two writes out"
				given: {state: "closed", clicks: 1}
				when:  "the trigger is clicked and the page is left alone for the delay"
				then:  "output.writes == [\"open\", \"closed\"] && output.clicks == 1"
			}
			"test-toast-rearms": {
				of: "ToastDemo"
				says:  "re-entering the state re-arms its wait, so the toast lives a full delay measured from the last click"
				given: {state: "open"}
				when:  "the trigger is clicked again before the wait comes due, and the first delay then elapses"
				then:  "output.writes == [\"open\", \"open\", \"closed\"] && output.stillOpenAtFirstDeadline == true"
			}
			"test-toast-cancels": {
				of: "ToastDemo"
				says:  "leaving the state cancels the wait it armed, so a dismissed toast writes nothing when the delay comes round"
				given: {state: "open"}
				when:  "the dismiss button is clicked, then the delay passes"
				then:  "output.writes == [\"open\", \"closed\"] && output.writesAfterTheDeadline == 0"
			}
			"test-toast-at-rest": {
				of: "toast"
				says:  "a wait is armed by entering the state that declares one, so the initial state declaring none leaves the screen still"
				given: {}
				when:  "the emitted machine is read and the screen is hydrated untouched"
				then:  "output.statesWithAfter == [\"open\"] && output.writesWithoutClicks == 0"
			}
			"test-toast-live-region": {
				of: "toast"
				says:  "the announcement is the always-mounted viewport's, polite, and stated once"
				given: {}
				when:  "the emitted screen is read"
				then:  "output.liveRole == \"status\" && output.rolesOnTheSurface == 0 && output.handWrittenAria == 0"
			}
			"test-way-back": {
				of: "catalog"
				says:  "the catalog is the only route on the strip, so the terminal draws none, and every other screen carries the one link back that replaces it"
				given: {}
				when:  "the emitted routes and every emitted screen are read"
				then:  "output.stripRoutes == [\"/\"] && output.screensWithNoWayBack == 0"
			}
			"test-slider-value": {
				of: "SliderDemo"
				says:  "the leaf lifts the number the control was showing off the event, so a drag lands a number in the row rather than the text a submit would have carried"
				given: {phase: "live", volume: 50}
				when:  "the range input is moved to 72 and then to 13"
				then:  "output.volumes == [72, 13] && output.spellings == [\"number\", \"number\"]"
			}
			"test-slider-stays": {
				of: "SliderDemo"
				says:  "a targetless transition acts and stays, so the field is a constant and only the value column moves"
				given: {phase: "live", volume: 50}
				when:  "the range input is moved three times and the emitted chart is read"
				then:  "output.phases == [\"live\", \"live\", \"live\"] && output.states == 1 && output.targets == 0"
			}
			"test-slider-one-row": {
				of: "SliderDemo"
				says:  "the bar beside the control paints the control's own row, and the bar over a row nobody writes stands where it started"
				given: {phase: "live", volume: 50}
				when:  "the range input is moved to 88"
				then:  "output.barNow == \"88\" && output.otherBarNow == \"72\" && output.writtenTables == [\"slider_demo\"]"
			}
			"test-slider-aria": {
				of: "slider"
				says:  "no ARIA is written at all: the platform has an element for each half, and a label names each"
				given: {}
				when:  "the emitted screen is read"
				then:  "output.ariaAttributes == [\"aria-hidden\"] && output.nativeControls == [\"input[type=range]\", \"progress\", \"progress\"] && output.labelled == 3"
			}
			"test-resizable-sizes": {
				of: "ResizableDemo"
				says:  "the handle writes one column and the group binds it into a custom property, so both panes are stated by one number"
				given: {}
				when:  "the reader drags the handle from its opening position to 25 and then to 80"
				then:  "output.split == [25, 80] && output.bound == output.split && output.ariaAttributes == [\"aria-hidden\", \"role\"]"
			}
			"test-resizable-clamps": {
				of: "ResizableDemo"
				says:  "the ends are the control's own, so a value past them never reaches the column and no chart states the clamp"
				given: {}
				when:  "the range reports a value below its min and above its max"
				then:  "output.min == 15 && output.max == 85 && output.writesOutOfRange == 0"
			}
			"test-command-types": {
				of: "CommandDemo"
				says:  "the machine reads the value off its own event, so what a reader types is a column and the row follows every keystroke"
				given: {}
				when:  "the search field is typed into three times, the last returning it to empty"
				then:  "output.writes == [\"cal\", \"cale\", \"\"] && output.writesBeforeTheFirstKeystroke == 0"
			}
			"test-command-filters": {
				of: "CommandItem"
				says:  "the palette is one region over the command rows, ordered pos.asc and filtered by the enclosing row's query column, and the operator folds case"
				given: {}
				when:  "the reader types cal, then PROF, then zzz, then empties the field"
				then:  "output.listed == [[\"Calendar\", \"Calculator\"], [\"Profile\"], [], output.all]"
			}
			"test-command-seeds": {
				of: "CommandItem"
				says:  "the commands arrive as rows the terminal wrote from the entity's seed, and nothing on the screen writes one"
				given: {}
				when:  "the screen is hydrated and left alone"
				then:  "output.rows == 6 && output.order == output.pos && output.writesAfterArrival == 0"
			}
			"test-command-caret": {
				of: "CommandDemo"
				says:  "the arrows walk the caret off the projection's neighbours, the first one landing on the head of the current read, and typing clears it"
				given: {}
				when:  "the reader arrows down twice, up once, then types"
				then:  "output.active == [\"calendar\", \"emoji\", \"calendar\", \"\"] && output.focusCalls == 0"
			}
			"test-command-runs": {
				of: "CommandDemo"
				says:  "the caret and the choice are two columns, so arrowing past a command never runs it and Enter runs the one it stands on"
				given: {}
				when:  "the reader arrows onto a command, then submits the field, then clicks another option"
				then:  "output.chosenAfterArrow == \"\" && output.chosenAfterEnter == \"emoji\" && output.chosenAfterClick == \"billing\""
			}
			"test-select-commits": {
				of: "SelectDemo"
				says:  "a pick fires change on a form holding no button, which submits it, and the row is what lands"
				given: {rows: 0}
				when:  "the Kotlin option is picked"
				then:  "output.writes == [{id: \"the\", choice: \"Kotlin\"}] && output.buttons == 0"
			}
			"test-select-options-are-rows": {
				of: "SelectOption"
				says:  "the live group is a region, so a minted row is an option the reader can then pick"
				given: {rows: 0}
				when:  "Zig is added and then picked"
				then:  "output.liveOptions == [\"Zig\"] && output.authoredOptions == 4 && output.writes == [\"Zig\"]"
			}
			"test-select-mint-refuses": {
				of: "SelectOption"
				says:  "the option grammar is one sentence, and the input's generated pattern is where it refuses"
				given: {rows: 0}
				when:  "a leading space is submitted as an option id"
				then:  "output.writes == 0 && output.state == \"validation-error\""
			}
			"test-select-trade": {
				of: "select"
				says:  "the screen runs no machine and prints the comparison instead, both directions and the walls"
				given: {}
				when:  "the emitted screen is read"
				then:  "output.machines == 0 && output.handlers == 0 && output.tradeRows == 7 && output.walls == 3"
			}
			"test-breadcrumb-stateless": {
				of: "breadcrumb"
				says:  "four components with nothing to be in a state about mount no region, no machine and no handler module, and need no id either"
				given: {}
				when:  "the emitted screen and its route are read"
				then:  "output.regions == 0 && output.machines == 0 && output.handlers.size() == 0 && output.ids == 0"
			}
			"test-breadcrumb-trail": {
				of: "breadcrumb"
				says:  "the trail is the route's real ancestry, every ancestor a link to a route this app serves, and the current page is text under aria-current with no disabled control anywhere"
				given: {}
				when:  "the emitted breadcrumb is read against the app's own routes"
				then:  "output.hrefs == [\"/\"] && output.current == \"page\" && output.disabled == 0 && output.separatorsInTheTree == 0"
			}
			"test-breadcrumb-fallback": {
				of: "breadcrumb"
				says:  "the initials are the element's own content behind the image, so the accessible name is the wrapper's and does not move with the bytes"
				given: {}
				when:  "the emitted avatars are read in document order"
				then:  "output.names == [\"Ada Lovelace\", \"Grace Hopper\", \"\"] && output.alts == [\"\"] && output.fallbacksBehindTheImage == 3"
			}
			"test-breadcrumb-tree": {
				of: "breadcrumb"
				says:  "the printed tree is the markup it describes, in both directions: every row's node carries what the row says, and no role, aria-* or image alt on the screen goes unlisted"
				given: {}
				when:  "the emitted screen is folded through the table it prints"
				then:  "output.rowsWithNoNode == 0 && output.nodesDisagreeing == 0 && output.ariaWithNoRow == 0"
			}
			"test-breadcrumb-motion": {
				of: "breadcrumb"
				says:  "the pulse is a multiple of the motion token the reduced-motion block zeroes, and the placeholder announces nothing while claiming no busyness it does not have"
				given: {}
				when:  "the screen's stylesheet and markup are read"
				then:  "output.literalDurations == 0 && output.barsAnnouncing == 0 && output.ariaBusy == 0"
			}
			"test-menu-items": {
				of: "menu"
				says:  "the three item kinds sit under one surface: plain items are links to routes this app serves and write nothing, and every stateful item is a region of its own"
				given: {}
				when:  "the emitted screen is read against the app's own routes"
				then:  "output.linksOffRoute == 0 && output.regionsInsideRegions == 0 && output.writesFromALink == 0"
			}
			"test-menu-check": {
				of: "MenuOptionDemo"
				says:  "a checkbox item runs the binary chart narrowed to its own button, and the two items on the bar are two rows of one collection that cannot move each other"
				given: {checked: "false"}
				when:  "the bookmarks item is clicked twice and the full-URLs item once"
				then:  "output.bookmarks == [\"true\", \"false\"] && output.urls == [\"true\"] && output.rows == 2"
			}
			"test-menu-radio": {
				of: "MenuProfileDemo"
				says:  "a radio item chooses itself and unchooses every other as one row, and the chosen item's own click writes nothing"
				given: {profile: "andy"}
				when:  "the Benoit item is clicked, then clicked again"
				then:  "output.writes == [\"benoit\"] && output.chk == [\"false\", \"true\", \"false\"] && output.rows == 1"
			}
			"test-menu-one-chart": {
				of: "menu"
				says:  "the screen's two checkbox items run one chart and the profile set runs the catalog's single-select chart: canonicalized by trigger id and by option index, neither pair can drift apart unnoticed"
				given: {}
				when:  "the emitted machines are canonicalized and compared"
				then:  "output.binaryCharts == 1 && output.oneOfMatches == true"
			}
			"test-menu-tree": {
				of: "menu"
				says:  "nothing but items, groups and separators reaches either menu's tree, and every group is named by the heading it hides"
				given: {}
				when:  "the emitted menus are folded through the roles they admit"
				then:  "output.strangersInTheTree == 0 && output.unnamedGroups == 0 && output.barChildrenNotItems == 0"
			}
			"test-menu-keyboard": {
				of: "menu"
				says:  "no tabindex is emitted, so every item and every trigger keeps its own tab stop, and no aria-expanded is written where the UA supplies one"
				given: {}
				when:  "the emitted screen is read"
				then:  "output.tabindex == 0 && output.writtenAriaExpanded == 0 && output.shortcutHints == 0"
			}
			"test-menu-no-context": {
				of: "menu"
				says:  "no arrow on the screen keys on contextmenu, and the interpreter cancels an event nowhere but a form's submit and a drag — so the refusal is measured rather than asserted"
				given: {}
				when:  "the emitted charts and the interpreter's cancellations are read"
				then:  "output.contextArrows == 0 && output.preventDefaultSites == [\"submit\", \"dragover\", \"drop\"]"
			}
			"test-sheet-one-generator": {
				of: "sheet"
				says:  "the three names are one generator: fold the instance key out and the sheet and the drawer differ by data-edge alone, while the alert dialog adds a role and one button and nothing else"
				given: {}
				when:  "the four emitted surfaces are canonicalized against each other"
				then:  "output.edgeOnly == [\"data-edge\"] && output.alertAdds == [\"role\", \"button.dialog-ask\"]"
			}
			"test-sheet-dismissal": {
				of: "sheet"
				says:  "every surface opens and closes through commandfor and command alone, both of the alert dialog's answers included, and the ARIA the UA supplies is written nowhere"
				given: {}
				when:  "the emitted screen is read"
				then:  "output.commands == [\"show-modal\", \"close\", \"show-modal\", \"close\", \"show-modal\", \"close\", \"show-modal\", \"close\", \"close\"] && output.unresolvedCommandfor == 0 && output.handWrittenAria == 0"
			}
			"test-sheet-alert-contract": {
				of: "sheet"
				says:  "one surface carries role=alertdialog, it is named and described by elements that exist, and the control that opens with focus is the refusal rather than the answer"
				given: {}
				when:  "the emitted surfaces are read"
				then:  "output.alertdialogs == 1 && output.namedAndDescribed == 4 && output.autofocused == \"Cancel\""
			}
			"test-sheet-stateless": {
				of: "sheet"
				says:  "asking a question is not holding one: the screen mounts no region, no machine and no handler module, and reaches the store not once"
				given: {}
				when:  "the emitted screen and its route are read"
				then:  "output.regions == 0 && output.machines == 0 && output.handlers.size() == 0 && output.storeTouched == 0"
			}
			"test-sheet-motion": {
				of: "sheet"
				says:  "each edge rests where it will travel from and states that rest twice, and no duration on the screen is a literal, so zeroing the tokens lands every surface instantly"
				given: {}
				when:  "the screen's stylesheet is read"
				then:  "output.literalDurations == 0 && output.travelling == 4 && output.startingFrames == 4"
			}
			"test-form-commits": {
				of: "FormDemo"
				says:  "a submit the gate admits states one row keyed by the form's hidden id, and the readout beside it follows"
				given: {rows: 0}
				when:  "a handle and a bio are typed and Save is pressed"
				then:  "output.writes == [{id: \"the\", handle: \"ada_lovelace\", bio: \"Wrote the first algorithm.\"}] && output.rows == 1"
			}
			"test-form-refuses": {
				of: "FormDemo"
				says:  "a handle the generated pattern refuses never reaches the store, the row it would have overwritten is untouched, and the one thing that clears the refusal is a keystroke"
				given: {handle: "ada_lovelace"}
				when:  "the saved handle is typed over with one the grammar refuses and Save is pressed, then one more character is typed"
				then:  "output.writesAfterTheSave == 0 && output.rowUnchanged == true && output.stateAfterSubmit == \"validation-error\" && output.alertRevealed == true && output.stateAfterTyping == \"populated\""
			}
			"test-form-defaults": {
				of: "form"
				says:  "each control binds its DEFAULT value — the input's value attribute, the textarea's own text — so the reset the shell performs on an accepted write lands on the row rather than on blank"
				given: {rows: 0}
				when:  "a handle and a bio are typed and Save is pressed, so the shell resets the form"
				then:  "output.dataValueControls == 0 && output.handleAfterReset == \"ada_lovelace\""
			}
			"test-form-labelled": {
				of: "form"
				says:  "every control is named by a label that resolves to it and described by a hint a reader can see; the refusal is an assertive live region no description names, and no aria-invalid is written at all"
				given: {}
				when:  "the emitted screen is read"
				then:  "output.unlabelledControls == 0 && output.describedByHidden == 0 && output.alertRoles == [\"alert\"] && output.ariaInvalid == 0"
			}
			"test-form-clears": {
				of: "FormDemo"
				says:  "the delete is a list region over the pinned row, so the affordance and the row arrive and leave together"
				given: {rows: 0}
				when:  "the screen hydrates, a row is saved, and the delete is pressed"
				then:  "output.deleteButtons == [0, 1, 0] && output.rows == 0 && output.states == [\"empty\", \"populated\", \"empty\"]"
			}
			"test-form-declaration": {
				of: "form"
				says:  "the form printed in the closing pane is the form in the markup, folded both ways: every declared field is a named control and every named control is a declared field"
				given: {}
				when:  "the emitted screen is folded through the declaration it prints"
				then:  "output.fieldsWithNoControl == 0 && output.controlsWithNoField == 0 && output.machines == 0 && output.handlers.size() == 0"
			}
			"test-table-rows": {
				of: "TableRow"
				says:  "a minted row is a rendered row: the tbody is a region whose item is a tr, and the columns the header states are the columns the row carries"
				given: {rows: 0}
				when:  "two rows are minted through the form the component ships"
				then:  "output.renderedRows == 2 && output.rowHeaders == 2 && output.headCells == 4 && output.cellsPerRow == 4"
			}
			"test-table-filters": {
				of: "TableRow"
				says:  "the table's region reads again under the enclosing row's query, at an arity that only works because the row template is named"
				given: {rows: 3}
				when:  "a query matching two rows is typed, then one matching one, then none, then emptied"
				then:  "output.matches == [2, 1, 0, 3] && output.template == \"named\""
			}
			"test-table-no-sort": {
				of: "table"
				says:  "the order is a literal the author wrote: no data-order on the screen interpolates, no column header is a control, and no arrow writes anything a region reads"
				given: {}
				when:  "the emitted screen and its chart are read"
				then:  "output.interpolatedOrders == 0 && output.headerControls == 0 && output.assignedColumns == [\"query\"]"
			}
			"test-table-arrives": {
				of: "TableQuery"
				says:  "the query row is stated on arrival by the chart's own clock, so the table stands before anyone types, and the state it lands in arms nothing"
				given: {rows: 0}
				when:  "the screen is hydrated and left alone"
				then:  "output.state == \"typing\" && output.tableRendered == true && output.writesAfterRest == 0"
			}
			"test-table-css-only": {
				of: "table"
				says:  "both CSS-only components carry the one fact that is not CSS: a scroll box is a named tab stop, and a ratio is a class rather than a length on the instance"
				given: {}
				when:  "the emitted screen is read"
				then:  "output.scrollAreas == 2 && output.unnamedScrollAreas == 0 && output.inlineStyles == 0"
			}
			"test-data-table-seeded": {
				of: "DataRow"
				says:  "the rows arrive with the program: the emitted shell states them, nobody mints them, and the screen has no arrival beat to pass through"
				given: {rows: 0}
				when:  "the screen is hydrated and left alone"
				then:  "output.seeded == 8 && output.mintForms == 0 && output.machineStates == 1 && output.writesAfterRest == 0"
			}
			"test-data-table-chosen": {
				of: "DataCursor"
				says:  "choosing a row writes one column of one row, and every row's aria-selected is that column compared against its own id"
				given: {cursor: "INV-1024"}
				when:  "the third row's own button is pressed"
				then:  "output.writes == [\"INV-1026\"] && output.selected == 1 && output.dataRowWrites == 0 && output.active == \"INV-1026\""
			}
			"test-data-table-walks": {
				of: "DataCursor"
				says:  "the arrow keys walk the grid through the neighbour the projection named, and stop at the ends rather than wrapping"
				given: {cursor: "INV-1024"}
				when:  "ArrowDown is pressed twice, then ArrowUp, then ArrowUp twice more at the top"
				then:  "output.active == [\"INV-1025\", \"INV-1026\", \"INV-1025\", \"INV-1024\", \"INV-1024\"] && output.focusMoves == 0"
			}
			"test-data-table-filters": {
				of: "DataRow"
				says:  "a keystroke narrows the grid and clears the choice, and the next arrow enters at the first row of what is left"
				given: {cursor: "INV-1029"}
				when:  "a query matching two rows is typed, then ArrowDown, then the field is emptied"
				then:  "output.matches == [2, 2, 8] && output.cleared == true && output.active == \"INV-1024\""
			}
			"test-data-table-positions": {
				of: "data-table"
				says:  "a row carries one ARIA state and no positional attribute of any kind, and no column header is a control"
				given: {}
				when:  "the grid is read whole, then under a filter matching two rows"
				then:  "output.stateAttrs == [\"aria-selected\"] && output.positionAttrs == 0 && output.headerControls == 0"
			}
			"test-navigation-rows": {
				of: "NavRailItem"
				says:  "the rail's items are seeded rows read under a literal order, standing before anyone touches the screen and written by nobody"
				given: {rows: 5}
				when:  "the screen is hydrated and left alone"
				then:  "output.railLinks == 5 && output.order == [\"Switch\", \"Tabs\", \"Menu\", \"Navigation\", \"Table\"] && output.writes == 0"
			}
			"test-navigation-current": {
				of: "NavRailItem"
				says:  "exactly one link is the current page, and the column that decides it is the projection's answer rather than anything a row stores"
				given: {rows: 5}
				when:  "the rail is rendered against the row naming the open route"
				then:  "output.currentLinks == 1 && output.currentHref == \"/navigation\" && output.storedCurrent == 0 && output.assignedColumns == [\"open\"]"
			}
			"test-navigation-collapse": {
				of: "NavSidebarDemo"
				says:  "the disclosure over the rail is one arrow narrowed to its own button, and the element it collapses is the one it names"
				given: {rows: 0}
				when:  "the control is pressed twice, and once more from inside the rail"
				then:  "output.expanded == [\"false\", \"true\"] && output.controls == \"nav-rail-board\" && output.rows == 1 && output.writesFromRail == 0"
			}
			"test-navigation-one-machine": {
				of: "navigation"
				says:  "the screen adds no chart to the catalog: one machine, and canonicalized by field name and trigger id it is the collapsible's but for which state it opens in"
				given: {}
				when:  "the emitted screen's one chart is canonicalized against the collapsible's"
				then:  "output.machines == 1 && output.differsFromCollapsible == [\"initial\"]"
			}
			"test-navigation-composition": {
				of: "navigation"
				says:  "the bar is the menubar generator and the narrow board the sheet generator, with every link a route this app serves and nothing restating what an element already says"
				given: {}
				when:  "the emitted screen is read against shell.yaml"
				then:  "output.menuItems == 6 && output.railLinks == 10 && output.deadLinks == 0 && output.barLabels == 0 && output.writtenAria == 0 && output.unresolvedCommandfor == 0"
			}
			"test-navigation-keyboard": {
				of: "navigation"
				says:  "every stop on the screen is the platform's own: no partial tabindex, no virtual focus, no key binding standing in for the roving tabstop the bar does not have, and the two scroll boxes that do take a stop are named"
				given: {}
				when:  "the emitted screen is read"
				then:  "output.partialTabindex == 0 && output.activedescendant == 0 && output.keyBindings == 0 && output.namedScrollAreas == 2"
			}
			"test-popover-platform": {
				of: "popover"
				says:  "every surface is opened by an invoker that resolves, the attribute carries one of its two rendered values, the ARIA the UA supplies is written nowhere, and the two scroll boxes that take a tab stop are named"
				given: {}
				when:  "the emitted screen is read"
				then:  "output.surfaces == 7 && output.unresolvedCommandfor == 0 && output.popoverValues == [\"auto\", \"manual\"] && output.handWrittenAria == 0 && output.namedScrollAreas == 2"
			}
			"test-popover-anchored": {
				of: "popover"
				says:  "each surface is placed against its own trigger by three CSS properties, and the top layer is what leaves the screen with no stacking to declare"
				given: {}
				when:  "the emitted screen and its stylesheet are read"
				then:  "output.unanchoredSurfaces == 0 && output.danglingAnchorNames == 0 && output.zIndexes == 0"
			}
			"test-popover-placement": {
				of: "popover"
				says:  "the placement table the screen prints is the stylesheet it describes, in both directions, and every fallback is its place's mirror on the axis that place sits on"
				given: {}
				when:  "the emitted screen is folded through its own stylesheet"
				then:  "output.placesWithNoRule == 0 && output.rulesWithNoRow == 0 && output.wrongArea == 0 && output.wrongFallback == 0"
			}
			"test-popover-manual": {
				of: "popover"
				says:  "the withdrawal is one attribute value and it forces the way out: the manual surface is the only one carrying a dismiss, and every auto one carries none"
				given: {}
				when:  "the emitted surfaces are read"
				then:  "output.manualSurfaces == 1 && output.manualWithoutDismiss == 0 && output.autoWithDismiss == 0"
			}
			"test-popover-stateless": {
				of: "popover"
				says:  "openness is not state anyone here holds: the screen mounts no region, no machine and no handler module, and reaches the store not once"
				given: {}
				when:  "the emitted screen and its route are read"
				then:  "output.regions == 0 && output.machines == 0 && output.handlers.size() == 0 && output.storeTouched == 0"
			}
			"test-calendar-steps": {
				of: "CalendarDemo"
				says:  "one month arrow writes three columns out of one leaf, and the grid is read again under the month it wrote"
				given: {rows: 212}
				when:  "the next-month arrow is pressed once from the month the visit opens on"
				then:  "output.month == \"2026-10\" && output.label == \"October 2026\" && output.value == \"2026-10-p15\" && output.writes == 1 && output.gridMonths == [\"2026-10\"]"
			}
			"test-calendar-clamps": {
				of: "CalendarDemo"
				says:  "the window's ends are literals in the chart and the leaf clamps to them, so an arrow at an end names the month it is already on"
				given: {rows: 212}
				when:  "the next-month arrow is pressed three times from September, past the last seeded month"
				then:  "output.months == [\"2026-10\", \"2026-11\", \"2026-11\"] && output.cells == 42"
			}
			"test-calendar-projection": {
				of: "CalendarCell"
				says:  "every ARIA state a day cell carries is a projected answer over rows the region holds, and no cell column holds one"
				given: {rows: 212}
				when:  "the September grid is rendered and one day is picked"
				then:  "output.selected == 1 && output.outside == 12 && output.colindexes == [1, 2, 3, 4, 5, 6, 7] && output.storedAriaColumns == 0"
			}
			"test-composition-relationships": {
				of: "composition"
				says:  "each arrangement is one relationship and the screen keeps it: a row that goes nowhere is no link, the group owns the box the ring is on, and the action group wears no aria-checked — the roster's fourth is the form screen's and is named rather than declared twice"
				given: {}
				when:  "the emitted markup is read"
				then:  "output.hrefless == 0 && output.fieldDefinitions == 1 && output.checkedActions == 0"
			}
			"test-composition-logical": {
				of: "composition"
				says:  "direction is an attribute rather than a provider: every edge this screen states is logical, so dir=rtl mirrors it and nothing in the terminal is told"
				given: {}
				when:  "the screen's stylesheet is read"
				then:  "output.physicalEdges == 0 && output.rtlFrames == 1"
			}
			"test-chat-kinds": {
				of: "ChatRow"
				says:  "one region over three kinds, and the kind is a column: a marker carries no seat, no avatar and no bubble, because it is a row nobody said"
				given: {rows: 6}
				when:  "the transcript is rendered"
				then:  "output.rows == 6 && output.bubbles == 4 && output.markers == 1 && output.regions == 1"
			}
			"test-chat-grows": {
				of: "chat"
				says:  "the composer adds a row and the live edge needs no listener: one create states every column, and the layout is what puts the newest row under the reader's eye"
				given: {rows: 6}
				when:  "a message is sent"
				then:  "output.rows == 7 && output.stated == 9 && output.listeners == 0"
			}
			"test-quiz-steps": {
				of: "QuizDemo"
				says:  "the steps are the chart's states and the answers are columns: choosing writes the answer and its option's own attribute, Next leaves only an answered step, and Back comes forward without asking again"
				given: {step: "one"}
				when:  "the first question is answered, Next, Back and Next again"
				then:  "output.step == [\"one\", \"two\", \"one\", \"two\"] && output.blocked == \"\" && output.rows == 1"
			}
			"test-quiz-skip": {
				of: "QuizDemo"
				says:  "skip is the arrow with no block on it, and it states an answer of its own rather than leaving the column empty"
				given: {step: "two"}
				when:  "the second question is skipped"
				then:  "output.step == \"three\" && output.answer == \"Skipped\""
			}
			"test-catalog-links": {
				of: "catalog"
				says:  "the index links every route the program declares and every link is a route: a screen nothing names is one nothing reaches, and a card pointing at a route that is gone is a dead end"
				given: {}
				when:  "the index is mounted and the emitted routes read"
				then:  "output.unlinked == 0 && output.dangling == 0 && output.controls == 0"
			}
			"test-atoms-skins": {
				of: "atoms"
				says:  "each of the four is a skin over a fact something else holds, and the screen states which: no region, no chart, no module, and a stylesheet that declares no colour of its own"
				given: {}
				when:  "the screen is mounted and its stylesheet read"
				then:  "output.regions == 0 && output.machines == 0 && output.literalColours == 0"
			}
			"test-atoms-reduced-motion": {
				of: "atoms"
				says:  "the spinner carries the wait without its animation: role=status and a label, so what reduced motion takes away is the decoration"
				given: {}
				when:  "the spinner's markup and rule are read"
				then:  "output.role == \"status\" && output.labelled == 3 && output.reducedMotionRule == true"
			}
			"test-chart-geometry": {
				of: "chart"
				says:  "a bar's length is calc() over a bound value and a bound domain, and the domain is computed where the rows are stated rather than derived from them"
				given: {rows: 6}
				when:  "the plot is rendered"
				then:  "output.bars == 6 && output.domain == 305 && output.arithmeticInMarkup == 0"
			}
			"test-chart-caret": {
				of: "ChartCursor"
				says:  "one tab stop for the whole plot, and Down, Up, Home and End write the caret's column off the projection's neighbours — the same column a click on a bar writes"
				given: {active: "mar"}
				when:  "ArrowDown, Home and End are pressed on the plot, and a bar is clicked"
				then:  "output.active == [\"apr\", \"jan\", \"jun\", \"feb\"] && output.tabStops == 1 && output.pointWrites == 0"
			}
			"test-chart-is-a-table": {
				of: "ChartPoint"
				says:  "the picture is the data: a row header per category, a cell per value, every bar's accessible name carrying the number it draws, and the line over them stating no number of its own"
				given: {rows: 6}
				when:  "the accessibility tree is read off the plot"
				then:  "output.rowHeaders == 6 && output.namedBars == 6 && output.lineText == \"\""
			}
			"test-hover-card-reachable": {
				of: "hover-card"
				says:  "the card's own link is reachable: the surface follows its trigger in document order, and focus moving into it keeps it open"
				given: {}
				when:  "the trigger takes focus and the reader Tabs into the card"
				then:  "output.open == true && output.surfaceFollowsTrigger == true"
			}
			"test-hover-card-aria": {
				of: "hover-card"
				says:  "a card carries neither role=tooltip nor aria-describedby, and the tip that carries both is the same terminal behaviour with the opposite answer"
				given: {}
				when:  "the emitted screens are read"
				then:  "output.cardRoles == 0 && output.cardDescribedBy == 0 && output.tipRoles == 1"
			}
			"test-hover-card-no-state": {
				of: "hover-card"
				says:  "openness is nobody's row: no region, no chart, no module, and not one call to the store on the whole visit"
				given: {}
				when:  "the screen is mounted and hovered"
				then:  "output.regions == 0 && output.machines == 0 && output.storeCalls == 0"
			}
			"test-otp-one-control": {
				of: "input-otp"
				says:  "the code is one control and the boxes are the stylesheet's: a paste arrives as one event and lands as one write, and no slot is an input of its own"
				given: {code: ""}
				when:  "six digits are pasted into the field"
				then:  "output.inputs == 1 && output.writes == [\"148203\"]"
			}
			"test-otp-complete": {
				of: "OtpDemo"
				says:  "the sixth digit completes the code, and what makes the verify button pressable is the column the same arrow wrote"
				given: {code: "14820"}
				when:  "the last digit is typed and the button is pressed"
				then:  "output.state == [\"complete\", \"verified\"] && output.blocked == \"\""
			}
			"test-otp-refused": {
				of: "OtpDemo"
				says:  "a keystroke that can never be part of a code is written and marked rather than swallowed, and the two arrows above it are the reason a code half typed is not wrong"
				given: {code: "148"}
				when:  "a letter is typed, and then a digit"
				then:  "output.invalid == [\"true\", \"false\"] && output.code == [\"148x\", \"1482\"]"
			}
			"test-calendar-keyboard": {
				of: "calendar"
				says:  "the four arrows walk the grid off the projection's neighbours: one tab stop, one column written per press, and no cell row touched"
				given: {rows: 212}
				when:  "ArrowRight, ArrowDown, ArrowUp and ArrowLeft are pressed on the grid in turn"
				then:  "output.active == [\"2026-09-p16\", \"2026-09-p23\", \"2026-09-p16\", \"2026-09-p15\"] && output.tabStops == 1 && output.cellWrites == 0"
			}
			"test-calendar-seeded": {
				of: "CalendarCell"
				says:  "the rows arrive with the visit and nothing on the screen writes a cell: the collections are the program's world, not the reader's"
				given: {rows: 212}
				when:  "the emitted screen and the emitted seed are read together"
				then:  "output.seededCells == 210 && output.seededRows == 2 && output.grids == 5 && output.cellsPerGrid == 42 && output.formsWritingCells == 0"
			}
			"test-calendar-no-today": {
				of: "calendar"
				says:  "no day is marked today, and the one module on the screen is reachable only as a chart's leaf"
				given: {}
				when:  "the emitted screen, its route and its chart are read"
				then:  "output.ariaCurrent == 0 && output.handlers == [\"shell/handlers/month-step.js\"] && output.chartNamed == 1 && output.domHandlers == 0"
			}
		}
	}
}

// The terminal's statics ride the cluster's caddy image; without this wiring
// the image bakes only the ladder docs and every route 404s.
cluster: (pronto.#DefaultCluster & {"code": code, statics: terminal.surface.statics}).out
terminal: (pronto.#DefaultTerminal & {"code": code}).out
loop: (pronto.#DefaultLoop & {"code": code, "cluster": cluster, "terminal": terminal}).out

// The acceptance suite: every screen mounted whole through the platform
// harness, against the EMITTED tree and a store that answers the fragment
// grammar. No cluster and no browser, so it rides the test verb. What each
// component is FOR is this suite's; that every arrow of every chart fires is
// the terminal's `machines` check, which needs nothing from this app.
//
// One invocation, because no file here has a module-load side effect: the clock
// is the test's, taken from the harness, rather than a knob read off location
// when a module is first evaluated.
loop: surface: checks: "gallery": {
	verb: "test"
	cmds: [
		"deno test --config tests/deno.json --no-lock --no-check --allow-env --allow-read tests/gallery.test.ts tests/screens.test.ts",
	]
	note: "hydrates every emitted screen and drives each component's machine: toggles write rows, the initial state is synthesized, the readout agrees with the control, and a fact between two instances of one component holds still"
}

build: (pronto.#DefaultBuild & {"code": code, "loop": loop, "cluster": cluster}).out

out: pronto.#emit & {"code": code, "cluster": cluster, "terminal": terminal, "loop": loop, "build": build}
