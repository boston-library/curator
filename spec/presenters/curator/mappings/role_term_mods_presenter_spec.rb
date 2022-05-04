# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::Mappings::RoleTermModsPresenter, type: :presnters do
  subject { described_class }

  specify { expect(subject).to respond_to(:new).with(1).argument }

  describe 'instance' do
    subject { described_class.new(role) }

    let!(:role) { create(:curator_controlled_terms_role) }
    let!(:delegated_methods) { %i(label authority_code authority_base_url value_uri) }

    it { is_expected.to respond_to(:role).with(0).arguments }

    it 'expects role to be an instance of Curator::ControlledTerms::Role' do
      expect(subject.role).to be_an_instance_of(Curator::ControlledTerms::Role)
    end

    it 'is expected to respond to and delegate methods to role and allow nil' do
      delegated_methods.each do |delegated_method|
        expect(subject).to respond_to(delegated_method).with(0).arguments
        expect(subject).to delegate_method(delegated_method).to(:role).allow_nil
      end
    end
  end
end
