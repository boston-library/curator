# frozen_string_literal: true

module Curator
  class Metastreams::OriginInfoModsDecorator < Decorators::BaseDecorator
    def publication
      return @publication if defined?(@publication)

      return @publication = nil if !__getobj__.respond_to?(:publication)

      @publication = __getobj__.publication
    end

    def edition
      return if publication.blank?

      publication.edition_name
    end

    def publisher
      super if __getobj__.respond_to?(:publisher)
    end

    def date
      super if __getobj__.respond_to?(:date)
    end

    def place
      return @place if defined?(@place)

      return @place = nil if !__getobj__.respond_to?(:place_of_publication) || __getobj__.place_of_publication.blank?

      @place = Curator::Metastreams::PlaceModsPresenter.new(__getobj__.place_of_publication)
    end

    def dates_inferred?
      return false if !__getobj__.respond_to?(:note) || __getobj__.note.blank?

      __getobj__.note.any? { |n| n.inferred_date? }
    end

    def date_created
      return @date_created if defined?(@date_created)

      return @dated_created = [] if date.blank? || date.created.blank?

      @date_created = map_date_presenters(date.created, 'dateCreated')
    end

    def date_issued
      return @date_issued if defined?(@date_issued)

      return @date_issued = [] if date.blank? || date.issued.blank?

      @date_issued = map_date_presenters(date.issued, 'dateIssued')
    end

    def copyright_date
      return @copyright_date if defined?(@copyright_date)

      return @copyright_date = [] if date.blank? || date.copyright.blank?

      @copyright_date = map_date_presenters(date.copyright, 'dateCopyright')
    end

    def blank?
      return true if __getobj__.blank?

      publisher.blank? && publication.blank? && place.blank? && date.blank?
    end

    private

    def map_date_presenters(date, type)
      date_hash = Curator::Parsers::EdtfDateParser.edtf_date_parser(date: date, type: type, inferred: dates_inferred?)
      date_hash = date_hash.except(:type)

      return Array.wrap(Curator::DescriptiveFieldSets::DateModsPresenter.new(key_date: true, **date_hash)) if date_hash[:start].blank? || date_hash[:end].blank?

      [date_hash.dup.except(:end).merge(key_date: true), date_hash.dup.except(:start)].map { |date_attrs| Curator::DescriptiveFieldSets::DateModsPresenter.new(**date_attrs) }
    end
  end
end