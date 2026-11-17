# SAMA Analysis Scope

**Status:** Draft
**Purpose:** Define the source-analysis task and its boundaries.

## Objective
- Analyze supplied software source materials.
- Identify source-supported structural entities and relationships.
- Generate one valid JSON document conforming exactly to the established SAMA schema.

## Scope
- Analyze software source materials.
- Keep the approach extensible to additional domains without adding non-software entities or schema fields to a software analysis.
- End the task when the conforming JSON has been generated and checked.

## Evidence Boundary
- Use supplied source materials as the evidence base.
- Do not substitute assumptions, conventions, remembered project details, summaries, or expected behavior for source evidence.
- Inspect actual supplied files; do not infer their contents from filenames or directory names.
- Do not execute source code unless the user explicitly requests execution as a separate task.
- Never present static inspection as runtime observation.
- Do not generate synthetic, fictitious, illustrative, sample, demonstration, or placeholder entities or relationships.
- Do not modify source materials.
