require "fast_gettext"
require "gettext_i18n_rails"
require "fog"
require "fog/fogdocker"
require "wicked"

module ForemanDocker
  #Inherit from the Rails module of the parent app (Foreman), not the plugin.
  #Thus, inherits from ::Rails::Engine and not from Rails::Engine
  class Engine < ::Rails::Engine
    initializer "foreman_docker.load_app_instance_data" do |app|
      app.config.paths['db/migrate'] += ForemanDocker::Engine.paths['db/migrate'].existent
    end

    initializer "foreman_docker.register_gettext", :after => :load_config_initializers do |app|
      locale_dir = File.join(File.expand_path("../../..", __FILE__), "locale")
      locale_domain = "foreman_docker"

      Foreman::Gettext::Support.add_text_domain locale_domain, locale_dir
    end

    initializer "foreman_docker.register_plugin", :after=> :finisher_hook do |app|
      Foreman::Plugin.register :foreman_docker do
        requires_foreman "> 1.4"
        compute_resource ForemanDocker::Docker

        sub_menu :top_menu, :containers_menu, :caption=> N_('Containers'), :after=> :monitor_menu do
          menu :top_menu, :containers,    :caption => N_('All containers'), :url_hash => { :controller => :containers, :action => :index }
          menu :top_menu, :new_container, :caption => N_('New container'),  :url_hash => { :controller => :containers, :action => :new }
        end
      end

    end

  end

  # extend fog docker server and image models.
  require "fog/fogdocker/models/compute/server"
  require "fog/fogdocker/models/compute/image"
  require File.expand_path("../../../app/models/concerns/fog_extensions/fogdocker/server", __FILE__)
  require File.expand_path("../../../app/models/concerns/fog_extensions/fogdocker/image", __FILE__)
  Fog::Compute::Fogdocker::Server.send(:include, ::FogExtensions::Fogdocker::Server)
  Fog::Compute::Fogdocker::Image.send(:include, ::FogExtensions::Fogdocker::Image)
end