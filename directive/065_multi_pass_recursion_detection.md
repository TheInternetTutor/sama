# SAMA Multi-Pass Recursion Detection

**Status:** Draft  
**Purpose:** Require an independent second-pass analysis of the initially generated JSON to identify and verify recursive function-call cycles.

## Required Analysis Passes

- Perform at least two distinct analytical passes before delivering the JSON.
- Pass 1 must inspect the supplied source materials and construct the initial JSON, including `function.rows` and the source-supported relationships in `function.calls`.
- Preserve the Pass 1 JSON as the initial analysis result. Do not treat its initial relationship classifications as final until Pass 2 is complete.
- Pass 2 must independently inspect the generated `function.calls` relationship graph for recursion. Do not rely only on recursion noticed while reading individual source files during Pass 1.

## Pass 2 — Function-Graph Cycle Analysis

- Treat `function.calls` as a directed graph. Each relationship's `from` index identifies the calling function and its `to` index identifies the called function.
- Use the corresponding entries in `function.rows` to resolve each index to its function name and module.
- Inspect the graph for:
  - Direct recursion: a self-loop in which a function calls itself.
  - Mutual recursion: a directed cycle involving two or more distinct functions.
  - Longer cycles: cycles involving any number of functions; do not limit the search to pairs of functions.
- Check the complete graph, not merely adjacent pairs or the first apparent cycle. A function may participate in more than one cycle.
- Identify the actual relationship edges that participate in each detected cycle. Do not classify every edge in a larger workflow as recursive merely because that workflow contains a cycle elsewhere.

## Source Verification and Classification

- Treat a graph cycle as a candidate recursion finding, not as independent proof that the source implements that call behavior.
- For every candidate cycle, trace each participating relationship back to the supplied source materials and verify that the calls and their targets are genuinely supported.
- Confirm that the relationships represent calls between the identified functions, rather than coincidental name matches, unresolved dynamic targets, or speculative links.
- If every participating call is source-supported, classify the participating relationship edges as recursive.
- Use `conditional_recursive` only when the source establishes that the recursive call relationship itself depends on a condition. Do not use it merely because a function contains an unrelated conditional branch.
- If a candidate cycle depends on an unsupported or unresolved edge, do not report the cycle as established recursion. Omit or correct unsupported relationships and record material uncertainty in `notes`.
- Do not invent missing edges to complete a cycle. Do not add entities or relationships that are not grounded in the supplied source materials.

## Apply Corrections to the JSON

- Update the relevant `line_type` values in `function.calls` after Pass 2 verification.
- Preserve the exact JSON schema, existing function rows, relationship indexes, and all classifications that remain correct.
- Do not add recursion-specific fields, labels, graph metadata, or explanatory properties.
- If Pass 2 reveals a missing source-supported call relationship, add it only after verifying it against the source, then re-evaluate the graph for cycles.
- If a relationship is reclassified or removed, ensure that the final graph and all indexes remain consistent.

## Final Check

- Re-run the structural JSON checks after all Pass 2 corrections.
- Confirm that every reported recursive or conditional-recursive edge participates in a verified source-supported cycle or self-call.
- Confirm that no source-supported recursive cycle was overlooked in the completed graph analysis, to the extent permitted by the inspected source materials.
- Record unresolved dynamic calls, inaccessible source references, or other limitations that prevent a conclusive recursion determination in `notes`.
- Deliver only the final corrected JSON, not the uncorrected Pass 1 version, unless the user explicitly requests intermediate results.
