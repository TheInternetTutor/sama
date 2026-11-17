# SAMA Source Analysis and JSON Generation Directive

**Status:** Active  
**Scope:** Static analysis of supplied software source materials and generation of the corresponding SAMA analysis JSON.

## Purpose

Analyze the supplied software source materials, identify source-supported structural entities and relationships, and produce a JSON document that conforms exactly to the established SAMA analysis schema.

This directive governs only source-material analysis and JSON generation. Its responsibility ends when the conforming JSON has been generated and checked. Do not expand this task into visualization, presentation, rendering, or implementation of any downstream consumer.

## Analysis Boundary

- Treat the supplied source materials as the evidence base. Do not substitute assumptions, conventions, remembered project details, or general knowledge for source evidence.
- The immediate analysis domain is software. Keep the analysis approach sufficiently general to accommodate additional domains in the future, but do not introduce non-software entities or schema extensions into a software analysis.
- Analyze the actual supplied files. Do not infer source contents from filenames, directory names, summaries, prior examples, or expected behavior.
- Do not execute source code unless the user explicitly requests execution as a separate part of the task. Static inspection must not be represented as runtime observation.
- Do not claim that a function, module, command, branch, or relationship executes at runtime unless that conclusion is directly established by the available evidence.
- Do not generate synthetic, fictitious, illustrative, sample, demonstration, or placeholder data of any kind. Every entity, function, module, and relationship in the output must be grounded in the supplied source materials.

## Source Discovery and Reference Resolution

- Inspect the supplied project structure and identify the source files relevant to the requested analysis.
- Follow relevant references recursively. When a source file refers to another file, module, script, configuration, manifest, resource, or document that materially informs the structure or relationships being analyzed, inspect that referenced material when it is available.
- Continue reference resolution when a referenced file contains further relevant references. Do not stop at the first level merely because the original source file has been inspected.
- Include referenced material only when it is relevant to the requested structural analysis. Do not indiscriminately include unrelated files.
- If a relevant referenced file is missing, inaccessible, excluded, or otherwise unavailable, do not reconstruct its contents. Record the limitation in `notes` and avoid asserting relationships that depend on the unavailable evidence.
- Distinguish a file's existence from its participation in an established relationship. A filename, comment, documentation statement, or configuration value may provide evidence, but its meaning must be interpreted within its actual source context.

## Structural Analysis

Identify the relevant source-supported modules and functions, then determine the relationships that can be established from the inspected materials.

### Modules

- Identify source modules and other relevant software units represented in the analysis, using their actual names as found in the supplied materials.
- Include configuration or resource files as module rows only when they materially participate in a relationship represented by the analysis.
- Identify source-supported module relationships, such as sourcing, importing, inclusion, configuration or data access, installer copying, and other explicit structural dependencies.
- Do not infer a dependency solely because two files are stored in the same directory or appear related by name.

### Functions

- Identify functions that are actually defined in the supplied source materials. Preserve their source-defined names, including meaningful signature notation where present.
- Associate each function with the actual module or source file in which it is defined.
- Identify direct calls and other source-supported invocation relationships between user-defined functions.
- Represent indirect or dynamically dispatched calls only when the source establishes the dispatch mechanism and the possible target. Do not invent a target when the target is supplied dynamically and cannot be resolved from the available evidence.
- Retain functions even when no caller is identified. The absence of an identified caller does not prove that a function is unused.
- Do not treat built-in language constructs, standard-library routines, external commands, or operating-system utilities as user-defined functions. Include them only if the established JSON schema and analysis purpose explicitly represent that class of entity; otherwise, describe a material limitation in `notes` when needed.

### Relationship Evidence

- Include only relationships directly supported by the inspected source materials.
- A direct call, import, include, source operation, or other explicit reference may support a direct relationship when its target is identifiable.
- Represent a relationship as indirect or conditional only when the source establishes the mechanism or condition. Do not convert a possible, speculative, or merely conventional interaction into an asserted edge.
- Distinguish static evidence from runtime uncertainty. For example, a function-name variable may establish dynamic dispatch but may not establish which target is selected at runtime.
- Do not infer execution order, frequency, success, or runtime reachability from a static relationship alone.
- If the evidence does not establish a relationship with sufficient confidence, omit the relationship and explain the uncertainty in `notes` when it materially affects interpretation.

### Recursion

- Identify direct recursion when a function calls itself.
- Identify mutual recursion when two or more functions form a source-supported directed call cycle.
- Use `recursive` for an established recursive relationship.
- Use `conditional_recursive` only when the recursive relationship is itself conditional according to the source.
- Do not label an ordinary call as recursive merely because it participates in a larger workflow or because recursion is theoretically possible.

## JSON Output Contract

Generate one valid JSON document using exactly the established top-level structure and field names:

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

Preserve this structure exactly. Do not add, remove, rename, or repurpose fields. Do not introduce renderer-specific, layout, coordinate, styling, or presentation properties.

### Field Requirements

- `project`: a string identifying the project when established by the supplied materials or the user's explicit task description. If it cannot be established, use an empty string rather than inventing a name.
- `archive`: a string containing the exact supplied archive filename when an archive was provided. If no archive was supplied, use an empty string.
- `analysis_method`: a concise string describing the actual analysis method and its material boundaries, including whether source code was executed. Never claim execution or testing that did not occur.
- `module.rows`: an array of strings containing the exact names of the modules or relevant software units included in the module analysis.
- `module.calls`: an array of relationship objects. Each object must contain exactly `from`, `to`, and `line_type`.
- `function.rows`: an array of objects. Each object must contain exactly `name` and `module`, both strings. `module` must identify the corresponding entry in `module.rows`.
- `function.calls`: an array of relationship objects. Each object must contain exactly `from`, `to`, and `line_type`.
- `notes`: an array of strings for material qualifications, explicit uncertainties, unresolved references, analysis limitations, and clarifications needed to interpret the output.

### Relationship Indexing and Types

- `from` and `to` are zero-based integer indexes into the relevant `rows` array. For `module.calls`, indexes refer to `module.rows`. For `function.calls`, indexes refer to `function.rows`.
- Every index must be within the bounds of its corresponding array.
- Use only these exact `line_type` values: `solid`, `dashed`, `recursive`, and `conditional_recursive`.
- Use `solid` for an explicit, direct relationship established by the source.
- Use `dashed` for an established indirect, dynamically dispatched, configuration/data-mediated, or other non-direct relationship. The relationship must still be supported by evidence; dashed does not mean speculative.
- Use `recursive` for an established recursive relationship.
- Use `conditional_recursive` for an established recursive relationship whose occurrence depends on a source-defined condition.
- Do not create new `line_type` values to express distinctions that the schema does not support. Explain any material nuance in `notes` instead.

## Uncertainty and Notes

- Use the existing top-level `notes` array to record explicit uncertainties and limitations. Do not add a separate uncertainty field or alter the schema.
- State what is uncertain, why the available evidence is insufficient, and which conclusions or relationships are therefore omitted or qualified.
- Record relevant missing references, unresolved dynamic targets, ambiguous dispatch, incomplete source coverage, and distinctions between static evidence and unverified runtime behavior.
- Do not use `notes` to introduce unsupported entities or relationships. Notes explain the evidence and its limits; they do not replace evidence.
- Keep notes concise, specific, and useful. Avoid generic disclaimers that do not affect interpretation.

## Validation Before Delivery

Before returning the JSON, verify all of the following:

- The output parses as valid JSON.
- The top-level keys and nested object keys match the established schema exactly.
- All required values have the correct JSON types.
- Every function's `module` value identifies a module present in `module.rows`.
- Every relationship object contains exactly `from`, `to`, and `line_type`.
- Every relationship index is an integer within the bounds of the correct rows array.
- Every `line_type` is one of the four permitted values.
- No duplicate entity or relationship has been introduced accidentally.
- Every entity and relationship is supported by the inspected source materials.
- No synthetic, fictitious, illustrative, sample, demonstration, or placeholder data has been included.
- Material uncertainty and analysis limitations are recorded in `notes`.

If a check cannot be completed, do not imply that it passed. State the specific limitation in `notes` when it affects the JSON's interpretation.

## Completion

Deliver the generated JSON as the analysis output. Keep any explanation outside the JSON separate from the JSON document. Do not modify source materials as part of this analysis task.
