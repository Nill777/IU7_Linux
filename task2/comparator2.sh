#!/bin/bash
# Проверка корректности количества переданных аргументов
[[ "$#" = 2 || "$#" = 3 ]] || exit 1
# Проверка существования обоих файлов
[[ -f "$1" && -f "$2" ]] || exit 1
# Проверка возможности чтения обоих файлов
[[ -r "$1" && -r "$2" ]] || exit 1
# Корректность ключа verbose
[[ "$#" = 3 && "$3" != "-v" ]] && exit 1
[[ "$#" = 3 && "$3" = "-v" ]] && echo "Дополнительная информация: -"
# Поиск маркера начала сравнения
coincidence1=0
while read text1; do
        for cell1 in $text1; do
                if [[ "$cell1" =~ "string:" ]]; then
                # Флаг существования маркера в первом тексте
			coincidence1=1
                fi
        done
done < $1
coincidence2=0
while read text2; do
        for cell2 in $text2; do
                if [[ "$cell2" =~ "string:" ]]; then
                # Флаг существования маркера во втором тексте
			coincidence2=1
                fi
        done
done < $2
# Проверка наличия маркера начала сравнения
if [[ "$coincidence1" != 1 && "$coincidence2" != 1 ]]; then
	echo "В обоих текстах нет маркера начала сравнения (string:)"
	exit 1
else
	if [[ "$coincidence1" != 1 ]]; then
		echo "В первом тексте нет маркера начала сравнения (string:)"
		exit 1
	elif [[ "$coincidence2" != 1 ]]; then
		echo "Во втором тексте нет маркера начала сравнения (string:)"
		exit 1
fi
fi
# Сохранияем старый разделитель и изменяем его
ifs="$IFS"
IFS=""
# Собираем из первого текста всё, что после маркера в первый массив
arrstr1=()
# Счётчик для индекса первого массива
i1=0
# Флаг для первой строки
first_str1=1
while read text1; do
	if [[ "$first_str1" = 1 ]]; then
        	if [[ "$text1" =~ "string:" ]]; then
        		arrstr1[$i1]={"$(echo "$(echo "$text1" | grep -Eo "string:.*")")"}
        		i1=$(($i1+1))
			first_str1=0
		fi
	elif [[ "$first_str1" = 0 ]]; then
		arrstr1[$i1]={"$text1"}
        	i1=$(($i1+1))	
        fi
done < $1
# Собираем из второго текста всё, что после маркера во второй массив
arrstr2=()
# Счётчик для индекса второго массива
i2=0
# Флаг для первой строки
first_str2=1
while read text2; do
	if [[ "$first_str2" = 1 ]]; then
        	if [[ "$text2" =~ "string:" ]]; then
        		arrstr2[$i2]={"$(echo "$(echo "$text2" | grep -Eo "string:.*")")"}
        		i2=$(($i2+1))
			first_str2=0
		fi
	elif [[ "$first_str2" = 0 ]]; then
		arrstr2[$i2]={"$text2"}
        	i2=$(($i2+1))	
        fi
done < $2
# Проверяем длины массивов
if  [[ "${#arrstr1[@]}" != "${#arrstr2[@]}" ]]; then
	echo "Тексты в файлах $1 и $2 не совпадают"
	exit 1
else
	# Проверяем совпадение элементов массива
	for i in ${!arrstr1[@]}; do
		if [[ "${arrstr1[$i]}" != "${arrstr2[$i]}" ]]; then
			echo "Тексты в файлах $1 и $2 не совпадают"
			exit 1
		fi
	done
fi
echo "Тексты в файлах $1 и $2 совпадают"
IFS="$ifs"
exit 0
