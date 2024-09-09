# frozen_string_literal: true

# lib/mount.rb

require 'fileutils'

module Sgpg
  # (un)mount a device to a mountpoint
  class Mount
    # Argument 'disk' = full path of the disk.
    # e.g: /dev/mapper/sgpg for cryptsetup (See Sgpg::Cryptsetup) of just /dev/sdX
    def initialize(disk)
      @user = ENV['USER'] || 'root'
      @disk = disk
    end

    def open
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

    def open_with(prefix = '')
      prefix == '' ? create_with_ruby : create_with_system(prefix)

      raise "Unable to mount #{@disk}" unless
        system(prefix, 'mount', '-t', 'ext4', @disk, Sgpg::MOUNTPOINT)
    end

    def close_with(prefix = '')
      raise "Unable to umount #{@disk}" unless
        system(prefix, 'umount', Sgpg::MOUNTPOINT)
    end

    private

    def create_wiht_ruby
      FileUtils.mkdir_p Sgpg::MOUNTPOINT
      FileUtils.chown @user, @user, Sgpg::MOUNTPOINT, verbose: true
      FileUtils.chmod 0644, Sgpg::MOUNTPOINT, verbose: true
    end

    def create_with_system(prefix)
      system(prefix, 'mkdir', '-p', Sgpg::MOUNTPOINT)
      system(prefix, 'chown', "#{@user}:#{@user}", Sgpg::MOUNTPOINT)
      system(prefix, 'chmod', '0644', Sgpg::MOUNTPOINT)
    end
  end
end
