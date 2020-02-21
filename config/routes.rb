# frozen_string_literal: true

Curator::Engine.routes.draw do
  JSON_CONSTRAINT = ->(request) { request.format.symbol == :json }
  NOMENCLATURE_TYPES = Curator.controlled_terms.nomenclature_types.map(&:downcase)
  FILE_SET_TYPES = Curator.filestreams.file_set_types.map(&:downcase)

  concern :administratable do
    resource :administrative, only: [:update, :show], module: :metatstreams
  end

  concern :descriptable do
    resource :descriptive, only: [:update, :show], module: :metastreams
  end

  concern :workflowable do
    resource :workflow, only: [:update, :show], module: :metatstreams
  end

  scope :api, defaults: { format: :json } do
    constraints(JSON_CONSTRAINT) do
      root to: Curator::Middleware::RootApp.new

      resources :collections, only: [:index, :create]
      resources :digital_objects, only: [:index, :create]
      resources :institutions, only: [:index, :create]

      resources :digital_objects,
                only: [:show, :update],
                concerns: [:administratable, :descriptable, :workflowable],
                constraints: Curator::Middleware::ArkOrIdConstraint.new

      resources :collections,
                only: [:show, :update],
                concerns: [:administratable, :workflowable],
                constraints: Curator::Middleware::ArkOrIdConstraint.new

      resources :institutions,
                only: [:show, :update],
                concerns: [:administratable, :workflowable],
                constraints: Curator::Middleware::ArkOrIdConstraint.new

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
                    concerns: [:administratable, :workflowable],
                    constraints: Curator::Middleware::ArkOrIdConstraint.new,
                    path: '/:type'
        end
      end
    end
  end
end
