# frozen_string_literal: true

module Curator
  class Metastreams::OriginInfoModsDecorator < Decorators::BaseDecorator
    # DESCRIPTION: This class wraps and delegates Curator::Metastreams::Descriptive objects to serialize/display <mods:originInfo> elements and sub elements
    # OriginInfoModsDecorator#initialize
    ## @param obj [Curator::Metastreams::Descriptive]
    ## @returns [Curator::Metastreams::OriginInfoModsDecorator]
    ## USAGE:
    ### desc = Curator.metastreams.descriptive_class.for_serialization.find_by(..)
    ### origin_info = Curator::Metastreams:OriginInfoModsDecorator.new(desc)

    def event_type
      return @event_type if defined?(@event_type)

      return @event_type = nil if !__getobj__.respond_to?(:origin_event)

      @event_type = __getobj__.origin_event
    end

    def publication
      return @publication if defined?(@publication)

      return @publication = nil if !__getobj__.respond_to?(:publication)

      @publication = __getobj__.publication
    end

    # @return [String | nil] - for <mods:edition>  sub elements
    def edition
      return if publication.blank?

      publication.edition_name
    end

    # @return [String | nil] - Used for <mods:publisher> elements
    def publisher
      super if __getobj__.respond_to?(:publisher)
    end

    def date
      super if __getobj__.respond_to?(:date)
    end

    def issuance
      super if __getobj__.respond_to?(:issuance)
    end

    # @return [Curator::Metastreams::PlaceModsPresenter] - used for <mods:place><mods:placeTerm> sub elements
    def place
      return @place if defined?(@place)

      return @place = nil if !__getobj__.respond_to?(:place_of_publication) || __getobj__.place_of_publication.blank?

      @place = Curator::Metastreams::PlaceModsPresenter.new(__getobj__.place_of_publication)
    end

    # @return [Boolean] - Used for detecting if the dates should be parsed as inferred
    def dates_inferred?
      return false if !__getobj__.respond_to?(:note) || __getobj__.note.blank?

      __getobj__.note.any? { |n| n.inferred_date? }
    end

    # @return [Array[Curator::DescriptiveFieldSets::DateModsPresenter]] - for <mods:dateCreated> sub elements
    def date_created
      return @date_created if defined?(@date_created)

      return @dated_created = [] if date.blank? || date.created.blank?

      @date_created = map_date_presenters(date.created, 'dateCreated')
    end

    # @return [Array[Curator::DescriptiveFieldSets::DateModsPresenter]] - for <mods:dateIssued> sub elements
    def date_issued
      return @date_issued if defined?(@date_issued)

      return @date_issued = [] if date.blank? || date.issued.blank?

      @date_issued = map_date_presenters(date.issued, 'dateIssued')
    end

    # @return [Array[Curator::DescriptiveFieldSets::DateModsPresenter]] - for <mods:copyrightDate> sub elements
    def copyright_date
      return @copyright_date if defined?(@copyright_date)

      return @copyright_date = [] if date.blank? || date.copyright.blank?

      @copyright_date = map_date_presenters(date.copyright, 'dateCopyright')
    end

    # @return [Boolean] - Needed for mods serializer
    def blank?
      return true if __getobj__.blank?

      event_type.blank? && publisher.blank? && publication.blank? && place.blank? && date.blank?
    end

    # @return [String] - Used for determinining which date the keyDate attribute should be for
    def key_date_for
      return if date.blank?

      if date.created.present?
        'dateCreated'
      elsif date.issued.present?
        'dateIssued'
      elsif date.copyright.present?
        'dateCopyright'
      end
    end

    # @param type [String]
    # @return [Boolean]
    def is_key_date?(type)
      return false if date.blank?

      key_date_for == type
    end

    private

    def map_date_presenters(date, type)
      date_hash = Curator::Parsers::EdtfDateParser.edtf_date_parser(date: date, type: type, inferred: dates_inferred?)
      date_hash = date_hash.except(:type)

      key_date = is_key_date?(type)
      date_hash = date_hash.merge(key_date: key_date)
      return Array.wrap(Curator::DescriptiveFieldSets::DateModsPresenter.new(**date_hash)) if date_hash[:start].blank? || date_hash[:end].blank?

      [date_hash.dup.except(:end), date_hash.dup.except(:start)].map { |date_attrs| Curator::DescriptiveFieldSets::DateModsPresenter.new(**date_attrs) }
    end
  end
end
