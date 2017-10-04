require 'sinatra'
require 'json'
require 'yaml'

class ServiceBrokerApp < Sinatra::Base
  # configure the Sinatra app
  use Rack::Auth::Basic do |username, password|
    credentials = app_settings.fetch('basic_auth')
    (username == credentials.fetch('username')) && (password == credentials.fetch('password'))
  end

  # declare the routes used by the app

  # CATALOG
  get '/v2/catalog' do
    content_type :json

    app_settings.fetch('catalog').to_json
  end

  # PROVISION
  put '/v2/service_instances/:id' do |id|
    content_type :json

    status 201
    {
        dashboard_url: ''
    }.to_json

    # do nothing
  end

  # BIND
  put '/v2/service_instances/:instance_id/service_bindings/:id' do |instance_id, binding_id|
    content_type :json
    status 201
    {
        credentials: { uri: ''}
    }.to_json

    # create app user account
  end

  # UNBIND
  delete '/v2/service_instances/:instance_id/service_bindings/:id' do |instance_id, binding_id|
    content_type :json
    status 200
    {}.to_json

    # do nothing
  end

  # UNPROVISION
  delete '/v2/service_instances/:instance_id' do |_instance_id|
    content_type :json
    status 200
    {}.to_json


    # do nothing
  end

  # helper methods
  private

  def self.app_settings
    @app_settings ||= begin
      settings_filename = defined?(SETTINGS_FILENAME) ? SETTINGS_FILENAME : 'config/settings.yml'
      YAML.load_file(settings_filename)
    end
  end

  def app_settings
    self.class.app_settings
  end

  def github_service
    @github_service ||= EthereumServiceHelper.new
  end
end
