{ config, pkgs, ... }:


{
  users.users.spcpolice = {
    name = "spcpolice";
    home = /Users/spcpolice;
  };
  system.primaryUser = "spcpolice";
  system.defaults.dock = {
    autohide = true;
    autohide-delay = 0.0;
    autohide-time-modifier = 0.25;
    orientation = "right";
  };
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
  };
  system.defaults.trackpad = {
    Clicking = true;
    TrackpadRightClick = true;
    TrackpadThreeFingerDrag = true;
  };
  system.defaults.screencapture = {
    target = "clipboard";
  };
  system.defaults.NSGlobalDomain."com.apple.trackpad.scaling" = 2.5;
   launchd.user.agents.aerospace = {
     serviceConfig = {
       ProgramArguments = [
         "/Applications/Aerospace.app/Contents/MacOS/Aerospace"
       ];
       RunAtLoad = true;
       KeepAlive = false;
     };
   };

   homebrew = {
     enable = true;
     brews = [
        "opencode"
     ];
     casks = [
       "google-chrome"
       "firefox"
     ];
   };
 }
