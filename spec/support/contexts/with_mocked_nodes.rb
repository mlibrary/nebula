# frozen_string_literal: true

RSpec.shared_context 'with mocked puppetdb functions' do |datacenter, nodes, class_nodes|
  before(:each) do
    stub_loader!
  end

  before(:each) do
    stub('nodes_for_class') do |d|
      class_nodes.each do |node_class, nodes_in_class|
        allow_call(d).with(node_class).and_return(%w[rolenode] + nodes_in_class)
      end
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
