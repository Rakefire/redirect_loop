Rails.application.routes.draw do
  match 'test/loop', via: [:get, :post]
end
