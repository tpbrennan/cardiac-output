#!/bin/bash
# assume input vile is csv with end of line separated by <CR>

# init
f1="export_echo.dsv" # input file frmo SQL with <CR> as line terminator
f2="echo_values.csv" # output file

if [ -a $f2 ] ; then
    rm $f2
fi

if [ -a $f1 ] ; then
    
    rm $f1 

    # remove lines
    cat $1 | tr '\n' ' ' > temp.csv 

    # Replace <CR> with '\n'
    cat temp.csv | tr '\n\r' '\n' > $f1

    rm temp.csv
fi

echo "SUBJECT_ID,HADM_ID,ICUSTAY_ID,CHARTTIME,VALUE" >> $f2

while read line
do
    lvef=`echo $line | grep -o -e ' [0-9][0-9]\%' -e '\?[0-9][0-9]\%' -e \<[0-9][0-9]\% -e \>[0-9][0-9]\% -e [0-9][0-9]-[0-9][0-9]\% | head -1 | awk -F\% '{print $1}'`
    sid=`echo $line | awk -F\| '{print $1","$2","$3","$4","}'`
    
    echo $sid $lvef >> $f2

done < $f1

