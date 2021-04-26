# frozen_string_literal: true

# make attaching file fixtures to Curator::Filestream objects easy in specs
module FileAttachmentHelpers
  def attach_text_file(file_set)
    attach_fixture_file(:text_plain, file_set, 'text_plain.txt')
  end

  def attach_text_coordinates_file(file_set)
    attach_fixture_file(:text_coordinates_access, file_set, 'text_coordinates_access.json')
  end

  def attach_georeferenced_file(file_set)
    attach_fixture_file(:image_georectified_primary, file_set, 'image_georectified_primary.tif')
  end

  private

  def attach_fixture_file(attachment_type, file_set, file_fixture_name)
    file_set.send(attachment_type).attach(io: File.open(file_fixture(file_fixture_name)),
                                          filename: file_fixture_name)
  end
end

RSpec.configure do |config|
  config.include FileAttachmentHelpers, type: :indexer
end
