# frozen_string_literal: true

RSpec.shared_examples 'georeferenceable', type: :model do
  it { is_expected.to respond_to(:georeferenceable?, :georeferenced?, :georeferenced_in_allmaps?) }

  describe '#georeferenceable?' do
    it 'returns a boolean value' do
      expect(subject.georeferenceable?).to eq(false)
    end
  end

  describe '#georeferenced?' do
    it 'returns a boolean value' do
      expect(subject.georeferenced?).to eq(false)
    end
  end

  describe '#georeferenced_in_allmaps?' do
    it 'returns a boolean value' do
      expect(subject.georeferenced_in_allmaps?).to eq(false)
    end
  end
end
