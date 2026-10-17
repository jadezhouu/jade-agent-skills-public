---
name: jade-react-performance
description: Diagnose and improve React loading, request waterfalls, interaction latency, and redundant rendering, or review related performance risks. Includes conditional Next.js/RSC guidance. Use for explicit performance tasks or identified implementation bottlenecks, not a comprehensive optimization pass on ordinary component, styling, or copy changes.
---

# React Performance Diagnosis and Improvement

Resolve explainable bottlenecks without turning a best-practice catalog into a mandate for broad rewrites.

## Assess and implement

1. Inspect dependencies and configuration for the React version, framework/router, SSR/RSC, build tool, and React Compiler enablement. Keep existing fetching and state libraries; do not introduce Next.js, SWR, or a cache library by default.
2. Agree on what is slow: initial display, server response, request chains, download/parse size, or a particular interaction. Use available network timings, build analysis, or Profiler evidence. With incomplete context, distinguish demonstrable waste from hypotheses needing measurement; do not invent gains.
3. First shorten waits on the critical path and reduce unnecessary client code and data, then address identified rendering or computation costs. Let the actual bottleneck determine priority; do not use fixed speedup multipliers.
4. Preserve authorization, error handling, cancellation, and interaction semantics. Recheck relevant metrics with the same inputs and build mode, and run project checks relevant to the change. Without a runnable environment, describe verification steps and mark results unverified rather than claiming a speedup.

## Read by symptom

- Serial requests, RSC data transfer, server caching, or post-response work: read [Server and data boundaries](references/server-and-data.md). Skip RSC/Next.js material for client-only applications.
- Large initial bundles, sluggish input, Effect resubscriptions, or hydration: read [Loading and rendering boundaries](references/loading-and-rendering.md).

## Avoid changes without a benefit

- Do not add `memo` / `useMemo` / `useCallback` in bulk or hide reactive relationships to remove dependencies. If Compiler is enabled, check its coverage and actual hotspots first.
- Do not default to rewriting array traversals, local variables, regular expressions, or `Set`/`Map` usage; require hotspot evidence.
- Reviews should identify location, trigger, impact, and the smallest fix, separating confirmed findings from measurement proposals. After implementation, report measurements and unverified items.
