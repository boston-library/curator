# frozen_string_literal: true

Curator::Engine.routes.draw do
  concern :administratable do |options|
    resource :administrative, options
  end

  concern :descriptable do |options|
    resource :descriptive, options
  end

  concern :workflowable do |options|
    resource :workflow, options
  end

  scope :api, defaults: { format: :json } do
    root to: Curator::Middleware::RootApp.new

    match '*path' => 'application#method_not_allowed', via: [:delete]

    constraints(Curator::Middleware::RouteConsts::XML_CONSTRAINT) do
      resources :digital_objects,
                param: :id,
                only: [:show],
                constraints: Curator::Middleware::ArkOrIdConstraint.new do
                  member do
                    scope module: :metastreams do
                      concerns :descriptable, only: [:show], as: 'digital_object_descriptive', metastreamable_type: 'DigitalObject'
                    end
                  end
                end
    end

    constraints(Curator::Middleware::RouteConsts::JSON_CONSTRAINT) do
      resources :institutions, :collections, :digital_objects, only: [:index, :create]

      resources :institutions, :collections, :digital_objects,
                only: [:show, :update],
                constraints: Curator::Middleware::ArkOrIdConstraint.new

      resources :institutions,
                only: [],
                param: :id,
                constraints: Curator::Middleware::ArkOrIdConstraint.new do
                  member do
                    scope module: :metastreams do
                      concerns :administratable, only: [:show, :update], as: 'institution_administrative', metastreamable_type: 'Institution'
                      concerns :workflowable, only: [:show, :update], as: 'institution_workflow', metastreamable_type: 'Institution'
                    end
                  end
                end

      resources :collections,
                only: [],
                param: :id,
                constraints: Curator::Middleware::ArkOrIdConstraint.new do
                  member do
                    scope module: :metastreams do
                      concerns :administratable, only: [:show, :update], as: 'collection_administrative', metastreamable_type: 'Collection'
                      concerns :workflowable, only: [:show, :update], as: 'collection_workflow', metastreamable_type: 'Collection'
                    end
                  end
                end

      resources :digital_objects,
                param: :id,
                only: [],
                constraints: Curator::Middleware::ArkOrIdConstraint.new do
                  member do
                    scope module: :metastreams do
                      concerns :administratable, only: [:show, :update], as: 'digital_object_administrative', metastreamable_type: 'DigitalObject'
                      concerns :descriptable, only: [:show, :update], as: 'digital_object_descriptive', metastreamable_type: 'DigitalObject'
                      concerns :workflowable, only: [:show, :update], as: 'digital_object_workflow', metastreamable_type: 'DigitalObject'
                    end
                  end
                end

      namespace :controlled_terms, constraints: Curator::Middleware::RouteConsts::JSON_CONSTRAINT do
        resources :authorities, only: [:index]

        resources :nomenclatures,
                  only: [:show, :update],
                  constraints: Curator::Middleware::StiTypesConstraint.new(Curator::Middleware::RouteConsts::NOMENCLATURE_TYPES),
                  path: '/:type'
      end

      namespace :filestreams, constraints: Curator::Middleware::RouteConsts::JSON_CONSTRAINT do
        constraints(Curator::Middleware::StiTypesConstraint.new(Curator::Middleware::RouteConsts::FILE_SET_TYPES)) do
          resources :file_sets, only: [:index, :create], path: '/:type'

          resources :file_sets,
                    only: [:show, :update],
                    constraints: Curator::Middleware::ArkOrIdConstraint.new,
                    path: '/:type'

          resources :file_sets,
                    only: [],
                    param: :id,
                    path: '/:type',
                    constraints: Curator::Middleware::ArkOrIdConstraint.new do
                      member do
                        concerns :administratable, only: [:show, :update], as: 'file_set_administrative', metastreamable_type: 'Filestreams::FileSet', controller: '/curator/metastreams/administratives'
                        concerns :workflowable, only: [:show], as: 'file_set_workflow', metastreamable_type: 'Filestreams::FileSet', controller: '/curator/metastreams/workflows'
                      end
                    end
        end
      end
    end

    match '*path' => 'application#not_found', via: [:all]
  end
end
