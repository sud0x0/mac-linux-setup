# Linux-Dev Parallels Bridge Mode Static IP

Sometimes Parallels will not assign the exact IP configured in the router for the dev vm. In that case, bake the static IP to the VM.

- `sudo vim /etc/netplan/99-static.yaml`

```yaml
network:
  version: 2
  renderer: NetworkManager
  ethernets:
    enp0s5:
      dhcp4: no
      addresses:
        - 10.10.10.100/24
      routes:
        - to: default
          via: 10.10.10.1
      nameservers:
        addresses:
          - 10.10.10.1
        search:
          - home.local
```

- `sudo chmod 600 /etc/netplan/*.yaml`
- `sudo netplan apply`
- `ping -c3 10.10.10.1`
- `ping -c3 1.1.1.1`
