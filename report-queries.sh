#!/bin/sh
curl -G 'localhost:8086/query?pretty=true' --data-urlencode "db=powerapi_formula" --data-urlencode "q=SELECT * FROM \"power_consumption\""


sudo docker exec -it researchproject-power-api-smartwatts-1 bash
#Extract the PowerApi folder containing power reports
sudo docker cp researchproject-power-api-smartwatts-1:/opt/powerapi /home/maxi/Desktop/Work/ResearchProject
