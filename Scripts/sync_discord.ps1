# sync_discord.ps1
# This script reads colors from wal colors.css and updates the Better Discord custom CSS

# Paths
 $walColorsPath = "$env:USERPROFILE\.cache\wal\colors.css"
 $BetterDiscordCSS = "$env:USERPROFILE\AppData\Roaming\BetterDiscord\data\stable\custom.css"
 $TEMPLATE = "$env:USERPROFILE\AppData\Roaming\BetterDiscord\bd-template.css"
 $HEADER = "$env:USERPROFILE\AppData\Roaming\BetterDiscord\bd-header.css"

# Overwrite Better Discord Custom CSS using pywal color palette
Get-Content $HEADER | Set-Content $BetterDiscordCSS
Add-Content $BetterDiscordCSS ""
Get-Content $walColorsPath | Add-Content $BetterDiscordCSS
Add-Content $BetterDiscordCSS ""
Get-Content $TEMPLATE | Add-Content $BetterDiscordCSS