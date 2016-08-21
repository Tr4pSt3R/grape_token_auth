# frozen_string_literal: true
module GrapeTokenAuth
  module ApiHelpers
    def self.included(base)
      GrapeTokenAuth.configuration.mappings.keys.each do |scope, _resource_class|
        define_method("current_#{scope}") do
          authorizer_data.fetch_stored_resource(scope)
        end

        define_method("authenticate_#{scope}!") do
          token_authorizer = TokenAuthorizer.new(authorizer_data)
          resource = token_authorizer.authenticate_from_token(scope)
          fail Unauthorized unless resource
          env['rack.session'] ||= {}
          authorizer_data.store_resource(resource, scope)
          resource
        end
      end
    end

    def authorizer_data
      @authorizer_data ||= AuthorizerData.load_from_env_or_create(env)
    end

    def authenticated?(scope = :user)
      user_type = "current_#{scope}"
      return false unless respond_to?(user_type)
      !!send(user_type)
    end
  end
end
