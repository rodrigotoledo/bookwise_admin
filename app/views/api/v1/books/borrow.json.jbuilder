# frozen_string_literal: true

json.id @borrowing.id
json.borrowed_at @borrowing.borrowed_at
json.due_at @borrowing.due_at
json.returned_at @borrowing.returned_at
json.user do
  json.extract! @borrowing.user, :id, :email_address
end
