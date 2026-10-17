# Server and Data Boundaries

## Parallelize the dependency graph, not every call

Independent reads can overlap; requests depending on identity, authorization, or earlier results must still wait. When each item has a follow-up read, chain it within that item's promise instead of waiting for an entire first batch before starting the next. Consider concurrency limits and service throttling for large collections; `Promise.all` failure does not cancel other work automatically.

In RSC, a parent that awaits data before returning its subtree delays child work. Move independent reads into siblings or start them earlier, with appropriate Suspense boundaries for independent content. Adding Suspense below an already completed `await` cannot remove that wait. Do not add a scheduling library for ordinary dependencies.

## Cache lifetime matters more than container type

- `React.cache` supports reuse within an RSC request, not general caching for arbitrary server functions. Share one wrapper; arguments are compared with `Object.is`, so fresh objects miss. Errors are cached too.
- Request deduplication is not persistent caching. Check Next.js `fetch`, routes, and cache configuration against the project's version and call context; do not assume every request is deduplicated or cached across requests.
- Server module scope can be shared by concurrent requests. Do not store the current user or request data in module variables. For intentional cross-request caching, define tenant/identity keys, invalidation, capacity, and data visibility first. An in-process LRU guarantees neither cross-instance sharing nor persistence.
- Reuse static resources only when their data does not vary by request. When caching promises, consider retries after failure to avoid permanently reusing a rejected result.

## RSC transfer and post-response work

Pass only the necessary fields that are safe to expose to the client. Do not move all filtering or sorting client-side merely to avoid duplicate serialization. Compare transfer size, client computation, and the data actually needed; retain work that belongs on the server.

When changing Server Action read or execution order, preserve authentication and resource authorization at the entry point; button visibility is not authorization.

Use Next.js `after()` for deferrable work only when the project version and deployment support it. It has runtime duration limits and is not a durable job queue. Do not move required successful business writes or reliable delivery into it merely to reduce response time, or replace it with floating promises unmanaged by the runtime.

## Official references

- [React cache](https://react.dev/reference/react/cache)
- [Next.js after](https://nextjs.org/docs/app/api-reference/functions/after)
- [Next.js authentication](https://nextjs.org/docs/app/guides/authentication)

These guidelines depend on runtime context. Check documentation matching the installed version before adopting version-specific APIs.
