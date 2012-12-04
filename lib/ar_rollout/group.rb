class Group < ActiveRecord::Base
  after_destroy :destroy_rollouts

  has_many :memberships, dependent: :destroy
  validates :name, presence: true, uniqueness: true
  validate :validate_not_defined
  attr_accessible :name

  private

  def destroy_rollouts
    Rollout.where(group: name).each(&:destroy)
  end

  def validate_not_defined
    if ArRollout.defined_groups.include?(name.intern)
      errors.add(:name, "can't be a defined group name")
    end
  end
end
