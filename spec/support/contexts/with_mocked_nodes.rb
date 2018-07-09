# frozen_string_literal: true

RSpec.shared_context 'with mocked puppetdb functions' do |datacenter, nodes|
  before(:each) do
    stub_loader!
  end

  before(:each) do
    stub('nodes_for_class') do |d|
      allow_call(d).and_return(%w[rolenode] + nodes)
    end

    stub('nodes_for_datacenter') do |d|
      allow_call(d).with(datacenter).and_return(%w[dcnode] + nodes)
    end

    # stub_function('fact_for', fact_for)
    stub('fact_for') do |d|
      nodes.each do |node|
        allow_call(d).with(node, 'networking').and_return(send(node.to_sym))
      end
    end
  end
end
