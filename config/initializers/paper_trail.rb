# frozen_string_literal: true

PaperTrail.config.track_associations = true
PaperTrail.config.has_paper_trail_defaults = {
  on: %i(update destroy touch),
  ignore: %i(created_at updated_at lock_version)
}
