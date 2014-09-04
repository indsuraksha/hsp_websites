# SystemRuleCondition belongs to a group, which belongs to a rule, which belong to
# a system. These are used in the system configuration tool to determine when to
# show/hide dependent options or show an alert. The action is determined by the
# related SystemRuleAction.
#
class SystemRuleCondition < ActiveRecord::Base
	enum logic_types: ["AND", "OR"]

	belongs_to :system_rule_condition_group
	belongs_to :system_option
	belongs_to :system_option_value

	validates :system_rule_condition_group, presence: true
	validates :system_option, presence: true
	# One or the other of these...
	# validates :system_option_value, presence: true
	# validates :direct_value, presence: true
	validates :operator, presence: true
	validates :logic_type, presence: true

	after_initialize :set_default_logic_type

	def self.operators
		# ['=', '<', '>', '!=', 'like']
		['is', 'is not', 'is greater than', 'is less than', 'is like']
	end

	def set_default_logic_type
		self.logic_type ||= "OR"
	end

	def to_s
		logic = self.system_rule_condition_group.system_rule_conditions.first == self ? '' : "#{self.logic_type} "
		"#{logic}'#{system_option.name}' #{operator} #{direct_value}"
	end

	# Just check if the object is good enough to be created as a nested element of a new
	# SystemRuleConditionGroup
	#
	def valid_for_nested_creation?
		self.operator.present? && self.logic_type.present? && self.system_option_id.present?
	end
end
