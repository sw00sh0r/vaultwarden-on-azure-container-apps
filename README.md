# Vaultwarden on Azure Container Apps

This repo contains the bicep files to deploy [Vaultwarden](https://github.com/dani-garcia/vaultwarden) on an Azure Container App. It also contains an empty SQLite database required to setup Vaultwarden using an Azure file share.

For more details visit my blog post: [https://blog.mwiedemeyer.de/post/2023/Vaultwarden-Bitwarden-on-Azure-Container-Apps/](https://blog.mwiedemeyer.de/post/2023/Vaultwarden-Bitwarden-on-Azure-Container-Apps/)

To run this template you can execute:

`az deployment group create --resource-group YOU_RESOURCE_GROUP_NAME --template-file main.bicep`

or click this button:

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fmwiedemeyer%2Fvaultwarden-on-azure-container-apps%2Fmain%2Fmain.json)

# Configuration

## SMTP
The bicep file is pre-configured to use a personal gmail account as smtp provider. In order to make the smtp authentication work the gmail account must have set a [less secure app password](https://support.google.com/accounts/answer/185833?hl=en).

## Admin token
Most secure way is to generate an argon2 hash as admin password for the `/admin` site of vaultwarden server. The hash can be generated via './vaultwarden hash` command inside the vaultwarden container.
