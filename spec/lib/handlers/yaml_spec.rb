require 'spec_helper'

describe PufferPages::Handlers::Yaml do
  subject { described_class.new(:yaml) }

  let!(:root) { Fabricate :root, name: 'root', page_parts: [ancestors.last] }
  let!(:first) { Fabricate :page, slug: 'first', parent: root, page_parts: [ancestors.first] }
  let!(:second) { Fabricate :page, slug: 'second', parent: first, page_parts: [page_part] }
  let(:page_part) {
    Fabricate.build :main, handler: 'yaml', body: YAML.dump(config: { value: 42, array: [1, 2], hash: { foo: 1 } })
  }
  let(:ancestors) {
    [
      Fabricate.build(:main, handler: 'yaml', body: YAML.dump(config: { array: [4, 5], hash: { bar: 2 } })),
      Fabricate.build(:main, handler: 'yaml', body: YAML.dump(config: { value: 33, hash: { bar: 1, baz: 3 } }))
    ]
  }

  context do
    specify { subject.process(page_part).should ==
      { config: { value: 42, array: [1, 2], hash: { foo: 1, bar: 2, baz: 3 } } } }
  end

  context 'error yaml' do
    let(:page_part) {
      Fabricate.build :main, handler: 'yaml', body: " key: value\n  key:value\n key:value"
    }

    specify do
      expect { subject.process(page_part).should }.
        to raise_exception Psych::SyntaxError
    end
  end
end
