require 'sinatra'
require 'json'
require 'yaml'
require 'logger'

require_relative './ethereum_service_helper'

class ServiceBrokerApp < Sinatra::Base
  attr_reader :ethereum_metadata_service

  helpers do
    def protected!
      return if authorized?
      headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
      halt 401, "Not authorized\n"
    end

    def authorized?
      @auth ||=  Rack::Auth::Basic::Request.new(request.env)
      credentials = app_settings.fetch('basic_auth')
      @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == [credentials.fetch('username'), credentials.fetch('password')]
    end
  end

  configure do
    set :logging, Logger::DEBUG
  end

  #
  # declare the routes used by the app

  # CATALOG
  get '/v2/catalog' do
    protected!

    content_type :json

    app_settings.fetch('catalog').to_json
  end

  # PROVISION
  put '/v2/service_instances/:id' do |id|
    protected!

    content_type :json

    status 201
    {
        dashboard_url: ''
    }.to_json

    # do nothing
  end

  # BIND
  put '/v2/service_instances/:instance_id/service_bindings/:id' do |instance_id, binding_id|
    protected!

    content_type :json
    status 201

    if ethereum_metadata_service.bootnode
      {
          credentials: {
              bootnode: ethereum_metadata_service.bootnode,
              nodes: ethereum_metadata_service.nodes,
          }
      }.to_json
    else
      {}.to_json
    end

    # create app user account
  end

  # UNBIND
  delete '/v2/service_instances/:instance_id/service_bindings/:id' do |instance_id, binding_id|
    protected!

    content_type :json
    status 200
    {}.to_json

    # do nothing
  end

  # UNPROVISION
  delete '/v2/service_instances/:instance_id' do |_instance_id|
    protected!

    content_type :json
    status 200
    {}.to_json


    # do nothing
  end

  post '/log-collector' do
    status 201

    request.body.rewind
    ethereum_metadata_service.parse_log(request.body.read)
    ethereum_metadata_service.nodes.to_json
  end

  get '/log-collector/bootnodes' do
    content_type :json

    status 200
    ethereum_metadata_service.bootnode.to_json
  end

  get '/log-collector/nodes' do
    content_type :json

    status 200
    ethereum_metadata_service.nodes.to_json
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

  def ethereum_metadata_service
    self.class.class_ethereum_metadata_service
  end

  def self.class_ethereum_metadata_service
    @@ethereum_metadata_service ||= EthereumServiceHelper.new
  end

end
