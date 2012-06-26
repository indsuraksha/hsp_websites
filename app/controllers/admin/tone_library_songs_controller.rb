class Admin::ToneLibrarySongsController < AdminController
  load_and_authorize_resource
  # GET /admin/tone_library_songs
  # GET /admin/tone_library_songs.xml
  def index
    @tone_library_songs = @tone_library_songs.order("artist_name, title")
    respond_to do |format|
      format.html { render_template } # index.html.erb
      format.xml  { render :xml => @tone_library_songs }
    end
  end

  # GET /admin/tone_library_songs/1
  # GET /admin/tone_library_songs/1.xml
  def show
    @tone_library_patch = ToneLibraryPatch.new(:tone_library_song => @tone_library_song)
    respond_to do |format|
      format.html { render_template } # show.html.erb
      format.xml  { render :xml => @tone_library_song }
    end
  end

  # GET /admin/tone_library_songs/new
  # GET /admin/tone_library_songs/new.xml
  def new
    respond_to do |format|
      format.html { render_template } # new.html.erb
      format.xml  { render :xml => @tone_library_song }
    end
  end

  # GET /admin/tone_library_songs/1/edit
  def edit
  end

  # POST /admin/tone_library_songs
  # POST /admin/tone_library_songs.xml
  def create
    respond_to do |format|
      if @tone_library_song.save
        format.html { redirect_to([:admin, @tone_library_song], :notice => 'Tone library song was successfully created.') }
        format.xml  { render :xml => @tone_library_song, :status => :created, :location => @tone_library_song }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @tone_library_song.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /admin/tone_library_songs/1
  # PUT /admin/tone_library_songs/1.xml
  def update
    respond_to do |format|
      if @tone_library_song.update_attributes(params[:tone_library_song])
        format.html { redirect_to([:admin, @tone_library_song], :notice => 'Tone library song was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tone_library_song.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/tone_library_songs/1
  # DELETE /admin/tone_library_songs/1.xml
  def destroy
    @tone_library_song.destroy
    respond_to do |format|
      format.html { redirect_to(admin_tone_library_songs_url) }
      format.xml  { head :ok }
    end
  end
end
