# frozen_string_literal: true

module Curator
  module Metastreams
    module ModsDescriptable
      extend ActiveSupport::Concern

      included do
        multi_node :title_info, target_obj: :title_info_list do
          target_value_blank!

          attribute :usage
          attribute :type

          attribute :supplied do |title_info|
            title_info.supplied == true ? 'yes' : nil
          end

          attribute :language, xml_label: :lang
          attribute :formatted_title_display_label, xml_label: :displayLabel
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

          node :name_part, multi_valued: true, target_obj: :name_parts do
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

        multi_node :type_of_resource, target_obj: :resource_type_presenters do
          target_value_as :label

          attribute :manuscript do |tor|
            tor.manuscript_label
          end
        end

        multi_node :genre, target_obj: :genre_list do
          target_value_as :label

          attribute :authority
          attribute :authority_uri, xml_label: :authorityURI
          attribute :value_uri, xml_label: :valueURI
          attribute :display_label
        end

        node :origin_info do
          target_value_blank!

          node :place do
            target_value_blank!

            node :place_term do
              target_value_as :label

              attribute :type
            end
          end

          element :publisher
          element :edition

          node :date_created, multi_valued: true do
            target_value_as :label

            attribute :encoding
            attribute :key_date, xml_label: :keyDate
            attribute :point
            attribute :qualifier
          end

          node :date_issued, multi_valued: true do
            target_value_as :label

            attribute :encoding
            attribute :key_date, xml_label: :keyDate
            attribute :point
            attribute :qualifier
          end

          node :copyright_date, multi_valued: true do
            target_value_as :label

            attribute :encoding
            attribute :key_date, xml_label: :keyDate
            attribute :point
            attribute :qualifier
          end
        end

        multi_node :language, target_obj: :languages do
          target_value_blank!

          element :language_term, target_val: :label do
            attribute :authority_code, xml_label: :authority
            attribute :authority_base_url, xml_label: :authorityURI
            attribute :value_uri, xml_label: :valueURI
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

        multi_node :table_of_contents, target_obj: :toc_mods do
          target_value_as :label

          attribute :xlink, xml_label: 'xlink:href'
        end

        multi_node :note, target_obj: :note_list do
          target_value_as :label

          attribute :type
        end

        multi_node :subject, target_obj: :subject_mods do
          target_value_blank!

          attribute :authority_code, xml_label: :authority
          attribute :authority_base_url, xml_label: :authorityURI
          attribute :value_uri, xml_label: :valueURI

          element :topic, target_val: :topic_label
          element :geographic, target_val: :geographic_label

          node :hierachical_geographic do
            target_value_blank!

            element :other
            element :area
            element :province
            element :region
            element :country
            element :continent
            element :island
            element :state
            element :city
            element :city_section
          end

          node :cartographics, target_obj: :cartographic_subject do
            target_value_blank!

            element :projection
            element :coordinates

            node :scale, multi_valued: true do
              target_value_as do |s|
                s
              end
            end
          end

          # node :temporal, multi_valued: true, target_obj: :temporals do
          #   target_value_as do |temporal|
          #     case temporal
          #     when String
          #       temporal
          #     when Curator::DescriptiveFieldSets::DateModsPresenter
          #       temporal.label
          #     end
          #   end
          #
          #   attribute :encoding do |temporal|
          #     case temporal
          #     when Curator::DescriptiveFieldSets::DateModsPresenter
          #       temporal.encoding
          #     end
          #   end
          #
          #   attribute :point do |temporal|
          #     temporal.point if temporal.respond_to?(:point)
          #   end
          # end

          node :name, target_obj: :name_subject do
            target_value_blank!

            attribute :type do |name_subject|
              name_subject.name_type
            end

            attribute :authority do |name_subject|
              name_subject.authority_code
            end

            attribute :authorityURI do |name_subject|
              name_subject.authority_base_url
            end

            attribute :valueURI do |name_subject|
              name_subject.value_uri
            end

            node :name_part, multi_valued: true, target_obj: :name_parts do
              target_value_as :label

              attribute :type do |np|
                np.is_date ? 'date' : nil
              end
            end
          end
        end

        multi_node :related_item, target_obj: :related_items do
          target_value_blank!

          attribute :type
          attribute :xlink, xml_label: 'xlink:href'
          attribute :display_label, xml_label: :displayLabel

          node :title_info do
            target_value_as :label
          end

          node :related_item, target_obj: -> (ri_sub) { ri_sub.respond_to?(:sub_series) ? ri_sub.sub_series : nil } do
            target_value_blank!

            attribute :type

            node :title_info do
              target_value_as :label
            end

            node :related_item, target_obj: ->(ri_sub_sub) { ri_sub_sub.respond_to?(:sub_series) ? ri_sub_sub.sub_series : nil } do
              target_value_blank!

              attribute :type

              node :title_info do
                target_value_as :label
              end
            end
          end
        end

        multi_node :identifier, target_obj: :identifier_list do
          target_value_as :label

          attribute :type
          attribute :invalid
        end

        multi_node :access_condition, target_obj: :access_condition_list do
          target_value_as :label

          attribute :uri
          attribute :type
          attribute :display_label
        end

        node :record_info do
          target_value_blank!

          element :record_content_source

          element :record_creation_date do
            attribute :date_encoding, xml_label: :encoding
          end

          element :record_change_date do
            attribute :date_encoding, xml_label: :encoding
          end

          element :record_origin

          node :language_of_cataloging do
            target_value_blank!

            attribute :usage

            node :language_term do
              target_value_as :label

              attribute :type
              attribute :authority
              attribute :authority_uri, xml_label: :authorityURI
              attribute :value_uri, xml_label: :valueURI
            end
          end

          element :description_standard do
            attribute :description_standard_authority, xml_label: :authority
          end
        end
      end

      def formatted_title_name(title_info)
        title_info.non_sort.blank? ? title_info.label : title_info.label.gsub(title_info.non_sort, '')
      end

      def formatted_title_display_label(title_info)
        title_info.display == 'primary' ? 'primary_display' : title_info.display
      end

      def title_info_list(desc)
        Array.wrap(desc.title.primary) + desc.title.other
      end

      def genre_list(desc)
        Curator::ControlledTerms::GenreModsDecorator.wrap_multiple(desc.genres)
      end

      def name_role_list(desc)
        Curator::Mappings::NameRoleModsDecorator.wrap_multiple(desc.name_roles)
      end

      def note_list(desc)
        desc.note.select { |n| n.type != 'physical description'}
      end

      def access_condition_list(desc)
        Curator::ControlledTerms::AccessConditionModsDecorator.wrap_multiple([desc.rights_statement, desc.license])
      end

      def identifier_list(desc)
        ark_identifier =  desc.digital_object.ark_identifier
        return Array.wrap(ark_identifier) + desc.identifier if ark_identifier.present?

        desc.identifier
      end

      def subject_mods(desc)
        Curator::Metastreams::SubjectModsDecorator.wrap_multiple(desc.subject.to_a)
      end

      def toc_mods(desc)
        return [] if desc.toc.blank? && desc.toc_url.blank?

        toc_attrs = {}
        toc_attrs[:label] = desc.toc if desc.toc.present?
        toc_attrs[:xlink] = desc.toc_url if desc.toc_url.present?

        toc_attrs.keys.map { |k| Curator::Metastreams::TocModsPresenter.new(k => toc_attrs[k]) }
      end

      def origin_info(desc)
        Curator::Metastreams::OriginInfoModsDecorator.new(desc)
      end

      def physical_description(desc)
        Curator::Metastreams::PhysicalDescriptionModsDecorator.new(desc)
      end

      def record_info(desc)
        Curator::Metastreams::RecordInfoModsDecorator.new(desc)
      end

      def related_items(desc)
        Curator::DescriptiveFieldSets::RelatedModsDecorator.new(desc).to_a
      end

      def resource_type_presenters(desc)
        Curator::ControlledTerms::ResourceTypeModsPresenter.wrap_multiple(desc.resource_types, resource_type_manuscript: desc.resource_type_manuscript)
      end
    end
  end
end
