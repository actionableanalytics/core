################################################
# Import Source of Individual Classifiers
################################################
source ${SRC_DIR}/lib_svm
source ${SRC_DIR}/lib_j48
source ${SRC_DIR}/lib_randomf
source ${SRC_DIR}/lib_NaiveBayes
source ${SRC_DIR}/lib_BayesNet

function _usage_
{
	echo "AA_CLASSIFY : Classification utility for AA POC"
	echo "USAGE : Train - aa_classify -b <Classifier_name> <file name : needs to be an arff file > "
	echo "TEST/EVALUATE : aa_classify -t <Model_name> <file name : needs to be an arff file >"
	echo "PREDICT : aa_classify -p <Model_name> <file name>"
	echo "Models will be created in ${MODEL_DIR}"
	echo "Logs will be created in ${LOG_DIR}"
}

function print_results
{
awk  ' BEGIN { print "===Prediction Results ==="; } \
{ if(strt_flg == 1 && "$1" != "" && "$3" != "" ) printf("%15s %30s \n",$1,$3);\
else if($1=="inst#") {strt_flg=1; printf("%15s %30s \n","Instance no.","Predicted Class");} } \
END { print "===End Of Results ==="; }' $1 | tee -a ${LOG_FL}
rm -v $1
}
function predict_main
{
        tmp_c_id=`echo $1 | cut -d "_"  -f 1-1`
        tmp_c_nm=` awk -F "|" -v x=$tmp_c_id '{if($1==x)print $2 }' ${CONFIG_DIR}/${CLASSIFY_LIST}`
        if [ "${tmp_c_nm}" == "" ]
        then
                echo "ERROR : Model Name Invalid. Please check Model Naem Provided."
                exit 1
        fi
        echo "Model has been built using Classifier : ${tmp_c_nm}" | tee -a ${LOG_FL}
        echo "Testing..." | tee -a ${LOG_FL}
        pr_${tmp_c_nm} $1 $2
        exit 0
}


function extract_metadata {
        new_nm=`echo "${MODEL_DIR}/${1}" | sed 's/\.mld/\.meta/g'`
        echo $new_nm
        echo "% Meta definition Created : "`date` > ${new_nm}
        while read lin;
        do
                echo $lin >> ${new_nm}
                if echo $lin | grep -qi '^@data' ;
                then
                        break;
                fi
        done < $2
        echo ${new_nm}" : Metadata for model has been created" | tee  -a  ${LOG_FL}
}


function print_eval_summ 
{
awk  '{ if(strt_flg == 1 && "$1" != "" ) { _n_ = _n_ +1 ;\
x=NF-1; \
if( NF > 1 && $x == "+") { \
_errno_ = _errno_ + 1; \
_error_ = _error_ + $NF; \
_rms_ = _rms_ + $NF*$NF; } } \
else if($1=="inst#") strt_flg=1; \
} END { print "=== Evaluation Summary ==="; \
printf(" Total Number of Instances \t : %16.4f \n Instances Incorrectly Classified: %16.4f \n Mean absolute error \t\t : %16.4f \n Root mean squared error \t : %16.4f \n",_n_,_errno_,_error_/_n_,sqrt(_rms_/_n_));} ' $1

}


function build_model
{
	_found_=0
	while read class_name;
	do
		c_id=`echo $class_name | cut -d "|" -f 1`
		c_fname=`echo $class_name | cut -d "|" -f 2`
		if [ "${c_id}" == "$1" ]
		then
			echo "FOUND $c_fname for the $c_id requested...evoking function"  >> ${LOG_FL}
			bm_${c_fname} $2
			_found_=1
			break
		fi
	done < ${CONFIG_DIR}/${CLASSIFY_LIST}
	if [ $_found_ == 0 ]
	then
		echo "ERROR : Classifier  Not Found. Please validate the inputs."
		exit 1
	else
		exit 0
	fi
}

function classify_main 
{
	tmp_c_id=`echo $1 | cut -d "_"  -f 1-1`
	tmp_c_nm=` awk -F "|" -v x=$tmp_c_id '{if($1==x)print $2 }' ${CONFIG_DIR}/${CLASSIFY_LIST}`
	if [ "${tmp_c_nm}" == "" ]
	then
		echo "ERROR : Model Name Invalid. Please check Model Naem Provided."
		exit 1
	fi
	echo "Model has been built using Classifier : ${tmp_c_nm}" | tee -a ${LOG_FL}
	echo "Testing..." | tee -a ${LOG_FL}
	tm_${tmp_c_nm} $1 $2
	exit 0
}
