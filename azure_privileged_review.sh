#!/bin/bash
echo "Pulling Subscriptions"
# example for scoping -> az account list --all --query '[?name.contains(@,`"Prod"`)||name.contains(@,`"Manage"`)]' -o tsv  > Subscriptions.txt
az account list --all -o tsv  > Subscriptions.txt
az role assignment list --include-groups --all --include-inherited > ALL_Role_Assignments.json
subscriptions=$(az account list --query '[].id' -o tsv)
for sub in ${subscriptions};do
  echo "Setting Subscription to ${sub}"
  az account set --subscription "${sub}"
  echo "Pulling Role Assignments and saving as $sub.Role_Assignments.txt"
  mkdir $sub
  az role assignment list --include-groups --include-inherited --all >  ./$sub/All_Role_Assignments.json
  oauthgrants=$(az ad app permission list-grants -r --query '[?contains(scope,`ReadWrite.All`)].clientId' -o tsv)
  for oauthid in ${oauthgrants};do az ad sp show --id ${oauthid};done >  ./$sub/Priv_OAuth_Permissions.json
  az role assignment list --include-groups --include-inherited --all --query '[].{"principalName":principalName,"principalType":principalType,"roleDefinitionName":roleDefinitionName,"scope":scope}' --out tsv |
  while IFS=$'\t' read -r name role perm scope spid;
  do
    if [[ "$perm" == *"Contributor"* ]]
    then
      if [[ "$role" == "Group" ]]
      then
         echo "Pulling Members of "${name}" and saving as ./$sub/"${name//[[:space:]]/}".txt"
         az ad group member list --group "${name}" --query '[].{"displayName":displayName,"accountenabled":accountEnabled}' --output tsv > ./$sub/${name//[[:space:]]/}.txt
         groupdetails=$(az ad group member list --group "${name}" --query '[].{"displayName":displayName,"accountenabled":accountEnabled}' --output tsv < ./$sub/${name//[[:space:]]/}.txt)
         echo $name ,$role ,$perm, $scope, ${groupdetails//True/Active;} >> ./$sub/Priv_Role_Assignments.csv
     elif [[ "$role" == "ServicePrincipal" ]]
     then
      spidinfo=$(az ad sp show --id ${name} --query '{"appDisplayName":appDisplayName}' -o tsv)
      az ad sp show --id ${name} --query '{"appDisplayName":appDisplayName,"objectType":objectType,"servicePrincipalType":servicePrincipalType,"oauth2Permissions":oauth2Permissions}' >> ./$sub/SP_Details.json
      echo ${spidinfo},$role ,$perm, $scope, $name | tee -a ./$sub/Priv_Role_Assignments.csv
      else
        echo $name ,$role ,$perm, $scope | tee -a ./$sub/Priv_Role_Assignments.csv
      fi
    elif [[  "$perm" == *"Owner"* ]]
    then
      if [[ "$role" == "Group" ]]
       then
         echo "Pulling Members of "${name}" and saving as ./$sub/"${name//[[:space:]]/}".txt"
         az ad group member list --group "${name}" --query '[].{"displayName":displayName,"accountenabled":accountEnabled}' --output tsv > ./$sub/${name//[[:space:]]/}.txt
         groupdetails=$(az ad group member list --group "${name}" --query '[].{"displayName":displayName,"accountenabled":accountEnabled}' --output tsv < ./$sub/${name//[[:space:]]/}.txt)
         echo $name ,$role ,$perm, $scope, ${groupdetails//True/Active;} >> ./$sub/Priv_Role_Assignments.csv
      elif [[ "$role" == "ServicePrincipal" ]]
       then
         spidinfo=$(az ad sp show --id ${name} --query '{"appDisplayName":appDisplayName}' -o tsv)
         az ad sp show --id ${name} --query '{"appDisplayName":appDisplayName,"objectType":objectType,"servicePrincipalType":servicePrincipalType,"oauth2Permissions":oauth2Permissions}' >> ./$sub/SP_Details.json
         echo ${spidinfo},$role ,$perm, $scope, $name >> ./$sub/Priv_Role_Assignments.csv
      else
        echo $name ,$role ,$perm, $scope >> ./$sub/Priv_Role_Assignments.csv
      fi
    elif [[  "$perm" == *"Admin"* ]]
    then
      if [[ "$role" == "Group" ]]
       then
         echo "Pulling Members of "${name}" and saving as ./$sub/"${name//[[:space:]]/}".txt"
         az ad group member list --group "${name}" --query '[].{"displayName":displayName,"accountenabled":accountEnabled}' --output tsv > ./$sub/${name//[[:space:]]/}.txt
         groupdetails=$(az ad group member list --group "${name}" --query '[].{"displayName":displayName,"accountenabled":accountEnabled}' --output tsv < ./$sub/${name//[[:space:]]/}.txt)
         echo $name ,$role ,$perm, $scope, ${groupdetails//True/Active;} >> ./$sub/Priv_Role_Assignments.csv
      elif [[ "$role" == "ServicePrincipal" ]]
       then
         spidinfo=$(az ad sp show --id ${name} --query '{"appDisplayName":appDisplayName}' -o tsv)
         az ad sp show --id ${name} --query '{"appDisplayName":appDisplayName,"objectType":objectType,"servicePrincipalType":servicePrincipalType,"oauth2Permissions":oauth2Permissions}' >> ./$sub/SP_Details.json
         echo ${spidinfo},$role ,$perm, $scope, $name >> ./$sub/Priv_Role_Assignments.csv
      else
        echo $name ,$role ,$perm, $scope >> ./$sub/Priv_Role_Assignments.csv
      fi
    elif [[  "$perm" == "AcrPush" ]]
    then
      if [[ "$role" == "Group" ]]
       then
         echo "Pulling Members of "${name}" and saving as ./$sub/"${name//[[:space:]]/}".txt"
         az ad group member list --group "${name}" --query '[].{"displayName":displayName,"accountenabled":accountEnabled}' --output tsv > ./$sub/${name//[[:space:]]/}.txt
         groupdetails=$(az ad group member list --group "${name}" --query '[].{"displayName":displayName,"accountenabled":accountEnabled}' --output tsv < ./$sub/${name//[[:space:]]/}.txt)
         echo $name ,$role ,$perm, $scope, ${groupdetails//True/Active;} >> ./$sub/Priv_Role_Assignments.csv
      elif [[ "$role" == "ServicePrincipal" ]]
       then
         spidinfo=$(az ad sp show --id ${name} --query '{"appDisplayName":appDisplayName}' -o tsv)
         az ad sp show --id ${name} --query '{"appDisplayName":appDisplayName,"objectType":objectType,"servicePrincipalType":servicePrincipalType,"oauth2Permissions":oauth2Permissions}' >> ./$sub/SP_Details.json
         echo ${spidinfo},$role ,$perm, $scope, $name >> ./$sub/Priv_Role_Assignments.csv
      else
        echo $name ,$role ,$perm, $scope >> ./$sub/Priv_Role_Assignments.csv
      fi
    fi
  done
done
echo "Export Completed"
