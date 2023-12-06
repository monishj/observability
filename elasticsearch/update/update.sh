#!/bin/bash


echo "Check if update needed and possible";
for domain in `aws --profile dhc-full-admin es list-domain-names | jq -r '.DomainNames[] | .DomainName'`; do
    aws --profile dhc-full-admin es describe-elasticsearch-domain --domain-name ${domain} | jq -r '.DomainStatus.ServiceSoftwareOptions';
    es_state="$(aws --profile dhc-full-admin es describe-elasticsearch-domain --domain-name ${domain} | jq -r '.DomainStatus.ServiceSoftwareOptions.UpdateStatus')";
    if [ "${es_state}" == "ELIGIBLE" ];then
        echo "Trigger update for ${domain}";
        aws --profile dhc-full-admin es start-elasticsearch-service-software-update --domain-name "${domain}";
    else
        echo "Skipped domain ${domain} because of state ${es_state}";
    fi;
done;
