# frozen_string_literal: true

module Curator
  module Serializers
    class SchemaBuilders::Mods < SchemaBuilders::XML
      ROOT_ATTRIBUTES = {
        'xmlns:xlink' => 'http://www.w3.org/1999/xlink',
        'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
        'xmlns:mods' => 'http://www.loc.gov/mods/v3',
        'version' => '3.7',
        'xsi:schemaLocation' => 'http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-7.xsd'
      }.freeze

      root_settings 'mods', root_namespace: true, root_attributes: ROOT_ATTRIBUTES
    end
  end
end
