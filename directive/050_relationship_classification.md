# SAMA Relationship Evidence and Classification

**Status:** Draft
**Purpose:** Apply consistent evidence rules and relationship types.

## Evidence Rules
- Include only relationships directly supported by inspected source materials.
- A direct call, import, include, source operation, or explicit reference may establish a direct relationship when its target is identifiable.
- Represent an indirect or conditional relationship only when the source establishes its mechanism or condition.
- Distinguish static evidence from runtime uncertainty.
- Omit relationships that cannot be established with sufficient confidence.
- Explain material omissions or uncertainty in `notes`.

## Permitted `line_type` Values
- `solid`: explicit, direct relationship established by the source.
- `dashed`: established indirect, dynamically dispatched, configuration/data-mediated, or other non-direct relationship.
- `recursive`: established recursive relationship.
- `conditional_recursive`: established recursive relationship whose occurrence depends on a source-defined condition.

## Restrictions
- Use only the four exact values above.
- Do not create new relationship types.
- Do not infer execution order, frequency, success, or runtime reachability from static evidence alone.
