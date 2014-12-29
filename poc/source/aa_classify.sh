#!/bin/bash
#Script : AA_BUILD_MODEL
#Author : Rahulj
#Data 	: 30 Aug, 2014
#Desc	: This Script will be the generic classifier accepting input information for intended task  and providing flexibility to save/control/modiy the
#		: the output generated

################################
#GLOBAL VARIABLE LIST
################################
CONFIG_DIR=poc/config/
CLASSIFY_LIST=classifier.lst
MODEL_DIR=poc/model/
LOG_DIR=poc/logs/
SRC_DIR='poc/source'
LOG_FL=${LOG_DIR}/`date +%Y%m%d_%H%M`.log
OP_DIR=poc/output/
TMP_DIR=poc/_tmp_/
source ${SRC_DIR}/base_functions.sh
########################
#STEP: 1 Validate the inputs
########################
while true; 
do
	case "$1" in
		-b | --build)	if [ "$2" == "" -o "$3" == "" ]
						then
							echo "ERROR : Training Requires Both a valid Classifier Name and Test file"
							_usage_
							exit 1
						else
							echo "Staring Porcess...Please Check Log for Details: ${LOG_FL}" 
							date >> ${LOG_FL}
							echo "Starting Model Build Process with Classifier : $2 and Test $3 "  >> ${LOG_FL}
							build_model $2 $3
						fi
                      ;;
		-t | --test)	if [ "$2" == "" -o "$3" == ""  ]
						then
							echo "ERROR : Testing Requires Two parameters Model file and Test file"
							_usage_
							exit 1
						else
							echo "Staring Porcess...Please Check Log for Details: ${LOG_FL}"

							echo `date`" : Starting Training Process with "  >> ${LOG_FL}
							classify_main $2 $3 
						fi
						;;
                -p | --predict)    if [ "$2" == "" -o "$3" == ""  ]
                                                then
                                                        echo "ERROR : Testing Requires Two parameters Model file and Data file"
                                                        _usage_
                                                        exit 1
                                                else
                                                        echo "Staring Porcess...Please Check Log for Details: ${LOG_FL}"

                                                        echo `date`" : Predicting... "  >> ${LOG_FL}
	                                                predict_main $2 $3
                                                fi
                                                ;;

		-h | --help)	_usage_
						exit 0
						;;
		*)				echo "ERROR: Incorrect Option Used"
						_usage_
						exit 1
						;;
	esac
done

