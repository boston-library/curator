# frozen_string_literal: true
class CreateCuratorMappingsIssues < ActiveRecord::Migration[5.2]
  def change
    create_table :curator_mappings_issues do |t|
      t.belongs_to :digital_object, index: { using: :btree, unique: true, name: 'unique_idx_map_issue_on_digital_obj' }, foreign_key: { to_table: :curator_digital_objects, on_delete: :cascade}, null: false
      t.belongs_to :issue_of, index: { using: :btree, name: 'index_map_issue_on_issue_of' }, foreign_key: { to_table: :curator_digital_objects, on_delete: :cascade }, null: false
      t.index [:digital_object_id, :issue_of_id], name: 'unique_idx_map_issue_on_digital_obj_and_issue_of', unique: true, using: :btree
    end
  end
end
