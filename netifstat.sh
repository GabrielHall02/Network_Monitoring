#!/bin/bash


# Functions
function parser () {
    iface=$2;   # interface
    t=$1        # time
    # echo $t
    if [ $# -eq 1 ];then
        
        # read -d ---> delimiter " "
        # read -a ---> create array  
        # netstat -i ---> displays statistics for the network
        # egrep -v ---> filter and invert selection (egrep = grep -E)
        # sort -u k1,1 ---> remove duplicates from column 1
        # awk ---> filter : column 3 != 0 and return the values of the column 1,3 and 7
        read -d -r -a array <<<  $(netstat -i | egrep -v "Iface|Kernel" |sort -u -k1,1 | awk '{print $1,$3,$7}')
        for ((i=0;i<=${#array[@]}-1;i+=3));do

        netif=${array[i]}
        ti=${array[i+1]}
        ri=${array[i+2]}
        sleep $t
        #Creating another array to calculate final values
        read -d -r -a arrayy <<<  $(netstat -i | egrep -v "Iface|Kernel" |sort -u -k1,1 | awk '{print $1,$3,$7}')
        tf=${arrayy[i+1]}  
        rf=${arrayy[i+2]}

        tx=$((tf - ti))
        rx=$((rf - ri))
        trate=$(echo |awk -va=$tx -vb=$t '{ print a/b}') 
        rrate=$(echo |awk -va=$rx -vb=$t '{ print a/b}')

        if [ $i -eq "0" ];then
        printf "%6s %5s %5s %5s %5s\n" NETIF TX RX TRATE RRATE
        fi
        printf "%6s %5s %5s %5s %5s\n" $netif $tx $rx $trate $rrate
        done

    elif [[ "$iface" != "" ]];then
        read -d -r -a array <<<  $(netstat -i | egrep -v "Iface|Kernel" | grep -w "$iface" | awk '{print $1,$3,$7}')

        for ((i=0;i<=${#array[@]}-1;i+=3));do

        netif=${array[i]}
        ti=${array[i+1]}
        ri=${array[i+2]}
        sleep $t
        read -d -r -a arrayy <<<  $(netstat -i | egrep -v "Iface|Kernel" | grep -w "$iface" | awk '{print $1,$3,$7}')
        tf=${arrayy[i+1]}
        rf=${arrayy[i+2]}

        tx=$((tf - ti))
        rx=$((rf - ri))
        trate=$(echo |awk -va=$tx -vb=$t '{ print a/b}') 
        rrate=$(echo |awk -va=$rx -vb=$t '{ print a/b}')

        if [ $i -eq "0" ];then
        printf "%5s %5s %5s %5s %5s\n" NETIF TX RX TRATE RRATE
        fi
        printf "%5s %5s %5s %5s %5s\n" $netif $tx $rx $trate $rrate

        done   
    fi
}
# End functions

# Validating Arguments
if [ $# -eq 1 ] || [ "$1" = "-p" ] || [[ "$1" = "-t" ]] || [[ "$1" = "-r" ]] || [[ "$1" = "-T" ]] || [[ "$1" = "-R" ]] || [[ "$1" = "-v" ]] || [[ "$1" = "-c" ]] || [[ "$1" = "-l" ]] || [[ "$1" = "-b" ]] || [[ "$1" = "-k" ]] || [[ "$1" = "-m" ]];then
echo "please wait ..."
# Método tempo (sem parametros além de um int)
if [ $# -eq 1 ];then
    if ! [[ "$1" =~ ^[0-9]+$ ]]   # Se $1 for um número chama a função parser como parametro de entrada $1
    then
    echo "Invalid argument -> netifstat.sh [time] time is an int"     
    else
    parser $1
    fi
fi

# Métodp -p n --> Número de interfaces --> Array composta por multiplos de 3 por isso é só fazer multiplos de 3 consoante o p de entrada
#$1 = -p ; $2 = n ; $3 = t
if [ $1 == "-p" ]; then
    if [ $# -eq 3 ]; then 
    t=$3        #time
    read -d -r -a array <<<  $(netstat -i | egrep -v "Iface|Kernel" | awk '{print $1,$3,$7}')
    if [[ $2 -le $((${#array[@]} / 3)) ]];then # if n_interfaces <= n_interfaces da array: length(array)/3 = n interfaces
    for ((i=0;i<=($2*3)-1;i+=3));do # Percorre todos os elementos da array

    netif=${array[i]}
    ti=${array[i+1]}
    ri=${array[i+2]}
    sleep $t
    read -d -r -a arrayy <<<  $(netstat -i | egrep -v "Iface|Kernel" | awk '{print $1,$3,$7}')
    tf=${arrayy[i+1]}
    rf=${arrayy[i+2]}

    tx=$((tf - ti))
    rx=$((rf - ri))
    trate=$(echo |awk -va=$tx -vb=$t '{ print a/b}') #Using awk to calculate the rates -va declares variable a
    rrate=$(echo |awk -va=$rx -vb=$t '{ print a/b}')

    if [ $i -eq "0" ];then
    printf "%6s %5s %5s %5s %5s\n" NETIF TX RX TRATE RRATE
    fi
    printf "%6s %5s %5s %5s %5s\n" $netif $tx $rx $trate $rrate
    done
    else
    echo "Invalid number of interfaces"
    fi
    else
    echo "Invalid number of arguments -> netifstat.sh -p [n interface] [time]"
    fi
fi

# Método -t sort TX || -r sort RX || -T sort trate || -R sort rrate || -v reverse order
if [[ "$1" = "-t" ]] || [[ "$1" = "-r" ]] || [[ "$1" = "-T" ]] || [[ "$1" = "-R" ]] || [[ "$1" = "-v" ]];then
    if [[ "$2" =~ ^[0-9]+$ ]];then
    declare -A tst
    t=$2        #time
    read -d -r -a array <<<  $(netstat -i | egrep -v "Iface|Kernel" | awk '{print $1,$3,$7}')
    for ((i=0;i<=${#array[@]}-1;i+=3));do

    netif=${array[i]}
    ti=${array[i+1]}
    ri=${array[i+2]}
    sleep $t
    read -d -r -a arrayy <<<  $(netstat -i | egrep -v "Iface|Kernel" | awk '{print $1,$3,$7}')
    tf=${arrayy[i+1]}
    rf=${arrayy[i+2]}

    tx=$((tf - ti))
    rx=$((rf - ri))
    trate=$(echo |awk -va=$tx -vb=$t '{ print a/b}') 
    rrate=$(echo |awk -va=$rx -vb=$t '{ print a/b}')
    

    c=$((i /  3)) # counter
    # Creating map with tx||rx||trate||rrate || iface as keys
    case $1 in
        -t)
            if [[ " ${tst[@]} " =~ " ${tx} " ]];then #--> checking if value exists in array 
            key=$((tx + c))
            tst[$key]="$netif $tx $rx $trate $rrate"
            else
            tst[$tx]="$netif $tx $rx $trate $rrate"
            fi
            ;;
        -r)
            if [[ " ${tst[@]} " =~ " ${rx} " ]];then
            key=$((rx + c))
            tst[$key]="$netif $tx $rx $trate $rrate"
            else
            tst[$tx]="$netif $tx $rx $trate $rrate"
            fi
            ;;
        -T)
            if [[ " ${tst[@]} " =~ " ${trate} " ]];then
            key=$((trate + c))
            tst[$key]="$netif $tx $rx $trate $rrate"
            else
            tst[$trate]="$netif $tx $rx $trate $rrate"
            fi
            ;;
        -R)
            if [[ " ${tst[@]} " =~ " ${rrate} " ]];then
            key=$((rrate + c))
            tst[$key]="$netif $tx $rx $trate $rrate"
            else
            tst[$rrate]="$netif $tx $rx $trate $rrate"
            fi
            ;;
        -v)
            tst[$i]="$netif $tx $rx $trate $rrate"
            ;;
    esac

    
    if [ $i -eq "0" ];then
    printf "%6s %5s %5s %5s %5s\n" NETIF TX RX TRATE RRATE 
    fi
    done
    
    # Basicamente isto cria um array com as sorted keys e depois dá print da array normal a partir da ordem da array das sorted keys
    declare -a keys #->Declaring array 
    for key in ${!tst[@]};do
        keys+=("$key")
    done
    IFS=$'\n' #--> Delilimter = \n -> Importante porque o sort faz sort por linha
    sorted=($(sort -r<<<"${keys[*]}")) #--> criar sorted com keys -> sort em reverse order (-r)

    for key in "${sorted[@]}"; do
        IFS=' ' #new delimiter = ' '
        read -a line_arr <<< ${tst[$key]} #Creating array in sorted order
        printf "%6s %5s %5s %5s %5s\n" ${line_arr[0]} ${line_arr[1]} ${line_arr[2]} ${line_arr[3]} ${line_arr[4]}

    done
    
    else
    echo "Invalid arguments netifstat.sh [-t/-r/-T/-R/-v] [time]"
    fi
    
fi

#Metodo -c "string" "time"
if [[ "$1" = "-c" ]];then
    if [ "$2" != "" ];then
        read -d -r -a interfaces <<<  $(netstat -i | egrep -v "Iface|Kernel" | awk '{print $1}')
        for element in ${interfaces[@]}
        do  
            if [[ $element =~ ^$2 ]]; then
                parser $3 $element
            fi
        done
    else
    printf "%s " Invalid Argument: $2
    fi
fi

#Método -l time --> Repete de t em t --> falta adicioonar colunas extra
if [[ "$1" = "-l" ]]; then
    if ! [[ "$2" =~ ^[0-9]+$ ]]
        then
        echo "Invalid Argument"
        else
        c=0 #->Counter
        t=$2 #->Time
        while :
        do
            read -d -r -a array <<<  $(netstat -i | egrep -v "Iface|Kernel" |sort -u -k1,1 | awk '{print $1,$3,$7}')
            for ((i=0;i<=${#array[@]}-1;i+=3));do

                netif=${array[i]}
                ti=${array[i+1]}
                ri=${array[i+2]}
                sleep $t
                read -d -r -a arrayy <<<  $(netstat -i | egrep -v "Iface|Kernel" |sort -u -k1,1 | awk '{print $1,$3,$7}')
                tf=${arrayy[i+1]}  
                rf=${arrayy[i+2]}

                tx=$((tf - ti))
                rx=$((rf - ri))
                trate=$(echo |awk -va=$tx -vb=$t '{ print a/b}') 
                rrate=$(echo |awk -va=$rx -vb=$t '{ print a/b}')
                
                #Creating array to get new values
                declare -A old_array
                old_array[$netif]="$tx, $rx, $trate, $rrate, $txtot, $rxtot"

            done
            sleep $2
            echo 
            
            #Creating array to store old values
            declare -A store_array
            if [[ $c -eq "0" ]];then
                printf "%6s %5s %5s %5s %5s %5s %5s\n" NETIF TX RX TRATE RRATE TXTOT RXTOT
                for key in ${!old_array[@]}
                do
                IFS=', '
                read -r -a  info <<< ${old_array[$key]}
                #echo "${info[@]}"
                txtot=$((${info[4]} + ${info[0]}))
                rxtot=$((${info[5]} + ${info[1]}))
                #Print new values 
                printf "%6s %5s %5s %5s %5s %5s %5s\n" $key ${info[0]} ${info[1]} ${info[2]} ${info[3]} $txtot $rxtot
                #Store new values
                store_array[$key]="${info[0]},${info[1]},${info[2]},${info[3]},$txtot,$rxtot"
                
                done

                unset IFS
            else
                #echo debug
                printf "%6s %5s %5s %5s %5s %5s %5s\n" NETIF TX RX TRATE RRATE TXTOT RXTOT
                #Accessing stored values to add new values
                for key in ${!store_array[@]}
                do
                IFS=', '
                read -r -a  info <<< ${store_array[$key]}
                #echo "${info[@]}"
                txtot=$((${info[4]} + ${info[0]}))
                rxtot=$((${info[5]} + ${info[1]}))
                #Print new values
                printf "%6s %5s %5s %5s %5s %5s %5s\n" $key ${info[0]} ${info[1]} ${info[2]} ${info[3]} $txtot $rxtot
                #Store new values
                store_array[$key]="${info[0]},${info[1]},${info[2]},${info[3]},$txtot,$rxtot"
                done
                unset IFS
            fi
            let c++ 
        done
    fi
fi

#Método -b || -k || -m --> Transforma em bytes em vez de packets
if [[ "$1" = "-b" ]] || [[ "$1" = "-k" ]] || [[ "$1" = "-m" ]];then

IFS=$'\n'
read -r -d '\n' -a array <<< $(netstat -ie | sed '/inet/d' | sed '/ether/d' | sed '/RX error/d' | sed '/TX errors/d' | sed '/loop/d' | sed '1d' | cut -f1 -d":")
unset IFS

t=$2

for ((i=0;i<=${#array[@]}-1;i+=3));do
#echo ${array[$i]}
	netif=${array[i]}
        line1=(${array[i+1]})
        line2=(${array[i+2]})
        for ((j=0;j<=${#line1[@]}-1;j++));do
        	if [[ "${line1[j]}" == "bytes" ]];then
        		ri=${line1[j+1]}
        	fi
        done
        for ((j=0;j<=${#line2[@]}-1;j++));do
        	if [[ "${line2[j]}" == "bytes" ]];then
        		ti=${line2[j+1]}
        	fi
        done
	sleep $t

    IFS=$'\n'
    read -r -d '\n' -a new_array <<< $(netstat -ie | sed '/inet/d' | sed '/ether/d' | sed '/RX error/d' | sed '/TX errors/d' | sed '/loop/d' | sed '1d' | cut -f1 -d":")
    unset IFS
	
    	line1=(${new_array[i+1]})
        line2=(${new_array[i+2]})
        for ((j=0;j<=${#line1[@]}-1;j++));do
        	if [[ "${line1[j]}" == "bytes" ]];then
        		rf=${line1[j+1]}
        	fi
        done
        for ((j=0;j<=${#line2[@]}-1;j++));do
        	if [[ "${line2[j]}" == "bytes" ]];then
        		tf=${line2[j+1]}
        	fi
        done
        rx=$((rf - ri))
        tx=$((tf - ti))
	
	trate=$(echo |awk -va=$tx -vb=$t '{ print a/b}') 
        rrate=$(echo |awk -va=$rx -vb=$t '{ print a/b}')
        
        
        
        case $1 in
        -b)
            if [ $i -eq "0" ];then
        	printf "%6s %6s %6s %7s %7s\n" NETIF TX/b RX/b TRATE/b RRATE/b
            fi
            printf "%6s %6s %6s %7s %7s\n" $netif $tx $rx $trate $rrate
            ;;
        -k)
            if [ $i -eq "0" ];then
        	printf "%6s %6s %6s %7s %7s\n" NETIF TX/kb RX/kb TRATE/kb RRATE/kb
            fi
            tx=$(echo |awk -va=$tx '{ print a*0.001}') 
            rx=$(echo |awk -va=$rx '{ print a*0.001}') 
            trate=$(echo |awk -va=$trate '{ print a*0.001}')
            rrate=$(echo |awk -va=$rrate '{ print a*0.001}')
            printf "%6s %6s %6s %7s %8s\n" $netif $tx $rx $trate $rrate
            ;;
        -m)
            if [ $i -eq "0" ];then
        	printf "%6s %8s %8s %9s %9s\n" NETIF TX/mb RX/mb TRATE/mb RRATE/mb
            fi
            tx=$(echo |awk -va=$tx '{ print a*0.00001}') 
            rx=$(echo |awk -va=$rx '{ print a*0.00001}') 
            trate=$(echo |awk -va=$trate '{ print a*0.00001}')
            rrate=$(echo |awk -va=$rrate '{ print a*0.00001}')
            printf "%6s %8s %8s %9s %9s\n" $netif $tx $rx $trate $rrate
            ;;
    	esac
      
        
done
fi
else
echo "Invalid argument"
echo "Valid arguments: [-p] [-t] [-r] [-T] [-R] [-v] [-c] [-l] [-b] [-k] [-m]"
fi
