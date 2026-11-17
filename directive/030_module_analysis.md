# SAMA Module Analysis

**Status:** Draft
**Purpose:** Identify modules and source-supported relationships between them.

## Module Identification
- Identify modules and relevant software units using their actual source-defined names.
- Include configuration or resource files only when they materially participate in a relationship represented in the analysis.
- Do not infer dependencies from directory co-location or similar filenames.

## Module Relationships
- Identify source-supported imports, includes, sourcing, configuration access, data access, installer copying, and other structural dependencies.
- Record the direction of each relationship as established by the source.
- Use `solid` for explicit direct relationships.
- Use `dashed` for established indirect or mediated relationships.
- Do not treat `dashed` as permission to include speculative relationships.
- Do not infer execution order, frequency, success, or runtime reachability from a static dependency alone.
