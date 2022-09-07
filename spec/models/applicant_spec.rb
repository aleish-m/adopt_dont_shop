require 'rails_helper'

RSpec.describe Applicant, type: :model do
  describe 'relationships' do
    it { should have_many(:applicant_pets) }
    it { should have_many(:pets).through (:applicant_pets) }
  end

  describe 'validations' do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_presence_of(:street_address) }
    it { should validate_presence_of(:city) }
    it { should validate_presence_of(:state) }
    it { should validate_length_of(:state).is_equal_to(2) }
    it { should validate_presence_of(:zip) }
    it { should validate_numericality_of(:zip) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:status) }
    it do
      should validate_inclusion_of(:status).
      in_array(['In Progress', 'Pending', 'Approved', 'Rejected'])
    end
  end

  describe 'class methods' do
    before :each do
    @shelter = Shelter.create!(name: 'Mystery Building', city: 'Irvine CA', foster_program: false, rank: 9)
    @john = Applicant.create!(first_name: 'John', last_name: 'Dough', street_address: '123 Fake Street', city: 'Denver', state: 'CO', zip: 80205, description: "I'm awesome", status: 'Pending')
    @pet_1 = @john.pets.create!(name: 'Scooby', age: 2, breed: 'Great Dane', adoptable: true, shelter_id: @shelter.id)
    @pet_2 = @john.pets.create!(name: 'Jake', age: 5, breed: 'Pug', adoptable: true, shelter_id: @shelter.id)
    @applicant = ApplicantPet.find_by(applicant_id: @john.id, pet_id: @pet_1.id)
    @applicant_2 = ApplicantPet.find_by(applicant_id: @john.id, pet_id: @pet_2.id)
    @applicant.update(approved: true)
    end

    it "#self.approved?" do
      expect(@john.approved?(@pet_1.id)).to eq true
      expect(@john.approved?(@pet_2.id)).to be (nil)
    end

    it "#self.app_status" do
      expect(@john.app_status(@pet_1.id)).to have_attributes ({:id => @applicant.id, :applicant_id => @john.id, :approved => true, :pet_id => @pet_1.id})
      expect(@john.app_status(@pet_2.id)).to be_an ApplicantPet
      expect(@john.app_status(@pet_1.id)).to eq(@applicant)
      expect(@john.app_status(@pet_1.id)).to_not eq(@applicant_2)
    end
  end
end