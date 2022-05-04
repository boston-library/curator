# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::ControlledTerms::GeographicModsPresenter, type: :presenters do
  subject { described_class }

  specify { expect(subject).to respond_to(:new).with(1).argument }
  specify { expect(subject).to be_const_defined(:TgnHierGeo) }

  describe Curator::ControlledTerms::GeographicModsPresenter::TgnHierGeo do
    subject { described_class }

    let!(:tgn_hier_geo_attrs) { Curator::Parsers::Constants::TGN_HIER_GEO_ATTRS }

    specify { expect(subject).to respond_to(:new).with_keywords(*tgn_hier_geo_attrs) }

    describe 'instance' do
      
    end
  end

  describe 'instance' do
  end
end
