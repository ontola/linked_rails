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

  def home_menu_item
    menu_item(
      :home,
      label: I18n.t('menus.home'),
      href: LinkedRails.iri,
      image: 'fa-home'
    )
  end

  def navigation_links
    [home_menu_item]
  end

  def user_menu_items
    return [] if user_context.guest?

    [
      otp_menu_item,
      sign_out_menu_item
    ]
  end

  def otp_menu_item
    if user_context.otp_active?
      delete_otp_menu_item
    else
      add_otp_menu_item
    end
  end

  def delete_otp_menu_item
    menu_item(
      :otp,
      label: I18n.t('menus.delete_otp'),
      href: LinkedRails.iri(path: 'u/otp_secret/delete')
    )
  end

  def add_otp_menu_item
    menu_item(
      :otp,
      label: I18n.t('menus.add_otp'),
      href: LinkedRails.iri(path: 'u/otp_secret/new')
    )
  end

  def sign_out_menu_item
    menu_item(
      :signout,
      action: Vocab.libro['actions/logout'],
      label: I18n.t('menus.sign_out'),
      href: LinkedRails.iri(path: :logout)
    )
  end
end
