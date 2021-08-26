# frozen_string_literal: true

class AppMenuList < ApplicationMenuList
  has_menu :navigations,
           iri_base: '/menus',
           menus: -> { navigation_links }
  has_menu :user,
           menus: -> { user_menu_items }

  def iri_template
    @iri_template ||= URITemplate.new('/menus{#fragment}')
  end

  private

  def navigation_links
    items = []
    items << menu_item(
      :home,
      label: I18n.t('menus.home'),
      href: LinkedRails.iri,
      image: 'fa-home'
    )
    items
  end

  def user_menu_items
    return [] if user_context.guest?

    [user_menu_sign_out_item]
  end

  def user_menu_sign_out_item
    menu_item(
      :signout,
      action: Vocab.libro['actions/logout'],
      label: I18n.t('menus.sign_out'),
      href: LinkedRails.iri(path: :logout)
    )
  end
end
