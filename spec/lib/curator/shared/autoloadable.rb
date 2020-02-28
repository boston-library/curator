# frozen_string_literal: true

RSpec.shared_examples 'autoloadable' do
  it { is_expected.to respond_to(:autoload,
                                 :autoload_at,
                                 :autoload_under,
                                 :autoloads,
                                 :eager_autoload,
                                 :eager_load!) }
end
