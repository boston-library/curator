# frozen_string_literal: true

module Curator
  module DescriptiveComplexAttrs
    extend ActiveSupport::Concern

    included do
      include InstanceMethods
    end

    module InstanceMethods
      protected

      def identifier(json_attrs = {})
        json_attrs.fetch(:identifier, []).map do |ident_attrs|
          Descriptives::Identifier.new(ident_attrs)
        end
      end

      def note(json_attrs = {})
        json_attrs.fetch(:note, []).map do |note_attrs|
          Descriptives::Note.new(note_attrs)
        end
      end

      def date(json_attrs = {})
        date_attrs = json_attrs.fetch(:date, {})
        created = date_attrs.fetch(:created, nil)
        issued = date_attrs.fetch(:issued, nil)
        copyright = date_attrs.fetch(:copyright, nil)
        Descriptives::Date.new(created: created, issued: issued, copyright: copyright)
      end

      def publication(json_attrs = {})
        pub_hash = {}
        pub_attrs = json_attrs.fetch(:publication, {})
        %i(edition_name edition_number volume issue_number).each do |k|
          pub_hash[k] = pub_attrs.fetch(k, nil)
        end
        Descriptives::Publication.new(pub_hash.compact)
      end

      def title(json_attrs = {})
        titles = json_attrs.fetch(:title, {})
        primary = titles.fetch(:primary, {})
        other = titles.fetch(:other, []).map { |t_attrs| title_attr(t_attrs) }
        Descriptives::TitleSet.new(primary: primary, other: other)
      end

      def subject_other(json_attrs = {})
        subject_json = json_attrs.fetch(:subject, {})
        uniform_title = subject_json.fetch(:titles, []).map { |ut_attrs| title_attr(ut_attrs) }
        temporal = subject_json.fetch(:temporals, [])
        date = subject_json.fetch(:dates, [])
        Descriptives::Subject.new(titles: uniform_title, temporals: temporal, dates: date)
      end

      def related(json_attrs = {})
        related_hash = {}
        related_attrs = json_attrs.fetch(:related, {})
        %i(constituent referenced_by_url references_url other_format review_url).each do |k|
          related_hash[k] = related_attrs.fetch(k, nil)
        end
        Descriptives::Related.new(related_hash)
      end

      def physical_location(json_attrs = {})
        physical_location_attrs = json_attrs.fetch(:physical_location)
        authority_code = physical_location_attrs.fetch(:authority_code, nil)
        term_data = physical_location_attrs.except(:authority_code)
        find_or_create_nomenclature(
          nomenclature_class: Curator.controlled_terms.name_class,
          term_data: term_data,
          authority_code: authority_code
        )
      end

      def license(json_attrs = {})
        license_term_data = json_attrs.fetch(:license)
        find_or_create_nomenclature(
          nomenclature_class: Curator.controlled_terms.license_class,
          term_data: license_term_data
        )
      end

      def title_attr(json_attrs = {})
        Descriptives::Title.new(json_attrs)
      end

      def cartographic(json_attrs = {})
        carto_attrs = json_attrs.fetch(:cartographic, {})
        Descriptives::Cartographic.new(
          scale: carto_attrs.fetch(:scale, []),
          projection: carto_attrs.fetch(:projection, nil)
        )
      end
    end
  end
end
