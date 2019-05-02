# frozen_string_literal: true

require_relative '../spec_helper'

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
    collection.send(:new_child, filter: {key: :value, key2: 'value2', key3: 'empty'})
  end
  let(:user_context) { {admin: true} }
  let(:type) { nil }

  describe '#iri' do
    context 'with collection' do
      subject { collection.iri }

      it { is_expected.to eq('http://example.com/records') }

      context 'with parent' do
        let(:parent) { Record.new({}) }

        it { is_expected.to eq('http://example.com/records/record_id/records') }
      end
    end

    context 'with filtered collection' do
      subject { filtered_collection.iri }

      let(:filter_string) { 'filter%5B%5D=key%3Dvalue&filter%5B%5D=key2%3Dvalue2&filter%5B%5D=key3%3Dempty' }

      it { is_expected.to eq("http://example.com/records?#{filter_string}") }

      context 'with parent' do
        let(:parent) { Record.new({}) }

        it { is_expected.to eq("http://example.com/records/record_id/records?#{filter_string}") }
      end
    end

    context 'with default type' do
      subject { collection.iri }

      let(:type) { :paginated }

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
        '"records"."actual_key" = \'actual_value\' AND "records"."key2" = \'value2\' AND "records"."key3" IS NULL'
      end

      it { is_expected.to eq(result) }
    end
  end

  describe '#apply_scope' do
    before do
      stub_const 'RecordPolicy::Scope', ApplicationPolicy::Scope
      RecordPolicy::Scope.class_eval { define_method('resolve') { user[:admin] ? scope : scope.where(admin: false) } }
    end

    subject { collection.association_base.to_sql }

    let(:result) { 'SELECT "records".* FROM "records"' }

    it { is_expected.to eq(result) }

    context 'with filters' do
      let(:user_context) { {admin: false} }
      let(:result) { 'SELECT "records".* FROM "records" WHERE "records"."admin" = 0' }

      it { is_expected.to eq(result) }
    end
  end
end
