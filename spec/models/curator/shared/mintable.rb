# frozen_string_literal: true

RSpec.shared_examples_for 'mintable', type: :model do |oai_specific: true, oai_parent: false|
  describe 'Mintable' do
    describe 'ClassMethods' do
      subject { described_class }

      let!(:mintable_object) { create(factory_key_for(described_class)) }
      let!(:invalid_ark_id) { 'bpl-dev:notavalidark' }

      it { is_expected.to respond_to(:find_ark, :find_ark!).with(1).argument }

      describe 'find_ark!' do
        it 'expects method to return the mintable_object' do
          expect(described_class.find_ark!(mintable_object.ark_id).id).to eql(mintable_object.id)
        end

        it 'expects an ActiveRecord::RecordNotFound error to be raised with invalid_ark_id' do
          expect { described_class.find_ark!(invalid_ark_id) }.to raise_error(ActiveRecord::RecordNotFound, "Couldn't find #{described_class.name}")
        end
      end

      describe 'find_ark' do
        it 'expects method to return the mintable_object' do
          expect(described_class.find_ark(mintable_object.ark_id).id).to eql(mintable_object.id)
        end

        it 'expects method to return nil with invalid_ark_id' do
          expect(described_class.find_ark(invalid_ark_id)).to be_nil
        end
      end
    end

    describe 'InstanceMethods' do
      it { is_expected.to respond_to(:ark_id, :ark_params, :ark_noid, :ark_identifier, :ark_preview_identifier, :ark_iiif_manifest_identifier) }

      describe 'Database' do
        it { is_expected.to have_db_column(:ark_id).of_type(:string).with_options(null: false) }
        it { is_expected.to have_db_index(:ark_id).unique(true) }
      end

      describe '#ark_params' do
        let!(:expected_ark_param_keys) { %i(namespace_ark namespace_id parent_pid secondary_parent_pids model_type local_original_identifier local_original_identifier_type) }

        it 'expects ark_params to be a hash with specific keys' do
          expect(subject.ark_params).to be_a_kind_of(Hash)

          expected_ark_param_keys.each do |expected_key|
            expect(subject.ark_params).to have_key(expected_key)
          end
        end

        context 'Not an OAI object' do
          specify { expect(subject).not_to be_oai_object }

          it 'expects not to match /oai/ in the namespace_id val' do
            expect(subject.ark_params[:namespace_id]).not_to match(/oai/)
          end
        end

        context 'OAI Object', if: oai_specific do
          context 'Checks #oai_object?', unless: oai_parent do
            before(:each) do
              subject.administrative.oai_header_id = 'someval'
            end

            after(:each) do
              subject.administrative.oai_header_id = nil
            end

            it 'expects to match /oai/ in the namespace_id val' do
              expect(subject.ark_params[:namespace_id]).to match(/oai/)
            end
          end

          # For Curator::Filestreams::FileSet
          context 'Checks parent#oai_object', if: oai_parent do
            before(:each) do
              subject.file_set_of.administrative.oai_header_id = 'someval'
            end

            after(:each) do
              subject.file_set_of.administrative.oai_header_id = nil
            end

            it 'expects to match /oai/ in the namespace_id val' do
              expect(subject.ark_params[:namespace_id]).to match(/oai/)
            end
          end
        end
      end

      describe 'Validations' do
        before(:context) { described_class.skip_callback(:validation, :before, Curator::MintableCallbacks) }

        after(:context) { described_class.set_callback(:validation, :before, Curator::MintableCallbacks) }

        it { is_expected.to validate_presence_of(:ark_id).on(:create) }
        it { is_expected.to validate_uniqueness_of(:ark_id).on(:create) }
      end

      describe '#Curator::MintableCallbacks.before_validation on create' do
        subject { build(factory_key_for(described_class), ark_id: nil) }

        it 'generates an #ark_id #before_validation on create if there is none' do
          # valid? invokes the before_validation callback without saving
          VCR.use_cassette("services/mintable_#{described_class.name.demodulize.underscore}") do
            expect { subject.valid? }.to change(subject, :ark_id).
            from(nil).
            to(a_string_starting_with('bpl-dev'))
          end
        end
      end
    end
  end
end
