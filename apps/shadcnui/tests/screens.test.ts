// Each demo screen mounted WHOLE — every component instance on it at once,
// the app's own emitted markup, a store that answers the fragment grammar, and
// the table's clock in the test's hand.
//
// The terminal's `machines` check answers for the same screens one region at a
// time, reading each through the filter that region pins, so it cannot see a
// fact that exists only BETWEEN instances — and a component gallery is exactly
// where those live.
//
// catalog is not mounted: it declares no data-live and no data-machine, so it
// computes nothing a test could name.
//
// Every assertion names a row the interpreter wrote or an attribute it bound
// from one. The emitted markup as such is the bijection check's, upstream.
import { assert, mountApp, type Mounted, oneByRole, only, type Row, textOf, writes } from "../../../plugins/omnishell/test/screen-harness.ts";
import { machineRegions } from "../../../plugins/omnishell/interpreter/lint.ts";

const APP = new URL("../", import.meta.url);

// No machine in this gallery is random, so the value only has to be fixed.
const SEED = 20260901;

// The gallery's three collections. Every entity takes the `tab` path
// (program.cue decision-01), so the app emits no migration and no table: a
// collection starts the visit empty, and that is what is seeded here.
// shell.yaml's `local:` block names exactly these three.
const tables = (): Record<string, Row[]> => ({ switch_demo: [], tabs_demo: [], picker_demo: [] });

const screen = (name: string) => mountApp({ appDir: APP, screen: name, seed: SEED, tables: tables() });

const tableTables = (): Record<string, Row[]> => ({ table_query: [], table_row: [] });

/** The one control of a role a reader would name; none or several is the screen
 * disagreeing with the reader, not a query to widen. */
// Each switch is named by the row its filter pins, which is the only thing
// telling the two apart — one() throws on a selector naming none or both, so
// reaching a switch this way is itself the proof that two distinct instances
// hydrated.
const SWITCH = (row: string) => `[role="switch"][data-filter="id=eq.${row}"]`;
const READOUT = (row: string) => `.rowview[data-filter="id=eq.${row}"] .row-readout`;

Deno.test({
  name: "the switch screen binds both instances from nothing, and persists nothing",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await screen("switch");
    await m.settle();
    // A tab collection opens empty and the fallback row is synthesized, never
    // stored: a screen that wrote on hydration would leave a visit's worth of
    // rows behind for the next screen to read.
    assert(m.rows("switch_demo").length === 0, `hydration stored ${JSON.stringify(m.rows("switch_demo"))}`);
    assert(writes(m).length === 0, `hydration wrote ${JSON.stringify(writes(m))}`);

    // aria-checked is written from {checked}, so an unbound control keeps the
    // placeholder: the opening value states that each instance synthesized a
    // fallback from the id its own filter pins.
    for (const row of ["the", "wifi"]) {
      assert(
        m.one(SWITCH(row)).getAttribute("aria-checked") === "false",
        `${row}'s control opened on ${m.one(SWITCH(row)).getAttribute("aria-checked")}`,
      );
    }

    // The panes are the other half of the same fact, and the emitter writes
    // their opening sentence into them as content — so only a value the markup
    // does not already carry proves one is bound at all.
    await m.store.put("switch_demo", { id: "the", checked: "true" });
    await m.settle();
    assert(
      textOf(m.one(READOUT("the"))) === "id: the · checked: true",
      `the pane reads "${textOf(m.one(READOUT("the")))}" for a row it should have followed`,
    );
    assert(
      textOf(m.one(READOUT("wifi"))) === "id: wifi · checked: false",
      `wifi's pane reads "${textOf(m.one(READOUT("wifi")))}" after a write it does not cover`,
    );
    await m.stop();
  },
});

Deno.test({
  name: "two switches on one collection move only their own row",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await screen("switch");
    await m.settle();

    // THE CASE THIS FILE EXISTS FOR. Both switch regions carry byte-identical
    // data-machine and data-live; the id in data-filter is the whole of an
    // instance's identity. Every write goes into the one collection both
    // subscribe to, so every write wakes both. Cache the machine's working row
    // per collection instead of per region, or key the synthesized fallback off
    // the table rather than off the filter, and one switch's click drags the
    // other's ARIA with it. The chart walk reads each region's field through
    // that region's own pinned filter, so the failure is structurally
    // invisible to it.
    m.fire(m.one(SWITCH("wifi")));
    await m.settle();

    const wifi = only(m.rows("switch_demo"), "after touching wifi alone");
    assert(wifi.id === "wifi", `the click on Wi-Fi wrote row "${wifi.id}"`);
    assert(wifi.checked === "true", `Wi-Fi landed on ${wifi.checked}`);
    assert(
      m.one(SWITCH("the")).getAttribute("aria-checked") === "false",
      "the other switch followed a click it never received",
    );
    assert(textOf(m.one(READOUT("the"))) === "id: the · checked: false", `the other pane moved: "${textOf(m.one(READOUT("the")))}"`);

    // And the two hold opposite values at once, which is only expressible if
    // each instance owns a row of its own.
    m.fire(m.one(SWITCH("the")));
    await m.settle();
    m.fire(m.one(SWITCH("the")));
    await m.settle();

    const rows = m.rows("switch_demo");
    assert(rows.length === 2, `two switches, ${rows.length} rows: ${JSON.stringify(rows)}`);
    assert(only(rows.filter((r) => r.id === "the"), "the").checked === "false", "the round trip did not come back");
    assert(only(rows.filter((r) => r.id === "wifi"), "wifi").checked === "true", "Wi-Fi lost its state to its neighbour");
    assert(m.one(SWITCH("the")).getAttribute("aria-checked") === "false", "the ARIA disagrees with the row it binds");
    assert(m.one(SWITCH("wifi")).getAttribute("aria-checked") === "true", "the ARIA disagrees with the row it binds");

    // No machine on this screen declares an `after`, so a minute of table time
    // owes nothing: a timed transition added without a demo pane to describe it
    // would move a row here.
    m.advance(60_000);
    await m.quiet();
    assert(
      JSON.stringify(m.rows("switch_demo")) === JSON.stringify(rows),
      `the clock moved a row on its own: ${JSON.stringify(m.rows("switch_demo"))}`,
    );
    await m.stop();
  },
});

Deno.test({
  name: "a tab trigger moves every region on the screen off one row",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await screen("tabs");
    await m.settle();
    assert(m.rows("tabs_demo").length === 0, `hydration stored ${JSON.stringify(m.rows("tabs_demo"))}`);
    // The control's opening state comes from the machine's initial plus its
    // context; the pane's from a hand-written data-empty-row listing the same
    // columns. Two declarations of one fact, checked against each other.
    assert(
      textOf(m.one(".row-readout")) === "active: account · account: true · password: false",
      `the pane opened on "${textOf(m.one(".row-readout"))}"`,
    );

    m.fire(oneByRole(m.mount, "tab", "Password"));
    await m.settle();

    const row = only(m.rows("tabs_demo"), "after activating password");
    assert(row.id === "the", `the write landed on row "${row.id}"`);
    assert(row.active === "password", `active is ${row.active}`);
    assert(row.sel_account === "false" && row.sel_password === "true", `the aria columns read ${JSON.stringify(row)}`);
    // The one row is read back by the control region and by the pane, which
    // declare different worlds and recompute independently. A first write that
    // stated the field without every context column would leave the pane and
    // the ARIA telling a reader two different stories.
    assert(m.one(".tabs").getAttribute("data-state") === "password", "the panel projection did not follow the row");
    assert(
      oneByRole(m.mount, "tab", "Password").getAttribute("aria-selected") === "true" &&
        oneByRole(m.mount, "tab", "Account").getAttribute("aria-selected") === "false",
      "aria-selected did not follow the row",
    );
    assert(
      textOf(m.one(".row-readout")) === "active: password · account: false · password: true",
      `the pane reads "${textOf(m.one(".row-readout"))}"`,
    );
    assert(writes(m).length === 1, `one activation, ${writes(m).length} writes: ${JSON.stringify(writes(m))}`);
    await m.stop();
  },
});

Deno.test({
  name: "the picker's first choice states a whole row inside its own filter",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    const m = await screen("picker");
    await m.settle();
    assert(m.rows("picker_demo").length === 0, `hydration stored ${JSON.stringify(m.rows("picker_demo"))}`);
    assert(textOf(m.one(".picker-value")) === "Apple", `the trigger opened on "${textOf(m.one(".picker-value"))}"`);
    assert(
      textOf(m.one(".row-readout")) === "choice: apple · label: Apple",
      `the pane opened on "${textOf(m.one(".row-readout"))}"`,
    );

    m.fire(oneByRole(m.mount, "option", "Cherry"));
    await m.settle();

    const row = only(m.rows("picker_demo"), "after choosing cherry");
    // The picker region reads `id=eq.the` and had no row to update, so its
    // first write is a whole stated row concluded from the synthesized
    // fallback. It has to carry that same id and every column the machine's
    // context seeded: a row landing outside the region's own filter is a row
    // the region cannot see, and the readouts below would snap back to Apple.
    assert(row.id === "the", `the first write landed on row "${row.id}"`);
    assert(row.choice === "cherry" && row.label === "Cherry", `the row reads ${JSON.stringify(row)}`);
    assert(
      row.sel_apple === "false" && row.sel_banana === "false" && row.sel_cherry === "true",
      `the aria columns read ${JSON.stringify(row)}`,
    );
    assert(textOf(m.one(".picker-value")) === "Cherry", `the trigger reads "${textOf(m.one(".picker-value"))}"`);
    assert(
      textOf(m.one(".row-readout")) === "choice: cherry · label: Cherry",
      `the pane reads "${textOf(m.one(".row-readout"))}"`,
    );
    assert(
      oneByRole(m.mount, "option", "Cherry").getAttribute("aria-selected") === "true" &&
        oneByRole(m.mount, "option", "Apple").getAttribute("aria-selected") === "false",
      "aria-selected did not follow the row",
    );
    assert(writes(m).length === 1, `one choice, ${writes(m).length} writes: ${JSON.stringify(writes(m))}`);
    await m.stop();
  },
});

Deno.test({
  name: "the table's frame arrives on the terminal's own beat",
  sanitizeOps: false,
  sanitizeResources: false,
  async fn() {
    // The one screen here whose opening act is a beat rather than a reader:
    // `pending` arms an `after` at hydration and the arrow states the query
    // row. Nothing below touches the screen.
    const m = await mountApp({ appDir: APP, screen: "table", seed: SEED, tables: tableTables() });
    await m.settle();

    // The row is the clock's, not a reader's.
    assert(
      JSON.stringify(m.rows("table_query")) === JSON.stringify([{ query: "", id: "the", state: "typing" }]),
      `the beat stated ${JSON.stringify(m.rows("table_query"))}`,
    );
    // And the frame it gates is on the screen, with its head still inert.
    const head = m.one("thead");
    assert(
      head.querySelectorAll("button, a, input, select, [tabindex], [role], [aria-sort]").length === 0,
      "no column header is a control, and none claims aria-sort",
    );
    assert(m.one("[data-live='table_row']").getAttribute("data-order") === "id.asc", "the order is a literal");
    await m.stop();
  },
});

Deno.test({
  name: "the emitted screens carry charts for the terminal's check to walk",
  async fn() {
    // That the check DROVE them is its own invariant (check-machines refuses an
    // app that states charts and walks none). What only this app can say is
    // that its emitter is still writing them — how many moves with every
    // component, so the floor is that there are any.
    let regions = 0;
    for await (const f of Deno.readDir(new URL("../shell/screens", import.meta.url))) {
      if (!f.isFile || !f.name.endsWith(".html")) continue;
      regions += machineRegions(await Deno.readTextFile(new URL(`../shell/screens/${f.name}`, import.meta.url))).length;
    }
    assert(regions >= 2, `the emitted screens carry ${regions} machine regions`);
  },
});
