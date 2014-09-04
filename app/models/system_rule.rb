# SystemRule is a combination of conditions and actions that happen when those
# conditions are met. The conditions are organized into groups so different
# types of operator logic can be applied.
#
class SystemRule < ActiveRecord::Base
	belongs_to :system
	has_many :system_rule_condition_groups, inverse_of: :system_rule
	has_many :system_rule_actions, inverse_of: :system_rule

	validates :system, presence: true
	validate :at_least_one_condition, :at_least_one_action

	accepts_nested_attributes_for :system_rule_condition_groups, reject_if: :reject_condition_groups
	accepts_nested_attributes_for :system_rule_actions, reject_if: :all_blank

	def name
		"When #{self.option_groups_text} then #{self.actions_text}"
	end

	def option_groups_text
		system_rule_condition_groups.map{|srcg| srcg.to_s}.join(", ")
	end

	def actions_text
		system_rule_actions.map{|sra| sra.to_s}.join(", ")
	end

	private

	def reject_condition_groups(attributed)
		attributed[:system_rule_conditions_attributes].each do |key,src_attr|
			src = SystemRuleCondition.new(src_attr)
			return false if src.valid_for_nested_creation?
		end
		true
	end

	def at_least_one_condition
		if !(system_rule_condition_groups.length > 0)
			errors.add(:base, "Must have at least one valid group of conditions.")
		end
	end

	def at_least_one_action
		if !(system_rule_actions.length > 0)
			errors.add(:base, "Must have at least one action.")
		end
	end
end
