# frozen_string_literal: true

module MatildaCore

  # Engine.
  class Engine < ::Rails::Engine

    isolate_namespace MatildaCore

    # Imposto le voci della sidebar utilizzando la configurazione dell'engine.
    initializer 'matilda_core.add_sidebar_items', after: :add_routing_paths do |_app|
      Rails.application.reload_routes!

      MatildaCore.config.add_sidebar_item(
        'matilda_core.groups',
        label: 'locale.groups',
        url: MatildaCore::Engine.routes.url_helpers.groups_index_view_path,
        icon: 'fas fa-tachometer-alt',
        index: 10
      )
      MatildaCore.config.add_sidebar_item(
        'matilda_core.memberships',
        label: 'locale.users',
        url: MatildaCore::Engine.routes.url_helpers.app_memberships_index_view_path,
        icon: 'fas fa-users',
        permission: 'matilda_core.memberships',
        index: 20
      )
    end

    # Imposto i permessi degli utenti.
    initializer 'matilda_core.add_memberships_permissions' do |_app|
      MatildaCore.config.add_memberships_permission(
        'matilda_core.memberships',
        label: 'Possibilità di gestire gli utenti e i relativi permessi',
        index: 0,
        group: 'Gestione utenti'
      )
    end

  end

end
