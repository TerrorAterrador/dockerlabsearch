#!/usr/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"
orangeColour="\e[38;5;214m\033[1m"
darkRedColour="\e[38;5;124m\033[1m"  


function ctrl_c() {
  echo -e "${redColour}[!] Saliendo...${endColour}"
  if [ -e tmp_dataOrdenada.txt ]; then
    rm tmp_dataOrdenada.txt -f
  fi
  tput cnorm; exit 1
}

function cerrar_flujo() {
  [ -e tmp_dataOrdenada.txt ] && rm tmp_dataOrdenada.txt -f
  [ -e tmp_data.txt ] && rm tmp_data.txt -f
  tput cnorm; exit 1
}

function panel() {
  echo -e "\n${turquoiseColour}"
  echo "  _____             _             _       _     _____                     _     "
  echo " |  __ \           | |           | |     | |   / ____|                   | |    "
  echo " | |  | | ___   ___| | _____ _ __| | __ _| |__| (___   ___  __ _ _ __ ___| |__  "
  echo " | |  | |/ _ \ / __| |/ / _ \ '__| |/ _\` | '_ \\\___ \ / _ \/ _\` | '__/ __| '_ \ "
  echo " | |__| | (_) | (__|   <  __/ |  | | (_| | |_) |___) |  __/ (_| | | | (__| | | |"
  echo " |_____/ \___/ \___|_|\_\___|_|  |_|\__,_|_.__/_____/ \___|\__,_|_|  \___|_| |_|"
  echo -e "${endColour}\n"
}

 # Ctrl+C
trap ctrl_c INT
tput civis # Ocultamos el cursor desde el primer momento

#Variable global
data=$(curl -s "https://dockerlabs.es/api/machines")
dataOrdenada="$(curl -s "https://dockerlabs.es/api/machines" | jq -r '.data[] | "{\(.name)} ; \(.downloadUrl) ; \(.size.value) ; [\(.difficulty)] ; Creator:\(.owner.name)"')"
echo "$dataOrdenada" > tmp_dataOrdenada.txt
echo "$data" > tmp_data.txt

function helpPanel(){
  echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Uso:${endColour}"
  echo -e "\t${purpleColour}h)${endColour} ${grayColour}Mostrar este panel de ayuda${endColour}"
  echo -e "\t${purpleColour}a)${endColour} ${grayColour}Listar todas las máquinas disponibles${endColour}"
  echo -e "\t${purpleColour}m)${endColour} ${grayColour}Mostrar información de una máquina a partir de su nombre${endColour}"
  echo -e "\t${purpleColour}c)${endColour} ${grayColour}Filtrar máquinas por creador${endColour}"
  echo -e "\t${purpleColour}d)${endColour} ${grayColour}Filtrar máquinas por dificultad ${grayColour}(${endColour}${blueColour}Muy Fácil${endColour} ${grayColour}-${endColour} ${greenColour}Fácil${endColour} ${grayColour}-${endColour} ${orangeColour}Media${endColour} ${grayColour}-${endColour} ${redColour}Difícil${endColour}${grayColour})${endColour}${endColour}"
  echo -e "\t${purpleColour}s)${endColour} ${grayColour}Filtrar máquinas por tamaño en MB${endColour}"
  echo -e "\t\t${purpleColour}g)${endColour} ${grayColour}Filtrar máquinas con un tamaño mayor al especificado${endColour}"
  echo -e "\t\t${purpleColour}l)${endColour} ${grayColour}Filtrar máquinas con un tamaño menor al especificado${endColour}\n"

}

function searchMachine() {
  
  machineNameUserUser="$1"

  # Regex
  regex="\{.*${machineNameUser}.*\}.*"

  #Checkers
  machine_checker=$(cat tmp_dataOrdenada.txt | awk -F';' '{print $1}' | grep "$machineNameUser" | tr -d '{}' | column)
  machine_checker2=$(cat tmp_dataOrdenada.txt | awk -F';' '{print $1}' | grep "$machineNameUser" | wc -l)
  machine_name=$(cat tmp_dataOrdenada.txt | awk -F';' '{print $1}' | grep "$machineNameUser" | tr -d '{}' | awk '{$1=$1; print}')

  download_link=$(cat tmp_dataOrdenada.txt | grep -oP $regex | awk -F';' '{print $2}' | tr -d " ")
  difficulty=$(cat tmp_dataOrdenada.txt | grep $regex | awk -F';' '{print $4}' | tr -d " " | tr -d "[]")
  autor=$(cat tmp_dataOrdenada.txt | grep $regex | awk -F';' '{print $NF}' | awk '{$1=$1; print}' | sed "s/Creator://")
  size=$(cat tmp_dataOrdenada.txt | grep $regex | awk -F';' '{print $3}' | tr -d " ")

  if [ ! "$machine_checker2" -gt 1 ]; then
    if [ ! -z "$machine_checker" ]; then
      if [ $difficulty -eq 0 ]; then
          echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Información de la máquina${endColour} ${blueColour}$machine_name${endColour}${grayColour}:${endColour}\n"
          echo -e "\t ${grayColour}- Autor/es:${endColour} ${yellowColour}$autor${endColour}"
          echo -e "\t ${grayColour}- Dificultad: ${endColour}${blueColour}Muy Fácil${endColour}"
          echo -e "\t ${grayColour}- Link Descarga: ${endColour}${redColour}$download_link${endColour}"
          echo -e "\t ${grayColour}- Tamaño:${endColour} ${turquoiseColour}$size MB${endColour}\n"
      elif [ $difficulty -eq 1 ]; then
          echo -e "${yellowColour}[+]${endColour} ${grayColour}Información de la máquina${endColour} ${greenColour}$machine_name${endColour}${grayColour}:${endColour}\n"
          echo -e "\t ${grayColour}- Autor/es: ${endColour}${yellowColour}$autor${endColour}"
          echo -e "\t ${grayColour}- Dificultad: ${endColour}${greenColour}Fácil${endColour}"
          echo -e "\t ${grayColour}- Link Descarga: ${endColour}${redColour}$download_link${endColour}"
          echo -e "\t ${grayColour}- Tamaño: ${endColour}${turquoiseColour}$size MB${endColour}\n"
      elif [ $difficulty -eq 2 ]; then
          echo -e "${yellowColour}[+]${endColour} ${grayColour}Información de la máquina${endColour} ${orangeColour}$machine_name${endColour}${grayColour}:${endColour}\n"
          echo -e "\t ${grayColour}- Autor/es: ${endColour}${yellowColour}$autor${endColour}"
          echo -e "\t ${grayColour}- Dificultad: ${endColour}${orangeColour}Media${endColour}"
          echo -e "\t ${grayColour}- Link Descarga: ${endColour}${redColour}$download_link${endColour}"
          echo -e "\t ${grayColour}- Tamaño:${endColour} ${turquoiseColour}$size MB${endColour}\n"
      elif [ $difficulty -eq 3 ]; then
          echo -e "${yellowColour}[+]${endColour} ${grayColour}Información de la máquina${endColour} ${redColour}$machine_name${endColour}${grayColour}:${endColour}\n"
          echo -e "\t ${grayColour}- Autor/es: ${endColour}${yellowColour}$autor${endColour}"
          echo -e "\t ${grayColour}- Dificultad: ${endColour}${redColour}Difícil${endColour}"
          echo -e "\t ${grayColour}- Link Descarga: ${endColour}${redColour}$download_link${endColour}"
          echo -e "\t ${grayColour}- Tamaño: ${endColour}${turquoiseColour}$size MB${endColour}\n"
      fi
    else
      echo -e "\n${redColour}[!] No existe ninguna máquina con este nombre:${endColour} ${blueColour}$machineNameUser${endColour}"
    fi
  else
    echo -e "\n${redColour}[!] Existen varias máquinas con ese nombre: \n\n\t${endColour}${blueColour}$machine_checker${endColour}"
  fi
}

function all_machines(){
  
  echo -e "\n${yellowColour}[+]${endColour}${grayColour} Listando todas las máquinas disponibles en ${endColour}${blueColour}dockerlabs${endColour}${grayColour} ordenadas por fecha de publicación:${endColour}\n"
  echo -e "${grayColour}"
  cat tmp_dataOrdenada.txt | awk -F';' '{print $1}'| tr -d '{}' | column
  echo -e "${endColour}"
}

function searchDifficulty(){
  
  difficulty_user="$1"
  difficulty_lower="${difficulty,,}"

  difficultys=("muy facil" "muy fácil" "facil" "fácil" "media" "dificil" "difícil")
  encontrado=0

  for difficulty in "${difficultys[@]}"; do
    if [ "$difficulty_lower" == "$difficulty" ]; then
      encontrado="1"
    fi
  done

  
  if [ "$encontrado" -eq "1" ]; then
    if [ "$difficulty_lower" == "muy fácil" ] || [ "$difficulty_lower" == "muy facil" ]; then
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Listando todas las máquinas de dificultad ${endColour}${blueColour}Muy Fácil${endColour}${grayColour}:${endColour}\n"
      echo -e "${blueColour}"
      cat tmp_dataOrdenada.txt | grep "\[0\]" | awk -F';' '{print $1}' | tr -d "{}" | awk '{$1=$1; print}' | column
      echo -e "${endColour}"

    elif [  "$difficulty_lower" == "fácil" ] || [ "$difficulty_lower" == "facil" ]; then
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Listando todas las máquinas de dificultad ${endColour}${greenColour}Fácil${endColour}${grayColour}:${endColour}\n"
      echo -e "${greenColour}"
      cat tmp_dataOrdenada.txt | grep "\[1\]" | awk -F';' '{print $1}' | tr -d "{}" | awk '{$1=$1; print}' | column
      echo -e "${endColour}"
    elif [  "$difficulty_lower" == "media" ]; then
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Listando todas las máquinas de dificultad ${endColour}${orangeColour}Media${endColour}${grayColour}:${endColour}\n"
      echo -e "${orangeColour}"
      cat tmp_dataOrdenada.txt | grep "\[2\]" | awk -F';' '{print $1}' | tr -d "{}" | awk '{$1=$1; print}' | column
      echo -e "${endColour}"
    elif [  "$difficulty_lower" == "díficil" ] || [ "$difficulty_lower" == "dificil" ]; then
      echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Listando todas las máquinas de dificultad ${endColour}${redColour}Difícil${endColour}${grayColour}:${endColour}\n"
      echo -e "${redColour}"
      cat tmp_dataOrdenada.txt | grep "\[3\]" | awk -F';' '{print $1}' | tr -d "{}" | awk '{$1=$1; print}' | column
      echo -e "${endColour}"
    fi
  else
    echo -e "\n${redColour}[!] La dificultad "$difficulty_user" no existe ${endColour}"
    cerrar_flujo
  fi
}

function searchCreator() {
  
  creator="$1"

  creator_checker=$(cat tmp_dataOrdenada.txt | grep -i -oP ".*Creator:.*${creator}.*" | wc -l)
  creator_real="$(cat tmp_dataOrdenada.txt | grep -i -oP ".*Creator:.*${creator}.*" | head -n1 | awk -F';' '{print $NF}' | sed "s/Creator://" | awk '{$1=$1; print}')"

  if [ $creator_checker -eq 0 ]; then
    echo -e "\n${redColour}[!] El creador${endColour} ${blueColour}"$creator"${endColour}${redColour} no existe${endColour}"
    cerrar_flujo
  else
    echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Máquinas creador por${endColour} ${blueColour}${creator_real}${endColour}${grayColour}:${endColour}\n"
    echo -e "${grayColour}"
    cat tmp_dataOrdenada.txt | grep -oP -i ".*Creator:.*${creator}.*" | awk -F';' '{print $1}' | tr -d "{}" | column
    echo -e "${endColour}"
  fi
}

function is_number() {
    input="$1"
    if [[ $input =~ ^-?[0-9]+$ ]] || [[ $input =~ ^-?[0-9]*\.[0-9]+$ ]]; then
        return 0
    else
        return 1
    fi
}


function searchSize(){

  size="$1"
  comparator=""

  if [ "$size" == "-g" ] || [ "$size" == "-l" ]; then
    echo -e "\n${redColour}[!] Se debe proporcinar un tamaño${endColour}\n"
    cerrar_flujo
  fi

  if [ $mayor -eq 1 ] && [ $menor -eq 1 ]; then
    echo -e "\n${redColour}[!] Debes seleccionar únicamente una opción ( ${endColour}${turquoiseColour}-g[mayor]${endColour}  ${redColour}/${endColour}  ${turquoiseColour}-l[menor]${endColour}${redColour} )${endColour}\n"
    cerrar_flujo
  elif [ $mayor -eq 0 ] && [ $menor -eq 0 ]; then
    echo -e "\n${redColour}[!] Debes seleccionar al menos una opción ( ${endColour}${turquoiseColour}-g [mayor]${endColour}  ${redColour}/${endColour}  ${turquoiseColour}-l [menor]${endColour}${redColour} )${endColour}\n"
    cerrar_flujo
  fi


  if is_number "$size"; then
    if [ $mayor -eq 1 ]; then
      comparator=">="
      echo -e "${yellowColour}[+]${endColour} ${grayColour}Listando las máquinas que ocupan más de${endColour} ${turquoiseColour}$size MB${endColour}${grayColour}:${endColour}\n"
      echo -e "${grayColour}"
      cat tmp_data.txt | jq -r --arg size "$size" --arg comparison "$comparator" '.data[] | select (.size.value | tonumber '$comparator' ($size | tonumber)) | "{\(.name)};\(.size.value)"' | tr -d "{}" | awk -F';' '{print $1 "[" $2 "]"}' |column
      echo -e "${endColour}"

    elif [ $menor -eq 1 ]; then
      comparator="<="
      echo -e "${yellowColour}[+]${endColour} ${grayColour}Listando las máquinas que ocupan menos de${endColour} ${turquoiseColour}$size MB${endColour}${grayColour}:${endColour}\n"
      echo -e "${grayColour}"
      cat tmp_data.txt | jq -r --arg size "$size" --arg comparison "$comparator" '.data[] | select (.size.value | tonumber '$comparator' ($size | tonumber)) | "{\(.name)};\(.size.value)"' | tr -d "{}" | awk -F';' '{print $1 "[" $2 "]"}' |column
      echo -e "${endColour}"
    fi
  else
    echo -e "${redColour}[!] ${endColour}${turquoiseColour}$size ${redColour}no es un número${endColour}"
    cerrar_flujo
  fi

}

#Indicadores
declare parameter_counter=0
declare help_flag=0

mayor=0
menor=0

panel; while getopts "ham:d:c:s:gl" arg; do
  case $arg in
    h) let help_flag+=1;;
    m) 
      machineNameUser="$OPTARG"; let parameter_counter+=1;;
    a) let parameter_counter+=2;;
    d) difficulty="$OPTARG"; let parameter_counter+=3;;
    c) creator="$OPTARG"; let parameter_counter+=4;;
    s) size="$OPTARG"; let parameter_counter+=5;;
    g) mayor=1 ;;
    l) menor=1 ;;
    \?) 
      echo -e "\n${redColour}[!] Parámetro inválido${endColour}"
      helpPanel 
      cerrar_flujo
      ;;
    :)
      case "$OPTARG" in
        m) 
          echo -e "\n${redColour}[!] Ingresa el nombre de la máquina${endColour}"
          cerrar_flujo
          ;;
      esac
  esac
done 2>/dev/null

if [ $parameter_counter -eq 1 ]; then
  searchMachine "$machineNameUser"
elif [ $parameter_counter -eq 2 ]; then
  all_machines
elif [ $parameter_counter -eq 3 ]; then
  searchDifficulty "$difficulty"
elif [ $parameter_counter -eq 4 ]; then
  searchCreator "$creator"
elif [ $parameter_counter -eq 5 ];then
  searchSize "$size"
elif [ $help_flag -eq 1 ]; then
  helpPanel
else
  echo -e "\n${redColour}[!] No se ha proporcinado ningún parámetro${endColour}\n"
  helpPanel
fi

tput cnorm
[ -e tmp_dataOrdenada.txt ] && rm tmp_dataOrdenada.txt -f
[ -e tmp_data.txt ] && rm tmp_data.txt -f
