# frozen_string_literal: true

class CreateCuratorMetastreamsDescriptives < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        create_enum 'curator.metastreams_descriptives_digital_origin', ['born_digital', 'reformatted_digital', 'digitized_microfilm', 'digitized_other_analog']
        create_table 'curator.metastreams_descriptives' do |t|
          t.belongs_to :physical_location, index: { using: :btree }, foreign_key: { to_table: 'curator.controlled_terms_nomenclatures' }, null: false
          t.belongs_to :license, index: { using: :btree }, foreign_key: { to_table: 'curator.controlled_terms_nomenclatures' }, null: false
          t.belongs_to :rights_statement, index: { using: :btree }, foreign_key: { to_table: 'curator.controlled_terms_nomenclatures' }
          t.jsonb :identifier_json, index: { using: :gin, opclass: :jsonb_path_ops }, default: {}
          t.jsonb :title, index: { using: :gin, opclass: :jsonb_path_ops }, default: {}
          t.jsonb :date, index: { using: :gin, opclass: :jsonb_path_ops }, default: {} # created/issued/copyright
          t.jsonb :note_json, index: { using: :gin, opclass: :jsonb_path_ops }, default: {}
          t.jsonb :subject_other, index: { using: :gin, opclass: :jsonb_path_ops }, default: {} # uniform_title/temporal/date
          t.jsonb :related, index: { using: :gin, opclass: :jsonb_path_ops }, default: {}
          t.jsonb :cartographic, index: { using: :gin, opclass: :jsonb_path_ops }, default: {}
          t.jsonb :publication, index: { using: :gin, opclass: :jsonb_path_ops }, default: {}
          t.enum :digital_origin, enum_name: 'curator.metastreams_descriptives_digital_origin', default: 'reformatted_digital'
          t.integer :text_direction
          t.boolean :resource_type_manuscript, default: false
          t.string :origin_event
          t.string :place_of_publication
          t.string :publisher
          t.string :issuance
          t.string :frequency
          t.string :extent
          t.string :physical_location_department
          t.string :physical_location_shelf_locator
          t.string :series
          t.string :subseries
          t.string :subsubseries
          t.string :rights
          t.string :access_restrictions
          t.string :toc_url
          t.text :toc, default: ''
          t.text :abstract, default: ''
          t.integer :lock_version
          t.timestamps null: false
        end
      end
      dir.down do
        drop_table 'curator.metastreams_descriptives'
        drop_enum 'curator.metastreams_descriptives_digital_origin'
      end
    end
  end
end
