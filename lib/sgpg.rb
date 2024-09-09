# frozen_string_literal: true

require_relative 'sgpg/version'
require_relative 'sgpg/option'
require_relative 'sgpg/yaml_config'
require_relative 'sgpg/helper'
require_relative 'sgpg/cryptsetup'
require_relative 'sgpg/mount'
require_relative 'sgpg/gpg'
require_relative 'sgpg/archive'

# Manage your gpg key easyly
module Sgpg
  def self.open(disk, is_crypted = false)
    return if Dir.glob("#{Sgpg::MOUNTPOINT}/*").length >= 1

    puts "Open device #{disk}..."
    if is_crypted
      Cryptsetup.new(disk).open
      Mount.new('/dev/mapper/sgpg').open
    else
      Mount.new(disk).open
    end
  end

  def self.close(disk, is_crypted = false)
    if is_crypted
      Mount.new('/dev/mapper/sgpg').close
      Cryptsetup.new(disk).close
    else
      Mount.new(disk).close
    end
  end

  def self.list_keys(keyname)
    keys = Dir.glob("#{Sgpg::MOUNTPOINT}/Persistent/#{keyname}*.tar")
    puts "Listing keys for #{keyname}..."
    keys = Dir.glob("#{Sgpg::MOUNTPOINT}/Persistent/*.tar") if keys == [] || keys == ''
    puts keys
  end

  # argument 'suffix' = master or lesser
  def self.last_key(opts, suffix = 'master')
    Sgpg.open(opts[:disk], opts[:crypted])

    keys = Dir.glob("#{Sgpg::KEYDIR}/#{opts[:keyname]}*#{suffix}*.tar").sort
    raise 'No keys found' unless keys.length >= 1

    keys[0]
  end

  def self.clear_keys
    return unless Dir.glob("#{Sgpg::WORKDIR}/*.key").length >= 1

    print "Clearing keys located at #{Sgpg::WORKDIR}? (y/n) "
    choice = gets.chomp
    return unless choice.match(/^y|^Y/)

    puts "Clearing #{Sgpg::WORKDIR}..."
    system("shred -u #{Sgpg::WORKDIR}/*.key")
  end

  # Main logic here
  module Main
    # import and edit a gpg key from an archive (opts[:keypath])
    def self.edit_key(opts)
      Sgpg.open(opts[:disk], opts[:crypted])
      archive = Archive.new(opts[:keypath], opts[:keyname])
      archive.extract
      archive.import
      Sgpg.clear_keys
    end

    # export your real keys and create an archive (tar)
    def self.export_secret(opts)
      archive = Archive.new(opts[:keypath], opts[:keyname])
      archive.create_master_tar
      archive.move(Sgpg::KEYDIR)
      Sgpg.clear_keys
    end

    # create an unpriviliged gpg key (no change can be made)
    def self.lesser_keys(opts)
      archive = Archive.new(opts[:keypath], opts[:keyname])
      archive.create_lesser_tar
      archive.move(Sgpg::KEYDIR)
      Sgpg.clear_keys
    end
  end
end
