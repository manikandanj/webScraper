if (( $# != 4 && $# != 5 ))
then
	echo "Usage: ./ocr.sh <Image Name> <State Name> [Starting String] <IsTranslationRequired>"
	exit
fi

skipOcr=0
skipTable=0
skipAutomation=0
individualRecords=0

if (( $# == 5 ))
then
	for i in $(echo $5 | sed "s/,/ /g")
	do
		option=`echo $i |awk '{print tolower($0)}'`

		case $option in
			"all")
				;;
			"ocr")
				skipOcr=1
				echo "**** Skipping OCR Generation ****"
				;;
			"table")
				echo "**** Skipping CSV Generation ****"
				skipTable=1
				;;
			"automation")
				echo "**** Skipping Automation ****"
				skipAutomation=1
				;;
			"ocr,table")
				echo "**** Skipping OCR, CSV Generation ****"
				skipOcr=1
				skipTable=1
				;;
			"individual")
				individualRecords=1
				;;
		esac
	done
fi

stateCode=""
case $2 in
	"Bihar")
		stateCode="br"
		;;
	"Uttar Pradesh")
		stateCode="up"
		;;
	"Madhya Pradesh")
		stateCode="mp"
		;;
	"Jharkhand")
		stateCode="jh"
		;;
	"Rajasthan")
		stateCode="rj"
		;;
	"Punjab")
		stateCode="pb"
		;;
	"Jammu")
		stateCode="jk"
		;;
	*)
		stateCode="invalid"
esac

echo -e "\n********************* If you want to see the ocr data, cat output.txt *********************\n"

if (( $skipOcr != 1 ))
then
	echo -e "\n******** Calling google vision api *******"
	python3 ocr_vision.py $1 > bounds.txt
	sed "s/@@statename@@/$stateCode/g; s/@@startingtext@@/$3/g; s/@@translationvalue@@/$4/g" ocrconfig.meta.orig > ocrconfig.meta
fi

if (( $skipTable != 1 ))
then
	echo -e "\n******** Using ocrconfig.meta, change ocrconfig.meta.orig for x and y intervals ******* "
	cat ocrconfig.meta
	echo -e "******** ++++++++ *******"
	python3 googlevision.py ocrconfig.meta $1
fi
cp output.txt ../.tmp/$stateCode.txt

if (( $skipAutomation != 1 && $individualRecords != 1 ))
then
	cd ..
	echo -e "\n******** Calling automation.py for $2  ******* "
	./automation.py "$2" "full" "ocr"
fi

if (( $individualRecords == 1 ))
then
	cd ..
	case $2 in
		"Bihar")
			./biharIndividual.py
			;;
		*)
			echo "No custom script found"
			;;
	esac
fi
