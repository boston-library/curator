# frozen_string_literal: true

# ControlledTerms::Authority

puts 'Seeding Authority values from bpldc_authority_api....'
auth_data = Curator::ControlledTerms::AuthorityService.call(path: 'authorities')
auth_data&.each do |auth_input|
  Curator.controlled_terms.authority_class.transaction do
    begin
      puts "Seeding ControlledTerms::Authority with id: #{auth_input[:code]}"
      Curator.controlled_terms.authority_class.where(auth_input).first_or_create!
    rescue StandardError => e
      puts "==== Failed to seed ControlledTerms::Authority with input #{auth_input.inspect} ===="
      puts e.inspect
    end
  end
end

# ControlledTerms::Genre, ControlledTerms::ResourceType, ControlledTerms::Language, ControlledTerms::Role
terms_for_seed = %w(basic_genres resource_types languages roles)
terms_for_seed.each do |term_for_seed|
  puts "Seeding Controlled Terms #{term_for_seed} from bpldc_authority_api"
  terms_data = Curator::ControlledTerms::AuthorityService.call(path: term_for_seed)
  terms_data&.each do |term_data|
    term_class_name = term_for_seed.gsub(/\Abasic_/, '').singularize
    term_class = Curator.controlled_terms.public_send("#{term_class_name}_class")
    term_class.transaction do
      begin
        auth = Curator.controlled_terms.authority_class.find_by(code: term_data[:authority_code])
        puts "Seeding #{term_class} with id: #{term_data[:id_from_auth]}..."
        term_data[:basic] = true if term_class == Curator::ControlledTerms::Genre
        term_class.where(term_data: term_data.except(:authority_code), authority: auth).first_or_create!
      rescue StandardError => e
        puts "==== Failed to seed #{term_class}: '#{term_data[:label]}' (#{term_data[:id_from_auth]}) for authority: #{term_data[:authority_code]}==== "
        puts e.inspect
      end
    end
  end
end

# ControlledTerms::License
puts 'Seeding License data from bpldc_authority_api'
licenses_data = Curator::ControlledTerms::AuthorityService.call(path: 'licenses')
licenses_data&.each do |license_input|
  Curator.controlled_terms.license_class.transaction do
    begin
      puts "Seeding License with attributes: #{license_input}"
      Curator.controlled_terms.license_class.where(term_data: license_input).first_or_create!
    rescue StandardError => e
      puts "==== Failed to seed License with attributes: #{license_input} ===="
      puts e.inspect
    end
  end
end



if Rails.env.development?
  puts 'Seeding development objects from spec/fixtures....'

  inst_json = Oj.load(File.read(Curator::Engine.root.join('spec', 'fixtures', 'files', 'institution.json'))).fetch('institution', {}).with_indifferent_access

  col_json = Oj.load(File.read(Curator::Engine.root.join('spec', 'fixtures', 'files', 'collection.json'))).fetch('collection', {}).with_indifferent_access

  obj_json = Oj.load(File.read(Curator::Engine.root.join('spec', 'fixtures', 'files', 'digital_object.json'))).fetch('digital_object',{}).with_indifferent_access

  inst_success, inst = Curator::InstitutionFactoryService.call(json_data: inst_json)

  puts "Errors occured; Details.. #{inst.inspect}" if !inst_success

  col_success, col = Curator::CollectionFactoryService.call(json_data: col_json) if inst_success

  obj_success, obj = Curator::DigitalObjectFactoryService.call(json_data: obj_json) if col_success
end
