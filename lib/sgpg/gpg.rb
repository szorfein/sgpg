# frozen_string_literal: true

module Sgpg
  # Interact with GnuPG from unix
  class Gpg
    # Code here
    def initialize(keyname)
      @keyname = keyname
      puts "using key #{@keyname}"
    end

    def delete_keys
      return unless system('gpg', '-k', @keyname)

      puts "Found older key name #{@keyname}, need to be deleted to import new..."
      system('gpg', '--delete-secret-keys', @keyname)
      system('gpg', '--delete-keys', @keyname)
    end

    def edit_key
      raise "No key #{@keyname} found." unless system('gpg', '-k', @keyname)

      system('gpg', '--edit-key', @keyname)
    end

    def export_secret_keys(pathdir)
      raise "No dir #{pathdir} exist" unless File.exist?(pathdir)

      output = "#{pathdir}/#{@keyname}"
      system("gpg --armor --export-secret-keys #{@keyname} > #{output}-secret.key")
      system("gpg --armor --export #{@keyname} > #{output}-public.key")
    end

    def export_subkey(pathdir)
      raise "No dir #{pathdir} exist" unless File.exist?(pathdir)

      system("gpg --export-secret-subkeys #{@keyname} > #{pathdir}/subkeys")
    end

    def import_lesser_keys
      keypath = "#{Sgpg::WORKDIR}/subkeys"
      raise "No key #{keypath} exist" unless File.exist?(keypath)

      system('gpg', '--import', keypath)
    end
  end
end
