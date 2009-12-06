require 'yaml'

class Hash
  def stringify!
    each do |key, value|
      delete(key)
      value.class == Hash ? store(key.to_s, value.stringify!) : store(key.to_s, value)
    end
  end

  def skip_nils!
    each do |key, value|
      value == nil ? delete(key) : (value.class == Hash ? value.skip_nils! : value)
    end
  end

  def rmerge!(other_hash)
    merge!(other_hash) do |key, oldval, newval|
      oldval.class == self.class ? oldval.rmerge!(newval) : newval
    end
  end

  def to_yml
    YAML.dump self
  end
end

module Rap
  class Tasks < Thor
    namespace :rap

    desc "about NAME", "show rap info"
    def about(name = nil)
      puts "Rap v.0.0.6"
      puts load_config(name).to_yml
    end

    desc "list", "list local domains"
    def list
      config = load_config
      path = "#{config.apache_root}/#{config.apache_available}/*"
      Dir.glob(path).each {|file| puts file.split('/').last}
    end

    desc "edit NAME", "edit domain configuration"
    def edit(name = nil)
      config = load_config(name)
      path = "#{config.apache_root}/#{config.apache_available}/#{config.site_name}"
      if File.exists?(path) 
        system "sudo vim #{path}"
      else
        puts "Domain configuration file for #{config.site_name} don't found: #{path}"
      end
    end

    desc "reload", "reload apache2 current configuration"
    def reload
      system "sudo #{config.apache_script} reload"
    end

    desc "restart", "restart apache2 current configuration"
    def restart
      system "sudo #{config.apache_script} restart"
    end

    private
    def load_config(name = nil)
      default = <<yaml
apache:
  root: '/etc/apache2'
  available: 'sites-available'
  script: '/etc/init.d/apache2'
yaml
      apache = YAML.load(default)
      local = File.exist?('rap.yml') ? YAML.load(File.read('rap.yml')) : {}
      params = name ? {:site => {:name => name}} : {}
      Config.new(apache, local, params)
    end

  end

  class Config
    def initialize(*args)
      @config = {}
      args.each  {|arg| @config.rmerge!(arg.skip_nils!) }
      @config.stringify!
    end

    def method_missing(name)
      value = @config
      keys = name.to_s.split('_')
      keys.each {|key| value = value[key] if value }
      return value if value
      raise NoMethodError.new(name)
    end

    def to_yml
      @config.to_yml
    end
  end

 
end
