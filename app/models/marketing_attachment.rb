class MarketingAttachment < ActiveRecord::Base
  attr_accessible :marketing_file, :marketing_project_id, :marketing_task_id

  # belongs to either a project or a task
  belongs_to :marketing_project
  belongs_to :marketing_task

  has_attached_file :marketing_file, 
    storage: :s3,
    bucket: Rails.configuration.aws[:protected_bucket],
    s3_credentials: Rails.configuration.aws,
    url: ':s3_alias_url',
    path: ":class/:attachment/:id_:timestamp/:basename_:style.:extension",
    s3_host_alias: nil

  do_not_validate_attachment_file_type :marketing_file

  def project_or_task
  	(self.marketing_project_id.present?) ? self.marketing_project : self.marketing_task
  end

  def project_or_task=(p_or_t)
  	p_or_t.is_a?(MarketingProject) ? self.marketing_project_id = p_or_t.id : self.marketing_task_id = p_or_t.id
  end

end
