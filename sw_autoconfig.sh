#!/usr/bin/env bash

#maxfrequency=$(printf %.0f $(lscpu -b -p=MAXMHZ | tail -n -1| cut -d , -f 1))
#minfrequency=$(printf %.0f $(lscpu -b -p=MINMHZ | tail -n -1 | cut -d , -f 1))
basefrequency=$(lscpu | grep "Model name" | cut -d @ -f 2 | cut -d G -f 1)
basefrequency=$(expr ${basefrequency}\*1000 | bc | cut -d . -f 1)
maxfrequency=$(($basefrequency * 2))
minfrequency=$(($basefrequency - 1000))

echo "
{
  \"verbose\": true,
  \"stream\": true,
  \"input\": {
    \"puller\":{
      \"type\": \"mongodb\",
      \"uri\": \"mongodb://127.0.0.1\",
      \"db\": \"powerapi\",
      \"collection\": \"hwpcsensor\"
    }
  },
  \"output\": {
    \"pusher_power\": {
      \"type\": \"csv\",
      \"model\": \"PowerReport\",
      \"uri\": \"/tmp/sensor_output/\"
    }
  },
  \"cpu-frequency-base\": $basefrequency,
  \"cpu-frequency-min\": $minfrequency,
  \"cpu-frequency-max\": $maxfrequency,
  \"cpu-error-threshold\": 2.0,
  \"disable-dram-formula\": true,
  \"sensor-report-sampling-interval\": 1000
}
" > ./smartwatts_config.json

