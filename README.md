# Curator

## Warning


This Project is currently in the early stages of **development** and not recommended for any use outside of **development**


## Description
Rails(~>5.2.3) engine that sets up the basic data elements and routes for a more data driven JSON API for digital repositories.
Implements ActiveStorage for Cloud or local stoarge for files.
Currently all data models have been created with basic routes and json serializers

## Todo

1. Specs
  * ~~Setup Rubocop~~
  * ~~Setup Database Cleaner~~
  * Setup Solr Wrapper
  * ~~Setup Fixtures~~
  * ~~Setup FactoryBot~~
  * ~~Setup VCR~~
  * ~~Spec Unit~~
  * Spec Functionality
  * Spec Integration
2. Development
  * Create Indexing Functionality(Solr)
  * Create Additional Seralizer Functionality(In priority)
    - Switch to Blueprinter(JSON)/ Modularize serializers
    - Mods XML
    - Dublic Core
    - Marc XML
    - RDF

## Installation(For development only)

Ensure you have the following installed on your development machine

`Postgresql ~9.6`

`Redis`

`Imagemagick`

`Ruby 2.5.7`

Clone Project

Run `bundle install`

Check `spec/internal/config/database.yml` and make sure your `postgres` credentials are correct.

`cd` into the `spec/internal` directory and run `rails curator:setup` this will run the databse setup scripts for you and install active storage.



## Contributing
Any Input/ Suggestions are appreciated as we develop this. Please contact [Ben](mailto:bbarber@bpl.org) or [Eben](mailto:eenglish@bpl.org).


## Acknowledgments

Special thank you to the [Samvera](https://github.com/samvera) community and [Jonathan Rochkind](https://github.com/jrochkind) for providing this project with gems and code samples to develop this.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
