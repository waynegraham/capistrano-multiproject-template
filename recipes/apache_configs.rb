namespace :apache do

  set :stage_prefix, '' unless exists(:stage_prefix)
  set :domain, '' unless exists(:domain)

  def compose_url
    set :server_name, "#{stage_prefix}.#{application}.#{domain}"
  end

  desc "Generate apache virtual host configuration from template"
  task :generate_config, :roles => :app do
    require 'erb'

    compose_url
    template = ERB.new(File.read('templates/apache.conf.erb'))
    result = template.resuld(binding)
    put(result, "#{shared_path}/#{application}.conf")
  end
end
