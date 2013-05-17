class LoadbalancersController < ApplicationController
  include MVCLI::RemoteRestController

  respond_to :txt, :json, :xml
  performs :create, :show, :update, :destroy

  param :name, :type => :string


end
