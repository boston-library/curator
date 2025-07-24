# frozen_string_literal: true

RSpec.shared_examples 'georeferenceable', type: :model do
  it { is_expected.to respond_to(:georeferenceable?, :georeferenced?, :georeferenced_in_allmaps?) }

  describe '#georeferenceable?' do
    it 'returns a boolean value' do
      expect([TrueClass, FalseClass].include?(subject.georeferenceable?.class)).to be_truthy
    end
  end

  describe '#georeferenced?' do
    it 'returns a boolean value' do
      expect([TrueClass, FalseClass].include?(subject.georeferenced?.class)).to be_truthy
    end
  end

  describe '#georeferenced_in_allmaps?' do
    it 'returns a boolean value' do
      expect([TrueClass, FalseClass].include?(subject.georeferenced_in_allmaps?.class)).to be_truthy
    end
  end
end
