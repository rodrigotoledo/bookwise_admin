# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe "#librarian?" do
    context "when session has a librarian user" do
      it "returns true" do
        user_librarian = create(:user, :librarian)
        session = create(:session, user: user_librarian)
        Current.session = session

        expect(helper.librarian?).to eq(true)
      end
    end

    context "when session has a member user" do
      it "returns false" do
        user_member = create(:user, :member)
        session = create(:session, user: user_member)
        Current.session = session

        expect(helper.librarian?).to eq(false)
      end
    end

    context "when there is no session" do
      it "returns nil" do
        Current.session = nil
        expect(helper.librarian?).to be_nil
      end
    end
  end

  describe "#member?" do
    context "when session has a member user" do
      it "returns true" do
        user_member = create(:user, :member)
        session = create(:session, user: user_member)
        Current.session = session

        expect(helper.member?).to eq(true)
      end
    end

    context "when session has a librarian user" do
      it "returns false" do
        user_librarian = create(:user, :librarian)
        session = create(:session, user: user_librarian)
        Current.session = session

        expect(helper.member?).to eq(false)
      end
    end

    context "when there is no session" do
      it "returns nil" do
        Current.session = nil
        expect(helper.member?).to be_nil
      end
    end
  end
end
