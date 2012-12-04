class Group < ActiveRecord::Base
  has_many :memberships, dependent: :destroy
  validates :name, presence: true, uniqueness: true
  validate :validate_not_defined
  attr_accessible :name

  private

  def validate_not_defined
    if ArRollout.defined_groups.include?(name.intern)
      errors.add(:name, "can't be a defined group name")
    end
  end
end
