match 'show plugins' => 'plugins#index'
match 'install plugin :name' => 'plugins#install'
match 'uninstall plugin :name' => 'plugins#uninstall'
