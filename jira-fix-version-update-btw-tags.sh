JIRAURL='COMPANY_JIRA_URL'


function query {
	git log ${tag1}..${tag2} --pretty=oneline | perl -ne '{ /(\w+)-(\d+)/ && print "$1-$2\n" }' | sort | uniq
}

echo -e "Find jira issues going into this release"
query > output.json

cat > input.json <<EOF
{
   "update":{
      "fixVersions":[
         {
            "add":{
               "name":"v1.0"
            }
         }
      ]
   }
}
EOF

function updateIssue {
curl -D- -u "$1":"$2" -X PUT --data @input.json -H "Content-Type: application/json" "$JIRAURL/rest/api/2/issue/$3"
}

# update issues going into this release with fix_Version 
echo "Updaing jira issues"
 
TOTAL=`cat output.json | wc -l`
echo "Total issues to be updated is: $TOTAL"

while read ISSUE; do
 	echo "updating "$OUTPUT"..."
 	updateIssue "$JIRAUSER" "$JIRAPASSWD" "$ISSUE"
 	echo "done"
 	sleep 3
done < output.json
