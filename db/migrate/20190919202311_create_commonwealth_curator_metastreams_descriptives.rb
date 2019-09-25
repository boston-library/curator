class CreateCommonwealthCuratorMetastreamsDescriptives < ActiveRecord::Migration[5.2]
  def change
    create_table :curator_metastreams_descriptives do |t|
      t.belongs_to :descriptable, polymorphic: true, index: { unique: true, using: :btree, name: 'unique_idx_meta_desc_on_metastreamable_poly'}, null: false
      t.belongs_to :physical_location, index: { using: :btree }, foreign_key: { to_table: :curator_controlled_terms_nomenclatures }, null: false
      t.jsonb :identifier_json, index: { using: :gin, opclass: :jsonb_path_ops }, default: '{}', null: false
      t.jsonb :title_json, index: { using: :gin, opclass: :jsonb_path_ops }, default: '{}', null: false
      t.jsonb :date_json, index: { using: :gin, opclass: :jsonb_path_ops }, default: '{}', null: false#created/issued/copyright
      t.jsonb :note_json, index: { using: :gin, opclass: :jsonb_path_ops }, default: '{}', null: false
      t.jsonb :subject_json, index: { using: :gin, opclass: :jsonb_path_ops }, default: '{}', null: false#/uniform_title/temporal/date
      t.jsonb :related_json, index: {using: :gin,  opclass: :jsonb_path_ops }, default: '{}', null: false
      t.jsonb :cartographics_json, index: { using: :gin, opclass: :jsonb_path_ops }, default: '{}', null: false
      t.integer :digital_origin, default: 1, null: false
      t.integer :origin_event, default: 0, null: false
      t.boolean :resource_type_manuscript, default: false, null: false
      t.string :place_of_publication
      t.string :publisher
      t.string :edition
      t.string :issuance
      t.string :frequency
      t.string :physical_description_extent
      t.string :physical_location_department
      t.string :physical_location_shelf_locator
      t.string :series
      t.string :subseries
      t.string :rights
      t.string :access_restrictions
      t.string :toc_url
      t.text :toc, default: ''
      t.text :abstract, default: ''
      t.integer :lock_version
      t.timestamps null: false
      t.datetime :archived_at, index: { using: :btree, where: 'archived_at is null' }
    end
  end
end
