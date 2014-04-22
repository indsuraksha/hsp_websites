class ToneLibraryPatch < ActiveRecord::Base
  belongs_to :tone_library_song, touch: true
  belongs_to :product, touch: true
  has_attached_file :patch,
    s3_headers: lambda { |f| 
      {"Content-Type" => f.mime_type} 
    }, 
    storage: :s3,
    bucket: Rails.configuration.aws[:bucket],
    s3_credentials: Rails.configuration.aws,
    s3_host_alias: S3_CLOUDFRONT,
    url: ':s3_domain_url',
    path: ":class/:attachment/:id_:timestamp/:basename_:style.:extension"

  validates_attachment :patch, presence: true
  do_not_validate_attachment_file_type :patch

  validates :tone_library_song_id, presence: true
  validates :product_id, presence: true

  def extension
  	patch_file_name.to_s.split(".").last.to_s
  end

  # Using the mime type to force iPB-10 files to work with Nexus
  # from the site.
  def mime_type
  	(extension.to_s.match(/ipb/)) ? 'application/ipb-10' : 'application/octet-stream'
  end
end
