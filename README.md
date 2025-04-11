# Vaultwarden on Azure Container Apps

This repo contains the bicep files to deploy [Vaultwarden](https://github.com/dani-garcia/vaultwarden) on an Azure Container App. It also contains an empty SQLite database required to setup Vaultwarden using an Azure file share.

For more details visit my blog post: [https://blog.mwiedemeyer.de/post/2023/Vaultwarden-Bitwarden-on-Azure-Container-Apps/](https://blog.mwiedemeyer.de/post/2023/Vaultwarden-Bitwarden-on-Azure-Container-Apps/)

To run this template you can execute:

`az deployment group create --resource-group YOU_RESOURCE_GROUP_NAME --template-file main.bicep`

or click this button:

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fsw00sh0r%2Fvaultwarden-on-azure-container-apps%2Frefs%2Fheads%2Fmain%2Fmain.json)

# Configuration

## SMTP
The bicep file is pre-configured to use a personal gmail account as smtp provider. In order to make the smtp authentication work the gmail account must have set a [less secure app password](https://support.google.com/accounts/answer/185833?hl=en).

## Admin token
Most secure way is to generate an argon2 hash as admin password for the `/admin` site of vaultwarden server. The hash can be generated via `./vaultwarden hash` command inside the vaultwarden container.

# Cloudflare

## Custom domain

Custome domain for the container app can be bought for at Cloudflare. In order to make it work with the container app, a few things need to be done.

### Configuration Cloudflare

#### Certificate

1. In Cloudflare dashboard under `SSl/TLS -> Origin server` an origin certificiate must be created
2. You receive a certificate in pem format and and the key. Both values must be copied and saved manually as `.pem` and `.key` file
3. After that a `.pfx` file be created: 
```bash 
openssl pkcs12 -inkey cloudflare.key -in cloudflare.pem -export -out cloudflare.pfx
``` 

#### DNS Records

In order to setup the correct DNS records go to `DNS -> Records` and add the two records requird by [Azure](#configuration-azure).

#### Web Application Firewall (WAF)

Create two rules for more security in `Security -> WAF -> Custom rules`

1. Create new custom rule and name it `Geoblocking all foreign countries`
2. Field: `Country`, Operator: `does not equal`, Value: `Germany`
3. This blocks all requests for your domain, which are not originated from Germany

1. Create new custom rule and name it `Block Admin Page`
2. Field: `Hostname`, Operator: `equals`, Value: `example.com`
2. Field: `URI Path`, Operator: `contains`, Value: `/admin
2. Field: `IP Soruce Address`, Operator: `does not equal`, Value: `your own public ip which accesses the vaults admin page, e.g. 89.124.56.76`
3. This blocks all requests for vaultwarden's `admin` page, which are not from your own public ip address.

### Configuration Azure

In Azure go to your container app and select `Settings -> Custom Domain -> Add custom domain`

1. Select bring your own certificate and upload the [generated](#certificate) `.pfx` file
2. Insert the `password` for the `.pfx` file which you set while creating it
3. Add the shown [dns records](#dns-records) in Cloudflare
4. After the records in Cloudflare are set and saved, hit `validate` and `save`.

# Automation

If your public ip is not static and your ISP changes your ip every 24 hours, the public ip in your [WAF rule](#web-application-firewall-waf) must be updated accordingly.

Therefore a script is needed, which uses `Cloudflare API` to update the `WAF rule`.

## Dynamic DNS

This solution uses a `dynamic DNS` from [DuckDNS](https://www.duckdns.org/). To keep the `dynamic DNS` updated, a `cron job` on a `Raspberry PI` is used.

1. Go to [DuckDNS install page](https://www.duckdns.org/install.jsp) and select linux GUI
2. Add the created script to crontab, optionally add a timestamp in the first line of the script for the log `date +%d-%m-%y/%H:%M:%S`
```bash
*/5 * * * * /home/helly/duckdns/duck.sh >> /var/log/duckdns.log 2>&1
```
3. Make sure the folder `duckdns` in `/var/log` is owned by the user, which runs the cron job. `Chown user:user duckdns` changes ownership of that folder.

## Cloudflare API

You need your [Global API Key](https://dash.cloudflare.com/profile/api-tokens) from your Cloudflare account in order to make the update script for the `WAF rule` work.

1. Copy the `update-cloudflare-firewall-rule.sh` to your `Raspberry PI`
2. Make sure the current user can execute the script
3. Fill in the `placeholders` in the script. Most of the can be found in Cloudflare Dashboard under `Security -> WAF -> Custom rules -> Geoblocking all foreign countries`, scroll down and expand `Save with API call`
4. Make sure that your `dynamic dns` in replaced with `exampledomain.duckdns.org` in Line 1 of the script
5. Add the script to crontab, optionally add a timestamp in the first line of the script for the log `date +%d-%m-%y/%H:%M:%S`
```bash
*/30 * * * * /home/helly/cloudflare/updateFirewall.sh >> /var/log/cloudflare/updateFirewall.log 2>&1
```
