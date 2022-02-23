# AzureAuditing
A collection of scripts and resources to help with getting a better understanding of whats going on in Azure for security or compliance.
### [Azure Privileged Review](https://github.com/ResistanceIsUseless/AzureAuditing/blob/main/azure_privileged_review.sh)
This script breaks down all Privileged access in Azure.
1. Show all users, groups, service principles that are have Owner, Contibutor, Admin or AcrPush in the role.
2. Show users in these groups (todo: Add expanding subgroups)
3. Show addtional information about Service Principles
4. Show OAuth permissions for anything with "ReadWrite.All" *Biggest concern would be Directory.ReadWrite.All*
