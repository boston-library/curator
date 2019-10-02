# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_09_25_164513) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_trgm"
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "curator_collections", force: :cascade do |t|
    t.string "ark_id", null: false
    t.bigint "institution_id", null: false
    t.string "name", null: false
    t.text "abstract", default: "", null: false
    t.integer "lock_version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "archived_at"
    t.index ["archived_at"], name: "index_curator_collections_on_archived_at", where: "(archived_at IS NULL)"
    t.index ["ark_id"], name: "index_curator_collections_on_ark_id", unique: true
    t.index ["institution_id"], name: "index_curator_collections_on_institution_id", unique: true
  end

  create_table "curator_controlled_terms_authorities", force: :cascade do |t|
    t.string "name", null: false
    t.string "code"
    t.string "base_url"
    t.integer "lock_version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "archived_at"
    t.index ["archived_at"], name: "index_curator_controlled_terms_authorities_on_archived_at", where: "(archived_at IS NULL)"
    t.index ["code", "base_url"], name: "index_curator_controlled_terms_authorities_on_code_and_base_url", unique: true, where: "(base_url IS NOT NULL)"
    t.index ["code"], name: "index_curator_controlled_terms_authorities_on_code", unique: true
  end

  create_table "curator_controlled_terms_nomenclatures", force: :cascade do |t|
    t.bigint "authority_id"
    t.jsonb "term_data", default: "{}", null: false
    t.string "type", null: false
    t.integer "lock_version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "archived_at"
    t.index "((term_data ->> 'basic'::text))", name: "index_ctl_terms_basic_genre_jsonb_field"
    t.index "((term_data ->> 'id_from_auth'::text))", name: "index_ctl_terms_nom_id_from_auth_jsonb_field"
    t.index ["archived_at"], name: "index_curator_controlled_terms_nomenclatures_on_archived_at", where: "(archived_at IS NULL)"
    t.index ["authority_id"], name: "index_curator_controlled_terms_nomenclatures_on_authority_id"
    t.index ["term_data"], name: "index_curator_controlled_terms_nomenclatures_on_term_data", opclass: :jsonb_path_ops, using: :gin
    t.index ["type"], name: "index_curator_controlled_terms_nomenclatures_on_type"
  end

  create_table "curator_digital_objects", force: :cascade do |t|
    t.string "ark_id", null: false
    t.bigint "admin_set_id", null: false
    t.integer "lock_version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "archived_at"
    t.index ["admin_set_id"], name: "index_curator_digital_objects_on_admin_set_id", unique: true
    t.index ["archived_at"], name: "index_curator_digital_objects_on_archived_at", where: "(archived_at IS NULL)"
    t.index ["ark_id"], name: "index_curator_digital_objects_on_ark_id", unique: true
  end

  create_table "curator_filestreams_file_sets", force: :cascade do |t|
    t.string "ark_id", null: false
    t.string "file_set_type", null: false
    t.string "file_name_base", null: false
    t.integer "position", null: false
    t.jsonb "pagination", default: "{}", null: false
    t.integer "lock_version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "archived_at"
    t.bigint "file_set_of_id", null: false
    t.index ["archived_at"], name: "index_curator_filestreams_file_sets_on_archived_at", where: "(archived_at IS NULL)"
    t.index ["ark_id"], name: "index_curator_filestreams_file_sets_on_ark_id", unique: true
    t.index ["file_set_of_id"], name: "index_fstream_file_set_on_file_set_of_id"
    t.index ["file_set_type"], name: "index_curator_filestreams_file_sets_on_file_set_type"
    t.index ["pagination"], name: "index_curator_filestreams_file_sets_on_pagination", opclass: :jsonb_path_ops, using: :gin
    t.index ["position"], name: "index_curator_filestreams_file_sets_on_position"
  end

  create_table "curator_institutions", force: :cascade do |t|
    t.bigint "location_id"
    t.string "ark_id", null: false
    t.string "name", null: false
    t.string "url"
    t.text "abstract", default: ""
    t.integer "lock_version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "archived_at"
    t.index ["archived_at"], name: "index_curator_institutions_on_archived_at", where: "(archived_at IS NULL)"
    t.index ["ark_id"], name: "index_curator_institutions_on_ark_id", unique: true
    t.index ["location_id"], name: "index_inst_on_geo_location_nom"
  end

  create_table "curator_mappings_collection_members", force: :cascade do |t|
    t.bigint "digital_object_id", null: false
    t.bigint "collection_id", null: false
    t.index ["collection_id"], name: "index_mapping_col_members_on_collection"
    t.index ["digital_object_id", "collection_id"], name: "unique_idx_mapping_col_members_on_digital_obj_and_col", unique: true
    t.index ["digital_object_id"], name: "index_mapping_col_members_on_digital_object"
  end

  create_table "curator_mappings_desc_host_collections", force: :cascade do |t|
    t.bigint "host_collection_id", null: false
    t.bigint "descriptive_id", null: false
    t.index ["descriptive_id", "host_collection_id"], name: "unique_idx_desc_mappping_of_col_on_desc_and_host_col", unique: true
    t.index ["descriptive_id"], name: "index_desc_mapping_host_col_on_desc"
    t.index ["host_collection_id"], name: "index_desc_mapping_host_col_on_host_col"
  end

  create_table "curator_mappings_desc_name_roles", force: :cascade do |t|
    t.bigint "descriptive_id", null: false
    t.bigint "name_id", null: false
    t.bigint "role_id", null: false
    t.index ["descriptive_id", "name_id", "role_id"], name: "unique_idx_on_meta_desc_name_role_on_desc_name_role", unique: true
    t.index ["descriptive_id"], name: "index_curator_mappings_desc_name_roles_on_descriptive_id"
    t.index ["name_id"], name: "index_curator_mappings_desc_name_roles_on_name_id"
    t.index ["role_id"], name: "index_curator_mappings_desc_name_roles_on_role_id"
  end

  create_table "curator_mappings_desc_terms", force: :cascade do |t|
    t.bigint "descriptive_id", null: false
    t.string "mappable_type", null: false
    t.bigint "mappable_id", null: false
    t.index ["descriptive_id"], name: "index_curator_mappings_desc_terms_on_descriptive_id"
    t.index ["mappable_id", "mappable_type", "descriptive_id"], name: "unique_idx_desc_map_on_mappable_poly_and_descriptive", unique: true
    t.index ["mappable_type", "mappable_id"], name: "index_meta_desc_map_on_mappable_poly"
  end

  create_table "curator_mappings_exemplary_images", force: :cascade do |t|
    t.bigint "file_set_id", null: false
    t.string "exemplary_type", null: false
    t.bigint "exemplary_id", null: false
    t.index ["exemplary_type", "exemplary_id"], name: "idx_map_exemp_img_on_exemp"
    t.index ["file_set_id", "exemplary_id", "exemplary_type"], name: "unique_idx_mappings_exemp_img_on_exemp_type_and_id_and_fset", unique: true
    t.index ["file_set_id"], name: "index_curator_mappings_exemplary_images_on_file_set_id"
  end

  create_table "curator_mappings_host_collections", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "institution_id", null: false
    t.index ["institution_id"], name: "index_curator_mappings_host_collections_on_institution_id"
    t.index ["name", "institution_id"], name: "unique_idx_map_host_col_col_and_and_name", unique: true
  end

  create_table "curator_metastreams_administratives", force: :cascade do |t|
    t.string "administratable_type", null: false
    t.bigint "administratable_id", null: false
    t.integer "description_standard"
    t.boolean "harvestable", default: true, null: false
    t.boolean "flagged", default: false, null: false
    t.string "destination_site", default: ["commonwealth"], null: false, array: true
    t.integer "lock_version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "archived_at"
    t.index ["administratable_type", "administratable_id"], name: "unique_idx_meta_admin_on_metastreamable_poly", unique: true
    t.index ["archived_at"], name: "index_curator_metastreams_administratives_on_archived_at", where: "(archived_at IS NULL)"
    t.index ["destination_site"], name: "index_curator_metastreams_administratives_on_destination_site", using: :gin
    t.index ["harvestable"], name: "index_curator_metastreams_administratives_on_harvestable"
  end

  create_table "curator_metastreams_descriptives", force: :cascade do |t|
    t.string "descriptable_type", null: false
    t.bigint "descriptable_id", null: false
    t.bigint "physical_location_id", null: false
    t.jsonb "identifier_json", default: "{}", null: false
    t.jsonb "title_json", default: "{}", null: false
    t.jsonb "date_json", default: "{}", null: false
    t.jsonb "note_json", default: "{}", null: false
    t.jsonb "subject_json", default: "{}", null: false
    t.jsonb "related_json", default: "{}", null: false
    t.jsonb "cartographics_json", default: "{}", null: false
    t.integer "digital_origin", default: 1, null: false
    t.integer "origin_event", default: 0, null: false
    t.boolean "resource_type_manuscript", default: false, null: false
    t.string "place_of_publication"
    t.string "publisher"
    t.string "edition"
    t.string "issuance"
    t.string "frequency"
    t.string "physical_description_extent"
    t.string "physical_location_department"
    t.string "physical_location_shelf_locator"
    t.string "series"
    t.string "subseries"
    t.string "rights"
    t.string "access_restrictions"
    t.string "toc_url"
    t.text "toc", default: ""
    t.text "abstract", default: ""
    t.integer "lock_version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "archived_at"
    t.index ["archived_at"], name: "index_curator_metastreams_descriptives_on_archived_at", where: "(archived_at IS NULL)"
    t.index ["cartographics_json"], name: "index_curator_metastreams_descriptives_on_cartographics_json", opclass: :jsonb_path_ops, using: :gin
    t.index ["date_json"], name: "index_curator_metastreams_descriptives_on_date_json", opclass: :jsonb_path_ops, using: :gin
    t.index ["descriptable_type", "descriptable_id"], name: "unique_idx_meta_desc_on_metastreamable_poly", unique: true
    t.index ["identifier_json"], name: "index_curator_metastreams_descriptives_on_identifier_json", opclass: :jsonb_path_ops, using: :gin
    t.index ["note_json"], name: "index_curator_metastreams_descriptives_on_note_json", opclass: :jsonb_path_ops, using: :gin
    t.index ["physical_location_id"], name: "index_curator_metastreams_descriptives_on_physical_location_id"
    t.index ["related_json"], name: "index_curator_metastreams_descriptives_on_related_json", opclass: :jsonb_path_ops, using: :gin
    t.index ["subject_json"], name: "index_curator_metastreams_descriptives_on_subject_json", opclass: :jsonb_path_ops, using: :gin
    t.index ["title_json"], name: "index_curator_metastreams_descriptives_on_title_json", opclass: :jsonb_path_ops, using: :gin
  end

  create_table "curator_metastreams_workflows", force: :cascade do |t|
    t.string "workflowable_type", null: false
    t.bigint "workflowable_id", null: false
    t.integer "publishing_state", default: 0, null: false
    t.integer "processing_state", default: 0, null: false
    t.string "ingest_origin", null: false
    t.string "ingest_filepath", null: false
    t.string "ingest_filename", null: false
    t.string "ingest_datastream", null: false
    t.jsonb "ingest_datastream_checksums", default: "{}", null: false
    t.integer "lock_version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "archived_at"
    t.index ["archived_at"], name: "index_curator_metastreams_workflows_on_archived_at", where: "(archived_at IS NULL)"
    t.index ["processing_state"], name: "index_curator_metastreams_workflows_on_processing_state"
    t.index ["publishing_state"], name: "index_curator_metastreams_workflows_on_publishing_state"
    t.index ["workflowable_type", "workflowable_id"], name: "unique_idx_meta_workflows_on_metastreamable_poly", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "curator_collections", "curator_institutions", column: "institution_id"
  add_foreign_key "curator_controlled_terms_nomenclatures", "curator_controlled_terms_authorities", column: "authority_id", on_delete: :cascade
  add_foreign_key "curator_digital_objects", "curator_collections", column: "admin_set_id", on_delete: :cascade
  add_foreign_key "curator_filestreams_file_sets", "curator_digital_objects", column: "file_set_of_id", on_delete: :cascade
  add_foreign_key "curator_institutions", "curator_controlled_terms_nomenclatures", column: "location_id", on_delete: :nullify
  add_foreign_key "curator_mappings_collection_members", "curator_collections", column: "collection_id", on_delete: :cascade
  add_foreign_key "curator_mappings_collection_members", "curator_digital_objects", column: "digital_object_id", on_delete: :cascade
  add_foreign_key "curator_mappings_desc_host_collections", "curator_mappings_host_collections", column: "host_collection_id", on_delete: :cascade
  add_foreign_key "curator_mappings_desc_host_collections", "curator_metastreams_descriptives", column: "descriptive_id", on_delete: :cascade
  add_foreign_key "curator_mappings_desc_name_roles", "curator_controlled_terms_nomenclatures", column: "name_id", on_delete: :cascade
  add_foreign_key "curator_mappings_desc_name_roles", "curator_controlled_terms_nomenclatures", column: "role_id", on_delete: :cascade
  add_foreign_key "curator_mappings_desc_name_roles", "curator_metastreams_descriptives", column: "descriptive_id", on_delete: :cascade
  add_foreign_key "curator_mappings_desc_terms", "curator_metastreams_descriptives", column: "descriptive_id", on_delete: :cascade
  add_foreign_key "curator_mappings_exemplary_images", "curator_filestreams_file_sets", column: "file_set_id", on_delete: :cascade
  add_foreign_key "curator_mappings_host_collections", "curator_institutions", column: "institution_id", on_delete: :cascade
  add_foreign_key "curator_metastreams_descriptives", "curator_controlled_terms_nomenclatures", column: "physical_location_id"
end
