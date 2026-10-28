package components

import (
	"strings"
	terminal "bonisoft.org/plugins/omnishell:terminal"
)

_#InitialRow: R={
	charts: [...terminal.#Machine]
	defaults: [string]: string | number | bool | null
	out: R.defaults & {for chart in R.charts {(chart.field): chart.initial}}
}

_initialRows: {
	"switch_demo": (_#InitialRow & {charts: [_switch.machine], defaults: {}}).out
	"tabs_demo": (_#InitialRow & {charts: [_tabs.machine], defaults: _tabs._choice.defaults}).out
	"picker_demo": (_#InitialRow & {charts: [_picker.machine], defaults: _picker.defaults}).out
	"toggle_group_demo": (_#InitialRow & {charts: [_toggleGroup.machine], defaults: _toggleGroup._choice.defaults}).out
	"accordion_single_demo": (_#InitialRow & {charts: [_accordionSingle._expansion, _accordionSingle._caret.machine], defaults: _accordionSingle._allClosed & _accordionSingle._caret.defaults}).out
	"accordion_multi_demo": (_#InitialRow & {charts: [_accordionMulti.machines.shipping], defaults: {}}).out
	"select_all_demo": (_#InitialRow & {charts: [selectAllDemo.machine], defaults: selectAllDemo.defaults}).out
	"checkbox_demo": (_#InitialRow & {charts: [_checkboxTerms.machine], defaults: {}}).out
	"toggle_demo": (_#InitialRow & {charts: [_toggle.machine], defaults: {}}).out
	"collapsible_demo": (_#InitialRow & {charts: [_collapsible.machine], defaults: {}}).out
	"radio_group_demo": (_#InitialRow & {charts: [_radioGroup.machine], defaults: _radioGroup._choice.defaults}).out
	"pagination_demo": (_#InitialRow & {charts: [_pagination.machine], defaults: _pagination._o.defaults}).out
	"carousel_demo": (_#InitialRow & {charts: [_carousel.machine], defaults: _carousel._o.defaults}).out
	"toast_demo": (_#InitialRow & {charts: [_toast.machine], defaults: {}}).out
	"slider_demo": (_#InitialRow & {charts: [_slider.machine], defaults: _slider.defaults}).out
	"resizable_demo": (_#InitialRow & {charts: [resizableDemo.machine], defaults: resizableDemo.defaults}).out
	"command_demo": (_#InitialRow & {charts: [commandDemo.machine], defaults: commandDemo.defaults}).out
	"menu_profile_demo": (_#InitialRow & {charts: _dropdownMenu._surface.charts, defaults: _dropdownMenu._surface._caret.defaults & _menuProfile._choice.defaults}).out
	"menubar_demo": (_#InitialRow & {charts: [_menubar._bar.machine], defaults: _menubar._bar.defaults}).out
	"menu_option_demo": (_#InitialRow & {charts: _menubar._surfaces[0].charts, defaults: _menubar._surfaces[0]._caret.defaults}).out
	"menu_go_demo": (_#InitialRow & {charts: _menubar._surfaces[1].charts, defaults: _menubar._surfaces[1]._caret.defaults}).out
	"context_menu_demo": (_#InitialRow & {charts: _contextMenu._charts, defaults: _contextMenu.defaults & _contextMenu._caret.defaults}).out
	"table_query": (_#InitialRow & {charts: [tableDemo.machine], defaults: tableDemo.defaults}).out
	"data_cursor": (_#InitialRow & {charts: [dataTable.machine], defaults: dataTable.defaults}).out
	"nav_sidebar_demo": (_#InitialRow & {charts: [_railBoard.machine], defaults: {}}).out
	"calendar_demo": (_#InitialRow & {charts: [calendarDemo.machine], defaults: calendarDemo.defaults}).out
	"otp_demo": (_#InitialRow & {charts: [otpDemo.machine], defaults: otpDemo._empty}).out
	"composition_demo": (_#InitialRow & {charts: [compositionDemo.machine], defaults: compositionDemo._empty}).out
	"quiz_demo": (_#InitialRow & {charts: [quizDemo.machine], defaults: quizDemo.defaults}).out
}

entityDefaults: {for table, row in _initialRows {(table): {for col, value in row {
	(col): [
		if value == null {"NULL"},
		if (value & string) != _|_ {"'" + strings.Replace(value, "'", "''", -1) + "'"},
		"\(value)",
	][0]
}}}}
