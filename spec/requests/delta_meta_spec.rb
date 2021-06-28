# frozen_string_literal: true

describe 'Delta meta' do
  subject { response }
  let(:record) { Record.create!(title: 'Old title', body: 'Old body') }
  let(:created_record) { Record.last }
  let(:record_params) do
    {
      title: 'New record',
      body: 'New body'
    }
  end

  describe '#create' do
    before do
      post '/records',
           params: {record: record_params},
           headers: request_headers
    end

    context 'with default params' do
      it { is_expected.to have_statement(created_record.iri, Vocab.schema.name, 'New record') }
      it { is_expected.to have_statement(created_record.iri, Vocab.schema.text, 'New body') }
    end
  end

  describe '#update' do
    before do
      put "/records/#{record.id}",
          params: {record: record_params},
          headers: request_headers
    end

    context 'with default params' do
      it do
        is_expected.to(
          have_statement(
            created_record.iri,
            Vocab.schema.name,
            'New record',
            graph_name: LinkedRails::Vocab.ontola[:replace]
          )
        )
      end
      it do
        is_expected.to(
          have_statement(
            created_record.iri,
            Vocab.schema.text,
            'New body',
            graph_name: LinkedRails::Vocab.ontola[:replace]
          )
        )
      end
    end

    context 'with blank body' do
      let(:record_params) do
        {
          title: 'New record',
          body: ''
        }
      end

      it do
        is_expected.to(
          have_statement(
            created_record.iri,
            Vocab.schema.text,
            LinkedRails::Vocab.sp[:Variable],
            graph_name: LinkedRails::Vocab.ontola[:remove]
          )
        )
      end
    end
  end
end
