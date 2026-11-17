# SAMA Recursion Analysis

**Status:** Draft
**Purpose:** Identify source-supported recursive call relationships.

## Detection
- Identify direct recursion when a function calls itself.
- Identify mutual recursion when two or more functions form a source-supported directed call cycle.
- Represent the actual recursive call relationships established by the source.

## Classification
- Use `recursive` for an established recursive relationship.
- Use `conditional_recursive` only when the recursive relationship itself depends on a condition established by the source.
- Do not label an ordinary call as recursive merely because it participates in a larger workflow or recursion is theoretically possible.
