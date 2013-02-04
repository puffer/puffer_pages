require "spec_helper"

describe "Origins controller" do
  let(:token) { "token" }

  describe "#import" do
    let(:json) { File.new('spec/data/import.json').read }
    let(:origin) { Fabricate :origin }

    before { FakeWeb.register_uri :get, origin.uri, :body => json, :content_length => json.length }
    before { get "/admin/origins/#{origin.id}/import" }

    specify { PufferPages::Layout.count.should == 2 }
    specify { PufferPages::Page.count.should == 1 }
    specify { PufferPages::Snippet.count.should == 1 }
    specify { PufferPages::PagePart.count.should == 2 }
  end

  describe "#export" do
    context "with a valid token" do
      before { get "/admin/origins/export", :token => "token" }

      subject { ActiveSupport::JSON.decode response.body }

      %w(layouts pages snippets).each do |key|
        it { should have_key(key) }
      end
    end

    context "with an invalid token" do
      before { get "/admin/origins/export", :token => "bad" }

      specify { response.body.should be_blank }
      specify { response.status.should == 401 }
    end
  end
end