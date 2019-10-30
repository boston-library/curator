# frozen_string_literal: true

Curator::Engine.routes.draw do
  resources :digital_objects
  resources :collections
  resources :institutions

  #TODO Make Below only avaialable to admins

  namespace :controlled_terms do
    Curator::ControlledTerms.nomenclature_types.each do |nom_type|
      resources nom_type.underscore.pluralize.to_sym, only: [:index, :show, :update, :create], controller: 'nomenclatures', type: nom_type
    end
    resources :authorities
  end
end
