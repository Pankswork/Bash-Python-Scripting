#!/bin/bash

#Author:Pankaj kumar
echo $(date)

#This script will add commit and push to orgin branch 

git add .
git commit -m "$1"
git push origin main
