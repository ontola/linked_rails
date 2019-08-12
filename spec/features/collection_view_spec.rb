# frozen_string_literal: true

require_relative '../spec_helper'

describe LinkedRails::Collection::View do
  subject { collection }

  let(:collection) do
    col = LinkedRails::Collection.new(
      name: :records,
      association: :resource,
      association_class: Record,
      filter: try(:filter),
      parent: try(:parent),
      type: type
    )
    col
  end
  let(:filtered_collection) do
    collection.send(:filtered_collection, a: 1, b: 2)
  end
  let(:paginated_collection_view) do
    collection.view_with_opts(page: 1)
  end
  let(:infinite_collection_view) do
    collection.view_with_opts(before: before_time)
  end
  let(:before_time) { Time.current.utc.iso8601(6) }
  let(:encoded_before_time) { ERB::Util.url_encode(before_time) }
  let(:type) { nil }

  describe '#id' do
    context 'with paginated view' do
      subject { paginated_collection_view.iri }

      it { is_expected.to eq('http://example.com/records?page=1&page_size=11') }

      context 'with parent' do
        let(:parent) { Record.new({}) }

        it { is_expected.to eq('http://example.com/records/record_id/records?page=1&page_size=11') }
      end
    end

    context 'with infinite' do
      subject { infinite_collection_view.iri }

      let(:type) { :infinite }

      it { is_expected.to eq("http://example.com/records?page_size=11&type=infinite&before=#{encoded_before_time}") }

      context 'with parent' do
        let(:parent) { Record.new({}) }

        it do
          is_expected.to(
            eq("http://example.com/records/record_id/records?page_size=11&type=infinite&before=#{encoded_before_time}")
          )
        end
      end
    end
  end

  describe '#collection' do
    context 'with paginated' do
      subject { paginated_collection_view.collection }

      it { is_expected.to eq(collection) }
    end

    context 'with infinite' do
      subject { infinite_collection_view.collection }

      let(:type) { :infinite }

      it { is_expected.to eq(collection) }
    end
  end
end
