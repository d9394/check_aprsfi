#!/bin/sh
( echo "From:<bbbbb@cqcqcqcqcqcqcqcq.net>";
echo "To:<$2>";
echo "Subject: $1";
echo "$1"
echo "$3"
)|ssmtp -v $2
