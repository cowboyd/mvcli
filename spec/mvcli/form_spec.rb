require "spec_helper"
require "mvcli/form"
require "mvcli/decoding"
require "ipaddr"

describe "A form for creating a load balancer" do
  use_natural_assertions
  Given(:definition) do
    Class.new(MVCLI::Form) do
      requires :naming

      input :name, String, default: -> {naming.generate 'l', 'b'}

      input :port, Integer, default: 80

      input :protocol, String, default: 'HTTP', &:upcase

      input :virtual_ips, [String], default: ['PUBLIC'], &:upcase

      input :nodes, ["ADDRESS:PORT[:CONDITION][:TYPE]"] do |attrs|
        Node.new attrs.
          address {|a| IPAddr.new a}.
          port {|p| p.to_i}.
          condition(&:to_s).type(&:to_s).
          condition(&:upcase).type(&:upcase)
      end
    end
  end
  Given(:form) do
    definition.new(params).tap do |f|
      f.stub(:decoders) {MVCLI::Decoding}
      f.stub(:naming) {mock(:NameGenerator, generate: 'random-name')}

    end
  end
  context "with partially specified, valid inputs" do
    Given(:params) {({nodes: ['10.0.0.1:80']})}
    Then {form.name == 'random-name'}
    And {form.port == 80}
    And {form.protocol == 'HTTP'}
    And {form.virtual_ips == ['PUBLIC']}
    context "the default form node" do
      Given(:node) {form.nodes.first}
      Then {node.address == IPAddr.new('10.0.0.1')}
      And {node.port = 80}
    end
  end
  context "with fully specified, valid inputs" do
    Given(:params) {
      ({
         name: 'foo',
         port: '80',
         protocol: 'http',
         virtual_ips: ['public', 'servicenet'],
         nodes: ['10.0.0.1:80:enabled:primary', '10.0.0.2:80:disabled:secondary']
       })
    }

    Then {form.name == 'foo'}
    And {form.port == 80}
    And {form.protocol == 'HTTP'}
    And {form.nodes.length == 2}
    context ". On the first node" do
      Given(:node) {form.nodes.first}
      Then {node.address == IPAddr.new('10.0.0.1')}
      And {node.port == 80}
      And {node.condition == 'ENABLED'}
      And {node.type == 'PRIMARY'}
    end
    context ". On the second node" do
      Given(:node) {form.nodes.last}
      Then {node.address == IPAddr.new('10.0.0.2')}
      And {node.port == 80}
      And {node.condition == 'DISABLED'}
      And {node.type == 'SECONDARY'}
    end
  end
end

class Node
  attr_accessor :address, :port, :protocol, :condition, :type

  def initialize(attrs)
    @address, @port, @protocal, @condition, @type = *attrs.values_at(:address, :port, :protocol, :condition, :type)
  end
end
