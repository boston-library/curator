# frozen_string_literal: true

class CreateCuratorMetastreamsAdministratives < ActiveRecord::Migration[5.2]
  def change
    create_table 'curator.metastreams_administratives' do |t|
      t.belongs_to :administratable, polymorphic: true, index: { unique: true, using: :btree, name: 'unique_idx_meta_admin_on_metastreamable_poly' }, null: false
      t.string :oai_header_id, index: { unique: true }
      t.integer :description_standard, index: { using: :btree, where: 'description_standard is not null', name: 'idx_administrative_on_not_null_desc_standard' }
      t.integer :hosting_status, index: { using: :btree }, default: 0
      t.boolean :harvestable, index: { using: :btree }, default: true
      t.string :flagged
      t.string :destination_site, index: { using: :gin }, array: true, default: ['commonwealth']
      t.integer :lock_version
      t.timestamps null: false
    end
  end
end
