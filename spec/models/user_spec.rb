# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe "enum roles" do
    it "creates a librarian user" do
      user_librarian = create(:user, :librarian)
      expect(user_librarian).to be_librarian
      expect(user_librarian.user_type).to eq("librarian")
    end

    it "creates a member user" do
      user_member = create(:user, :member)
      expect(user_member).to be_member
      expect(user_member.user_type).to eq("member")
    end
  end

  describe "email normalization" do
    it "downcases and strips email_address" do
      user = create(:user, email_address: "  Test@BookWise.Com ")
      expect(user.email_address).to eq("test@bookwise.com")
    end
  end

  describe "associations" do
    it { should have_many(:sessions).dependent(:destroy) }
  end

  describe "validations" do
    it { should validate_presence_of(:email_address) }
    it "validates uniqueness of email_address" do
      user = create(:user, email_address: "unique@example.com")
      duplicate_user = build(:user, email_address: user.email_address)
      expect(duplicate_user).not_to be_valid
    end
    it { should allow_value("user@example.com").for(:email_address) }
    it { should_not allow_value("invalid_email").for(:email_address) }

    it "is invalid without a user_type" do
      user = build(:user, user_type: nil)
      expect(user).not_to be_valid
      expect(user.errors[:user_type]).not_to be_blank
    end

    it "is invalid with an unknown user_type string" do
      expect {
        build(:user, user_type: "admin")
      }.to raise_error(ArgumentError)
    end

    it "is invalid with an empty string" do
      user = build(:user, user_type: "")
      expect(user).not_to be_valid
      expect(user.errors[:user_type]).to include("can't be blank")
    end
  end
end
