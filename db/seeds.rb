# frozen_string_literal: true

# fetch data from source authority and seed database for input validation
authority_api_url = "#{ENV['AUTHORITY_API_URL']}/bpldc"

# ControlledTerms::Authority
authorities_url = "#{authority_api_url}/authorities"
auth_data = Curator::ControlledTerms::CannonicalLabelService.call(url: authorities_url, json_path: nil)
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
  terms_url = "#{authority_api_url}/#{term_for_seed}"
  terms_data = Curator::ControlledTerms::CannonicalLabelService.call(url: terms_url, json_path: nil)
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
        puts "==== Failed to seed #{term_class}: '#{term_data[:label]}' (#{term_data[:id_from_auth]}) for authority:
#{term_data[:authority_code]}==== "
        puts e.inspect
      end
    end
  end
end

# ControlledTerms::License
licenses_url = "#{authority_api_url}/licenses"
licenses_data = Curator::ControlledTerms::CannonicalLabelService.call(url: licenses_url, json_path: nil)
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
