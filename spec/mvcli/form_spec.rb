require "spec_helper"
require "mvcli/form"
require "mvcli/decoding"
require "ipaddr"

describe "A form for creating a load balancer" do
  use_natural_assertions
  Given(:definition) do
    Class.new(MVCLI::Form) do
      input :name, String, default: -> {naming.generate 'l', 'b'}

      input :port, Integer, default: 80, decode: ->(s) {Integer s}

      input :protocol, String, default: 'HTTP', decode: :upcase

      input :virtual_ips, [String], default: ['PUBLIC']

      input :nodes, [Node], required: true do
        input :address, IPAddr, required: true, decode: ->(s) {IPAddr.new s}
        input :port, Integer, default: 80, decode: ->(s) {Integer s}
        input :type, String, default: 'PRIMARY', decode: :upcase
        input :condition, String, default: 'ENABLED', decode: :upcase

        validates(:port, "port must be between 0 and 65,535") {|port| port >= 0 && port <= 65535}
        validates(:type, "invalid type") {|type| ['PRIMARY', 'SECONDARY'].member? type}
        validates(:condition, "invalid condition") {|c| ['ENABLED', 'DISABLED'].member? c}
      end
    end
  end
  Given(:form) do
    definition.new(params).tap do |f|
      f.stub(:decoders) {MVCLI::Decoding}
      f.stub(:naming) {mock(:NameGenerator, generate: 'random-name')}
    end
  end
  context "with no nodes provided" do
    Given(:params) {({node: []})}
    Then {!form.valid?}
    And {form.violations[:nodes] == ["cannot be empty"]}

  end
  context "with invalid node inputs" do
    Given(:params) do
      ({
         node: ['10.0.0.1:-500', 'xxx:80']
       })
    end
    Then {!form.valid?}
    context "the first violation" do
      Given(:violations) {form.validation[:nodes].first.violations}
      Then {violations[:port] == ["port must be between 0 and 65,535"]}
    end
    context "the second error" do
      Given(:errors) {form.validation[:nodes].last.errors}
      Then {errors[:address].first.is_a?(IPAddr::InvalidAddressError)}
    end
  end
  context "with partially specified, valid inputs" do
    Given(:params) do
      ({node: ['10.0.0.1:80']})
    end
    Then {form.name == 'random-name'}
    And {form.port == 80}
    And {form.protocol == 'HTTP'}
    And {form.virtual_ips == ['PUBLIC']}
    context "the default form node" do
      Given(:node) {form.nodes.first}
      Then {node.address == IPAddr.new('10.0.0.1')}
      And {node.port == 80}
    end
  end
  context "with fully specified, valid inputs" do
    Given(:params) {
      ({
         name: 'foo',
         port: '80',
         protocol: 'http',
         virtual_ip: ['public', 'servicenet'],
         node: [
                 '10.0.0.1:80:primary:enabled',
                 '10.0.0.2:80:secondary:disabled'
                ]
       })
    }
    Then {form.valid?}
    And {form.name == 'foo'}
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
  include MVCLI::Validatable
  attr_accessor :address, :port, :protocol, :condition, :type
  validates(:port, "port must be between 0 and 65,535") {|port| port >= 0 && port <= 65535}

  def initialize(attrs)
    @address, @port, @protocal, @condition, @type = *attrs.values_at(:address, :port, :protocol, :condition, :type)
  end

end
