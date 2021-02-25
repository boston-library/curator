# Curator
[![Build Status](https://travis-ci.org/boston-library/curator.svg?branch=master)](https://travis-ci.org/boston-library/curator) [![Coverage Status](https://coveralls.io/repos/github/boston-library/curator/badge.svg?branch=master)](https://coveralls.io/github/boston-library/curator?branch=master)

## Warning


This Project is currently in the early stages of **development** and not recommended for any use outside of **development**


## Description
Rails(~> 5.2) engine that sets up the basic data elements and routes for a more data driven JSON API for digital repositories.
Implements ActiveStorage for Cloud or local stoarge for files.
Currently all data models have been created with basic routes and json serializers

## Todo

1. Specs
  * ~~Setup Rubocop~~
  * ~~Setup Database Cleaner~~
  * ~~Setup Solr Wrapper~~
  * ~~Setup Fixtures~~
  * ~~Setup FactoryBot~~
  * ~~Setup VCR~~
  * ~~Spec Unit~~
  * Spec Functionality
  * Spec Integration
2. Development
  * Create Indexing Functionality (Solr)
  * Create Additional Seralizer Functionality (In priority)
    - Build JSON/XML Serializer
    - Use `AdapterBase` class to build extended functionality for the following
      * Mods XML
      * Dublic Core XML
      * Marc XML
      * RDF

## Installation (for development only)

1. Ensure you have the following installed on your development machine
    * `Postgresql ~9.6`
    * `Redis`
    * `Imagemagick`
    * `Ruby  >= 2.5.7`
    * [Docker](https://docs.docker.com/)

2. Clone Project

3. Run `bundle install`

4. Check `spec/internal/config/database.yml` and make sure your `postgres` credentials are correct.

5. `cd` into the `spec/internal` directory and:
    * run `$ rails curator:setup` -- this will run the database setup scripts for you and install ActiveStorage.
    * run `$ rails generate curator:install` (optional) -- this will add an initializer for customizing `Curator.config` settings

## Running (for development only)
Curator requires several additional services:
* [Solr](https://lucene.apache.org/solr/) (for indexing records)
* [BPLDC Authority API](https://github.com/boston-library/bpldc_authority_api) (for retrieving authority data for
 controlled vocabluaries)

To set up these services:
1. Clone the BPLDC Authority API project and run the Docker container (see the project README for instructions). The
 application should be running on `127.0.0.1:3001`
2. In the Curator project, start Solr using the following command (see [solr_wrapper](https://github.com/cbeer/solr_wrapper) for more documentation):
    * `$ cd ./spec/internal && solr_wrapper` (development)
    * `$ solr_wrapper` (test)
3. Make sure the URLs for these services are set as `ENV` variables (`AUTHORITY_API_URL` and `SOLR_URL`). You can set
 these using the `spec/internal/.env.#{RAILS_ENV}` files.


## Contributing
Any Input/ Suggestions are appreciated as we develop this. Please contact [Ben](mailto:bbarber@bpl.org) or [Eben](mailto:eenglish@bpl.org).

### Running specs

Solr needs to be running before specs can be run.

Prior to starting Solr, create config directory (only needs to be run once):
```
# populates spec/internal/solr/conf
$ git submodule init
$ git submodule update
```

To start Solr in Test mode (use a separate console session):
```
$ cd spec/internal
$ solr_wrapper --config .solr_wrapper_test
```

Run the specs:
```
$ bundle exec rake spec
```

## Acknowledgments

Special thank you to the [Samvera](https://github.com/samvera) community and [Jonathan Rochkind](https://github.com/jrochkind) for providing this project with gems and code samples to develop this.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
