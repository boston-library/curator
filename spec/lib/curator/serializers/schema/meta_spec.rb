# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::Serializers::Meta do
  let!(:meta_object) { create(:curator_institution, collection_count: 5) }
end
