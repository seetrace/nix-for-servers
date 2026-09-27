{ config, lib, pkgs, ... }:

{
        # NixOS tailscale bridge server module
        # Author    seetrace (Yuta, Seiya) 2026
        # Licence   GPL3.0
        # README    change the adreses to your needs, after rebuilding do 'tailscale up'

        networking.interfaces.ens18 = { # VM sandbox bridge (vmbr1)
                ipv4.addresses = [ {
                        address = "10.75.0.2";
                        prefixLength = 24;
                } ];
        };
        networking.interfaces.ens19 = { # PROXMOX VE (vmbr0)
                ipv4.addresses = [ {
                        address = "192.168.10.251";
                        prefixLength = 24;
                } ];
        };

        services.tailscale.enable  = true;
        services.tailscale = {
                useRoutingFeatures = "server";
                extraUpFlags = [
                        "--advertise-routes=192.168.10.0/24,10.75.0.0/24"
                ];
        };
        networking.nftables.enable = true;
        networking.firewall = {
                enable = true;
                trustedInterfaces = [ config.services.tailscale.interfaceName ];
                allowedUDPPorts = [ config.services.tailscale.port ];
        };
        systemd.services.tailscaled.serviceConfig.Environment = [
                "TS_DEBUG_FIREWALL_MODE=nftables"
        ];
        systemd.network.wait-online.enable = true;
        boot.initrd.systemd.network.wait-online.enable = false;
        boot.kernel.sysctl = {
                "net.ipv4.conf.all.forwarding" = true;
        };
}

