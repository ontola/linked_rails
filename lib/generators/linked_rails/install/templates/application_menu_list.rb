# frozen_string_literal: true

class ApplicationMenuList < LinkedRails::Menus::List
  include LinkedRails::Helpers::OntolaActionsHelper

  private

  def copy_menu_item(url)
    menu_item(
      :copy,
      action: ontola_copy_action(url),
      item_type: 'copy',
      image: 'fa-clipboard',
      href: url
    )
  end

  def delete_menu_item(resource)
    iri = resource.iri.dup
    iri.path += '/delete'

    menu_item(
      :destroy,
      action: ontola_dialog_action(iri),
      href: iri,
      image: 'fa-close',
      policy: :destroy?
    )
  end

  def edit_menu_item(resource)
    iri = resource.iri.dup
    iri.path += '/edit'

    menu_item(
      :edit,
      image: 'fa-edit',
      href: iri,
      policy: :update?
    )
  end
end
