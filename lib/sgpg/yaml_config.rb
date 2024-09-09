# frozen_string_literal: true

require 'yaml'

module Sgpg
  # Manage the configuration file
  class YamlConfig
    attr_reader :config

    def initialize
      @file_dir = "#{ENV['HOME']}/.config/sgpg"
      @filename = 'config.yml'
      @full_path = "#{@file_dir}/#{@filename}"
      @config = {
        disk: '',
        keyname: '',
        crypted: false
      }
    end

    def load
      if !Dir.exist?(@file_dir) || !File.exist?(@full_path)
        create_dir
        write_config unless File.exist?(@full_path)
      else
        loading
      end
    end

    def to_s
      "Using disk >> #{@config[:disk]}, key >> #{@config[:keyname]}"
    end

    def save(opts)
      puts "saving options #{opts}"
      @config[:disk] = opts[:disk] if opts[:disk]
      @config[:keyname] = opts[:keyname] if opts[:keyname]
      @config[:crypted] = opts[:crypted] if opts[:crypted]
      puts "current #{config}"
      write_config
    end

    protected

    def loading
      puts "Loading #{@full_path}..."
      @config = YAML.load_file(@full_path)
    rescue Psych::SyntaxError => e
      puts "YAML syntax error: #{e.message}"
    rescue Errno::ENOENT
      puts "File not found: #{@full_path}"
    end

    private

    def create_dir
      return if Dir.exist? @file_dir

      puts "Creating #{@file_dir}..."
      Dir.mkdir @file_dir
    end

    def write_config
      in_yaml = YAML.dump(@config)
      File.write(@full_path, in_yaml)
    end
  end
end
