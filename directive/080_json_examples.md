# SAMA JSON Examples

**Status:** Draft
**Purpose:** Show the required JSON representation of source-supported module dependencies and function interactions.

## Example Rules
- Examples use actual names and relationships from the established GHPUtil source-analysis material.
- Do not treat example data as permission to invent entities or relationships in a new analysis.
- Every generated analysis must be grounded independently in the source materials supplied for that analysis.
- Preserve the exact JSON field names and structures shown here.

## Module Dependency Example

This excerpt represents the established relationships from `github_publish.sh` to `config.sh` and `validation.sh`.

```json
{
  "module": {
    "rows": [
      "github_publish.sh",
      "config.sh",
      "validation.sh"
    ],
    "calls": [
      {
        "from": 0,
        "to": 1,
        "line_type": "solid"
      },
      {
        "from": 0,
        "to": 2,
        "line_type": "solid"
      }
    ]
  }
}
```

## Function Interaction Example

This excerpt represents the established direct calls from `bootstrap()` to `main()`, and from `main()` to `run_step()`.

```json
{
  "function": {
    "rows": [
      {
        "name": "bootstrap()",
        "module": "github_publish.sh"
      },
      {
        "name": "main()",
        "module": "github_publish.sh"
      },
      {
        "name": "run_step()",
        "module": "validation.sh"
      }
    ],
    "calls": [
      {
        "from": 0,
        "to": 1,
        "line_type": "solid"
      },
      {
        "from": 1,
        "to": 2,
        "line_type": "solid"
      }
    ]
  }
}
```

## Index Interpretation
- `from: 0` identifies the first entry in the corresponding `rows` array.
- `to: 1` identifies the second entry in that array.
- Indexes are zero-based and must be recalculated from the final row ordering.
- Never copy an index from an example without verifying the target row in the current analysis.
- These excerpts are partial JSON fragments illustrating the established schema; they are not complete SAMA output documents.
