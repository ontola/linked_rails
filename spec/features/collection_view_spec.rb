# frozen_string_literal: true

describe LinkedRails::Collection::View do
  subject { collection }

  let(:collection) do
    col = LinkedRails::Collection.new(
      name: :records,
      association: :children,
      association_class: Record,
      filter: try(:filter),
      parent: try(:parent),
      type: type
    )
    col
  end
  let(:collection_view) do
    collection.default_view
  end
  let(:type) { nil }

  shared_examples_for 'view' do
    subject { collection_view.iri }

    describe '#iri' do
      it { is_expected.to eq(expected_iri) }
    end

    describe '#collection' do
      subject { collection_view.collection }

      it { is_expected.to eq(collection) }
    end

    describe '#members_query' do
      subject { collection_view.send(:members_query).to_sql }

      it { is_expected.to eq(expected_sql) }
    end
  end

  context 'with paginated view' do
    let(:expected_iri) { 'http://example.com/records?page=1' }
    let(:expected_where) { 'WHERE "records"."admin" = \'f\' ' }
    let(:expected_order) { 'ORDER BY "records"."created_at" DESC, "records"."id" ASC ' }
    let(:expected_sql) { "SELECT  \"records\".* FROM \"records\" #{expected_where}#{expected_order}LIMIT 11 OFFSET 0" }

    it_behaves_like 'view'

    context 'with parent' do
      let(:parent) { Record.create! }
      let(:expected_iri) { "http://example.com/records/#{parent.id}/records?page=1" }
      let(:expected_where) { 'WHERE "records"."parent_id" = 1 AND "records"."admin" = \'f\' ' }

      it_behaves_like 'view'
    end
  end

  context 'with infinite view' do
    let(:type) { :infinite }
    let(:before_time) { collection_view.before.first[:value] }
    let(:create_before) do
      "#{CGI.escape(RDF::Vocab::SCHEMA[:dateCreated])}=#{before_time}"
    end
    let(:primary_before) do
      "#{CGI.escape(LinkedRails::Vocab::ONTOLA[:primaryKey])}=#{min_int}"
    end
    let(:min_int) { ActiveModel::Type::Integer.new.send(:min_value) }
    let(:before_params) { [{'before[]': create_before}.to_param, {'before[]': primary_before}.to_param].join('&') }
    let(:expected_iri) { "http://example.com/records?type=infinite&#{before_params}" }
    let(:expected_where) { "WHERE \"records\".\"admin\" = 'f' #{infinite_where} " }
    let(:infinite_where) do
      "AND (\"records\".\"created_at\" < '#{Time.parse(before_time).iso8601(6).sub('T', ' ').sub('Z', '')}' "\
      "OR \"records\".\"created_at\" = '#{Time.parse(before_time).iso8601(6).sub('T', ' ').sub('Z', '')}' "\
      "AND \"records\".\"id\" > #{min_int})"
    end
    let(:expected_order) { 'ORDER BY "records"."created_at" DESC, "records"."id" ASC ' }
    let(:expected_sql) { "SELECT  \"records\".* FROM \"records\" #{expected_where}#{expected_order}LIMIT 11" }

    it_behaves_like 'view'

    context 'with parent' do
      let(:parent) { Record.create! }
      let(:expected_iri) do
        "http://example.com/records/#{parent.id}/records?type=infinite&#{before_params}"
      end
      let(:expected_where) do
        "WHERE \"records\".\"parent_id\" = 1 AND \"records\".\"admin\" = 'f' #{infinite_where} "
      end

      it_behaves_like 'view'
    end
  end
end
