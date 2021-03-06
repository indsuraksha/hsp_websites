class SystemConfigurationOptionValue < ActiveRecord::Base
  belongs_to :system_configuration_option
  belongs_to :system_option_value

  validates :system_configuration_option, presence: true
  validates :system_option_value, presence: true

  def recipients
    if system_option_value.send_mail_to.present?
      @recipients ||= system_option_value.send_mail_to.split(/\s\,/)
    end
  end

end
