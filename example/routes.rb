collection :loadbalancers do
  # match "create loadbalancer"
  # match "show loadbalancers"
  # match "loadbalancers"
  # match "show loadbalancer :id" #=> 'loadbalancers#show'
  # match "update loadbalancer :id #=> loadbalancers#update"
  # match "destroy loadbalancer :id"
  collection :nodes do
    # match "create node on loadbalancer :loadbalancer_id"
    # match "create loadbalancer :loadbalancer_id node"
    # match "show nodes on loadbalancer :loadbalancer_id"
    # match "loadbalancer nodes"
    # match "show loadbalancer :loadbalancer_id  nodes"
    # match "show loadbalancer :loadbalancer_id node :id"
    # match "show node :id on loadbalancer :loadbalancer_id"
    # match "update loadbalancer:node"
    # match "destroy loadbalancer:node:$id"
    # match "destroy loadbalancer node $id"
    # match "destroy loadbalancer:node $id"
    # match "help "
  end

  collection :virtual_ips, :only => :index
  # match "show virtual_ips on loadbalancer :loadbalancer_id"
  # match "show loadbalancer :loadbalancer_id virtual_ips"
  # match "loadbalancers"
end

collection :servers do

end
