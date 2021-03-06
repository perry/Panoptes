module Api
  include ApiErrors

  class ApiController < ApplicationController
    include JsonApiController
    include RoleControl::RoledController

    API_ACCEPTED_CONTENT_TYPES = ['application/json',
                                  'application/vnd.api+json']
    API_ALLOWED_METHOD_OVERRIDES = { 'PATCH' => 'application/patch+json' }

    rescue_from ActiveRecord::RecordNotFound,            with: :not_found
    rescue_from ActiveRecord::RecordInvalid,             with: :invalid_record
    rescue_from Api::NotLoggedIn,                        with: :not_authenticated
    rescue_from Api::UnauthorizedTokenError,             with: :not_authenticated
    rescue_from Api::UnsupportedMediaType,               with: :unsupported_media_type
    rescue_from RoleControl::AccessDenied,               with: :not_found
    rescue_from JsonApiController::PreconditionNotPresent, with: :precondition_required
    rescue_from JsonApiController::PreconditionFailed,   with: :precondition_failed
    rescue_from ActiveRecord::StaleObjectError,          with: :conflict
    rescue_from Api::PatchResourceError,
                Api::UserSeenSubjectIdError,
                ActionController::UnpermittedParameters,
                ActionController::ParameterMissing,
                SubjectSelector::MissingParameter,
                Api::RolesExist,
                JsonSchema::ValidationError,
                JsonApiController::NotLinkable,
                RestPack::Serializer::InvalidInclude,    with: :unprocessable_entity

    prepend_before_action :require_login, only: [:create, :update, :destroy]
    prepend_before_action :ban_user, only: [:create, :update, :destroy]
    prepend_before_action ContentTypeFilter.new(*API_ACCEPTED_CONTENT_TYPES,
                                                API_ALLOWED_METHOD_OVERRIDES)

    skip_before_action :verify_authenticity_token

    def current_resource_owner
      if doorkeeper_token
        @current_resource_owner ||= User.find_by_id(doorkeeper_token.resource_owner_id)
      end
    end

    def api_user
      @api_user ||= ApiUser.new(current_resource_owner, admin: admin_flag?)
    end

    def current_languages
      param_langs  = [ params[:language] ]
      user_langs   = user_accept_languages
      header_langs = parse_http_accept_languages
      ( param_langs | user_langs | header_langs ).compact
    end

    alias_method :user_for_paper_trail, :current_resource_owner

    def user_accept_languages
      api_user.try(:languages) || []
    end

    def parse_http_accept_languages
      language_extractor = AcceptLanguageExtractor
                           .new(request.env['HTTP_ACCEPT_LANGUAGE'])

      language_extractor.parse_languages
    end

    def cellect_session
      session[:cellect_hosts] ||= {}
    end

    def request_ip
      request.remote_ip
    end

    def require_login
      unless api_user.logged_in?
        raise Api::NotLoggedIn.new("You must be logged in to access this resource.")
      end
    end

    def admin_flag?
      !!params[:admin]
    end

    def ban_user
      if api_user.banned?
        case action_name
        when "update"
          head :ok
        when "create"
          head :created
        when "destroy"
          head :no_content
        end
      end
    end
  end
end
