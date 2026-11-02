## Project Overview
Rails 7.2 API-only engine (gem) for a digital repository. REST API managing file assets (ActiveStorage), metadata, and Solr indexing.

## Stack
- Rails 7.2, isolated engine (`isolate_namespace Curator`), API-only (no views, no asset pipeline).
- Has some sub namespaces (Filestreams, Metastreams, Mappings, DescriptiveFieldSets, ControlledTerms)
- Files: ActiveStorage (host app configures services; engine must not hardcode a service).
- Metadata: stored in the DB, source of truth.
- Search: Solr is a derived index. DB is authoritative; Solr can always be rebuilt.
- Do NOT add frontend/asset tooling (propshaft, sprockets, importmap, Node).

## Solr
- Index via background jobs, not inline in requests.
- Indexing uses **Traject** and **Traject::SolrPool**(gem dependencies): all of it lives in `app/indexing/`, never ad hoc in models or controllers.
- Keep Solr field names/schema mappings in one place. Reuse Traject macros/extractors; keep them unit-testable.
- Jobs call the Traject indexer; index on create/update, delete from Solr on destroy. Provide a rake task for full reindex.
- Solr URL/collection comes from host config (Traject `solr.url` setting). Specs use a stub or test Solr; never hit production.
- Search endpoints translate query params to Solr; escape/sanitize user input.

## Rules for Claude
- Check `Gemfile.lock`, gemspec, and existing code before assuming versions or APIs.
- Ask before adding dependencies or changing the storage/index design.
- Add RSpec specs (request specs for endpoints, plus specs for Traject mappings and jobs); run `bin/rails rspec` before declaring done.
- Only current user can push commits to github