# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Admin
    describe CreateNewsletter, :db do
      describe "call" do
        let(:user) { create(:user, organization: organization) }
        let(:organization) { create(:organization) }

        let(:form) do
          double(
            subject: Decidim::Faker::Localized.paragraph(3),
            body: Decidim::Faker::Localized.paragraph(3),
            valid?: true
          )
        end

        let(:command) { described_class.new(form, user) }

        describe "when the form is not valid" do
          before do
            expect(form).to receive(:valid?).and_return(false)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't create a newsletter" do
            expect do
              command.call
            end.not_to change { Newsletter.count }
          end
        end

        describe "when the form is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "creates a new category" do
            expect do
              command.call
            end.to change { Newsletter.count }.by(1)
          end

          it "creates a newsletter with the right attributes" do
            command.call
            newsletter = Newsletter.last

            expect(newsletter.author).to eq(user)
            expect(newsletter.organization).to eq(organization)
            expect(newsletter.subject).to eq(form.subject.stringify_keys)
            expect(newsletter.sent?).to eq(false)
            expect(newsletter.body).to eq(form.body.stringify_keys)
          end
        end
      end
    end
  end
end
