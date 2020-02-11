# frozen_string_literal: true

# SEQUENCE GENERATOR FOR ARK_IDS

FactoryBot.define do
  sequence(:ark_id) { |n| "commonwealth:#{SecureRandom.hex(rand([n, 8].min..[n, 32].min))}" }
end
