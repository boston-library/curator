# frozen_string_literal: true

module Curator
  module Metastreams
    module ModsDescriptable
      extend ActiveSupport::Concern

      ACCESS_CONDITION_TYPE='use and reproduction'

      ResourceTypeWrapper = Struct.new(:resource_type_manuscript, :resource_type)
      RecordInfoWrapper = Struct.new(:record_content_source, :record_origin, :language_of_cataloging, :description_standard)

      included do
        multi_node :title_info, target_obj: :title_info_list do
          target_value_blank!

          attribute :usage
          attribute :type
          attribute :supplied do |title_info|
            title_info.supplied == true ? 'yes' : nil
          end
          attribute :language, xml_label: :lang
          attribute :format_title_display_label, xml_label: :displayLabel

          attribute :authority_code, xml_label: :authority

          element :non_sort
          element :title, target_val: :formatted_title_name
          element :subTitle, target_val: :subtitle
        end

        multi_node :name, target_obj: :name_role_list do
          target_value_blank!

          attribute :type do |name_role|
            name_role.name_type
          end

          attribute :authority do |name_role|
            name_role.name_authority
          end

          attribute :authorityURI do |name_role|
            name_role.name_authority_uri
          end

          attribute :valueURI do |name_role|
            name_role.name_value_uri
          end

          node :namePart, multi_valued: true, target_obj: :name_parts do
            target_value_as :label

            attribute :type do |np|
              np.is_date ? 'date' : nil
            end
          end

          node :role, target_obj: :role_term do
            target_value_blank!

            node :roleTerm, target_obj: ->(rt) { rt } do
              target_value_as :label

              attribute :authority_code, xml_label: :authority

              attribute :authority_base_url, xml_label: :authorityURI

              attribute :value_uri, xml_label: :valueURI
            end
          end
        end

        multi_node :type_of_resource, target_obj: :resource_type_wrappers do
          attribute :manuscript do |tor|
            tor.resource_type_manuscript == true ? 'yes' : nil
          end

          target_value_as do |tor|
            tor.resource_type&.label
          end
        end

        # multi_node :subject_geos, xml_label: :subject do
        # end

        #multi_node


        multi_node :subject_topics, xml_label: :subject do
          target_value_blank!

          attribute :authority_code, xml_label: :authority

          attribute :authority_base_url, xml_label: :authorityURI

          attribute :value_uri, xml_label: :valueURI

          element :topic, target_val: :label
        end

        multi_node :access_condition, target_obj: :access_condition_list do
          target_value_as :label

          attribute :uri

          attribute :type do |_access_condition|
            ACCESS_CONDITION_TYPE
          end

          attribute :displayLabel do |access_condition|
            case access_condition
            when Curator::ControlledTerms::RightsStatement
              'rights'
            when Curator::ControlledTerms::License
              'license'
            end
          end
        end

        multi_node :genre, target_obj: :genres do
          target_value_as :label

          attribute :authority_code, xml_label: :authority

          attribute :authority_base_url, xml_label: :authorityURI

          attribute :value_uri, xml_label: :valueURI

          attribute :displayLabel do |obj|
            obj.basic? ? 'general' : 'specific'
          end
        end

        node :physical_description do
          target_value_blank!

          element :digital_origin
          element :extent

          node :note, multi_valued: true, target_obj: :physical_description_note_list do
            target_value_as :label
          end

          node :internet_media_type, multi_valued: true, target_obj: :internet_media_type_list do
            target_value_as do |imt|
              imt
            end
          end
        end

        multi_node :language, target_obj: :languages do
          target_value_blank!

          element :languageTerm, target_val: :label do
            attribute :authority_code, xml_label: :authority

            attribute :authority_base_url, xml_label: :authorityURI

            attribute :value_uri, xml_label: :valueURI
          end
        end

        multi_node :note, target_obj: :note_list do
          attribute :type
          target_value_as :label
        end

        multi_node :identifier, target_obj: :identifier_list do
          attribute :type
          attribute :invalid

          target_value_as :label
        end
      end

      def formatted_title_name(title_info)
        title_info.non_sort.blank? ? title_info.label : title_info.label.gsub(title_info.non_sort, '')
      end

      def format_title_display_label(title_info)
        title_info.display == 'primary' ? 'primary_display' : title_info.display
      end

      def title_info_list(desc)
        Array.wrap(desc.title.primary) + desc.title.other
      end

      def name_role_list(desc)
        desc.name_roles.map { |nr| Curator::Mappings::NameRoleModsDecorator.new(nr) }
      end

      def note_list(desc)
        desc.note.select { |n| n.type != 'physical description'}
      end

      def access_condition_list(desc)
        [desc.rights_statement, desc.license]
      end

      def identifier_list(desc)
        ark_identifier = Curator::DescriptiveFieldSets::Identifier.new(type: 'uri', label: desc.digital_object.ark_uri)
        return Array.wrap(ark_identifier) + desc.identifier if ark_identifier.valid?

        desc.identifier
      end

      def physical_description(desc)
        Curator::Metastreams::PhysicalDescriptionModsDecorator.new(desc)
      end

      def resource_type_wrappers(desc)
        desc.resource_types.map { |rt| ResourceTypeWrapper.new(desc.resource_type_manuscript, rt) }
      end
    end
  end
end
