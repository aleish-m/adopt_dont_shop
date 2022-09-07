require 'rails_helper'

RSpec.describe 'the applicants show' do
  before :each do
    @shelter = Shelter.create!(name: 'Mystery Building', city: 'Irvine CA', foster_program: false, rank: 9)
    @applicant = Applicant.create!(first_name: 'John', last_name: 'Smith', street_address: '123 Fake Street', city: 'Denver',
      state: 'CO', zip: 80205, description: "I'm awesome", status: 'Pending')
    @applicant_1 = Applicant.create!(first_name: 'Jimmy', last_name: 'Dough', street_address: '567 Fake Street', city: 'Denver',
      state: 'CO', zip: 80205, description: "I'm kinda awesome", status: 'Pending')
    @applicant_2 = Applicant.create!(first_name: 'Johnny', last_name: 'Johnson', street_address: '17 Psuedo Street', city: 'Denver',
      state: 'CO', zip: 80205, description: "I'm not awesome", status: 'In Progress')
    @pet = @applicant.pets.create!(name: 'Scooby', age: 2, breed: 'Great Dane', adoptable: true, shelter_id: @shelter.id)
    @pet_1 = @applicant_1.pets.create!(name: 'Mr. Pirate', breed: 'tuxedo shorthair', age: 5, adoptable: false, shelter_id: @shelter.id)
    @pet_2 = @applicant.pets.create!(name: 'Jake', age: 5, breed: 'Pug', adoptable: true, shelter_id: @shelter.id)
    @applicant_1.pets << @pet
    @applicant_2.pets << @pet_2

  end

  describe 'as a admin' do
    describe 'Approving a Pet for Adoption' do
      it "For every pet that the application is for, I see a button to approve the application for that specific pet" do

        visit "/admin/applicants/#{@applicant.id}"

        expect(page).to have_content(@applicant.first_name)
        expect(page).to have_content(@applicant.last_name)

        within("#review_pet-#{@pet.id}") do
          expect(page).to have_content(@pet.name)
          expect(page).to have_button("Approve Adoption")
          expect(page).to_not have_content(@pet_2.name)
        end

        within("#review_pet-#{@pet_2.id}") do
          expect(page).to have_content(@pet_2.name)
          expect(page).to have_button("Approve Adoption")
          expect(page).to_not have_content(@pet.name)
        end

        expect(page).to_not have_content(@pet_1.name)
        expect(page).to_not have_content(@applicant_1.first_name)
        expect(page).to_not have_content(@applicant_1.last_name)
        expect(page).to_not have_content(@applicant_1.street_address)
      end

      it "When I click that button, I'm taken back to the admin application show page" do

        visit "/admin/applicants/#{@applicant.id}"

        within("#review_pet-#{@pet.id}") do
          click_on("Approve Adoption")
        end

        expect(current_path).to eq("/admin/applicants/#{@applicant.id}")

      end

      it "Next to the pet that I approved, I do not see a button to approve this pet, instead I see an indicator next to the pet that they have been approved" do
        visit "/admin/applicants/#{@applicant.id}"

        within("#review_pet-#{@pet.id}") do
          click_on("Approve Adoption")

          expect(page).to have_content("Adoption Approved for #{@pet.name}")
          expect(page).to_not have_content(@pet_2.name)
          expect(page).to_not have_button("Approve Adoption")
        end

        within("#review_pet-#{@pet_2.id}") do
          expect(page).to have_content(@pet_2.name)
          expect(page).to have_button("Approve Adoption")
          expect(page).to_not have_content(@pet.name)
        end

        expect(page).to_not have_content(@pet_1.name)
      end
    end

    describe 'Rejecting a Pet for Adoption' do
      it "For every pet that the application is for, I see a button to reject the application for that specific pet" do

        visit "/admin/applicants/#{@applicant.id}"

        expect(page).to have_content(@applicant.first_name)
        expect(page).to have_content(@applicant.last_name)

        within("#review_pet-#{@pet.id}") do
          expect(page).to have_content(@pet.name)
          expect(page).to have_button("Reject Adoption")
          expect(page).to_not have_content(@pet_2.name)
        end

        within("#review_pet-#{@pet_2.id}") do
          expect(page).to have_content(@pet_2.name)
          expect(page).to have_button("Reject Adoption")
          expect(page).to_not have_content(@pet.name)
        end

        expect(page).to_not have_content(@pet_1.name)
        expect(page).to_not have_content(@applicant_1.first_name)
        expect(page).to_not have_content(@applicant_1.last_name)
        expect(page).to_not have_content(@applicant_1.street_address)
      end

      it "When I click that button, I'm taken back to the admin application show page" do

        visit "/admin/applicants/#{@applicant.id}"
        within("#review_pet-#{@pet.id}") do
          click_on("Reject Adoption")
        end

        expect(current_path).to eq("/admin/applicants/#{@applicant.id}")
      end

      it "Next to the pet that I Rejected, I do not see a button to reject or approve this pet, instead I see an indicator next to the pet that they have been rejected" do
        visit "/admin/applicants/#{@applicant.id}"

        within("#review_pet-#{@pet.id}") do
          click_on("Reject Adoption")

          expect(page).to have_content("Adoption Rejected for #{@pet.name}")
          expect(page).to_not have_button("Approve Adoption")
          expect(page).to_not have_button("Reject Adoption")
        end

        within("#review_pet-#{@pet_2.id}") do
          expect(page).to have_content(@pet_2.name)
          expect(page).to have_button("Reject Adoption")
          expect(page).to have_button("Approve Adoption")
          expect(page).to_not have_content("Adoption Rejected for #{@pet_2.name}")
          expect(page).to_not have_content("Adoption Approved for #{@pet_2.name}")
        end

        expect(page).to_not have_content(@pet_1.name)
        expect(page).to_not have_content("Adoption Rejected for #{@pet_1.name}")
        expect(page).to_not have_content("Adoption Approved for #{@pet_1.name}")
      end
    end

    describe 'One application does not affect others' do
      it 'I approve or reject the pet for an application' do

        visit "/admin/applicants/#{@applicant.id}"

        expect(page).to have_content(@applicant.first_name)
        expect(page).to have_content(@applicant.last_name)

        within("#review_pet-#{@pet.id}") do
          click_on("Reject Adoption")

          expect(page).to have_content("Adoption Rejected for #{@pet.name}")
          expect(page).to_not have_button("Approve Adoption")
          expect(page).to_not have_button("Reject Adoption")
        end

        within("#review_pet-#{@pet_2.id}") do
          click_on("Approve Adoption")

          expect(page).to have_content("Adoption Approved for #{@pet_2.name}")
          expect(page).to_not have_button("Approve Adoption")
          expect(page).to_not have_button("Reject Adoption")
        end

        expect(page).to_not have_content(@pet_1.name)
        expect(page).to_not have_content(@applicant_1.first_name)
        expect(page).to_not have_content(@applicant_1.last_name)
        expect(page).to_not have_content(@applicant_1.street_address)
      end
      
      it 'I visit another applications show page and I do not see that same pet has been rejected/accepted on this application' do

        visit "/admin/applicants/#{@applicant.id}"

        expect(page).to have_content(@applicant.first_name)
        expect(page).to have_content(@applicant.last_name)

        expect(page).to_not have_content(@applicant_1.first_name)
        expect(page).to_not have_content(@applicant_1.last_name)
        expect(page).to_not have_content(@pet_1.name)

        within("#review_pet-#{@pet.id}") do
          click_on("Reject Adoption")
        end

        within("#review_pet-#{@pet_2.id}") do
          click_on("Approve Adoption")
        end

        visit "/admin/applicants/#{@applicant_1.id}"

        expect(page).to have_content(@applicant_1.first_name)
        expect(page).to have_content(@applicant_1.last_name)

        expect(page).to_not have_content(@applicant.first_name)
        expect(page).to_not have_content(@applicant.last_name)
        expect(page).to_not have_content(@pet_2.name)

        expect(page).to_not have_content("Adoption Rejected for #{@pet.name}")
        expect(page).to_not have_content("Adoption Approved for #{@pet.name}")
        expect(page).to_not have_content("Adoption Rejected for #{@pet_1.name}")
        expect(page).to_not have_content("Adoption Approved for #{@pet_1.name}")
        expect(page).to_not have_content("Adoption Rejected for #{@pet_2.name}")
        expect(page).to_not have_content("Adoption Approved for #{@pet_2.name}")

        expect(page).to have_content(@pet.name)
        expect(page).to have_content(@pet_1.name)
      end

      it 'I see buttons to approve or reject the pets for this specific application' do

        visit "/admin/applicants/#{@applicant.id}"

        within("#review_pet-#{@pet.id}") do
          click_on("Reject Adoption")
        end

        within("#review_pet-#{@pet_2.id}") do
          click_on("Approve Adoption")
        end

        visit "/admin/applicants/#{@applicant_1.id}"

        expect(page).to_not have_content(@pet_2.name)

        within("#review_pet-#{@pet.id}") do
          expect(page).to have_content(@pet.name)
          expect(page).to have_button("Reject Adoption")
          expect(page).to have_button("Approve Adoption")
          expect(page).to_not have_content("Adoption Rejected for #{@pet.name}")
          expect(page).to_not have_content("Adoption Approved for #{@pet.name}")
        end

        within("#review_pet-#{@pet_1.id}") do
          expect(page).to have_content(@pet_1.name)
          expect(page).to have_button("Reject Adoption")
          expect(page).to have_button("Approve Adoption")
          expect(page).to_not have_content("Adoption Rejected for #{@pet_1.name}")
          expect(page).to_not have_content("Adoption Approved for #{@pet_1.name}")
        end

      end
    end
  end
end
