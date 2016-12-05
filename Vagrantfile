machine_name = "MDT2013U201"
gist_url="https://gist.githubusercontent.com/brianfgonzalez/fa0720471ce2f6722d3ced4672e3f47a/raw/a4efb95b2e1fb5dd21167619bc1742decbb2049e/mdt2013u2.ps1"

Vagrant.configure("2") do |config|
  config.vm.box = "brianfgonzalez/winserver12r2"
  #config.vm.box = "ferventcoder/win7pro-x64-nocm-lite"
  config.vm.box_check_update = false
  config.vm.network "private_network", ip: "192.168.50.2", virtualbox__intnet: "intnet"
  config.vm.boot_timeout = 1200

  config.vm.provider :virtualbox do |v, override|
    v.gui = true
    v.name = machine_name
    v.memory = "4096"
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
  
  ["vmware_fusion", "vmware_workstation", "vmware_desktop"].each do |provider|
	  config.vm.provider :provider do |v, override|
	    v.gui = true
	    v.name = machine_name
	    v.vmx["memsize"] = "4096"
	    v.vmx["numvcpus"] = "2"
	    v.vmx["cpuid.coresPerSocket"] = "1"
	    v.vmx["ethernet0.virtualDev"] = "vmxnet3"
	    v.vmx["RemoteDisplay.vnc.enabled"] = "false"
	    v.vmx["RemoteDisplay.vnc.port"] = "5900"
	    v.vmx["scsi0.virtualDev"] = "lsisas1068"
	  end
  end
  
  #Use this command to list all time zones: tzutil /l | more
  config.vm.provision "shell", privileged:"true", powershell_elevated_interactive:"true",
    name: "force timezone set", inline:'tzutil.exe /s "Eastern Standard Time"'

  #Provision section
  config.vm.provision "b", type: "shell", privileged:"true", powershell_elevated_interactive:"true",
    inline: 'iwr -Uri "'+gist_url+'" -OutFile "\tmp\script.ps1"'
  config.vm.provision "c", type: "shell", privileged:"true", powershell_elevated_interactive:"true",
    inline: 'saps powershell.exe "\tmp\script.ps1 -CompName '+machine_name+'"'
end