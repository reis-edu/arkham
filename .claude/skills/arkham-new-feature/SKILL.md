---
name: arkham-new-feature
description: End-to-end checklist for adding a brand-new resource/feature to Arkham (e.g. Activity, Checklist, Plantao) across every layer of the hexagonal architecture — domain, repository, validator, use cases, presenters, controller, routes, dependency wiring, and specs. Use when a task requires a full new CRUD-style resource rather than a single-layer change.
---

# Arkham: Adding a New Feature End-to-End

This is the orchestrator skill: it sequences the layer-specific skills in the right order. Read each referenced skill when you reach its step rather than guessing the pattern — they each have the concrete reference file to copy from.

Arkham is a Rails hexagonal-architecture backend (see [docs/HLD-Arkham-MVP-v1.md](../../../docs/HLD-Arkham-MVP-v1.md)). The canonical fully-migrated example is the `Patient` resource across `lib/arkham/{domain,repository,validators,use_cases,presenters}` and `app/controllers/api/patients_controller.rb`. Everything new should look like that, not like the older `Visit`/`Visitor`/`Medicament` code, which predates this architecture and is not the pattern to copy.

## Order of implementation

Work outside-in is tempting but leads to rework — build inside-out instead, so each layer only depends on layers already built:

1. **Migration + AR model** — plain Rails migration and `ApplicationRecord` subclass under `db/migrate` and `app/models`. Not covered by a dedicated skill; follow existing migrations in `db/migrate` for conventions (UUID pk, timestamps).
2. **Domain entity + domain errors** — `arkham-domain-entity`. Decide the entity's fields and which failure modes need a dedicated error class (not-found, already-exists, invalid-state, etc.) before writing use cases.
3. **Repository** — `arkham-repository`. AR repository first; add a filter repository only if listing needs more than a trivial `where`; add an external-service repository only if this feature talks to something outside Postgres (S3, WhatsApp provider, etc., per the HLD's external dependencies).
4. **Validator** — `arkham-validator`. One contract per resource shape accepted from the API.
5. **Use cases** — `arkham-use-case`. One class per operation (Create/Update/Show/List/Destroy/Activate/Inactivate/etc.), each composing the repository + validator + domain errors from steps 2-4.
6. **Presenters** — `arkham-presenter`. One per response shape the controller will render.
7. **Controller + routes + dependency wiring** — `arkham-api-controller`. Register every new repository and use case in `lib/arkham/dependencies.rb`, add routes under the `:api` namespace, and add `rescue_from` entries in `ApplicationController` for every new domain/validation error.
8. **Specs** — `arkham-rspec`. Use-case specs mirroring the contexts in the reference spec, plus a factory for the new AR model.

## Checklist to track progress

```
- [ ] Migration + model
- [ ] Domain entity + errors
- [ ] Repository (+ filter/external repo if needed)
- [ ] Validator contract
- [ ] Use case(s)
- [ ] Presenter(s)
- [ ] Controller + routes
- [ ] Dependencies wiring
- [ ] rescue_from entries for new errors
- [ ] Specs + factory
```

## Don't

- Don't put ActiveRecord queries, validation logic, or HTTP concerns inside a use case — each belongs in repository, validator, and controller respectively.
- Don't invent a new DI mechanism — everything is resolved through `Arkham::Dependencies` memoized class methods.
- Don't skip the transaction wrapper for multi-write use cases, and don't add one for single-write or read-only use cases.
- Don't copy patterns from `Visit`/`Visitor`/`Medicament` controllers/models — they predate this architecture.
