# SAMA Source Discovery and Reference Resolution

**Status:** Draft
**Purpose:** Identify the source materials relevant to structural analysis.

## Discovery
- Inspect the supplied project structure.
- Identify source files relevant to the requested analysis.
- Follow relevant references recursively, including references found inside referenced files.
- Inspect referenced scripts, modules, configuration, manifests, resources, and documents when available and materially relevant.
- Exclude unrelated files.

## Missing or Unavailable Sources
- Do not reconstruct missing, inaccessible, excluded, or unavailable files.
- Record material gaps in `notes`.
- Omit relationships that depend on unavailable evidence.
- Distinguish a file's existence from its participation in an established relationship.
- Interpret comments, documentation, filenames, and configuration values in their actual source context.
