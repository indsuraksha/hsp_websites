# SystemOption belongs to a master System. These options are arranged in a tree hierarchy. 
# Certain options may be hidden by default, only to appear if certain SystemRules are met.
# This is usually based on the selected SystemOptionValue for the given SystemOption.
#
class SystemOption < ActiveRecord::Base
	enum option_types: [:boolean, :radio, :checkbox, :integer, :string, :dropdown]

	belongs_to :system
	has_many :system_option_values
	has_many :system_rule_conditions

	validates :system, presence: true
	validates :name, presence: true
	validates :option_type, presence: true

	acts_as_tree
	acts_as_list scope: :parent_id

	accepts_nested_attributes_for :system_option_values, reject_if: :all_blank, allow_destroy: true

	def system_rules
		system_rule_conditions.map{|src| src.system_rule_condition_group.system_rule }.uniq
	end

	def default_direct_value
		case option_type
			when 'boolean'
				(default_value == true || default_value.to_s.match(/true|1/i)) ? true : false
			when 'integer'
				default_value.to_i
			else
				default_value.to_s
		end
	end

	def default_system_option_value_id
		begin
			case option_type
				when /dropdown|radio|checkbox/
					system_option_values.where(name: default_value.to_s).id
				else
					nil
			end
		rescue
			nil
		end
	end

end
