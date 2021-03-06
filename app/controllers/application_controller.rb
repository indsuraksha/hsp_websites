class ApplicationController < ActionController::Base
  # before_filter :set_locale
  # before_filter :set_default_meta_tags
  before_filter :respond_to_htm
  before_filter :configure_permitted_parameters, if: :devise_controller?
  before_filter :ensure_locale_for_site, except: [:locale_root, :default_locale, :locale_selector]
  before_filter :catch_criminals
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  layout :set_layout

  unless config.consider_all_requests_local || Rails.env.development?
    # rescue_from Exception, with: :render_error
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
    rescue_from ActionController::RoutingError, with: :render_not_found
    rescue_from ActionController::UnknownController, with: :render_not_found
    # customize these as much as you want, ie, different for every error or all the same
    rescue_from ::AbstractController::ActionNotFound, with: :render_not_found
  end

  # This method is getting complicated...It chooses the appropriate layout file based on
  # several criteria: whether or not this is a devise (user login) controller, whether or
  # not the website's brand has a custom layout (usually should), etc., whether or not
  # the 'website' object exists (if not, this is the toolkit)...
  #
  def set_layout
    template = 'application'
    if (website && website.folder)
      controller_brand_specific = "#{website.folder}/layouts/#{controller_path}"
      brand_specific = "#{website.folder}/layouts/application"
      homepage = "#{website.folder}/layouts/home"
      if devise_controller? && resource_name == :artist
        artist_brand_specific = "#{website.folder}/layouts/artists"
        if File.exists?(Rails.root.join("app", "views", "#{artist_brand_specific}.html.erb"))
          template = artist_brand_specific
        elsif File.exists?(Rails.root.join("app", "views", "layouts", "artists.html.erb"))
          template = "artists"
        elsif File.exists?(Rails.root.join("app", "views", "#{brand_specific}.html.erb"))
          template = brand_specific
        end
      elsif devise_controller? && resource_name == :user
        template = "admin"
      elsif controller_path == 'main' && action_name == 'index' && File.exists?(Rails.root.join("app", "views", "#{homepage}.html.erb"))
        template = homepage
      elsif File.exists?(Rails.root.join("app", "views", "#{controller_brand_specific}.html.erb"))
        template = controller_brand_specific
      elsif File.exists?(Rails.root.join("app", "views", "#{brand_specific}.html.erb"))
        template = brand_specific
      end
    elsif devise_controller? && resource_name == :user
      template = 'toolkit'
    end
    template
  end

  def render_template(options={})
    default_options = {controller: controller_path, action: action_name, layout: set_layout}
    options = default_options.merge options
    root_folder = (website && website.folder) ? "#{website.folder}/" : ''
    brand_specific = "#{root_folder}#{options[:controller]}/#{options[:action]}"
    generic = "#{options[:controller]}/#{options[:action]}"
    template = (File.exists?(Rails.root.join("app", "views", "#{brand_specific}.html.erb"))) ? brand_specific : generic
    logger.debug "------> Brand template: #{brand_specific}"
    logger.debug "----------------------------> Selected Template: #{template}"
    render template: template, layout: options[:layout]
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to admin_root_path, alert: exception.message
  end

  def set_default_meta_tags
    begin
      @page_description = website.value_for('default_meta_tag_description')
      @page_keywords = website.value_for("default_meta_tag_keywords")
    rescue
      @page_description = ""
      @page_keywords = ""
    end
  end

  def default_url_options(options={})
    if !!(request.host.to_s.match(/toolkit/i))
      {}
    else
      # {locale: website.locale}
      {locale: I18n.locale}
    end
  end

  # Utility function used to re-order an ActiveRecord list
  # Pass in a model name and a list of ordered objects
  def update_list_order(model, order)
    order.to_a.each_with_index do |item, pos|
      model.update(item, position:(pos + 1))
    end
  end

private

  # Used as a filter, redirects to the site's default locale if the site is not
  # configured for the locale passed by the user. I have a feeling this is going
  # to cause problems.
  #
  def ensure_locale_for_site
    if (website && website.folder) # (skips this filter for tooklit)
      if website.respond_to?(:list_of_available_locales)
        if params[:locale] && !params[:locale].to_s.match(/en/i) && l = website.list_of_available_locales
          unless l.include?(params[:locale].to_s)
            new_locale = website.default_locale || I18n.default_locale.to_s
            redirect_to locale_root_path(new_locale), status: :moved_permanently and return false
          end
        end
      else # this is not one of our configured sites
        site_not_found and return false
      end
    end
  end

  # Old sites often come through with *.htm extensions instead of *.html. Fix it.
  def respond_to_htm
    if params[:format] && params[:format] == 'htm'
      request.format = 'html'
    end
  end

  def catch_criminals
    begin
      x = request.env["HTTP_X_FORWARDED_FOR"].to_s
      i = request.remote_ip.to_s
      if x.match(/198\.91\.53/) || i.match(/198\.91\.53/) || x.match(/162\.211\.152/) || i.match(/162\.211\.152/)
        # send this idiot back to his own ISP
        redirect_to "http://www.securitymetrics.com#{ENV['REQUEST_URI']}" and return false
      end
    rescue
    end
  end

  def render_not_found(exception)
    error_page(404)
  end

  def render_error(exception)
    error_page(500)
  end

  def error_page(status=404)
    root_folder = (website && website.folder) ? "#{website.folder}/" : ''
    generic = "errors/#{status}"
    brand_specific = "#{root_folder}#{generic}"
    template = (File.exists?(Rails.root.join("app", "views", "#{brand_specific}.html.erb"))) ? brand_specific : generic
    render template: template, layout: false, status: status and return
  end

  def site_not_found
    error_page(404)
  end

  def website
    @website ||= Website.where(url: request.host).first
  end
  helper_method :website

  ######## START A WHOLE BUNCH OF YOUTUBE METHODS ##########
  #
  # These should probably go somewhere else like their own
  # module. So, do that someday. For now, they live here as
  # a replacement for the youtube_it gem which did not work
  # with Google's Youtube API v3. (v2 is being phased out
  # and started having problems on 4/20/2015.)
  #
  def youtube_client
    @youtube_client ||= Google::APIClient.new(key: ENV['GOOGLE_YOUTUBE_API_KEY'],
      authorization: nil,
      application_name: "HSP-WWW",
      application_version: "1.0.0"
    )
  end
  helper_method :youtube_client

  def youtube_api
    @youtube_api ||= youtube_client.discovered_api('youtube', 'v3')
  end
  helper_method :youtube_api

  def get_video(video_id)
    video_info = youtube_client.execute!(
      api_method: youtube_api.videos.list,
      parameters: {
        part: 'snippet',
        limit: 1,
        id: video_id
      }
    )
    JSON.parse(video_info.body)["items"].first["snippet"]
  end
  helper_method :get_video

  def get_default_playlist_id(youtube_user)
    channel_info = youtube_client.execute!(
      api_method: youtube_api.channels.list,
      parameters: {
        part: "contentDetails",
        forUsername: youtube_user
      }
    )
    JSON.parse(channel_info.body)["items"].first["contentDetails"]["relatedPlaylists"]["uploads"]
  end
  helper_method :get_default_playlist_id

  def get_user_playlists(youtube_user)
    channel_id = get_youtube_channel_id(youtube_user)
    info = youtube_client.execute!(
      api_method: youtube_api.playlists.list,
      parameters: {
        part: "snippet",
        channelId: channel_id
      }
    )
    JSON.parse(info.body)["items"]
  end

  def get_specific_playlists(playlist_ids)
    info = youtube_client.execute!(
      api_method: youtube_api.playlists.list,
      parameters: {
        part: "snippet",
        id: playlist_ids
      }
    )
    JSON.parse(info.body)["items"]
  end

  def get_youtube_channel_id(youtube_user)
    info = youtube_client.execute!(
      api_method: youtube_api.channels.list,
      parameters: {
        part: "id",
        forUsername: youtube_user
      }
    )
    JSON.parse(info.body)["items"].first["id"]
  end

  def get_video_list_data(youtube_list_id, options)
    limit = options[:limit] || 4
    info = youtube_client.execute!(
      api_method: youtube_api.playlist_items.list,
      parameters: {
        part: "snippet",
        maxResults: limit,
        playlistId: youtube_list_id
      }
    )
    JSON.parse(info.body)
  end
  helper_method :get_video_list_data

  ########## END YOUTUBE METHODS ##########

  # TODO: the big if statement below setting the locale needs to be refactored and will eventually include plenty of other countries
  def set_locale
    # This isn't really setting the locale, we're just trying
    # to be smart and pick the user's country for "Buy It Now"
    begin
      if params['geo']
        session['geo_country'] = params['geo']
        session['geo_usa'] = (params['geo'] == "US") ? true : false
      else
        unless session['geo_country']
          ip = request.env["HTTP_X_FORWARDED_FOR"] || request.remote_ip
          lookup = GeoKit::Geocoders::GeoPluginGeocoder.do_geocode(ip)
          # lookup = GeoKit::Geocoders::MultiGeocoder.do_geocode(ip)
          if lookup.success? || lookup.country_code
            session['geo_country'] = lookup.country_code
            session['geo_usa'] = lookup.is_us?
          else
            session['geo_country'] = "US"
            session['geo_usa'] = true
          end
        end
      end
    rescue
      session['geo_country'] = "US"
      session['geo_usa'] = true
    end
    # This is where we set the locale:
    if website.respond_to?(:list_of_available_locales)
      if params[:locale]
        I18n.locale = params[:locale]
      elsif !!(session['geo_usa']) && website.list_of_available_locales.include?("en-US")
        I18n.locale = 'en-US'
      elsif session['geo_country'] == "CN" && website.list_of_available_locales.include?("zh")
        I18n.locale = 'zh'
      elsif session['geo_country'] == "UK" && website.list_of_available_locales.include?("en")
        I18n.locale = 'en'
      elsif website.show_locales? && controller_path == "main" && action_name == "default_locale"
        locale_selector # otherwise the default locale is appended to the URL. #ugly
      else
        redirect_to root_path, status: :moved_permanently and return false
      end
    else
      site_not_found and return false
    end
  end

  # locale selector
  def locale_selector
    render_template(action: "locale_selector", layout: "locale")
  end

  def current_ability
    if current_user
      @current_ability ||= Ability.new(current_user)
    elsif current_toolkit_user
      @current_ability ||= Ability.new(current_toolkit_user)
    elsif current_artist
      @current_ability ||= Ability.new(current_artist)
    else
      @current_ability ||= Ability.new(User.new)
    end
  end

  def after_sign_in_path_for(resource)
    if resource.is_a?(Artist)
      artist_root_path
    elsif !!(request.host.match(/toolkit/i))
      root_path
    else
      admin_root_path
    end
  end

  def after_inactive_sign_up_path_for(resource)
    if resource.is_a?(Artist)
      new_artist_session_path
    elsif !!(request.host.match(/toolkit/i))
      "/users/sign_in?utm=mommy"
    else
      admin_root_path
    end
  end

  def restrict_api_access
    if Rails.env.production?
      authenticate_or_request_with_http_token do |token, options|
        ApiKey.exists?(access_token: token)
      end
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [
      :name,
      :email,
      :password,
      :password_confirmation,
      :invitation_code,
      :signup_type,
      :dealer,
      :distributor,
      :rep,
      :employee,
      :media,
      :artist,
      :clinician,
      :rso,
      :website,
      :artist_photo,
      :artist_product_photo,
      :bio,
      :main_instrument,
      :twitter,
      :artist_products,
      :job_title,
      :job_description,
      :phone_number,
      :account_number,
      :profile_pic])
    devise_parameter_sanitizer.permit(:account_update, keys: [
      :name,
      :email,
      :password,
      :password_confirmation,
      :current_password,
      :website,
      :artist_photo,
      :artist_product_photo,
      :bio,
      :main_instrument,
      :twitter,
      :artist_products,
      :job_title,
      :job_description,
      :phone_number,
      :account_number,
      :profile_pic])
  end

end
