# frozen_string_literal: true

module ApplicationHelper
  def librarian?
    Current.user&.librarian?
  end
end
