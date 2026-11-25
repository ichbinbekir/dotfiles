# Flutter + Android SDK for the whole KDE Plasma session.
# Plasma sources this at login and then hands the environment to systemd, so every app
# (Konsole/fish, VS Code, ...) gets it. Log out and back in after a change.
# Not in environment.d: the login (SDDM + Plasma) overwrites PATH from there.
# Tools live in their default places: Flutter via FVM in ~/fvm, Android SDK in ~/Android/Sdk.
export ANDROID_HOME="$HOME/Android/Sdk"
case ":$PATH:" in
    *":$HOME/fvm/default/bin:"*) ;;
    *) export PATH="$HOME/fvm/default/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH" ;;
esac
