# frozen_string_literal: true

require_relative '../optimistic_lockable.rb'
require_relative '../timestampable.rb'

RSpec.shared_examples 'nomenclature', type: :model do
  it { is_expected.to be_a_kind_of(Curator::ControlledTerms::Nomenclature) }

  it_behaves_like 'optimistic_lockable'
  it_behaves_like 'timestampable'

  it { is_expected.to have_db_column(:type).of_type(:string).with_options(null: false) }
  it { is_expected.to have_db_column(:term_data).of_type(:jsonb).with_options(null: false) }
  it { is_expected.to have_db_column(:authority_id).of_type(:integer) }

  it { is_expected.to have_db_index(:authority_id) }
  it { is_expected.to have_db_index(:type) }
  it { is_expected.to have_db_index(:term_data) }
  it { is_expected.to have_db_index("(((term_data ->> 'id_from_auth'::text))::character varying)") }

  it { is_expected.to validate_presence_of(:type) }

  it { is_expected.to validate_inclusion_of(:type).
    in_array(Curator::ControlledTerms.nomenclature_types.collect { |type| "Curator::ControlledTerms::#{type}" }) }

  describe 'attr_json configuration' do
    it 'expects attr_json to be configured correctly' do
      expect(described_class).to respond_to(:attr_json_config, :attr_json, :attr_json_registry, :jsonb_contains)
      expect(described_class.attr_json_config.default_container_attribute).to be(:term_data)
      expect(subject).to respond_to(:attr_json_changes)
    end

    describe 'base nomenclature json attributes' do
      it { is_expected.to respond_to(:label) }
      it { is_expected.to respond_to(:id_from_auth) }

      it 'expects the attributes to have specific types' do
        expect(described_class.attr_json_registry.fetch(:label, nil)&.type).to be_a_kind_of(ActiveModel::Type::String)
        expect(described_class.attr_json_registry.fetch(:id_from_auth, nil)&.type).to be_a_kind_of(ActiveModel::Type::String)
      end
    end
  end
end
