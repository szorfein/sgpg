# frozen_string_literal: true

# lib/cryptsetup.rb

module Sgpg
  # Control program cryptsetup
  class Cryptsetup
    class InvalidDisk < StandardError; end

    def initialize(disk)
      raise "No disk #{disk} specified..." unless disk

      @disk = disk
      @mapname = 'sgpg'
    end

    # Tails Linux make persistent volume on second partition 'disk_name'2
    def open
      check_disk

      case Helper.auth?
      when :root
        open_with
      when :doas
        open_with 'doas'
      when :sudo
        open_with 'sudo'
      end
    end

    def close
      case Helper.auth?
      when :root
        close_with
      when :doas
        close_with 'doas'
      when :sudo
        close_with 'sudo'
      end
    end

    protected

    def check_disk
      raise InvalidDisk, "Disk #{@disk} not exist or not plugged." unless
        File.exist?(@disk)
    end

    private

    def open_with(prefix = nil)
      if prefix
        puts "Opening disk #{@disk} with #{prefix}..."
      else
        puts "Opening disk #{@disk}..."
      end

      raise "Unable to open #{@disk} #{prefix}" unless
        system(prefix, 'cryptsetup', 'open', '--type', 'luks', @disk, @mapname)
    end

    def close_with(prefix = nil)
      puts "Closing disk #{@disk}..."

      raise "Closing disk #{@disk} failed" unless
        system(prefix, 'cryptsetup', 'close', @mapname)
    end
  end
end
