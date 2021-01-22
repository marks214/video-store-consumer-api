class VideosController < ApplicationController
  before_action :require_video, only: [:show]

  def index
    data = if params[:query]
      VideoWrapper.search(params[:query])
    else
      Video.all
           end

    render status: :ok, json: data
  end

  def show
    render(
      status: :ok,
      json: @video.as_json(
        only: %i[title overview release_date inventory],
        methods: [:available_inventory]
        )
      )
  end

  def create
    video = Video.new(video_params)
    result = video.save
    if result
      render(
        status: :ok,
        json: result.as_json(
          only: %i[title overview release_date inventory image_url external_id],
          methods: [:available_inventory]
        )
      )
    else
      render status: :bad_request, json: {
        errors: video.errors.messages
      }
    end
  end

  private

  def require_video
    @video = Video.find_by(title: params[:title])
    unless @video
      render status: :not_found, json: { errors: { title: ["No video with title #{params['title']}"] } }
    end
  end

  def video_params
    return params.permit(:title, :release_date, :overview, :inventory, :image_url, :external_id)
  end
end
