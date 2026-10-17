# Loading and Rendering Boundaries

## Download and loading

Determine whether the cost is development module traversal, the production client bundle, or a server cold start. A barrel import does not automatically ship the whole library to the client. Inspect build output and existing package-import optimization before considering public, typed subpaths; avoid private deep imports.

Consider lazy loading for heavy features outside the initial view, without creating a new waterfall for critical content. Prefer explicit loader maps with values such as `() => import('literal-path')` so tools can identify candidate modules. Inspect actual chunks; an `import()` alone does not prove successful splitting. Next.js `ssr: false` has Client Component boundary restrictions and is not a general React prescription.

## Responsiveness and subscriptions

- `useDeferredValue` delays display updates; it neither debounces requests nor moves synchronous computation to a background thread. Expensive subtrees need to skip urgent renders, and expensive computations need to reuse results for unchanged inputs. Substituting a deferred value alone does not ensure responsive input. A long indivisible computation may still need splitting or a Worker.
- Identify the actual rerender source before narrowing subscriptions or extracting expensive components. Reference stability matters at cache, dependency, or subscription boundaries.
- When the project supports `useEffectEvent`, use it for Effect logic that needs latest values without triggering resubscription. It is not a general stable callback: exclude it from dependency arrays, do not pass it to children or use it as an ordinary interaction handler, and do not hide dependencies that genuinely require resynchronization.

## Hydration

Server output and the first client render should match. Prefer a consistent initial snapshot or the project's existing theme/SSR integration. Mutating the DOM before hydration does not automatically ensure consistency; arbitrary inline scripts are not a universal flicker-free solution.

`suppressHydrationWarning` is a local escape hatch, works only one level deep, and does not patch mismatched text. Use it only for unavoidable differences; disappearance of a warning is not correctness verification.

## Official references

- [React memo and Compiler](https://react.dev/reference/react/memo)
- [React useDeferredValue](https://react.dev/reference/react/useDeferredValue)
- [React useEffectEvent](https://react.dev/reference/react/useEffectEvent)
- [React hydrateRoot](https://react.dev/reference/react-dom/client/hydrateRoot)
- [Next.js lazy loading](https://nextjs.org/docs/app/guides/lazy-loading)
