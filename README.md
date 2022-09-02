# Curator
[![Build Status](https://travis-ci.org/boston-library/curator.svg?branch=master)](https://travis-ci.org/boston-library/curator) [![Coverage Status](https://coveralls.io/repos/github/boston-library/curator/badge.svg?branch=master)](https://coveralls.io/github/boston-library/curator?branch=master)

## Test for pull request
## Test again...


## Warning


This Project is currently in the early stages of **development** and not recommended for any use outside of **development**


## Description
Rails(~> 6.1) engine that sets up the basic data elements and routes for a more data driven JSON API for digital repositories.
Implements ActiveStorage for Cloud or local storage for files.
Currently all data models have been created with basic routes and json serializers

## Todo

1. Development
  * Create Additional Seralizer Functionality (In priority)
  - ~~Build JSON/XML Serializer~~
    - Refactor to be less complex
    - Use `AdapterBase` class to build extended functionality for the following
      * Mods XML
      * Dublic Core XML
      * Marc XML
      * RDF

## Installation (for development only)

1. Ensure you have the following installed on your development machine
    * `Postgresql ~9.6(v 12 stable is recommended)`
    * `Redis`
    * `Imagemagick`
    * `Ruby  >= 2.6.8`
    * [Docker](https://docs.docker.com/)

2. Clone Project

3. Run `bundle install`

4. Setup development dependencies(See the Running guide below)

5. Check `spec/internal/config/database.yml` and make sure your `postgres` credentials are correct.

6. `cd` into the `spec/internal` directory and:
    * run `$ rails curator:setup` -- this will run the database setup scripts for you
    * run `$ rails generate curator:install` (optional) -- this will add an initializer for customizing `Curator.config` settings
   

## Running (for development only)
Curator requires several additional services:
* [Solr](https://lucene.apache.org/solr/) (for indexing records)
* [BPLDC Authority API](https://github.com/boston-library/bpldc_authority_api) (for retrieving authority data for
 controlled vocabluaries)
* [Ark Manager](https://github.com/boston-library/ark-manager) (for creating persistent identifiers and permalinks)
* [Azurite](https://github.com/Azure/Azurite) (for testing azure cloud storage)
* [Avi Processor](https://github.com/boston-library/avi_processor_v3) (for creating derivatives from primary files. NOTE this project is still in development and is not needed at the moment)

To set up these services:
1. Add Environment variables. Make sure the URLs for these services are set as `ENV` variables (`AUTHORITY_API_URL`, `SOLR_URL`, `AVI_PROCESSOR_API_URL`, `INGEST_SOURCE_DIRECTORY`). You can set
 these using the `spec/internal/.env.#{RAILS_ENV}` files. You are also required to create an `.env` and set the variables listed in the `.env.docker.sample` file in the root of curator. These are required to start the docker containers
2. Start the docker containers with `docker-compose up` This will run docker images of the `ark_manager`, `bpldc_authority_api`, `azurite` as well as internal shared `postgres` and `redis` containers. On start the `ark-manager` and `bpldc_authority_api` apps will run `bundle exec rails db:prepare` which will wither run pending migrations OR run `rails db:setup`. NOTE the postgres container is NOT exposed to the host machine so you will need to run a local instance of postgres for the curator app itself.
3. Install the [Azure Cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) on your local machine for your given operating system. NOTE.If installing on linux apt/deb DO NOT use the install with one command option as it appears broken in Ubuntu 16.04. Follow the step by step guide instead.
4. Setup azure containers on azurite instance.
    - First check if the containers exist by running. This will help test if you are having issues with your `--connection-string` param. See the [Configure Connection String](https://docs.microsoft.com/en-us/azure/storage/common/storage-configure-connection-string) guide to troubleshoot problems you may have.:
      - `az storage container exists --name 'primary' --connection-string 'UseDevelopmentStorage=true'`
      - `az storage container exists --name 'derivatives' --connection-string 'UseDevelopmentStorage=true'`
    - If both containers return `{exist: false}` run the following two commands:
      - `az storage container create -n primary --connection-string "UseDevelopmentStorage=true" --public-access off`
      - `az storage container create -n derivatives --connection-string "UseDevelopmentStorage=true" --public-access container`


4 In the Curator project, start Solr using the following command (see [solr_wrapper](https://github.com/cbeer/solr_wrapper) for more documentation):
    * `$ cd ./spec/internal && solr_wrapper` (development)
    * `$ solr_wrapper` (test)


## Contributing
Any Input/ Suggestions are appreciated as we develop this. Please contact [Ben](mailto:bbarber@bpl.org) or [Eben](mailto:eenglish@bpl.org).

### Running specs

Solr needs to be running before specs can be run.

Prior to starting Solr, create config directory (only needs to be run once):
```
# populates spec/internal/solr/conf
$ git submodule init
$ git submodule update --remote
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
