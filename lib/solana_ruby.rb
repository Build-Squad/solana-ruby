# frozen_string_literal: true

Dir[File.join(__dir__, 'solana_ruby', '*.rb')].each { |file| require file }
# Dir["solana_ruby/*.rb"].each { |f| require_relative f.delete(".rb") }
require 'pry'
module SolanaRuby
  class Error < StandardError; end
end
