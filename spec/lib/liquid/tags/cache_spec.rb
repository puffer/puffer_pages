require 'spec_helper'

describe PufferPages::Liquid::Tags::Cache do
  describe '#expires_in' do
    subject { PufferPages::Liquid::Tags::Cache.allocate }

    specify { subject.expires_in('10').should == 10.seconds }
    specify { subject.expires_in('10s').should == 10.seconds }
    specify { subject.expires_in('10m').should == 10.minutes }
    specify { subject.expires_in('10h').should == 10.hours }
    specify { subject.expires_in('10h 10m 10s').should == 10.hours + 10.minutes + 10.seconds }
    specify { subject.expires_in(nil).should be_nil }
    specify { subject.expires_in('').should be_nil }
    specify { subject.expires_in('10blabla').should be_nil }
    specify { subject.expires_in('10blabla 10m').should be_nil }
  end

  describe '#render' do

    def cache_key *args
      ActiveSupport::Cache.expand_cache_key args.unshift('puffer_pages_cache')
    end

    let!(:root) { Fabricate :root }
    before { PufferPages.cache_store = :memory_store }
    before { PufferPages.config.stub(:perform_caching) { true } }

    context 'simple caching' do
      let(:entry) { ActiveSupport::Cache::Entry.new 'Bye' }

      specify do
        PufferPages.config.stub(:perform_caching) { false }
        PufferPages.cache_store.should_not_receive(:write)
        PufferPages.cache_store.should_not_receive(:read_entry)
        root.render("{% cache %}Hello{% endcache %}").should == 'Hello'
      end

      specify do
        PufferPages.cache_store.should_receive(:write).with(
          cache_key(root), 'Hello', {}
        ).and_call_original
        root.render("{% cache %}Hello{% endcache %}").should == 'Hello'
      end

      specify do
        PufferPages.cache_store.stub(:read_entry).with(
          cache_key(root), {}
        ) { entry }
        root.render("{% cache %}Hello{% endcache %}").should == entry.value
      end
    end

    context 'additional params' do
      specify do
        PufferPages.cache_store.should_receive(:write).with(
          cache_key(root), 'Hello', { expires_in: 60 }
        ).and_call_original
        root.render("{% cache expires_in: '1m' %}Hello{% endcache %}")
      end

      specify do
        PufferPages.cache_store.should_receive(:write).with(
          cache_key(root, 'additional_key'), 'Hello', { expires_in: 60 }
        ).and_call_original
        root.render("{% cache 'additional_key', expires_in: '1m' %}Hello{% endcache %}")
      end

      specify do
        PufferPages.cache_store.should_receive(:write).with(
          cache_key(root, 'key1', 'key2'), 'Hello', {}
        ).and_call_original
        root.render("{% cache 'key1', 'key2', expires_in: '' %}Hello{% endcache %}")
      end

      specify do
        PufferPages.cache_store.should_receive(:write).with(
          cache_key(root, 'additional_key'), 'Hello', { expires_in: 3600 }
        ).and_call_original
        root.render(
          "{% cache key, expires_in: expire %}Hello{% endcache %}",
          { expire: '1h', key: 'additional_key' }
        )
      end
    end

    context 'proper cache key' do
      let!(:custom) { Fabricate :custom, body: "{% cache %}Hello{% endcache %}" }

      specify do
        PufferPages.cache_store.should_receive(:write).with(
          cache_key(custom), 'Hello', {}
        ).and_call_original
        root.render("{% snippet 'custom' %}")
      end
    end
  end
end
