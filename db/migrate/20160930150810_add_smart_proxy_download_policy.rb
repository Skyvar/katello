class AddSmartProxyDownloadPolicy < ActiveRecord::Migration[4.2]
  def up
    #set default to on_demand, but update existing proxies to inherit
    add_column :smart_proxies, :download_policy, :string, :null => true
    SmartProxy.reset_column_information
    SmartProxy.all.each do |proxy|
      proxy.update(:download_policy => SmartProxy::DOWNLOAD_INHERIT)
    end
  end

  def down
    remove_column :smart_proxies, :download_policy
  end
end
