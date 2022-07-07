#include <iostream>                                 //for menu and version output
#include <fstream>                                  //to open fasta file and create longest variant file
#include <string>                                   //to store file names, headers, and sequences
#include <map>                                      //to store fasta file
#include "fasta_f.h"                                //personal library with fasta-related management functions

using namespace std;

void menu();
void version();

int main (int argc, char* argv[])
{
    map<string, string> data, sorted;               //map to hold the fasta file
    map<string, string>::iterator mt, it;           //iterator to loop over fasta file
    string filename;                                //name of fasta file
    string outdir;                                  //optional output file
    string keytemp;                                 //header line to be operated upon
    string valtemp;                                 //sequence associated with current header
    string keylong;                                 //header of longest sequence found so far
    string vallong;                                 //longest sequence found so far
    ofstream os;                                    //optional output file
    
//options menu for command line flags. Currently only one flag.
    while (*++argv)
    {
        if ((*argv)[0] == '-')
        {
            switch ((*argv)[1])
            {
                default:            continue;
                case         'd'    : filename = *(argv+1); //file name
                                    continue;
                case         'o'    : outdir = *(argv+1);   //output file
                                    continue;
                case         'h'    :menu();                //help menu
                                    exit (-1);
                case         'V'    :version();             //version information
                                    exit (-1);
            }
        }
    }
//check if mandatory arguments are provided
    if (filename.empty() == true)
    {
        menu();
        exit(-1);
    }
//Upload a fasta file to a map of the form: map[header] = sequence
    read_fasta(filename, data);
    
//Loop to find the longest variations of each gene and place them into a new map
    for (mt = data.begin(); mt != data.end(); ++mt)
    {
//Upload a header and sequence to temporary variables keytemp and valtemp
        keytemp = mt->first;                                    //assign header line to keytemp
        if (keytemp.find("_") != string::npos)                  //does the header contain an underscore?
            keytemp = keytemp.substr(0, keytemp.find("_"));     //if yes, remove the underscore number
        valtemp = mt->second;                                   //assign dna sequence to valtemp

//Upload longest variants to sorted map by checking for duplicate entries
        it = sorted.find(keytemp);                              //search for the header in the sorted map
        if (it != sorted.end())                                 //if it exists, compare
        {
            vallong = it->second;                               //create string to hold the existing dna sequence
            if (valtemp.length() > vallong.length())            //is the new sequence longer than the existing sequence?
                it->second = valtemp;                           //if so, replace existing with new
            else
                continue;                                       //if not, move on
        }
        else
            sorted[keytemp] = valtemp;                          //if the header does not exist, make a new entry
    }
//create an output file if one was requested
    if (outdir.empty() != true)                                 //if an output file name was provided
        os.open(outdir.c_str());                                //create output file
//print out the sorted file
    for (mt = sorted.begin(); mt != sorted.end(); ++mt)         //loop over map  
    {

        if (outdir.empty() == true)                             //if no output file was requested
        {
            cout << mt->first << endl;                          //print header to standard output
            cout << mt->second << endl;                         //print sequence to standard output
        }
        else                                                    //if an output file name was provided
        {
            os << mt->first << endl;                            //print header to output file
            os << mt->second << endl;                           //print sequence to output file
        }
    }
    if (outdir.empty() != true)                                 //if an output file was created
        os.close();                                             //close the output file object
}

//Functions
//version() prints program version
//menu() prints parameters and arguments

void version()
{
    cout << "long_var 2.0                               "   << endl;
}

void menu()
{
    cout << "-------------------------------------------"   << endl;
    cout << " Long_var version 2.0 (22-Dec-2021)        "   << endl;
    cout                                                    << endl;
    cout << "This program accepts a fasta file with     "   << endl;
    cout << "matching sequence headers with variable    "   << endl;
    cout << "lengths, sorts out the longest variant for "   << endl;
    cout << "each header, and outputs them.             "   << endl;
    cout                                                    << endl;
    cout << " Parameters:                               "   << endl;
    cout << " -d    fasta file to be input (mandatory)  "   << endl;
    cout                                                    << endl;
    cout << " -o    Optional output file                "   << endl;
    cout << "       Default is to standard output stream"   << endl;
    cout                                                    << endl;
    cout << " -h    This help menu                      "   << endl;
    cout << "-------------------------------------------"   << endl;
    cout << "Written by Brandon Kirk Harris             "   << endl;
    cout << "-------------------------------------------"   << endl;
}
