{ pkgs, ... }:

let
  isNapePro = pkgs.writeShellScript "is-nape-pro-hidraw" ''
    node="/sys/class/hidraw/$1"

    ${pkgs.gnugrep}/bin/grep -q \
      '^HID_NAME=.*Nape Pro$' "$node/device/uevent" || exit 1

    case "$(${pkgs.coreutils}/bin/readlink -f "$node/device")" in
      *:1.1/*) echo yes ;;
      *) exit 1 ;;
    esac
  '';
in
{
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="hidraw", KERNEL=="hidraw*", PROGRAM="${isNapePro} %k", RESULT=="yes", TAG+="systemd", ENV{SYSTEMD_WANTS}+="nape-pro@%k.service"
  '';

  systemd.services."nape-pro@" = {
    description = "Read Nape Pro /dev/%i";
    bindsTo = [ "dev-%i.device" ];
    after = [ "dev-%i.device" ];

    serviceConfig = {
      ExecStart = "${pkgs.coreutils}/bin/cat /dev/%i";
      StandardOutput = "null";
      Restart = "on-failure";
      RestartSec = 1;
    };
  };
}
