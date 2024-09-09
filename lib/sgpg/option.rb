# frozen_string_literal: true

# lib/option.rb

module Sgpg
  MOUNTPOINT = '/mnt/sgpg' # Better permission than /media/sgpg
  KEYDIR = "#{MOUNTPOINT}/Persistent" # Tails Linux Comptatible
  WORKDIR = '/tmp/sgpg'
end
