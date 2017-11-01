# How to use 

./ipv4-divide 192.168.2.0/24 0 

## The subnet mask should be performed under CIDR. We will get alert like below if User use mask

./ipv4-divide 192.168.2.0/255.255.255.0 0

You definitely can convert your mask to CIDR http://goo.gl/uhEzik

## We just able to divide the subnet smaller than current one (/24). We should not divide larger subnet, It cause Network unstable 

./ipv4-divide 192.168.2.0/22 0 

IP Overlap! Please input the CIDR equal or larger than 24

## How many cases We have in sub-divide network 

I think We have 2 cases of divide 

Firstly, The network pre defined equal 0 

Secondly, The network pre-defined larger than 0

## Mechanism 

 
