class CreateCommonwealthCuratorMetastreamsAdministratives < ActiveRecord::Migration[5.2]
  def change
    create_table :curator_metastreams_administratives do |t|
      t.belongs_to :administratable, polymorphic: true, index: { unique: true, using: :btree, name: 'unique_idx_meta_admin_on_metastreamable_poly'}, null: false
      t.integer :description_standard
      t.boolean :harvestable, index: { using: :btree }, default: true, null: false
      t.boolean :flagged, default: false, null: false
      t.string :destination_site, index: { using: :gin }, array: true, null: false, default: ['commonwealth']
      t.integer :lock_version
      t.timestamps null: false
    end
  end
end
