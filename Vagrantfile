# -*- mode: ruby -*-
# vi: set ft=ruby :
mem = `wmic computersystem Get TotalPhysicalMemory`.split[1].to_i/1024/1024/ 4
`net user vagrant vagrant /add >nul 2>&1`

Vagrant.configure("2") do |root|
	root.vm.define "server", primary: "true" do |server|
		# Change comp name
		server.vm.guest = :windows
		server.vm.box = "brianfgonzalez/winserver12r2"
		server.vm.network "private_network", ip: "192.168.50.2", virtualbox__intnet: "intnet"
		server.vm.boot_timeout = 1200
		server.vm.synced_folder "vagrant_share", "/vagrant_share", create: true, type:"smb",
			smb_username: "vagrant", smb_password: "vagrant"
		server.vm.provider :virtualbox do |v, override|
			v.gui = true
			#v.name = server_name
			v.memory = mem
			v.cpus = "2"
			v.customize ["modifyvm", :id, "--ostype", "Windows2012_64"]
			v.customize ["modifyvm", :id, "--groups", "/"]
			v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
			v.customize ["modifyvm", :id, "--audio", "none"]
			v.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
			v.customize ["modifyvm", :id, "--draganddrop", "hosttoguest"]
			v.customize ["modifyvm", :id, "--usb", "off"]
			v.customize ["modifyvm", :id, "--chipset", "ich9"]
			v.customize ["modifyvm", :id, "--nictype1", "82540EM"]
			v.customize ["modifyvm", :id, "--nictype2", "82540EM"]
			v.customize ["modifyvm", :id, "--cableconnected2", "on"]

			# Sets input key to Right-Alt key for toughbooks usage
			v.customize ["setextradata", "global", "GUI/Input/HostKeyCombination", "165"]
			v.customize ["setextradata", "global", "GUI/SuppressMessages", "all"]
			
			#Fixes associated with the time sync with virtualbox
			v.customize ["guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", "1000"]
		end

		# Use this command to list all time zones: tzutil /l | more
		server.vm.provision "shell", privileged: "true", powershell_elevated_interactive: "true",
		 name: "timezone config", inline:'tzutil.exe /s "Eastern Standard Time"'
		 
		# SMB share fix https://www.vagrantup.com/docs/synced-folders/smb.html
		server.vm.provision "shell", privileged: "true", powershell_elevated_interactive: "true",
		 name: "disable autodisconnect", inline:'net config server /autodisconnect:-1'
	end
end