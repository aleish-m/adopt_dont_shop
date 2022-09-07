class Applicant < ApplicationRecord
  has_many :applicant_pets
  has_many :pets, through: :applicant_pets

  validates_presence_of :first_name, :last_name, :street_address, :city, :state, :zip, :description, :status
  validates :state, length: { is: 2 }
  validates :zip, numericality: true
  validates :status, inclusion: { in: ['In Progress', 'Pending', 'Approved', 'Rejected'] }

  def app_status(id)
    applicant_pets.find_by(pet_id: id)
  end

  def approved?(pet_id)
    app_status(pet_id).approved
  end

end
