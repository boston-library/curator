# frozen_string_literal: true
module Curator
  class ObjectFactoryService < ServiceClass
  include DigitalRepository::FactoryService

  def initialize(json_attrs: {})
    @json_attrs = json_attrs.with_indifferent_access
    awesome_print @json_attrs
  end

  def call
    admin_set_ark_id = @json_attrs.dig('admin_set', 'ark_id')
    metastream_json_attrs = @json_attrs.fetch('metastreams', {}).with_indifferent_access
    desc_json_attrs = metastream_json_attrs.fetch('descriptive', {}).with_indifferent_access
    workflow_json_attrs = metastream_json_attrs.fetch('workflow', {}).with_indifferent_access
    admin_json_attrs = metastream_json_attrs.fetch('administrative', {}).with_indifferent_access
    begin
      Curator.digital_object_class.transaction do
        @digital_object = Curator.digital_object_class.new
        @digital_object.admin_set = Curator.collection_class.find_by(ark_id: admin_set_ark_id)
        @digital_object.save!

        build_workflow(@digital_object) do |workflow|
          [:ingest_origin, :processing_state, :publishing_state].each do |attr|
            workflow.send("#{attr}=", workflow_json_attrs.fetch(attr, nil))
          end
        end

        build_administrative(@digital_object) do |admin|
          [:description_standard, :flagged, :destination_site, :harvestable].each do |attr|
            admin.send("#{attr}=", admin_json_attrs.fetch(attr, nil))
          end
        end


        build_descriptive(@digital_object) do |descriptive|
          [:abstract, :access_restrictions, :digital_origin, :edition, :frequency, :issuance, :origin_event, :physical_description_extent, :physical_location_department, :physical_location_shelf_locator, :place_of_publication, :publisher, :rights, :series, :subseries, :toc, :toc_url].each do |attr|
            descriptive.send("#{attr}=", desc_json_attrs.fetch(attr, nil))
          end
          descriptive.resource_type_manuscript =  desc_json_attrs.fetch('resource_type_manuscript?', false)
          descriptive.identifier = identifier(desc_json_attrs)
          descriptive.physical_location = physical_location(desc_json_attrs)
          descriptive.date = date(desc_json_attrs)
          descriptive.title = title(desc_json_attrs)
          descriptive.note = note(desc_json_attrs)
          descriptive.subject_other = subject_other(desc_json_attrs)
          descriptive.related = related(desc_json_attrs)
          [:genre, :resource_type, :language].each do |map_type|
            desc_json_attrs.fetch(map_type, []).each do |map_attrs|
              mappable = get_mappable(map_attrs,
                nomenclature_class: Curator.controlled_terms.public_send("#{map_type.to_s}_class")
              )
              descriptive.desc_terms << Curator.mappings.desc_term_class.new(mappable: mappable)
            end
          end
          license_attrs = desc_json_attrs.fetch(:license, {})
          if license_attrs.present?
            descriptive.desc_terms << Curator.mappings.desc_term_class.new(mappable:
              get_mappable(license_attrs,
                nomenclature_class: Curator.controlled_terms.license_class
              )
          )
          end
          desc_json_attrs.fetch(:subject, {}).each do |k,v|
            map_type = case k.to_s
            when 'topic'
              :subject
            when 'name'
              :name
            when 'geo'
              :geographic
            else
              nil
            end
            unless map_type.blank?
              v.each do |map_attrs|
                descriptive.desc_terms << Curator.mappings.desc_term_class.new(mappable:
                  get_mappable(map_attrs,
                    nomenclature_class: Curator.controlled_terms.public_send("#{map_type.to_s}_class")
                  )
                )
              end
            end
          end

          desc_json_attrs.fetch(:name_role, []).each do |name_role_attrs|
            name_role_attrs = name_role(name_role_attrs.fetch(:name), name_role_attrs.fetch(:role))
            descriptive.name_roles.build(name_role_attrs)
          end
        end
      end
    rescue => e
      puts "#{e.to_s}"
    end
  end


  def identifier(json_attrs={})
     json_attrs.fetch(:identifier, []).map do |ident_attrs|
       Descriptives::Identifier.new(ident_attrs)
     end
   end

   def note(json_attrs={})
     json_attrs.fetch(:note, []).map do |note_attrs|
       Descriptives::Note.new(note_attrs)
     end
   end

   def date(json_attrs={})
     date_attrs  = json_attrs.fetch(:date, {})
     created = date_attrs.fetch(:date_created, nil)
     issued = date_attrs.fetch(:date_issued, nil)
     copyright = date_attrs.fetch(:date_copyright, nil)
     Descriptives::Date.new(created: created, issued: issued, copyright: copyright)
   end

   def title(json_attrs={})
     primary = json_attrs.fetch(:title_primary, {})
     other = json_attrs.fetch(:title_other, {}).map {|t_attrs| title_attr(t_attrs) }
     Descriptives::TitleSet.new(primary: primary, other: other)
   end

   def subject_other(json_attrs={})
     subject_json = json_attrs.fetch(:subject, {})
     uniform_title = subject_json.fetch(:title, []).map{|ut_attrs| title_attr(ut_attrs)}
     temporal = subject_json.fetch(:temporal, [])
     date = subject_json.fetch(:date, [])
     Descriptives::Subject.new(title: uniform_title, temporal: temporal, date: date)
   end

   def related(json_attrs={})
     constituent = json_attrs.fetch(:related_constituent, nil)
     referenced_by_url = json_attrs.fetch(:related_referenced_by_url, [])
     references_url = json_attrs.fetch(:related_references_url, [])
     other_format = json_attrs.fetch(:related_other_format, [])
     review_url = json_attrs.fetch(:related_review_url, [])
     Descriptives::Related.new(constituent: constituent, referenced_by_url: referenced_by_url, references_url: references_url, other_format: other_format, review_url: review_url)
   end

   def physical_location(json_attrs={})
     physical_location_attrs = json_attrs.fetch(:physical_location)
     authority_code = physical_location_attrs.fetch(:authority_code, nil)
     term_data = physical_location_attrs.except(:authority_code)
     find_or_create_nomenclature(
       nomenclature_class: Curator.controlled_terms.name_class,
       term_data: term_data,
       authority_code: authority_code
     )
   end

   def title_attr(json_attrs={})
     Descriptives::Title.new(json_attrs)
   end

   def cartographics(json_attrs={})
     Descriptives::Cartographic.new(
       scale: json_attrs.fetch(:scale, []),
       projection: json_attrs.fetch(:projection, nil)
     )
   end

   private
   def get_mappable(json_attrs={}, nomenclature_class:)
     authority_code = json_attrs.fetch(:authority_code, nil)
     term_data = json_attrs.except(:authority_code)

     find_or_create_nomenclature(
       nomenclature_class: nomenclature_class,
       term_data: term_data,
       authority_code: authority_code
     )
   end

    def name_role(name_attrs={}, role_attrs={})
      {
       name: find_or_create_nomenclature(
         nomenclature_class: Curator.controlled_terms.name_class,
         term_data: name_attrs.except(:authority_code),
         authority_code: name_attrs.fetch(:authority_code, nil)
       ),
       role: find_or_create_nomenclature(
         nomenclature_class: Curator.controlled_terms.role_class,
         term_data: role_attrs.except(:authority_code),
         authority_code: role_attrs.fetch(:authority_code, nil)
       )
      }
    end
  end
end
