#!/bin/bash


# INPUT variables
PARAM_1="$1"; # The first parameter   (i.e) 192.168.0.0/24
PARAM_2="$2"; # The second parameter  (i.e) 3

# Parsing variables
octet1=$(echo ${PARAM_1} | tr "." " " | awk '{ print $1 }')
octet2=$(echo ${PARAM_1} | tr "." " " | awk '{ print $2 }')
octet3=$(echo ${PARAM_1} | tr "." " " | awk '{ print $3 }')
octet4=$(echo ${PARAM_1} | tr "." " " | awk '{ print $4 }' | cut -d/ -f1)
CORRECT_MASK=$(echo ${PARAM_1} | tr "." " " | awk '{ print $4 }' | cut -d/ -f2)
WRONG_MASK=$(echo ${PARAM_1} | awk -F'/' '{print $2}')
CURRENT_IPS_PER_SUBNET=`echo "256/2^(8-(32-$CORRECT_MASK))" | bc`;
CURRENT_MAX_SUBNET=`echo "$CURRENT_IPS_PER_SUBNET/4" | bc`;
#4 because We have reserve 3 for network/broadcast address, number of hosts and assign gateway.1 is host

# OUTPUT variables

SUBNET="";
NETWORK="";
GATEWAY="";
BROADCAST="";
HOSTS="";


# Validate variables.

if [[ $# -ne 2 ]] ; then
    printf " Missing Variables ! Examples 192.168.1.0/24 [space] 3 ";
    exit 1;
fi;

if [[ $WRONG_MASK == *['!'.]* ]]; then
     printf " You definitely can convert your mask to CIDR http://goo.gl/uhEzik ";
     exit 1;
fi;

if [[ $CORRECT_MASK -lt 24 ]]; then
    echo " IP Overlap! Please input the CIDR equal or larger than 24 ";
    exit 1;
fi;


if [[ ${CURRENT_MAX_SUBNET} -lt ${PARAM_2} ]]; then
    printf " We cannot divide ! Because IP range on subnet does not enough IP address ";
    exit 1;
fi;

### Calculation ###

if [[ ${PARAM_2} -eq 0 ]]; then

t=0;  # A temporary variable
SUBNET=$(echo "${octet1}.${octet2}.${octet3}.${octet4}/$CORRECT_MASK");
NETWORK=$(echo "${octet1}.${octet2}.${octet3}.${octet4}");

t=`echo "${octet4}+1" | bc `;
GATEWAY=$(echo "${octet1}.${octet2}.${octet3}.${t}");

t=`echo "${octet4}+${CURRENT_IPS_PER_SUBNET}-1" | bc `;
BROADCAST=$(echo "${octet1}.${octet2}.${octet3}.${t}");
HOSTS=$(echo "`echo "${CURRENT_IPS_PER_SUBNET}-3" | bc`");


echo "Subnet=$SUBNET
Network=$NETWORK
Gateway=$GATEWAY
Broadcast=$BROADCAST
Hosts=$HOSTS
";

fi;

REMAINDER=${PARAM_2};    # REMAINDER VARIABLE is to keep track of still how many
SUM=0;					 # subnets are yet to be created . Other varibles are all
j=0;					 # just temporary usage variables.
COUNT=0;
FLAG=0;
SUM1=0;
TEMP1=${octet4};


# !!!!!!!!!!!! !!!!! !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# THIS IS THE MAIN FUNCTION OF THIS PROGRAM WHICH CALCULATE AND PRINTS THE VALUES
function POW_OF_2 {

SUM1=`echo "${SUM1}+$1" | bc ` ;
a=`echo "$CORRECT_MASK+${SUM1}" | bc `;
CURRENT_IPS_PER_SUBNET=`echo "2^(32-$a)" | bc`;
b=$CURRENT_IPS_PER_SUBNET;
LIMIT=0;


# If flag=1 , Subnetting is over
#If flag=0 , further subnetting is there

if [[ FLAG -eq 1 ]]; then
	LIMIT=`echo "2^$1" | bc`;
else
	LIMIT=`echo "(2^$1)-1" | bc`
fi

# Main Calculations

for (( m=1; m<=${LIMIT}; m++ )) ; do

q=`echo "${TEMP1}+(${m}-1)*${b}" | bc `;
SUBNET=$(echo "${octet1}.${octet2}.${octet3}.${q}/$a");
NETWORK=$(echo "${octet1}.${octet2}.${octet3}.${q}");

q=`echo "${q}+1" | bc `;
GATEWAY=$(echo "${octet1}.${octet2}.${octet3}.${q}");

q=`echo "${q}+${b}-2" | bc `;
BROADCAST=$(echo "${octet1}.${octet2}.${octet3}.${q}");

HOSTS=$(echo "${b}-3" | bc);

echo "Subnet=$SUBNET
Network=$NETWORK
Gateway=$GATEWAY
Broadcast=$BROADCAST
Hosts=$HOSTS
";

done;

TEMP1=`echo "${q}+1" | bc `;
}
#echo "HI NEXT ${TEMP1}";
function FLOOR_POW_OF_2 {

	TEMP=${1};
	SUM=0;j=0;

	until [[ ${SUM} -ge ${TEMP} ]]; do
		SUM=`echo "2^${j}" | bc `;  # 0,1,2,4,8,16,32,.....
		COUNT=`echo "${j}-1" | bc `;
		j=`echo "${j}+1" | bc `;    # 0,1,2,3,4,5,.........
	done
		#echo "HI ${COUNT}"


		if [[ ${SUM} -eq ${TEMP} ]]; then
			FLAG=1;
			COUNT=`echo "${COUNT}+1" | bc`;
			POW_OF_2 ${COUNT};
			REMAINDER=0;
		else
			FLAG=0;
			POW_OF_2 ${COUNT};
			REMAINDER=`echo "(${TEMP}-${SUM}/2)+1" | bc`;
			# Power of 2 extraction.
		fi

}

while [[ ${REMAINDER} -ne 0 ]]; do
	FLOOR_POW_OF_2 ${REMAINDER};
done;