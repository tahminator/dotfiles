# launch bitwarden and allow browser integration
ALLOW_BROWSER_INTEGRATION_OVERRIDE=true /Applications/Bitwarden.app/Contents/MacOS/Bitwarden >>/dev/null 2>&1 &
disown
