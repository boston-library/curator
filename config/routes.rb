# frozen_string_literal: true

Curator::Engine.routes.draw do
  concern :administrative do
    resource :administrative, only: [:update], module: :metatstreams
  end

  concern :descriptable do
    resource :descriptive, only: [:update], module: :metastreams
  end

  concern :workflowable do
    resource :workflow, only: [:update], module: :metatstreams
  end


  scope :api, defaults: { format: :json } do
    constraints(-> (request) { [:json, :xml].include?(request.format) }) do
      resources :digital_objects, only: [:index, :show, :update ,:create], concerns: [:administrative, :descriptable, :workflowable]
      resources :collections, only: [:index, :show, :update ,:create], concerns: [:administrative, :workflowable]
      resources :institutions, only: [:index, :show, :update ,:create], concerns: [:administrative, :workflowable]


      namespace :controlled_terms do
        resources :authorities, only: [:index, :show, :update, :create]

        Curator.controlled_terms.nomenclature_types.each do |nom_type|
          resources nom_type.underscore.pluralize.to_sym, only: [:index, :show, :update, :create], controller: 'nomenclatures', type: nom_type
        end
      end

      namespace :filestreams do
      end
    end
  end
end
