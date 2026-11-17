# SAMA JSON Validation and Delivery

**Status:** Draft
**Purpose:** Validate and deliver the generated JSON.

## Validation
- Confirm that the output parses as valid JSON.
- Confirm that top-level keys and nested object keys match the established schema exactly.
- Confirm that all required values have the correct JSON types.
- Confirm that every function's `module` value identifies an entry in `module.rows`.
- Confirm that every relationship object contains exactly `from`, `to`, and `line_type`.
- Confirm that every relationship index is an integer within the bounds of the correct `rows` array.
- Confirm that every `line_type` is one of the four permitted values.
- Confirm that the required second-pass function-graph recursion analysis was completed before delivery.
- Confirm that every `recursive` or `conditional_recursive` function relationship was verified against the source and participates in a self-call or directed call cycle.
- Confirm that the recursion analysis considered cycles of arbitrary length, not only self-calls or pairs of functions.
- Check for accidental duplicate entities or relationships.
- Confirm that every entity and relationship is supported by inspected source materials.
- Confirm that no synthetic, fictitious, illustrative, sample, demonstration, or placeholder data has been included.
- Confirm that material uncertainty and limitations are recorded in `notes`.

## Failed or Incomplete Checks
- Do not imply that a check passed when it could not be completed.
- Record material limitations in `notes`.

## Delivery
- Deliver the generated JSON as the analysis output.
- Keep any explanation outside the JSON separate from the JSON document.
- Do not modify source materials as part of the analysis task.
