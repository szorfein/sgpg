# frozen_string_literal: true

# lib/helper.rb

module Sgpg
  # Reusable functions for the program
  module Helper
    def self.auth?
      return :root if Process.uid == '0'
      return :doas if File.exist?('/bin/doas') || File.exist?('/sbin/doas')
      return :sudo if File.exist?('/bin/sudo') || File.exist?('/sbin/sudo')
    end
  end
end
