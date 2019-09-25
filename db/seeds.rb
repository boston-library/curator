# frozen_string_literal: true
AUTHORITY_INPUTS=[
  {code: 'gmgpc', base_url: 'http://id.loc.gov/vocabulary/graphicMaterials'},
  {code: 'lctgm', base_url: 'http://id.loc.gov/vocabulary/graphicMaterials'},
  {code: 'naf', base_url: 'http://id.loc.gov/authorities/names'},
  {code: 'lcsh', base_url: 'http://id.loc.gov/authorities/subjects'},
  {code: 'lcgft', base_url: 'http://id.loc.gov/authorities/genreForms'},
  {code: 'iso639-2', base_url: 'http://id.loc.gov/vocabulary/iso639-2'},
  {code: 'marcrelator', base_url: 'http://id.loc.gov/vocabulary/relators'},
  {code: 'aat', base_url: 'http://vocab.getty.edu/aat'},
  {code: 'tgn', base_url: 'http://vocab.getty.edu/tgn', name: 'Thesaurus of Geographic Names' },
  {code: 'ulan', base_url: 'http://vocab.getty.edu/ulan', name: 'Getty Union List of Artist Names'},
  {code: 'geonames', base_url: 'http://sws.geonames.org/', name: 'GeoNames' },
  {code: 'resourceTypes', base_url: 'http://id.loc.gov/vocabulary/resourceTypes'}
]


AUTHORITY_INPUTS.each do |auth_input|
  CommonwealthCurator::ControlledTerms::Authority.transaction do
    begin
      CommonwealthCurator::ControlledTerms::Authority.where(auth_input).first_or_create!
    rescue ActiveRecord::ActiveRecordError => e
      Rails.logger.error "Failed to seed Authority Record with the following input #{auth_input.inspect}"
      Rails.logger.error e.inspect
    end
  end
end



BASIC_GENRE_INPUTS={
  'gmgpc' => %w(tgm001686 tgm003185 tgm003279 tgm003634 tgm012286 tgm006261 tgm007393 tgm007721 tgm008104 tgm008237 tgm007641 tgm001221 tgm000229),
  'lctgm' => %w(tgm002590 tgm007159 tgm007068 tgm009874 tgm006804 tgm006926 tgm006906)
}.freeze


BASIC_GENRE_INPUTS.each do |auth_code, ids_from_auth|
  CommonwealthCurator::ControlledTerms::Genre.transaction do
    begin
      auth = CommonwealthCurator::ControlledTerms::Authority.find_by(code: auth_code)
      ids_from_auth.each do |id_from_auth|
        puts "Seeding Basic Genre #{id_from_auth}..."
        auth.genres.where(term_data: {basic: true, id_from_auth: id_from_auth}).first_or_create!
      end
    rescue ActiveRecord::ActiveRecordError => e
      puts "====Failed to seed Basic Genre for the following authority #{auth_code}===="
      puts e.inspect
    end
  end
end




LICENSE_INPUTS=[
  {label: 'No known restrictions on use.', uri: nil},
  {label: 'This work is in the public domain under a Creative Commons No Rights Reserved License (CC0).', uri: nil},
  {label: 'This work is licensed for use under a Creative Commons Attribution License (CC BY).', uri: 'https://creativecommons.org/licenses/by/4.0'},
  {label: 'This work is licensed for use under a Creative Commons Attribution Share Alike License (CC BY-SA).', uri: 'https://creativecommons.org/licenses/by-sa/4.0'},
  {label: 'This work is licensed for use under a Creative Commons Attribution No Derivatives License (CC BY-ND).', uri: 'https://creativecommons.org/licenses/by-nd/4.0'},
  {label: 'This work is licensed for use under a Creative Commons Attribution Non-Commercial License (CC BY-NC).', uri: 'https://creativecommons.org/licenses/by-nc/4.0'},
  {label: 'This work is licensed for use under a Creative Commons Attribution Non-Commercial Share Alike License (CC BY-NC-SA).', uri: 'https://creativecommons.org/licenses/by-nc-sa/4.0'},
  {label: 'This work is licensed for use under a Creative Commons Attribution Non-Commercial No Derivatives License (CC BY-NC-ND).', uri: 'https://creativecommons.org/licenses/by-nc-nd/4.0'},
  {label: 'All rights reserved.', uri: nil},
  {label: 'Contact host institution for more information.', uri: nil}
].freeze


LICENSE_INPUTS.each do |license_input|
  ControlledTerms::License.transaction do
    begin
      ControlledTerms::License.where(term_data: license_input).first_or_create!
    rescue ActiveRecord::ActiveRecordError => e
      puts "Failed to seed Basic Genre for the following authority #{auth_code}"
      puts e.inspect
    end
  end
end
