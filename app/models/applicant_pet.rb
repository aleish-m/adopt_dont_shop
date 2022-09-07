class ApplicantPet < ApplicationRecord
  belongs_to :applicant
  belongs_to :pet
  validates :approved, inclusion: [true, false], on: :update
  validates_associated :applicant, :pet
end