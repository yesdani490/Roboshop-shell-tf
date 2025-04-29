#!/bin/bash
Names=$@
IMAGEID=ami-03265a0778a880afb 
SECURITYGROUGID=sg-08105091605f3144d 
INSTACETYPE=""
HOSTEDZONE=Z05740803UNSE6BOTDZEC
DOMAIN_NAME=joindevops.top
for i in "$@"
do
  if [[ $i == "mongo" || $i == "mysql" ]]
  then 
       INSTACETYPE="t2.small"
    else
       INSTACETYPE="t2.micro"
 fi

 IpAddress=$(aws ec2 run-instances --image-id $IMAGEID --count 1 --instance-type $INSTACETYPE --security-group-ids $SECURITYGROUGID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$i}]" | jq -r '.Instances[0].PrivateIpAddress')
 echo "creating instance $i $IpAddress $Names"

#aws route53 change-resource-record-sets --hosted-zone-id $HOSTEDZONE --change-batch file "
# {
#                 " Comment ": " CREATE ",
#                  " Changes ": [ {
#                              " Action ": " CREATE ",
#                             " ResourceRecordSet ": { 
#                                 " Name ": " $i.$DOMAIN_NAME ",
#                                     " Type ": " A ",
#                                      " TTL ": 300,
#                                   " ResourceRecords ": [{" Value ": " $IpAddress "}]
#                             }},
# "
 aws route53 change-resource-record-sets --hosted-zone-id "$HOSTEDZONE" --change-batch "{
  \"Comment\": \"CREATE\",
  \"Changes\": [
    {
      \"Action\": \"CREATE\",
      \"ResourceRecordSet\": {
        \"Name\": \"$i.$DOMAIN_NAME\",
        \"Type\": \"A\",
        \"TTL\": 300,
        \"ResourceRecords\": [
          {
            \"Value\": \"$IpAddress\"
          }
        ]
      }
    }
  ]
}"

done