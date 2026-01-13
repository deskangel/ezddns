This project provides a simple way to automatically update your Cloudflare DNS records with your current dynamic global ipv6 address.

These scripts and configurations support both macOS and Linux.

# Script files

## record_id.sh
This script fetches the `DNS record ID` for a specified domain from Cloudflare.

## ddns.sh
This script updates the DNS Record with the current IP address.

# Configuration

## Prerequisites

For privacy reasons, the following variables are saved in `~/.config/cloudflare/`.

### `API Token` and `Zone ID`
In order to update the DNS Record to Cloudflare, you need to get your Cloudflare `API Token` and `Zone ID`. You can obtain these values from the Cloudflare dashboard.
Save the values to `~/.config/cloudflare/api_token` and `~/.config/cloudflare/zone_id`.

**DO NOT confuse the `API Key` with the `API Token`.**

### `DNS record ID`
1. Create a new AAAA record for your domain, the IP address can be ::1.
2. Save the domain (like `sub.example.com`) to `~/.config/cloudflare/domain`.
3. Run the `record_id.sh` script to fetch the Record id:
```bash
bash record_id.sh
```
4. Save the Record id to `~/.config/cloudflare/record_id`.

## Settings

Now we have the following configuration files to run `ddns.sh`:

- `~/.config/cloudflare/api_token`: Your Cloudflare API Token.
- `~/.config/cloudflare/zone_id`: The Zone ID for your domain.
- `~/.config/cloudflare/domain`: The domain name you want to query (e.g., `example.com` or `sub.example.com`).
- `~/.config/cloudflare/record_id`: The `DNS record ID` for the domain.

Alternatively, you can assign the `values` to the variables in `ddns.sh` directly.

You can run `ddns.sh` manually by executing the following command:

```bash
bash ddns.sh
```

# Auto-run

## macOS

To automatically run the `ddns.sh` script every hour, you can use `launchd`. Create a new file in `~/Library/LaunchAgents/` called `com.example.ddns.plist` with the following content:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.example.ddns</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>/usr/local/bin/ddns</string>
    </array>

    <key>StartInterval</key>
    <integer>300</integer>
    <key>StandardOutPath</key>
    <string>/tmp/ddns.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/ddns_err.log</string>
</dict>
</plist>
```
Please follow these steps:

1. Put the `ddns.sh` script in `/usr/local/bin/`.
2. Keep the `Label` key value the same as the plist file name.
3. `StartInterval` is in seconds, so set it to the value you want.

Then, load the plist file using the following command:
```bash
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.example.ddns.plist
```
**In case you want to unload the plist file in the future, replace the `bootstrap` with `bootout`.**

Then, test the service once using the following command:
```bash
launchctl kickstart -p gui/$(id -u)/com.example.ddns
```

Then, check the status of the service using the following command:
```bash
launchctl list | grep com.example.ddns
```
if the result is like the following, it means the service has started successfully:
```bash
-       0   com.example.ddns
```

If the second column is not zero, check the log files using the following command:
```bash
cat /tmp/ddns.log
cat /tmp/ddns_err.log
```

## Linux

In `Linux`, we use `cron` to run the scheduled task. 

Put the `ddns.sh` script in `/usr/local/bin/`, then use `crontab -e` to edit your crontab file.

```bash
0 * * * * /usr/local/bin/ddns.sh
```
The above task runs the `ddns.sh` script every hour.
