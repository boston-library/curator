# frozen_string_literal: true

Curator::Engine.routes.draw do
  concern :administrative do
    resource :administrative, only: [:update, :show], module: :metatstreams
  end

  concern :descriptable do
    resource :descriptive, only: [:update, :show], module: :metastreams
  end

  concern :workflowable do
    resource :workflow, only: [:update, :show], module: :metatstreams
  end

  concern :typeable do |options|
    with_options constraints: Curator::Middleware::StiTypesConstraint.new(options.fetch(:types, [])) do
      get '*type' => :index
      get '*type/:id' => :show

      put '*type/:id' => :update
      patch '*type/:id' => :update

      post '*type' => :create
    end
  end

  scope :api, defaults: { format: :json } do
    constraints(format: /json/) do
      root to: Curator::Middleware::RootApp.new
      resources :digital_objects,
                only: [:index, :show, :update ,:create],
                concerns: [:administrative, :descriptable, :workflowable],
                constraints: Curator::Middleware::ArkOrIdConstraint.new

      resources :collections, only: [:index, :show, :update ,:create],
                 concerns: [:administrative, :workflowable],
                 constraints: Curator::Middleware::ArkOrIdConstraint.new

      resources :institutions,
                 only: [:index, :show, :update ,:create],
                 concerns: [:administrative, :workflowable],
                 constraints: Curator::Middleware::ArkOrIdConstraint.new
    end

    constraints(->(request) { awesome_print request.format; request.format.symbol != :json }) do
      root to: Curator::Middleware::RootApp.new
    end


    namespace :controlled_terms, constraints: { format: /json/ } do
      resources :authorities, only: [:index, :show, :update, :create]
      controller :nomenclatures do
        concerns :typeable, types: Curator.controlled_terms.nomenclature_types.map(&:downcase)
      end
    end

    namespace :filestreams, constraints: { format: /json/ } do
      controller :file_sets do
        constraints(Curator::Middleware::ArkOrIdConstraint.new) do
          concerns :typeable, types: Curator.filestreams.file_set_types.map(&:downcase)
        end
      end
    end
  end
end
