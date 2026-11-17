# SAMA JSON Output Contract

**Status:** Draft
**Purpose:** Define the exact JSON structure and field requirements.

## Required Top-Level Structure
- `project`
- `archive`
- `analysis_method`
- `module`
  - `rows`
  - `calls`
- `function`
  - `rows`
  - `calls`
- `notes`

## Field Requirements
- `project`: string; use the established project name, or an empty string if it cannot be established.
- `archive`: string; use the exact supplied archive filename, or an empty string if no archive was supplied.
- `analysis_method`: concise string describing the actual analysis method and material boundaries, including whether source code was executed.
- `module.rows`: array of strings containing exact names of included modules or relevant software units.
- `module.calls`: array of relationship objects.
- `function.rows`: array of objects, each containing exactly `name` and `module`, both strings.
- `function.calls`: array of relationship objects.
- `notes`: array of strings containing material qualifications, uncertainties, unresolved references, limitations, and interpretation notes.

## Relationship Object
- Each relationship object must contain exactly `from`, `to`, and `line_type`.
- `from` and `to` are zero-based integer indexes into the corresponding `rows` array.
- `module.calls` indexes refer to `module.rows`.
- `function.calls` indexes refer to `function.rows`.
- Every index must be within the corresponding array bounds.

## Schema Restrictions
- Preserve the structure and field names exactly.
- Do not add, remove, rename, or repurpose fields.
- Do not add renderer-specific, layout, coordinate, styling, or presentation properties.
- Do not add relationship properties such as `kind`, `label`, or `conditional`.
