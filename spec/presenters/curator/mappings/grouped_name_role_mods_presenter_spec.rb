# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::Mappings::GroupedNameRoleModsPresenter, type: :presenters do
  subject { described_class }

  let!(:name_roles) { create_list(:curator_mappings_desc_name_role, 3) }
  let!(:grouped_name_roles) { name_roles.group_by(&:name) }

  it { is_expected.to respond_to(:new).with(1..2).arguments }
  it { is_expected.to respond_to(:wrap_multiple).with(0..1).arguments }

  describe '.wrap_multiple' do
    subject { described_class.wrap_multiple(grouped_name_roles) }

    it { is_expected.to be_an_instance_of(Array).and all(be_an_instance_of(described_class)) }
  end

  describe 'instance' do
    subject { described_class.new(name, desc_name_roles) }

    let!(:grouped_name_role) { grouped_name_roles.to_a.sample }
    let!(:name) { grouped_name_role.first }
    let!(:desc_name_roles) { grouped_name_role.last }
    let!(:roles) { desc_name_roles.map(&:role) }

    it { is_expected.to respond_to(:name, :roles).with(0).arguments }

    it 'expects #name to be an instance of Curator::ControlledTerms::Name and equal :name' do
      expect(subject.name).to be_an_instance_of(Curator::ControlledTerms::Name).and equal(name)
    end

    it 'expects roles to be an array of Curator::ControlledTerms::Role and match_array :roles' do
      expect(subject.roles).to be_an_instance_of(Array).and all(be_an_instance_of(Curator::ControlledTerms::Role))
      expect(subject.roles).to match_array(roles)
    end
  end
end
