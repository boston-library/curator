# frozen_string_literal: true

require 'rails_helper'
require_relative '../shared/curator_decorator'
require_relative '../shared/name_partable'

RSpec.describe Curator::Mappings::NameRoleModsDecorator, type: :decorators do
  let!(:name_roles) { create_list(:curator_mappings_desc_name_role, 3) }
  let!(:grouped_name_roles) { Curator::Mappings::GroupedNameRoleModsPresenter.wrap_multiple(name_roles.group_by(&:name)) }

  describe 'Base Behavior' do
    it_behaves_like 'curator_decorator' do
      let(:decorator) { described_class.new(name_roles.sample) }
    end

    it_behaves_like 'curator_multi_decorator' do
      let(:wrapped) { described_class.wrap_multiple(name_roles) }
    end
  end

  describe 'included Curator::ControlledTerms::NamePartableMods' do
    it_behaves_like 'name_partable' do
      let(:name_partable_decorator_inst) { described_class.new(name_roles.sample) }
    end
  end

  describe 'Decorator specific behavior' do
    subject { described_class.new(name_role) }

    let!(:name_role) { grouped_name_roles.sample }
    let!(:expected_blank_condition) { subject.name.blank? && subject.roles.blank? }

    it { is_expected.to respond_to(:name, :roles, :name_type, :name_authority, :name_authority_uri, :name_affiliation, :name_value_uri, :role_terms).with(0).arguments }

    it 'is expected to return #blank? based on the :expected_blank_condition' do
      expect(subject.blank?).to eq(expected_blank_condition)
    end

    it 'expects the decorator methods to return the correct values' do
      expect(subject.name).to be_an_instance_of(Curator::ControlledTerms::Name).and eql(name_role.name)
      expect(subject.roles).to be_an_instance_of(Array).and all(be_an_instance_of(Curator::ControlledTerms::Role))
      expect(subject.name_type).to eql(name_role.name.name_type)
      expect(subject.name_authority).to eql(name_role.name.authority_code)
      expect(subject.name_value_uri).to eql(name_role.name.value_uri)
    end

    it 'expects the role_term to be a Curator::Mappings::RoleTermModsPresenter' do
      expect(subject.role_terms).to be_an_instance_of(Array).and all(be_an_instance_of(Curator::Mappings::RoleTermModsPresenter))
    end
  end
end
