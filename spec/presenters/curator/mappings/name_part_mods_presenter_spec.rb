# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Curator::Mappings::NamePartModsPresenter, type: :presenters do
  subject { described_class }

  specify { expect(subject).to respond_to(:new).with(1..2).arguments }

  describe 'instance' do
    let!(:corp_name) { 'Catholic Church' }
    let!(:personal_name) { 'Matteo, da Milano, active 1492-1523' }
    let!(:corp_name_parts) { Curator::Parsers::InputParser.corp_name_part_splitter(corp_name) }
    let!(:personal_name_parts) { Curator::Parsers::InputParser.pers_name_part_splitter(personal_name) }

    context 'with corporate name' do
      subject { described_class.new(corp_name_parts[0]) }

      specify { expect(subject).to respond_to(:label, :is_date, :is_date?, :name_part_type).with(0).arguments }

      it 'is expected to have the correct values' do
        expect(subject.label).to eql(corp_name_parts[0])
        expect(subject.is_date).to be false
        expect(subject.is_date?).to be false
        expect(subject.name_part_type).to be nil
      end
    end

    context 'with personal name' do
      let!(:name_part) { described_class.new(personal_name_parts[:name_part]) }
      let!(:date_part) { described_class.new(personal_name_parts[:date_part], true) }

      describe ':name_part' do
        subject { name_part }

        specify { expect(subject).to respond_to(:label, :is_date, :is_date?, :name_part_type).with(0).arguments }

        it 'is expected to have the correct values' do
          expect(subject.label).to eql(personal_name_parts[:name_part])
          expect(subject.is_date).to be false
          expect(subject.is_date?).to be false
          expect(subject.name_part_type).to be nil
        end
      end

      describe ':date_part' do
        subject { date_part }

        specify { expect(subject).to respond_to(:label, :is_date, :is_date?, :name_part_type).with(0).arguments }

        it 'is expected to have the correct values' do
          expect(subject.label).to eql(personal_name_parts[:date_part])
          expect(subject.is_date).to be true
          expect(subject.is_date?).to be true
          expect(subject.name_part_type).to eql('date')
        end
      end
    end
  end
end
