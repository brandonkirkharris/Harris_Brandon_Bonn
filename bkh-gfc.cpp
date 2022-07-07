//The program should take a fasta file and a gene-of-interest (goi) file.
//The program should take every fasta entry and compare it to the goi file.
//If the fasta entry is in the goi file, it will append it to an existing file that corresponds to that gene.
//If the file does not yet exist, the program shall create the file, and then add the appropriate fasta line.
//What should result is a series of files (ex. ~12,000) that hold the consensus sequences of each gene, per individual.

//December 2021 update:
//Updating this program to be able to accept no gene-of-interest file.
//If no gene of interest file exists, then the program should sort each individual gene instead.
//This program will also accept a list of files (list.txt) and run for all provided fastas.

#include <iostream>                         //for printing menu and version information
#include <map>                              //for storing fasta files
#include <fstream>                          //for opening and closing fasta files and creating gene files
#include <string>                           //for storing file names, headers, and sequences
#include <set>                              //For creating sets of genes of interest or list of files
#include <cstdlib>                          //for adding .c_str() for flexibility with the compiler
#include "fasta_f.h"                        //personal library with fasta-related management functions

using namespace std;
void menu();
void version();
void write_fasta (string key, string value, string outdir, string indiv, int flag);

int main(int argc, char* argv[])
{
    map<string,string> fasta;               //map to hold consensus sequence .fasta
    map<string,string>::iterator mt;        //iterator to loop over fasta
    set<string> goi, list;                  //map to hold genes of interest .txt
    set<string>::iterator st;               //iterator to loop over set
    string fasta_name;                      //name of fasta file
    string goi_name;                        //name of goi file
    string gene_name;                       //name of new gene name files
    string indiv;                           //name of specimen represented in fasta
    string list_name;                       //list of files to process simultaneously
    string temp;                            //temporary to hold header lines during comparison
    string seq;                             //sequence corresponding to header
    string outdir;                          //optional output directory
    string outtemp;                         //to open created files in output directory
    int flag = 0;                           //flag to indicate header modification
    int indiv_flag = 0;                     //flag to indicate user-specified header
    ofstream os;                            //to open appending gene files
    
    
//Check the input argv array for both input file names
    while (*++argv)
    {
        if ((*argv)[0] == '-')
        {
            switch ((*argv)[1])
            {
                default             :continue;
                case        'd'     :fasta_name = *(argv+1);     //fasta input flag
                                     continue;
                case        'i'     :goi_name = *(argv+1);       //goi input flag
                                     continue;
                case        'n'     :indiv = *(argv+1);          //individual name (optional)
                                     indiv_flag = 1;             //individual name flag
                                     continue;
                case        'r'     :flag = 1;                   //Flag to signal header modification
                                     continue;
                case        'o'     :outdir = *(argv+1);         //output directory
                                     continue;
                case        'l'     :list_name = *(argv+1);      //list of files (optional)
                                     continue;
                case        'h'     :menu();                     //help menu, closes program.
                                     exit (-1);
                case        'V'     :version();                  //Version information, closes program.
                                     exit (-1);
            }
        }
    }


//Check to make sure that a fasta file was provided
    if (fasta_name.empty() == true && list_name.empty() == true) //is there a fasta file or a list of fasta files?
    {
        menu();
        exit (-1);
    }
//Upload all files to maps/sets
    if (list_name.empty() == true)          //if there is only one fasta file to read
    {
        list.insert(fasta_name);            //upload the one fasta file name into a set
//        read_value(fasta_name, list);       
        read_fasta(fasta_name, fasta);      //upload consensus sequences to fasta map
    }
    else                                    //if there are multiple fastas to be read
        read_value(list_name, list);        //write list of files to a set
    if (goi_name.empty() != true)           //if there are genes of interest
        read_value(goi_name, goi);          //upload genes of interest to goi map
    
//check if the output directory (if any) has a slash in its path
    if (outdir.empty() != true && outdir[-1] != '/')
    {
        outdir = outdir + "/";
    }
//Decide whether to sort all genes or only genes of interest, create and append gene files
    for (st = list.begin(); st != list.end(); ++st)
    {
        temp = *st;
        read_fasta(temp, fasta);
        if (indiv_flag == 0)                                                            //Is there a provided gene modifier?
        {
            indiv = temp.substr(temp.find_last_of("/") + 1, temp.find_last_of("."));    //if not, change to name of file
            indiv = indiv.substr(0, indiv.find("."));                                   //the above doesn't work without this, don't know why
        }
        if (goi_name.empty() != true)                                                   //If the user wants to filter specific genes
        {               
            for (mt = fasta.begin(); mt != fasta.end(); ++mt)               
            {               
                temp = mt->first;                                                       //make a temp out of the header line
                seq = mt->second;                                                       //make a temp (seq) out of the sequence
                if (goi.find(temp) != goi.end())                                        //is the header in the goi file?
                    write_fasta(temp, seq, outdir, indiv, flag);                        //write the entry to a file
                else                                                                    //if the gene is not in the goi file
                    continue;                                                           //move on
            }               
        }               
        else                                                                            //If the user does not want to filter specific genes
        {               
            for (mt = fasta.begin(); mt != fasta.end(); ++mt)               
            {               
                temp = mt->first;                                                       //make a temp out of the header line
                seq = mt->second;                                                       //make a temp (seq) out of the sequence
                write_fasta(temp, seq, outdir, indiv, flag);                            //write the entry to a file
            }               
        }               
        fasta.clear();                                                                  //clear the uploaded fasta file
    }
}



//Functions
//version() prints version information
//menu() prints parameters
//write_fasta() writes a single entry to a new file, or appends to an existing file

void version()
{
    cout << "gfc 2.0"                                                       << endl;

}   
void menu() 
{   
    cout << "----------------------------------------------------------"    << endl;
    cout << "Gene from consensus generator version 2.0 (22-Dec-2021)"       << endl;
    cout                                                                    << endl;
    cout << " Mandatory Parameters: -d OR -l"                               << endl;
    cout                                                                    << endl;
    cout << " -d     A single fasta file to be sorted."                     << endl;
    cout                                                                    << endl;
    cout << " -l     Takes a .txt file with multiple entries to sort."      << endl;
    cout << "        Default behavior: sorts a single file."                << endl;
    cout << "        This option requires paths within the file."           << endl;
    cout << "        These linux commands will produce required output:"    << endl;
    cout << "        find /path/to/dir/* -type f > list_of_files.txt"       << endl;
    cout << "        ls -d /path/to/dir/* > list_of_files.txt"              << endl;
    cout                                                                    << endl;
    cout << " Optional Parameters:"                                         << endl;
    cout                                                                    << endl;
    cout << " -i     Interest values to be selected."                       << endl;
    cout << "        Default behavior: sort all genes."                     << endl;
    cout                                                                    << endl;
    cout << " -r     remove gene header and replace with SRR number. "      << endl;
    cout << "        Default behavior: append header with SRR number."      << endl;
    cout                                                                    << endl;
    cout << " -n     Name of individual specimen."                          << endl;
    cout << "        Default behavior: uses file name."                     << endl;
    cout << "        Use if file is in another directory (maybe)."          << endl;
    cout                                                                    << endl;
    cout << " -o     Generates files into output directory."                << endl;
    cout << "        Default behavior: outputs to working directory."       << endl;
    cout                                                                    << endl;
    cout << " -h     Prints this help menu."                                << endl;
    cout << " -V     Prints version information."                           << endl;
    cout << "----------------------------------------------------------"    << endl;
    cout << "Written by Brandon Kirk Harris"                                << endl;
    cout << "----------------------------------------------------------"    << endl;
}

void write_fasta (string key, string value, string outdir, string indiv, int flag)
{
    ofstream os;                                        //file object to open
    string outtemp;                                     //name of file
    
    outtemp = outdir + key.substr(1,-1) + ".fasta";     //create name of file
    os.open(outtemp.c_str(), ios_base::app);            //open or create gene file
    if (flag == 0)                                      //append header with name?
    key = key + "_" + indiv;                            //if yes, do so
    else                                                //don't append header with name?
    key = ">" + indiv;                                  //if not, change header to indiv
    os << key << endl;                                  //output header
    os << value << endl;                                //output sequence
    os.close();                                         //close file
}


//
