##Script to download from wgeet
#!/bin/bash

#########################################################################
 # Functions
pro_name="wgetter"
Help()
{
    echo "-------------------------------------------------------"
    echo "${pro_name} version 3.0 (24-December-2021)             "
    echo "-------------------------------------------------------"
    echo "This program takes a file from OrthoDB with a list     "
    echo "of cluster ids in a single line. It will process this  "
    echo "list into a file of cluster id urls, then runs the     "
    echo "program wget to download the tab-delimited file from   "
    echo "orthoDB. Optionally, it will also produce a list of    "
    echo "genes from this tab-delimited file, and will also      "
    echo "optionally compare them with another provided list of  "
    echo "genes (ex. a list from Busco EZ lab) and output the    "
    echo "matching entries.                                      "
    echo "-------------------------------------------------------"
    echo "Written by Brandon Kirk Harris                         "
    echo "                                                       "
    echo "This program calls the sed, grep, and wget commands    "
    echo "from the Linux command line. For version information,  "
    echo "try [COMMAND] -V, or -h/--help for help                "
    echo "This program also uses oDBget, part of this package.   "
    echo "For version information, use oDBget -V, or -h for help "
    echo "-------------------------------------------------------"
}

Version()
{
    echo "${pro_name} 3.0"
}

Parameters()
{
    echo "Parameters                                             "
    echo "-------------------------------------------------------"
    echo "Modal Parameters                                       "
    echo "Modal parameters select which functions of the program "
    echo "will be run. Modes can be run in combination with each "
    echo "other for diverse functionality.                       "
    echo "Default behavior is to run oDBget -> wget -> goi       "
    echo "Using -C runs oDBget -> wget -> compare -> goi         "
    echo "                                                       "
    echo " -O       run oDBget                                   "
    echo "          Compilates a text file of urls from orthoDB  "
    echo "                                                       "
    echo " -W       run wget (requires url list text file)       "
    echo "          Downloads a tab-delimited file from orthoDB  "
    echo "                                                       "
    echo " -C       run compare (requires comparison file)       "
    echo "          Compares list of cluster ids to the          "
    echo "          tab delimited file and creates a new         "
    echo "          tab delimited file with matching entries     "
    echo "                                                       "
    echo " -G       run goi (requires tab-delmited file)         "
    echo "          Produces a list of genes of interest         "
    echo "                                                       "
    echo "-------------------------------------------------------"
    echo "Input Parameters                                       "
    echo "Each step of the program pipes into the next step in   "
    echo "this order: oDBget -> wget -> compare* -> goi          "
    echo "      *compare is optional and can also be moved       "
    echo "       before wget with the -c option                  "
    echo "When choosing input parameters, please note that input "
    echo "flags override internal variables. Thus, if you provide"
    echo "a tab-delimited file with -t for the goi step but also "
    echo "have the program run the wget step, then the provided  "
    echo "tab-delimited file will override what is created by the"
    echo "wget step. The same is true for oDBget and the list of "
    echo "urls with the -u option.                               "
    echo "                                                       "
    echo " -d       input file for oDBget (mandatory for oDBget) "
    echo "          file should be a list of cluster ids from    "
    echo "          orthoDB and be in a one-line format.         "
    echo "                                                       "
    echo " -s       orthoDB species number (mandatory for oDBget)"
    echo "          ex. Carnivora = 33554                        "
    echo "                                                       "
    echo " -c       comparison step modifier (compare option)    "
    echo "          CURRENTLY IN DEVELOPMENT                     "
    echo "          orders program to run comparison step before "
    echo "          wget step to reduce downloads performed.     "
    echo "          If this option is enabled, $pro_name will    "
    echo "          check the comparison files against the list  "
    echo "          of urls rather than the default behavior,    "
    echo "          which checks the tab-delimited file.         "
    echo "                                                       "
    echo " -o       output file name (optional for goi step)     "
    echo "                                                       "
    echo "Other Parameters                                       "
    echo "-------------------------------------------------------"
    echo " -h       Prints this help menu                        "
    echo "                                                       "
    echo " -v       Verbose mode                                 "
    echo "                                                       "
    echo " -V       Prints version information                   "
    echo "-------------------------------------------------------" 
}

Exist()
{
    if [ -f "$1" ]
    then
        echo "$1 created."
    else
        echo "Error: $1 not created."
    fi
}

#########################################################################
 # options and command line arguments
#########################################################################
output="genes_of_interest.txt"          ##Default name for output
verbose=0                               ##verbose mode (default is off)
full=1                                  ##full program (default is on)
O_on=0                                  ##oDBget on    (default is off)
W_on=0                                  ##wget on      (default is off)
G_on=0                                  ##goi on       (default is off)
C_first=0                               ##changes order of comparison step (default is after wget)
url_name="tmp_url.txt"                  ##default name for list of urls used by wget
tdf_name="tmp_wget.txt"                 ##default name for tab-delimited file downloaded from wget
tdf_final="tab-delim.txt"               ##default name for tab-delimited file after removing header lines

while getopts "d:s:C:o:W:G:OvhV" flag; ##c 
do
    case ${flag} in
        d) data=${OPTARG};;             ##data file for oDBget
        s) species=${OPTARG};;          ##species number for oDBget
        C) compare=${OPTARG};;          ##comparison file
        o) output=${OPTARG};;           ##optional output file name for goi step
        W) W_on=1                       ##turn on wget mode (and full mode off)
           full=0
           url_name=${OPTARG};;         ##url list for wget
        G) G_on=1                       ##turn on goi mode (and full mode off)
           full=0
           tdf_name=${OPTARG};;         ##tab-delimited file for goi step
##        c) C_first=1;;                  ##move comparison step before wget
        O) O_on=1                       ##turn on oDBget mode (and full mode off)
           full=0;;
        v) verbose=1;;
        h) Help
           Parameters
           exit 0;;
        V) Version
           exit;;
       \?) echo "Error: Invalid option -${OPTARG}. Terminating Program."
           exit;;
    esac
done

 # Make log file if verbose mode is turned off
if [ "$verbose" == 0 ];
then
    rand=$((1 + $RANDOM % 10000))
    log="${pro_name}_log.o${rand}"
    touch $log
    Help >> $log
else
    Help
fi

#########################################################################
 # oDBget step
#########################################################################
if [ "$O_on" == 1 ];
then
    SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )   ##Find source directory
    oDBget="${SCRIPT_DIR}/pro_bkh_oDBget"                                             ##oDBget location
    $oDBget -d $data -s $species -o tmp_url.txt                                       ##oDBget to assemble urls
fi
#########################################################################
 # wget step
#########################################################################
if [ "$full" == 1 ] || [ "$W_on" == 1 ];
then
    if [ "$verbose" == 0 ];
    then
        wget --input-file=${url_name} --output-document=${tdf_name} -o tmp_wgetout.txt
        cat tmp_wgetout.txt >> $log
        rm tmp_wgetout.txt
    else
        wget --input-file=${url_name} --output-document=${tdf_name}
    fi
fi

    # remove header lines from tab-delimited file, if any
if [ ! -z "${tdf_name}" ];
then
    ##sed '1 ! {/^p/d;}' tmp_wget.txt > ortho.txt                           ##This version leaves the header line
    sed '/^p/d' ${tdf_name} > ${tdf_final}                              ##This version does not leave it
fi

 # remove temporaries if in full mode
if [ "$full" == 1 ];
then
    if [ "$verbose" == 0 ];
    then
        Exist ${tdf_final} >> $log
        echo "Removing temporary files tmp_url.txt and tmp_wget.txt" >> $log
    else
        Exist ${tdf_final}
        echo "Removing temporary files tmp_url.txt and tmp_wget.txt"
    fi
    rm ${url_name}
    rm ${tdf_name}
fi

############################################################################
 # compare step (compares to list of cluster ids provided)
############################################################################

if [ ! -z "$compare" ] && [ "$C_first" == 0 ];
then
    modified="mod_${tdf_final}"
    cat ${tdf_final} | grep -Ff ${compare} > ${modified}
    if [ "$verbose" == 0 ];
    then
        echo "Producing genes of interest from orthoDB and comparison file." >> $log
    else
        echo "Producing genes of interest from orthoDB and comparison file."
    fi
fi

############################################################################
 # goi step (produce list of genes of interest
############################################################################

 # add modifier to final name if compare step was done
if [ ! -z "${modified}" ];
then
    tdf_final="${modified}"
fi

 # produce a list of genes of interest
if [ "$full" == 1 ] || [ "$G_on" == 1 ];
then
    cut -f7 ${tdf_final} | sort | uniq > $output
    if [ "$verbose" == 0 ];
    then
        Exist ${output} >> $log
    else
        Exist ${output}
    fi
fi

