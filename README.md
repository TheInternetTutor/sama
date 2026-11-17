# Modular Function Call Diagrams — Project Handover

## Purpose and starting idea

This project grew out of the idea: *“Let's assume that we have a Bash module called A, containing several functions inside, called A1 and A2...”* The goal is to find a clear, compact way to document how functions in a modular program call one another—including calls within a module, calls across modules, conditional calls, and recursion.

The diagram should make the program's structure and possible call relationships easy to understand at a glance. It is a **call-relationship diagram**, not necessarily a chronological execution trace: it describes which calls may occur, not one particular run of the program.

## Approaches considered

### Mermaid diagrams

We first explored Mermaid flowcharts, especially arrangements using subgraphs to represent modules and nodes to represent functions. The desired layout was compact and landscape-oriented: module groups arranged side by side, with their functions stacked vertically inside each group. We tested eight combinations of parent direction, subgraph direction, and declaration order. Results varied with the renderer and were not predictable enough for the layout we wanted. Some arrangements became too long, some too wide, and some appeared in reverse group order. One tested arrangement looked promising, but the overall experience showed that Mermaid layout control was too fragile for this particular diagram. The eight experiments and their conclusions are documented separately in `mermaid_layout_experiments.md` and `020_documentation/010_mermaid_subgraph_layout_experiment_conclusions.md` in the existing GHPUtil materials.

### ASCII diagrams

We also considered ASCII-art diagrams as a lightweight, portable alternative. They could use aligned function labels, horizontal tracks, vertical connectors, and simple symbols for call starts, destinations, conditions, and recursion. ASCII would be easy to generate in a terminal or Markdown document and would avoid dependence on a diagram renderer. Its main weakness is that routing many crossing or long-distance relationships can become cluttered and alignment can be fragile when labels or fonts vary. It remains a useful fallback for terminal output or compact documentation.

### HTML table with SVG drawing

The current direction is a standalone HTML document. The HTML table acts only as an invisible geometry and alignment framework: no visible borders, no cell padding, and no cell spacing. SVG draws the visible diagram elements—function tracks, call paths, arrowheads, and markers. Function names occupy the first column; their horizontal tracks should be vertically centered and emerge from the midpoint of each name. Call paths use a shared coordinate system so long vertical connectors remain continuous across intervening rows.

The current prototype is `modular_function_call_matrix.html`, stored beside the GHPUtil ZIP archives. Its rendering is promising: a clean, borderless matrix with function tracks and visible call paths. It demonstrates that SVG over an HTML layout can give us more deterministic control than Mermaid. The screenshot reviewed on November 13, 2026 showed eight function rows and seven call relationships. This is a prototype, not yet a finalized specification.

## Example model used so far

The example contains three modules and eight functions:

- Module A: `A.a1`, `A.a2`
- Module B: `B.b1`, `B.b2`, `B.b3`
- Module C: `C.c1`, `C.c2`, `C.c3`

The relationships demonstrated are:

1. `A.a1 → A.a2` — unconditional call within one module.
2. `A.a1 → B.b3` — unconditional call across modules.
3. `B.b3 → B.b2` — conditional call, directed upward in the matrix.
4. `B.b3 → B.b3` — direct recursion.
5. `A.a2 → B.b1` and `B.b1 → A.a2` — mutual recursion, represented by two distinct directed calls.
6. `C.c1 → A.a2` — upward cross-module call.

The prototype uses separate horizontal lanes to keep multiple calls visible. Arrowheads point toward the callee. A dashed connector and diamond distinguish the conditional call. Direct recursion is shown as a loop returning to the same function. Mutual recursion is two opposing directed relationships; it is not one combined event. Recursion itself does not imply that a call is conditional—termination conditions may be internal to the functions.

## Matrix and layout concepts

- Rows represent functions; groups of rows represent modules.
- A function's horizontal SVG track identifies its row.
- Call relationships are drawn as thicker SVG paths, with a clear start marker and destination arrow/marker.
- Vertical connectors may pass through intervening rows; their paths must remain continuous and must not be confused with calls to those intermediate functions.
- A spacer row between function rows was considered to provide routing room. The current shared-SVG-overlay approach may make explicit spacer rows unnecessary, or they may still be useful for visual separation.
- Initially, a square matrix was proposed, with one call-position column per function. The design may later decouple the number of function rows from the number of call lanes/slots; there is no requirement that the final diagram remain square.
- Module colors and a legend were considered, but deliberately deferred until geometry, routing, and semantics are stable.
- Possible universal markers were discussed: a start marker, a destination/end marker, a conditional marker (such as a diamond), and a recursion treatment. Exact marker vocabulary and shape conventions remain open.
- The diagram should distinguish a static call graph (possible call relationships) from a concrete execution trace (the sequence of calls in one run). If columns imply an order, their meaning must be explicitly defined; otherwise they should be understood as routing lanes, not time or execution order.

## Possible automatic or deterministic generation

A longer-term idea is to generate the diagram from program structure rather than hand-authoring each relationship. One route would be to define a small structured data model—functions, modules, and directed call edges—and have JavaScript deterministically render the table and SVG. This would make layout repeatable and allow the diagram to be regenerated whenever the data changes.

A more ambitious route would inspect the actual program source and infer function-to-function calls. For Bash, this would require understanding function definitions, direct calls, sourced files, aliases or indirect invocation patterns, and potentially dynamically constructed command names. Static analysis may identify many direct relationships, but it cannot always resolve dynamic behavior.

An even more ambitious proposal is to execute or instrument the program and collect call traces. This introduces the key difficulty Emilio raised: to capture every possible scenario, one would need to exercise every relevant branch, input, environment, error condition, and runtime path. In general, exhaustive path coverage can be impractical or impossible, especially when behavior depends on external state or unbounded input. A runtime trace therefore shows only the scenarios actually exercised; it must not be mistaken for a complete call graph. A sensible progression would be:

1. Hand-authored example data to settle the visual notation.
2. A deterministic renderer driven by explicit function/call records.
3. Optional static source analysis for relationships that can be inferred reliably.
4. Optional runtime instrumentation for observed execution traces, clearly labeled as observed scenarios rather than exhaustive truth.

## Current status and next design work

The HTML/SVG approach is the current preferred direction. The prototype already makes the relationships visible and establishes a promising visual language. The next iteration should refine the diagram rather than revisit the whole technology choice. In particular, review connector routing and spacing, clarify the meaning of call lanes/columns, and settle the start/destination markers. Keep color coding and data-driven generation as later steps unless they become necessary to solve a current layout problem.

This handover is intended to seed a separate project. Continue from the existing prototype and the design decisions above; do not assume the GHPUtil publishing utility itself is part of the new project's scope. The current HTML file and Mermaid experiment notes are useful background artifacts, not immutable specifications.
