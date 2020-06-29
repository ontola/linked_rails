# frozen_string_literal: true

describe LinkedRails::Collection do
  subject { collection }

  let(:collection) do
    col = described_class.new(
      name: :records,
      association: :resource,
      association_class: Record,
      filter: try(:filter),
      parent: try(:parent),
      user_context: user_context,
      type: type
    )
    col
  end
  let(:filtered_collection) do
    collection.send(:new_child, filter: {key: [:value], key2: ['value2'], key3: [false]})
  end
  let(:user_context) { {admin: true} }
  let(:type) { nil }

  describe '#iri' do
    context 'with collection' do
      subject { collection.iri }

      it { is_expected.to eq('http://example.com/records') }

      context 'with parent' do
        let(:parent) { Record.create! }

        it { is_expected.to eq("http://example.com/records/#{parent.id}/records") }
      end
    end

    context 'with filtered collection' do
      subject { filtered_collection.iri }

      let(:filter_string) do
        'filter%5B%5D=http%253A%252F%252Fexample.com%252Fmy_vocab%2523key%3Dvalue'\
        '&filter%5B%5D=http%253A%252F%252Fexample.com%252Fmy_vocab%2523key2%3Dvalue2'\
        '&filter%5B%5D=http%253A%252F%252Fexample.com%252Fmy_vocab%2523key3%3Dfalse'
      end

      it { is_expected.to eq("http://example.com/records?#{filter_string}") }

      context 'with parent' do
        let(:parent) { Record.create! }

        it { is_expected.to eq("http://example.com/records/#{parent.id}/records?#{filter_string}") }
      end
    end

    context 'with default type' do
      subject { collection.iri }

      it { is_expected.to eq('http://example.com/records') }
    end

    context 'with different type' do
      subject { collection.iri }

      let(:type) { :infinite }

      it { is_expected.to eq('http://example.com/records?type=infinite') }
    end
  end

  describe '#unfiltered_collection' do
    context 'with filtered collection' do
      subject { filtered_collection.unfiltered_collection }

      it { is_expected.to eq(collection) }
    end
  end

  describe '#apply_filter' do
    subject { collection.send(:apply_filters, Record.all).to_sql }

    let(:result) { 'SELECT "records".* FROM "records"' }

    it { is_expected.to eq(result) }

    context 'with filters' do
      subject { filtered_collection.send(:apply_filters, Record.all).to_sql }

      let(:result) do
        'SELECT "records".* FROM "records" WHERE '\
        '"records"."actual_key" = \'value\' AND "records"."key2" = \'value2\' AND "records"."key3" IS NULL'
      end

      it { is_expected.to eq(result) }
    end
  end

  describe '#apply_scope' do
    subject { collection.association_base.to_sql }

    let(:result) { 'SELECT "records".* FROM "records" ORDER BY "records"."created_at" DESC, "records"."id" ASC' }

    it { is_expected.to eq(result) }

    context 'with filters' do
      let(:user_context) { {admin: false} }
      let(:result) do
        'SELECT "records".* FROM "records" WHERE "records"."admin" = \'f\' ORDER BY "records"."created_at" DESC, '\
        '"records"."id" ASC'
      end

      it { is_expected.to eq(result) }
    end
  end
end
