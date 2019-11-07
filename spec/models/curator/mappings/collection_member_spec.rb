# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::Mappings::CollectionMember, type: :model do
  subject { create(:curator_mappings_collection_member) }

  it { is_expected.to have_db_column(:digital_object_id) }
  it { is_expected.to have_db_column(:collection_id) }

  it { is_expected.to belong_to(:collection).
                      inverse_of(:collection_members).
                      class_name('Curator::Collection')}
end
