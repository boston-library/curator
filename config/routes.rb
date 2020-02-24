# frozen_string_literal: true

Curator::Engine.routes.draw do
  JSON_CONSTRAINT = ->(request) { request.format.symbol == :json }
  NOMENCLATURE_TYPES = Curator.controlled_terms.nomenclature_types.map(&:downcase)
  FILE_SET_TYPES = Curator.filestreams.file_set_types.map(&:downcase)

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
    match '*path' => 'application#method_not_allowed', via: [:delete]

    constraints(JSON_CONSTRAINT) do
      root to: Curator::Middleware::RootApp.new

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
                      concerns :administratable, only: [:show, :update], as: 'institution_administrative'
                      concerns :workflowable, only: [:show, :update], as: 'institution_workflow'
                    end
                  end
                end

      resources :collections,
                only: [],
                param: :id,
                constraints: Curator::Middleware::ArkOrIdConstraint.new do
                  member do
                    scope module: :metastreams do
                      concerns :administratable, only: [:show, :update], as: 'collection_administrative'
                      concerns :workflowable, only: [:show, :update], as: 'collection_workflow'
                    end
                  end
                end

      resources :digital_objects,
                param: :id,
                only: [],
                constraints: Curator::Middleware::ArkOrIdConstraint.new do
                  member do
                    scope module: :metastreams do
                      concerns :administratable, only: [:show, :update], as: 'digital_object_administrative'
                      concerns :descriptable, only: [:show, :update], as: 'digital_object_descriptive'
                      concerns :workflowable, only: [:show, :update], as: 'digital_object_workflow'
                    end
                  end
                end

      namespace :controlled_terms do
        resources :authorities, only: [:index, :show, :update, :create]

        resources :nomenclatures,
                  only: [:index, :show, :update, :create],
                  constraints: Curator::Middleware::StiTypesConstraint.new(NOMENCLATURE_TYPES),
                  path: '/:type'
      end

      namespace :filestreams, constraints: JSON_CONSTRAINT do
        constraints(Curator::Middleware::StiTypesConstraint.new(FILE_SET_TYPES)) do
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
                        concerns :administratable, only: [:show, :update], as: 'file_set_administrative', controller: '/curator/metastreams/administratives'
                        concerns :workflowable, only: [:show, :update], as: 'file_set_workflow', controller: '/curator/metastreams/workflows'
                      end
                    end
        end
      end
    end
  end
end
