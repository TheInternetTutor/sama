# SAMA Function Analysis

**Status:** Draft
**Purpose:** Identify functions and source-supported interactions between them.

## Function Identification
- Include functions actually defined in supplied source materials.
- Preserve source-defined names, including meaningful signature notation.
- Associate each function with the actual module or source file where it is defined.
- Retain functions even when no caller is identified; absence of an identified caller does not prove that a function is unused.

## Function Interactions
- Identify direct calls and other source-supported invocation relationships between user-defined functions.
- Represent indirect or dynamically dispatched calls only when the dispatch mechanism and possible target are established by source evidence.
- Do not invent a target when it is selected dynamically and cannot be resolved.
- Exclude language built-ins, standard-library routines, external commands, and operating-system utilities unless the established schema and analysis purpose explicitly represent them.
- Record material exclusions or limitations in `notes`.
