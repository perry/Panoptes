class Api::V1::SubjectsController < Api::ApiController
  include Versioned

  doorkeeper_for :update, :create, :destroy, :version, :versions,
                 scopes: [:subject]
  resource_actions :default
  schema_type :json_schema

  alias_method :subject, :controlled_resource

  def index
    case params[:sort]
    when 'cellect'
      render json_api: SubjectSerializer.page(params, selector.cellect_subjects)
    when 'queued'
      render json_api: SubjectSerializer.page(params, selector.queued_subjects)
    else
      super
    end
  end

  private

  def context
    case action_name
    when "update", "create"
      { post_urls: true }
    else
      { }
    end
  end

  def build_resource_for_create(create_params)
    create_params[:locations] = add_subject_path(create_params[:locations],
                                                 create_params[:links][:project])
    create_params[:upload_user_id] = api_user.id
    subject = super(create_params)
    subject
  end

  def build_update_hash(update_params, id)
    if update_params.has_key? :locations
      update_params[:locations] = add_subject_path(update_params[:locations],
                                                   controlled_resource.project.id)
    end
    super(update_params, id)
  end

  def selector
    @selector ||= SubjectSelector.new(api_user,
                                      params,
                                      controlled_resources,
                                      cellect_session)
  end

  def add_subject_path(locations, project_id)
    locations.map.with_index do |mime, idx|
      mime.split(',').reduce({}) do |location, mime|
        location[mime] = subject_path(idx, mime, project_id)
        location
      end
    end
  end

  def subject_path(location, mime, project_id)
    extension = MIME::Types[mime].first.extensions.first
    "#{::Panoptes.bucket_path}/#{project_id}/#{location}/#{SecureRandom.uuid}.#{extension}"
  end
end
