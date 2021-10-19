#!/bin/bash
set +m

# REGIONS is for all regions
# SINGLE is for one single region
declare REGIONS=`aws ec2 describe-regions --query "Regions[*].[RegionName]" --output text`
declare SINGLE='us-east-1'
#echo "$REGIONS"

for region in $REGIONS;do
{
	echo $region
	aws ec2 describe-instances --region $region | jq '[.Reservations | .[] | .Instances | .[] | select ( .Platform == "windows" and .State.Name == "running" ) |
	{
		ip: .PrivateIpAddress,
	}]' > ec2-win-ips-$region.txt
}
done

cat ec2-win-ips*.txt > ec2-win-ips.all
rm ec2-win-ips*.txt

# Remove empty lines and send to file.
awk 'NF' ec2-win-ips.all > clean1.txt
rm ec2-win-ips.all

# Clean above file
sed 's/\[.*//g;s/\].*//g;s/{.*//g;s/}.*//g;/^[[:space:]]*$/d;s/[\"ip\: "]//g' clean1.txt > results.txt
rm clean1.txt
