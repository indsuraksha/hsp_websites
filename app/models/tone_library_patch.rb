class ToneLibraryPatch < ActiveRecord::Base
  belongs_to :tone_library_song, touch: true
  belongs_to :product, touch: true
  has_attached_file :patch,
    path: ":rails_root/public/system/:attachment/:id_:timestamp/:basename_:style.:extension",
    url: "/system/:attachment/:id_:timestamp/:basename_:style.:extension"

  validates_presence_of :tone_library_song_id, :product_id

  def extension
  	patch_file_name.split(".").last.to_s
  end

  # Using the mime type to force iPB-10 files to work with Nexus
  # from the site.
  def mime_type
  	(extension.to_s.match(/ipb/)) ? 'application/ipb-10' : 'application/octet-stream'
  end
end
