#!/bin/bash
############################################################################
###                               Spirobot                               ###
###    Dumps dns records from dnsdumpster, pings results to identify     ###
### valid servers, then crawls through the robots.txt file of main host  ###
###      looking for any misconfigured or exposed endpoints.             ###
### Finally outputs endpoints and response codes. Grep for 200 for fun!  ###
###    Use only for education and authorized research -- MrBreadcrumbs   ###
############################################################################

echo "RoboCrawler, the robots.txt crawler!"
echo "Input url(example.com) or ip address"
echo -ne " >> "
read URL
echo ''

#get robots.txt
curl -L -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101 Firefox/68.0" -s "https://www."$URL"/robots.txt" |grep ":" | cut -d "/" -f 2-  >> curl_res.txt;
chmod +r curl_res.txt;
number_results=$(wc -l ./curl_res.txt)
echo "Got robots.txt file!"
echo "$number_results directories to scan!"
#handle csrf and get cookies
middleware_token=$(curl -s -i -c cookies.txt -b cookies.txt https://dnsdumpster.com/ | grep middleware | cut -d "=" -f 7 | cut -d '"' -f 2;)
echo "Got CSRFMiddlewareToken! $middleware_token"

#gets dnsdumpster results, greps and cuts for ip addresses
curl -s -i -c cookies.txt -b cookies.txt -d "csrfmiddlewaretoken=$middleware_token&targetip=$URL" -e "https://dnsdumpster.com" -A "Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101 Firefox/68.0" https://dnsdumpster.com/ > dumpster_results.txt
cat dumpster_results.txt | grep "?q" | cut -d "=" -f 5 | cut -d '"' -f 1 | grep -v http | sort -u > targlist.txt;
cat dumpster_results.txt | grep "?q" | cut -d "=" -f 5 | cut -d '"' -f 1 | grep http | cut -d '/' -f 3 | sort -u > domains.txt;
echo "Got DNSDumpster Results!"

#pings ip list to check if target up
echo "Checking targets..."
targ_check="./targlist.txt"
while i= read -r line
do
    ping -W 1 -c 1 $line >> ping_results.txt;
done < "$targ_check"

#grep and cut to get responsive ips; list
cat ping_results.txt | grep icmp | cut -d " " -f 4 | cut -d ":" -f 1 > clean_targlist.txt;
#add domains just in case
cat domains.txt >> clean_targlist.txt;
number_targets=$(wc -l ./clean_targlist.txt)
echo "There are $number_targets available to scan!"

echo "Enumerating directories in responsive ips..."

#start loop through target ips
while f= read -r line;
do
    echo "Enumerating $line..."
    #start loop through dirs on each ip
    while d= read -r dir;
    do
        curl --max-time 1 -o /dev/null --silent --head --write-out "%{http_code} https://$line/$dir\n" "https://$line/$dir" >> response_codes.txt;
    done < "./curl_res.txt"
done < "./clean_targlist.txt"

cp response_codes.txt final_results.txt;
cat response_codes.txt;
echo "results in ./final_results.txt"

#cleanup
rm clean_targlist.txt;rm response_codes.txt; rm curl_res.txt; rm dumpster_results.txt; rm targlist.txt; rm ping_results.txt; rm domains.txt;
