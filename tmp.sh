#GLOBAL PARAMS SECTION
NewLine=$'\n';
#unzipRootFolder="archive";
unzipRootFolder=$1;
rootDir=$(pwd)
arr=();


#---------------------------------------------------------
_replaceJarsClientDirWithLibDir () {

local __return=$4;
local nums="";

local libJarsStr=$1;
local clientAntNumbers=$2;
local dirName=$3;

declare -i i;
declare -i j;
local tmpArr=();
local GAV=();
local tmp="";
local tmpNums="";
local tmpDel="";

nums="$clientAntNumbers"




dirName=$(echo $dirName | sed 's/\(.*\)\///')

echo
echo "---- DIR NAME ----"
echo "$dirName"

if [ "$dirName" = "lib" ]; then
libJarsStr=$(echo $libJarsStr | sed 's/^#//g')
echo
echo "---- libJarsStr ----"
echo "$libJarsStr"
IFS='#' read -ra arr <<< "$libJarsStr"
echo
echo "---- Lib Jrs ----"
echo "${arr[1]}"
echo
fi


if [ "$dirName" = "client" ]; then

if [ "$clientAntNumbers" != "" ]; then
clientAntNumbers=$(echo $clientAntNumbers | sed 's/^://g')

echo "-- clientAntNumbers"
echo "$clientAntNumbers"

IFS=':' read -ra tmpArr <<< "$clientAntNumbers"
echo "tmpArr: ""${tmpArr[1]}"

echo "FUNCTION CLIENTS ANT ART"
for j in "${tmpArr[@]}"
do
IFS='#' read -ra GAV <<< "${antTree[$j]}"
tmp="${GAV[0]}"":""${GAV[1]}"
tr="$tr""$tmp"${NewLine}
done
echo "{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{"
echo "$tr"
echo "{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{{"

for j in "${tmpArr[@]}"
do
IFS='#' read -ra GAV <<< "${antTree[$j]}"
tmp="${GAV[0]}"":""${GAV[1]}"
################################
echo "TMP: ""$tmp"
for((i=0; i<${#arr[@]}; i++))
do # ---- 1 begin loop
echo "arr["$i"]=""${arr[$i]}"
if [ "$tmp" = "${arr[$i]}" ]; then
tmpDel="$tmpDel"${NewLine}"$tmp"":""${GAV[2]}"
echo
echo "---- IGNORE CLIENT ARTIFACTS ----"
echo "$tmp"":""${GAV[2]}"
echo
break
else
if [ "$i" -eq $((${#arr[@]}-1)) ]; then tmpNums="$tmpNums"":""$j"; fi;
fi
done # ---- 1 begin loop
################################
done

if [ "$tmpNums" != "" ]; then nums="$tmpNums"; fi;

if [ "$tmpDel" != "" ]; then echo "$tmpDel" >> IgnoreClientArt.txt; fi;

fi
fi

eval $__return="'$nums'"

}



#---------------------------------------------------------
_generateDepSection () {

local resStr=$1;
local currDir=$2;
local DependencyTagsFile=$3;

local uniqueArr=();

IFS=':' read -ra tmpArr <<< "$resStr"

uniqueArr=($(echo "${tmpArr[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

echo "----- Uniq nums from ant tree array"
echo "${uniqueArr[@]}"


for i in "${uniqueArr[@]}"
do
IFS='#' read -ra GAV <<< "${antTree[$i]}"
#dependencyTag="$dependencyTag""<dependency>"${NewLine}"<groupId>""${GAV[0]}""</groupId>"${NewLine}"<artifactId>""${GAV[1]}""</artifactId>"${NewLine}"<version>""${GAV[2]}""</version>"${NewLine}"<exclusions>"${NewLine}"<exclusion>"${NewLine}"<groupId>*</groupId>"${NewLine}"<artifactId>*</artifactId>"${NewLine}"</exclusion>"${NewLine}"</exclusions>"${NewLine}"</dependency>"${NewLine}
dependencyTag="$dependencyTag""<dependency>\n<groupId>""${GAV[0]}""<\/groupId>\n<artifactId>""${GAV[1]}""<\/artifactId>\n<version>""${GAV[2]}""<\/version>\n<exclusions>\n<exclusion>\n<groupId>*<\/groupId>\n<artifactId>*<\/artifactId>\n<\/exclusion>\n<\/exclusions>\n<\/dependency>\n"
done

echo "---- DEPENDENCIES -------"
echo "$dependencyTag"

if [ "$dependencyTag" != "" ]; then
echo "$dependencyTag" >> $2/$3
fi

}




#---------------------------------------------------------
_compareMVNTree () {

local __returnNumbers=$3;
local numbers="";

local __returnUnresolved=$4;
local unresolved="";


jarsArr=$1[@]
jarsArr=("${!jarsArr}")

AVArr=$2[@]
AVArr=("${!AVArr}")

echo "======================"
echo "A = " "${jarsArr[0]}"
echo "B = " "${AVArr[1]}"


for j in "${jarsArr[@]}"
do  # ---- 5 begin loop

for((i=0; i<${#AVArr[@]}; i++))
do # ---- 1 begin loop

if [ "$j" = "${AVArr[$i]}" ]; then
numbers="$numbers"":""$i"
break
else

if [ "$i" -eq $((${#AVArr[@]}-1)) ]; then unresolved="$unresolved"":""$j"; fi
fi


done # ---- 1 begin loop

done # ---- 5 end loop
echo "__________________ numbers""$numbers"
echo "__________________ unresolved""$unresolved"


eval $__returnNumbers="'$numbers'"
eval $__returnUnresolved="'$unresolved'"

}



#---------------------------------------------------------
_compareANTTree () {

local __returnNumbers=$3;
local numbers="";
local unresolved="";

local jars=$1;
local jarsArr=();

AVAntArr=$2[@]
AVAntArr=("${!AVAntArr}")

IFS=':' read -ra jarsArr <<< "$jars"

echo "======================"
echo "AAnt = " "${jarsArr[0]}"
echo "BAnt = " "${AVAntArr[0]}"


for j in "${jarsArr[@]}"
do  # ---- 5 begin loop

for((i=0; i<${#AVAntArr[@]}; i++))
do # ---- 1 begin loop

if [ "$j" = "${AVAntArr[$i]}" ]; then
numbers="$numbers"":""$i"
break
else

if [ "$i" -eq $((${#AVAntArr[@]}-1)) ]; then unresolved="$unresolved"":""$j"; fi
fi


done # ---- 1 begin loop

done # ---- 5 end loop

echo "__________________ numbers""$numbers"
echo "__________________ unresolved""$unresolved"


eval $__returnNumbers="'$numbers'"

}


##----------------------------------
#Params:
# $1 - folder name inside archive (i.e. lib, client, pmr)
# $2 - array with maven tree rows
##----------------------------------
_compareUnzipJarsWithMavenTree () {

local __return=$4;
local resStr="";

local outputDirectory="";
local str="";
local version="";
local includeSection="";
local dependencyTag="";
local jarsFile=jars.txt;
local antTreeFile=$5;

local numb="";
local unres="";
local antNumbs="";

local includeSection="";
local includeSection0="";
local includeSection1="";
includeSectionFalse="";
local includeSectionAnt="";

local transitiveTrue=();

local dependencyTag="";

local tmpArr=();

local libJars="";
local retNums="";

#add all artifactId`s from the directory (i.e. lib, client, pmr) to an array
cd $1
shopt -s nullglob
local unzipJars=(*.jar)

if [ ${#unzipJars[@]} -ne 0 ]; then   # 4` ------ begin loop
echo "unzipJars Length = "${#unzipJars[@]}

printf "%s\n" "${unzipJars[@]}" > ${jarsFile}

#directory in dependencySet section in assembly descriptor file
outputDirectory=$(echo $1 | sed 's/^[^\/]*//g')
echo
echo "outputDirectory: ""$outputDirectory"


AVArr=();
AVAntArr=();

for (( i = 0; i < ${#tree[@]}; i ++ ))
#for p in "${tree[@]}"
do  # ---- 4 begin loop
str=$(echo "${tree[$i]}" | sed 's/^.*\s//g')

echo "GET PARENT DEPENDENCY"
plusVal="${mvnTreePlus[$i]}"
echo "$plusVal"

if [ ${plusVal:0:1} = "+" ]; then
parentArr["${#parentArr[@]}"]="1"
else
parentArr["${#parentArr[@]}"]="0"
fi

									
IFS=':' read -ra GAV <<< "$str"

if [ "${#GAV[@]}" -eq 6 ]; then
AVArr[${#AVArr[@]}]="${GAV[1]}""-""${GAV[4]}""-""${GAV[3]}"".""${GAV[2]}"
else
AVArr[${#AVArr[@]}]="${GAV[1]}""-""${GAV[3]}"".""${GAV[2]}"
fi



done  # ---- 4 end loop
echo "FINISH GET PARENT DEPENDENCY"


#determine transitive false sections

for (( i = 0; i < ${#parentArr[@]}; i++ ))
do

if [ "$i" -lt $((${#parentArr[@]}-1)) ]; then

if [[ "${parentArr[$i]}" = "${parentArr[$(($i+1))]}" && "${parentArr[$i]}" = "1" ]]; then
transitiveTrue["${#transitiveTrue[@]}"]="false"
else
transitiveTrue["${#transitiveTrue[@]}"]="true"
fi

else

if [[ "${parentArr[$i]}" = "1" ]]; then
transitiveTrue["${#transitiveTrue[@]}"]="false"
else
transitiveTrue["${#transitiveTrue[@]}"]="true"
fi

fi

done


echo "################TRANSITIVE#####################"
for (( i = 0; i < ${#parentArr[@]}; i++ ))
do
echo "parent[$i]=""${parentArr[$i]}" "---""transitive[$i]=""${transitiveTrue[$i]}"
done
echo 



echo "_______________________________"
echo "AVARR = ""${AVArr[4]}"

_compareMVNTree unzipJars AVArr numb unres

numb=$(echo $numb | sed 's/^://g')
echo
echo "NUM = ""$numb"

unres=$(echo $unres | sed 's/^://g')
echo
echo "UNR = ""$unres"

if [ "$unres" != "" ]; then  # 9 ------ begin if


#-------------------------------------
for p in "${antTree[@]}"
do  # ---- 7 begin loop
									
IFS='#' read -ra GAV <<< "$p"

AVAntArr[${#AVAntArr[@]}]="${GAV[1]}""-""${GAV[2]}"".jar"

done  # ---- 7 end loop
#-------------------------------------


_compareANTTree "$unres" AVAntArr antNumbs

antNumbs=$(echo $antNumbs | sed 's/^://g')
echo
echo "antNUM = ""$antNumbs"

else
antNumbs=""
fi  # 9 ------ end if


#----------- Create DependencySet Section MVN ---------------

if [ "$numb" != "" ]; then
IFS=':' read -ra tmpArr <<< "$numb"

for (( i = 0; i < ${#tmpArr[@]}; i++ ))
#for i in "${tmpArr[@]}"
do
IFS=':' read -ra GAV <<< "${tree[${tmpArr[$i]}]}"
if [ "${parentArr[${tmpArr[$i]}]}" = "0" ]; then
includeSection0="$includeSection0""<include>""${GAV[0]}"":""${GAV[1]}""</include>"${NewLine}
else
echo "8888"
echo "${parentArr[${tmpArr[$i]}]}"
echo "${transitiveTrue[${tmpArr[$i]}]}"
if [ "${transitiveTrue[${tmpArr[$i]}]}" = "true" ]; then
includeSection1="$includeSection1""<include>""${GAV[0]}"":""${GAV[1]}""</include>"${NewLine}
else
includeSectionFalse="$includeSectionFalse""<include>""${GAV[0]}"":""${GAV[1]}""</include>"${NewLine}
fi

fi

includeSection11="$includeSection1""${GAV[0]}"":""${GAV[1]}"":""${GAV[3]}"${NewLine}


libJars="$libJars""#""${GAV[0]}"":""${GAV[1]}"
done
#echo "---- INCLUDES MVN -------"
#echo "$includeSection"


echo "############# MVN ###############"
echo "$includeSectionFalse"


fi
tmpArr=();
#--------------------------------------------------------


#----------- Create Dependency Set section Ant ----------
incl2="";

if [ "$antNumbs" != "" ]; then
IFS=':' read -ra tmpArr <<< "$antNumbs"

for i in "${tmpArr[@]}"
do
IFS='#' read -ra GAV <<< "${antTree[$i]}"
includeSectionAnt="$includeSectionAnt""<include>""${GAV[0]}"":""${GAV[1]}""</include>"${NewLine}

incl2="$incl2""${GAV[0]}"":""${GAV[1]}"":""${GAV[2]}"${NewLine}
includeSection11="$includeSection1""${GAV[0]}"":""${GAV[1]}"":""${GAV[2]}"${NewLine}


libJars="$libJars""#""${GAV[0]}"":""${GAV[1]}"
#dependencyTag="$dependencyTag""<dependency>"${NewLine}"<groupId>""${GAV[0]}""</groupId>"${NewLine}"<artifactId>""${GAV[1]}""</artifactId>"${NewLine}"<version>""${GAV[2]}""</version>"${NewLine}"</dependency>"${NewLine}
done
#echo "---- INCLUDES MVN + ANT -------"
#echo "$includeSection"


echo "############# MVN + ANT ###############"
echo "$includeSection11"

echo "||||||||||||| ONLY ANT |||||||||||||"
echo "$incl2"
echo "////////////////////////////////////"
echo

fi

#_replaceJarsClientDirWithLibDir 


resStr="$antNumbs"
tmpArr=();
#--------------------------------------------------------

fi # 4` ------ end loop
result="";

if [  "$includeSectionFalse" != "" ]; then

echo "includeSectionFalse"
echo "$includeSectionFalse"


result="<dependencySet>"${NewLine}"<outputDirectory>"${outputDirectory}"</outputDirectory>"${NewLine}"<useTransitiveDependencies>false</useTransitiveDependencies>"${NewLine}"<useTransitiveFiltering>false</useTransitiveFiltering>"${NewLine}"<includes>"${NewLine}${includeSectionFalse}"</includes>"${NewLine}"<excludes>"${NewLine}"<exclude>*:tests:*</exclude>"${NewLine}"</excludes>"${NewLine}"</dependencySet>"${NewLine}
fi

includeSection="$includeSection1""$includeSection0""$includeSectionAnt"

if [ "$includeSection" != "" ]; then
includeSection="<!-- Parent MVN Dependencies -->"${NewLine}"$includeSection1"${NewLine}"<!-- Transitive MVN Dependencies -->"${NewLine}"$includeSection0"${NewLine}"<!-- Transitive ANT Dependencies -->"${NewLine}"$includeSectionAnt"
result="$result""<dependencySet>"${NewLine}"<outputDirectory>"${outputDirectory}"</outputDirectory>"${NewLine}"<includes>"${NewLine}${includeSection}"</includes>"${NewLine}"<excludes>"${NewLine}"<exclude>*:tests:*</exclude>"${NewLine}"</excludes>"${NewLine}"</dependencySet>"

echo "$result" >> $2/$3

else
if [ "$result" != "" ]; then
#result="$result""<dependencySet>"${NewLine}"<outputDirectory>"${outputDirectory}"</outputDirectory>"${NewLine}"<includes>"${NewLine}${includeSection}"</includes>"${NewLine}"<excludes>"${NewLine}"<exclude>*:tests:*</exclude>"${NewLine}"</excludes>"${NewLine}"</dependencySet>"

result="${result::-1}"
echo "$result" >> $2/$3
fi

fi
#----------------------------------

rm -f ${jarsFile}

_replaceJarsClientDirWithLibDir ${libJars} ${resStr} $(pwd) retNums
resStr="$retNums"


eval $__return="'$resStr'"

}




#---------------------------------------------------------
main () {

local currDir=$3;
local DependencyTagsFile=$4;
local pluginFile=$5;
local antTreeFile=$6;

local resultStr="";
local resultMVNDep="";

#Array contains the list of the lib folder jars - function argument
local lib=();
#Array gets jars from the lib array function argument
local defaultJars=();

#do not forget pass file name as $1 parameter to get vmn dependency tree
IFS=$'\r\n' GLOBIGNORE='*' command eval  'tree=($(cat $2))'
IFS=$'\r\n' GLOBIGNORE='*' command eval  'antTree=($(cat $6))'
IFS=$'\r\n' GLOBIGNORE='*' command eval  'mvnTreePlus=($(cat $7))'

cp $2 ${rootDir}/mvnTree
cp $6 ${rootDir}/antTree
rm -f $2
rm -f $6

#get folder`s tree from unzip archive (i.e. lib, client, pmr folders)
local folderTree=( $(find ${unzipRootFolder} -type d -print) )
echo "ROOT = "$rootDir


#------- Create head section of assembly descriptor file -------
fileSet=${NewLine}"<id>plugin</id>"${NewLine}"<baseDirectory>"$1"</baseDirectory>"${NewLine}"<formats>"${NewLine}"<format>zip</format>"${NewLine}"</formats>"${NewLine}"<fileSets>"${NewLine}"<fileSet>"${NewLine}"<directory>\${basedir}/src/main/resources</directory>"${NewLine}"<outputDirectory>/</outputDirectory>"${NewLine}"</fileSet>"${NewLine}"</fileSets>"${NewLine}
header="<assembly>"${fileSet}"<dependencySets>"
echo "$header" >> $3/${pluginFile}
#---------------------------------------------------------------

for((k=1; k<${#folderTree[@]}; k++))
do # ---- 1 begin loop

echo "All dirs: ""${folderTree[@]}"

echo "Directory: ""${folderTree[$k]}"
_compareUnzipJarsWithMavenTree "${folderTree[$k]}" ${currDir} ${pluginFile} resultStr lib


if [ "$resultStr" != "" ]; then
resultMVNDep="$resultMVNDep""$resultStr"":"
fi

#returnt to root directory
cd ${rootDir}

done # ---- 1 end loop

#------- Create footer section of assembly descriptor file -------
footer="</dependencySets>"${NewLine}"</assembly>"${NewLine}
echo "$footer" >> $3/${pluginFile}
#-----------------------------------------------------------------


#------- Create dependencies section for pom file ---------------
resultMVNDep=$(echo $resultMVNDep | sed 's/^://g')

echo
echo "RESULT STRING: ""$resultMVNDep"

if [ "$resultMVNDep" != "" ]; then
_generateDepSection ${resultMVNDep} ${currDir} ${DependencyTagsFile}
fi

#-----------------------------------------------------------------

arr=();

}



#------------------------ MAIN FUNCTION CALLS ------------------------------

main $1 $2 $3 $4 $5 $6 $7

# test () {
# IFS=$'\r\n' GLOBIGNORE='*' command eval  'tree=($(cat $2))'
# f=$1
# echo "GGGGGGGGGGGGGGGGGGGG = ""${tree[5]}"
# echo "1 param = " $f

# }

# test $1 $2