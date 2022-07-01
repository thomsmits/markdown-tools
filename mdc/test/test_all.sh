#!/usr/bin/bash

for file in ./*.rb; do
  echo -e "\n\n--------------------------------------------"
  echo "Executing: $file"
  ruby "$file"
  if [ $? -ne 0 ]
    then
      exit
  fi
done

echo -e "\n\n"
echo "==============================="
echo "Finished without errors"
echo "==============================="

