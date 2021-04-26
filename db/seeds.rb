# frozen_string_literal: true

puts 'Seeding ControlledTerms values...'
# ControlledTerms::Authority
puts 'Fetching authority values from bpldc_authority_api....'
auth_data = Curator::ControlledTerms::AuthorityService.call(path: 'authorities')
puts 'Seeding ControlledTerms::Authority values...'
auth_data&.each do |auth_input|
  Curator.controlled_terms.authority_class.transaction do
    begin
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
  puts "Fetching #{term_for_seed} data from bpldc_authority_api"
  terms_data = Curator::ControlledTerms::AuthorityService.call(path: term_for_seed)
  term_class_name = term_for_seed.gsub(/\Abasic_/, '').singularize
  term_class = Curator.controlled_terms.public_send("#{term_class_name}_class")
  puts "Seeding #{term_class} values..."
  terms_data&.each do |term_data|
    term_class.transaction do
      begin
        auth = Curator.controlled_terms.authority_class.find_by(code: term_data[:authority_code])
        term_data[:basic] = true if term_class == Curator::ControlledTerms::Genre
        term_class.where(term_data: term_data.except(:authority_code), authority: auth).first_or_create!
      rescue StandardError => e
        puts "==== Failed to seed #{term_class}: '#{term_data[:label]}' (#{term_data[:id_from_auth]}) for authority: #{term_data[:authority_code]}==== "
        puts e.inspect
      end
    end
  end
end

# ControlledTerms::License, ControlledTerms::RightsStatement
terms_for_seed = %w(licenses rights_statements)
terms_for_seed.each do |term_for_seed|
  puts "Fetching #{term_for_seed} data from bpldc_authority_api"
  terms_data = Curator::ControlledTerms::AuthorityService.call(path: term_for_seed)
  term_class = Curator.controlled_terms.public_send("#{term_for_seed.singularize}_class")
  puts "Seeding #{term_class} values..."
  terms_data&.each do |term_input|
    term_class.transaction do
      begin
        term_class.where(term_data: term_input).first_or_create!
      rescue StandardError => e
        puts "==== Failed to seed #{term_class} with attributes: #{term_input} ===="
        puts e.inspect
      end
    end
  end
end

if Rails.env.development?
  begin
    puts 'Seeding development objects from spec/fixtures....'

    inst_json = Oj.load(File.read(Curator::Engine.root.join('spec', 'fixtures', 'files', 'institution.json'))).fetch('institution', {}).with_indifferent_access

    col_json = Oj.load(File.read(Curator::Engine.root.join('spec', 'fixtures', 'files', 'collection.json'))).fetch('collection', {}).with_indifferent_access

    obj_json = Oj.load(File.read(Curator::Engine.root.join('spec', 'fixtures', 'files', 'digital_object.json'))).fetch('digital_object', {}).with_indifferent_access

    inst_success, inst = Curator::InstitutionFactoryService.call(json_data: inst_json)

    raise "Institution Errors occured; Details.. #{inst.errors.inspect}" if !inst_success

    col_success, _col = Curator::CollectionFactoryService.call(json_data: col_json)

    raise "Collection Errors occured; Details.. #{col.errors.inspect}" if !col_success

    obj_success, obj = Curator::DigitalObjectFactoryService.call(json_data: obj_json)

    raise "DigitalObject Errors occured; Details.. #{obj.errors.inspect}" if !obj_success
  rescue RuntimeError =>  e
    puts 'errors occured seeding default development objects!'
    puts "Reason #{e.message}"
  end
end
