# System is used to configure IDX (and possibly other) systems. It consists of nested
# options and values. Selected values may trigger one or more SystemActions.
#
class System < ActiveRecord::Base
	has_many :system_options, -> { order(:position) }
	has_many :system_rules
	has_many :system_configurations
	has_many :system_components
	belongs_to :brand

	validates :brand, presence: true
	validates :name, presence: true, uniqueness: { scope: :brand_id }

	def options_with_possible_values
		option_ids = SystemOptionValue.where(id: self.system_options).pluck(:system_option_id).uniq
		system_options.where(id: option_ids)
	end

	def system_options_for_start_page
		@system_options_for_start_page ||= self.system_options.where(show_on_first_screen: true)
	end

	def parent_system_options
		@parent_system_options ||= system_options.where("parent_id IS NULL")
	end

	def parent_system_options_for_start_page
		@parent_system_options_for_start_page ||= parent_system_options.where(show_on_first_screen: true)
	end

  def enabled_system_rules
    system_rules.where(enabled: true)
  end

	# Blank system config
	def system_configuration(stage='configure', options={})
		@system_configuration ||= SystemConfiguration.new
		configured_option_ids = @system_configuration.system_configuration_options.map{|sco| sco.system_option_id}
    configured_options = Hash.new

		if options[:system_configuration_options_attributes]
			options[:system_configuration_options_attributes].each do |key, scoa|
				sco = SystemConfigurationOption.new(scoa)
        configured_options[sco.system_option_id] = sco
			end
		end

		options_to_build = case stage
			when 'start'
				system_options_for_start_page
			when 'parents'
				parent_system_options
			else
				system_options
		end

		options_to_build.each do |system_option|
      if configured_options[system_option.id]
        @system_configuration.system_configuration_options << configured_options[system_option.id]
      else
        new_option = SystemConfigurationOption.new(
					system_option: system_option,
					direct_value: system_option.default_direct_value,
					system_option_value_id: system_option.default_system_option_value_id
				)
				@system_configuration.system_configuration_options << new_option
      end
      configured_option_ids << system_option.id
		end

    # initialize all components with zero quantity
    SystemComponent.all.each do |component|
      @system_configuration.system_configuration_components << SystemConfigurationComponent.new(
        system_component: component,
        quantity: 0
      )
    end

		@system_configuration
	end

end
