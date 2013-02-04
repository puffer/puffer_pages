# encoding: UTF-8
require 'spec_helper'

describe PufferPages::Origin do
  let!(:origin) { Fabricate :origin }

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:host) }
    it { should validate_presence_of(:token) }
    it { should validate_uniqueness_of(:name) }
  end

  describe ".export_json" do
    let!(:layout) { Fabricate :application }
    let!(:snippet) { Fabricate :snippet }
    let!(:page) { Fabricate :root, page_parts: [Fabricate(:main)] }

    let(:json) { described_class.export_json }

    describe "root level keys" do
      subject { ActiveSupport::JSON.decode json }

      %w(layouts pages snippets).each do |key|
        it { should have_key(key) }
      end
    end

    describe "exported page parts" do
      subject { ActiveSupport::JSON.decode(json)["pages"].first }
      it { should have_key("page_parts") }
      specify { subject["page_parts"].should have(1).items }
    end
  end

  describe "#uri" do
    {
      "http://localhost#{PufferPages.export_path}" => { host: 'localhost' },
      "http://ya.ru#{PufferPages.export_path}" => { host: 'ya.ru' },
      "http://localhost:3000#{PufferPages.export_path}" => { host: 'localhost:3000' },
      "https://localhost:3000#{PufferPages.export_path}" => { host: 'https://localhost:3000' },
      "https://localhost:3000#{PufferPages.export_path}" => { host: 'https://localhost:3000', token: 'token2' },
      "http://localhost:3000/export/path" => { host: 'http://localhost:3000', token: 'token2', path: 'export/path' }
    }.each_with_index do |(uri, attributes), index|
      specify {
        origin = Fabricate :origin, attributes
        origin.uri.to_s.should == [uri, { token: origin.token }.to_query].join(??)
      }
    end
  end

  context "import" do
    let(:json) { File.read('spec/data/import.json') }

    describe "#import_json" do
      specify { expect { origin.import_json(json) }.to change(PufferPages::Layout, :count).from(0).to(2) }
      specify { expect { origin.import_json(json) }.to change(PufferPages::Page, :count).from(0).to(1) }
      specify { expect { origin.import_json(json) }.to change(PufferPages::PagePart, :count).from(0).to(2) }
      specify { expect { origin.import_json(json) }.to change(PufferPages::Snippet, :count).from(0).to(1) }
    end

    describe "#import!" do
      before { FakeWeb.register_uri(:get, origin.uri, body: json, content_length: json.length) }

      specify { expect { origin.import! }.to change(PufferPages::Layout, :count).from(0).to(2) }
      specify { expect { origin.import! }.to change(PufferPages::Page, :count).from(0).to(1) }
      specify { expect { origin.import! }.to change(PufferPages::PagePart, :count).from(0).to(2) }
      specify { expect { origin.import! }.to change(PufferPages::Snippet, :count).from(0).to(1) }
    end
  end

  context "import error" do
    let(:json) { File.read('spec/data/broken.json') }

    specify { expect { origin.import_json json }.to raise_exception ActiveRecord::UnknownAttributeError }
  end

  context "import-export integrity" do
    before { Timecop.freeze Time.parse('2013/12/23 23:23') }
    after { Timecop.return }

    let!(:layout) { Fabricate :application }
    let!(:snippet) { Fabricate :snippet }
    let!(:root) { Fabricate :root, page_parts: [Fabricate(:main), Fabricate(:sidebar)] }
    let!(:first) { Fabricate :page, slug: 'first', parent: root, page_parts: [Fabricate(:main)] }
    let!(:second) { Fabricate :page, slug: 'second', parent: first, page_parts: [Fabricate(:sidebar)] }

    let(:json) do
      PufferPages.localize ?
        File.read('spec/data/localized.json') :
        File.read('spec/data/unlocalized.json')
    end

    # TODO: make this work will be perfect
    # specify do
    #   ActiveSupport::JSON.decode(described_class.export_json).should ==
    #     ActiveSupport::JSON.decode(json)
    # end

    specify do
      origin.import_json json

      old_dump = ActiveSupport::JSON.decode(json)
      new_dump = ActiveSupport::JSON.decode(described_class.export_json)
      new_dump.each do |(table, rows)|
        rows.each_with_index do |attributes, index|
          attributes.should == old_dump[table][index]
        end
      end
    end
  end
end
