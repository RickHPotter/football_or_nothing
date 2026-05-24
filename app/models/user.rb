# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :careers, dependent: :destroy
  has_many :managers, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
