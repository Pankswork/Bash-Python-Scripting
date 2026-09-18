#!/bin/bash

#Author=Pankaj kumar
#Date=21/07/2025

echo "Enter 2 number"
read n1
read n2
echo -e "Press number for operation 1.Additon\n2.Subtaction\n3.Multiply\n4.Divide"
read x
if [ $x -eq 1 ]; then
echo "addition of number $n1 + $n2 = $(($n1 + $n2))"
elif [ $x -eq 2 ]; then
echo "subtraction of number $n1 - $n2 = $(($n1 - $n2))"
elif [ $x -eq 3 ]; then
echo "multiply of number $n1 * $n2 =  $(($n1 * $n2))"
elif [ $x -eq 4 ]; then
	if [ $n2 -eq 0 ]; then
        	echo "Cannot divide by zero!"
	else
		result=$(echo "scale=2; $n1 / $n2" | bc)
		echo "divide of number $n1 / $n2 = $result"
	fi
else
echo "Invalid option"
fi

