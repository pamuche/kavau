require 'rails_helper'

RSpec.describe Pdf, type: :model do
  [:standard_letter, :balance_letter, :termination_letter].each do |letter_type|
    context "letter is a #{letter_type}" do
      before :each do
        @creditor = create :person
        @letter = create letter_type, year: 2014
      end

      it "is not valid without associated letter" do
        pdf = Pdf.new(creditor: @creditor)
        expect(pdf).not_to be_valid
        expect(pdf.errors[:letter_id]).not_to be_blank
      end

      it "is not valid without associated creditor" do
        pdf = Pdf.new(letter: @letter)
        expect(pdf).not_to be_valid
        expect(pdf.errors[:creditor_id]).not_to be_blank
      end

      it "is valid with associated letter and creditor" do
        pdf = Pdf.new(letter: @letter, creditor: @creditor)
        expect(pdf).to be_valid
      end

      context "saving it" do
        before(:each){ 
          @project_address = create :complete_project_address, legal_form: 'registered_society'
          @pdf = Pdf.new(letter: @letter, creditor: @creditor) 
        }

        it "the combination of letter_id and creditor_id has to be unique" do
          pending "to_pdf for termination_letters not yet implemented" if letter_type == :termination_letter
          @pdf.save
          expect(Pdf.new(letter: @letter, creditor: @creditor)).not_to be_valid
          expect(Pdf.new(letter: @letter, creditor: (create :person))).to be_valid
          expect(Pdf.new(letter: (create :letter), creditor: @creditor)).to be_valid
        end


        it "sets the correct path" do
          pending "to_pdf for termination_letters not yet implemented" if letter_type == :termination_letter
          @pdf.save
          expect(@pdf).to be_persisted
          expect(@pdf.path).to match(path(letter_type))
        end

        it "creates the file" do
          pending "to_pdf for termination_letters not yet implemented" if letter_type == :termination_letter
          @pdf.save
          expect(File).to exist(@pdf.path)
        end

        it "build the correct pdf" do
          pending "to_pdf for termination_letters not yet implemented" if letter_type == :termination_letter
          allow(@letter).to receive(:to_pdf).and_return(true)
          @pdf.save
          expect(@letter).to have_received(:to_pdf).with(@creditor)
        end

        it "updates the pdf" do
          pending "to_pdf for termination_letters not yet implemented" if letter_type == :termination_letter
          @pdf.save
          allow(IO).to receive(:binwrite).and_return(:true)
          allow(@letter).to receive(:to_pdf).and_return(true)
          @pdf.update_file
          expect(IO).to have_received(:binwrite)
          expect(@letter).to have_received(:to_pdf).with(@creditor)
        end
      end

      context "destroying it" do
        before(:each){ 
          @project_address = create :complete_project_address, legal_form: 'registered_society'
          @pdf = Pdf.create(letter: @letter, creditor: @creditor) unless letter_type == :termination_letter
        }

        it "deletes the correspoding file" do
          pending "to_pdf for termination_letters not yet implemented" if letter_type == :termination_letter
          @pdf.destroy
          expect(File).not_to exist(@pdf.path)
        end
      end
    end
  end

  def path(letter_type)
    if letter_type == :standard_letter
      'public/system/rundbriefe/2014'
    elsif letter_type == :balance_letter
      "public/system/jahresabschluss_briefe/2014"
    elsif letter_type == :termination_letter
      'public/system/kuendigungsbriefe/2014'
    end
  end
end
