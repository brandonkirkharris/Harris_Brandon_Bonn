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

int main (int argc, char* argv[])
{
    set<string> list;
    set<string>::iterator st;
    string f1 = "[";                                    //first delimiter to find cluster ids
    string f2 = "]";                                    //second delimiter to find cluster ids
    string f3 = "\"";                                   //delimiter around cluster ids
    string f4 = ",";                                    //delimiter between cluster ids
    string url = "https://v101.orthodb.org/tab?";       //webpage start
    string idlab = "id=";                               //id label
    string id;                                          //id to take from file                    
    string splab = "&species=";                         //species label
    string species;                                     //species number
    string outfile;                                     //optional output file
    string filename;                                    //input file
    string file;                                        //temporary file storage
    string temp;                                        //to build individual cluster ids for set
    int i = 0;                                          //iterator for loop to compose clusters
    char c;                                             //container for individual characters when composing clusters
    ifstream is;                                        //input file object
    ofstream os;                                        //optional output file object   
    
  //Check the input argv array for both input file names
    while (*++argv)
    {
        if ((*argv)[0] == '-')
        {
            switch ((*argv)[1])
            {
                default             :continue;
                case        'd'     :filename = *(argv+1);              //input file
                                     continue;
                case        'u'     :url = *(argv+1);                   //optional url change
                                     continue;
                case        's'     :species = *(argv+1);               //optional species tag
                                     continue;
                case        'o'     :outfile = *(argv+1);               //optional output file
                                     continue;
                case        'f'     :f1 = *(argv+1);                    //optional delimiter change
                                     continue;
                case        'b'     :f2 = *(argv+1);                    //optional delimiter change
                                     continue;
                case        'q'     :f3 = *(argv+1);                    //optional delimiter change
                                     continue;
                case        'c'     :f4 = *(argv+1);                    //optional delimiter change
                                     continue;
                case        'i'     :idlab = *(argv+1);                 //optional id edit
                                     continue;
                case        'p'     :splab = *(argv+1);                 //optional species edit
                                     continue;
                case        'h'     :menu();                            //parameters menu
                                     exit (-1);
                case        'V'     :version();                         //parameters menu
                                     exit (-1);
            }
        }
    }

//Check to see if main parameter was filled, and open the file if so
    if (filename.empty() == true || species.empty() == true)
    {
        menu();
        exit (-1);
    }
    else
    {
        is.open(filename.c_str());                                          //open file
        if (is.fail())                                                      //check to see if file exists
        {
            cout << "Error: " << filename << " does not exist." << endl;    //print an error message
            cout << "Terminating program." << endl;                     
            exit (-1);                                                      //close program
        }
    getline(is, file);                                                      //upload information from object to file variable
    file = delim_cut(f1, f2, file);                                         //remove precluding and concluding excess data
    is.close();                                                             //close the file object
    }

//Iterate over the file (which should be in one line) and break it down into cluster ids in a set
    c = file[i];                                                            //set first character in c
    for (int i = 0; i < file.length(); ++i)                                 //loop over length of file
    {
        if (c == f3[0] || c == ' ')                                         //if the character is f3 ( " ) or a whitespace
        {
            c = file[i];                                                    //place a new character in c
            continue;                                                       //move on
        }
        else if (c == f4[0])                                                //if the character is f4 ( , )
        {
            list.insert(temp);                                              //insert the completed cluster id into a set
            temp.clear();                                                   //reset the temp variable holding the cluster id
            c = file[i];                                                    //place a new character in c
        }
        else                                                                //if the character is anything else
        {
            temp.push_back(c);                                              //add the character to the temp container
            c = file[i];                                                    //place a new container in c
        }
    }    
    list.insert(temp);                                                      //place the last cluster id into the set
    temp.clear();                                                           //clear the temp container

//Output the cluster ids
    if (outfile.empty() != true)                                            //if the user requests an output file
        os.open(outfile);                                                   //create the output file
    
    for (st = list.begin(); st != list.end(); ++st)                         //iterate over the set of cluster ids
    {
        id = *st;                                                           //set the cluster id into a container
        temp = url + idlab + id + splab + species;                          //build the url
        if (outfile.empty() == true)                                        //if the user requests an output file
            cout << temp << endl;                                           //print the url into an output file
        else                                                                //if no output file was requested
            os << temp << endl;                                             //print the url to the standard output
    }
    if (outfile.empty() != true)                                            //if the user requested an output file
        os.close();                                                         //close the file object
}

void version()
{
    cout << "oDBget 3.0                                                           " << endl;
}
void menu()
{
    cout << "---------------------------------------------------------------------" << endl;
    cout << "oDBget version 3.0 (23-December-2021)                                " << endl;
    cout << "---------------------------------------------------------------------" << endl;
    cout << "This program takes a text file from OrthoDB with cluster ids.        " << endl;
    cout << "Format: {DATA DATA DATA [\"#at#\", \"#at#\", ...] DATA DATA DATA]    " << endl;
    cout << "Cluster ID format: #####at#####                                      " << endl;
    cout << "This program then creates a text file with urls for each cluster id. " << endl;
    cout << "The text file should be used with the wget program to download a     " << endl;
    cout << "tab-delimited file for all desired genes.                            " << endl;
    cout << "                                                                     " << endl;
    cout << "Main Parameters:                                                     " << endl;
    cout << "                                                                     " << endl;
    cout << " -d    .txt file from OrthoDB with list of cluster ids (Mandatory)   " << endl;
    cout << "                                                                     " << endl;
    cout << " -s    Species number (ex. carnivora = 33554) (Mandatory)            " << endl;
    cout << "                                                                     " << endl;
    cout << " -o    Output file (optional)                                        " << endl;
    cout << "       Default: prints to standard output                            " << endl;
    cout << "                                                                     " << endl;
    cout << " -h    Prints this help menu                                         " << endl;
    cout << " -V    Prints version information                                    " << endl;
    cout << "                                                                     " << endl;
    cout << "Formatting Parameters (optional):                                    " << endl;
    cout << "                                                                     " << endl;
    cout << " -u    Updates url body to user-desired line                         " << endl;
    cout << "       Default: https://v101.orthodb.org/tab?                        " << endl;
    cout << "                                                                     " << endl;
    cout << " -f    Updates front delimiter that denotes start of cluster ids     " << endl;
    cout << "       Default: opening square bracket ( [ )                         " << endl;
    cout << "                                                                     " << endl;
    cout << " -b    Updates back delimiter that denotes end of cluster ids        " << endl;
    cout << "       Default: closing square bracket ( [ )                         " << endl;
    cout << "                                                                     " << endl;
    cout << " -q    Updates characters enclosing individual cluster ids           " << endl;
    cout << "       Default: quotation marks ( \" )                               " << endl;
    cout << "                                                                     " << endl;
    cout << " -c    Updates characters separating individual cluster ids          " << endl;
    cout << "       Default: comma ( , )                                          " << endl;
    cout << "                                                                     " << endl;
    cout << " -i    Updates label that declares the cluster id within the url     " << endl;
    cout << "       Default: id=                                                  " << endl;
    cout << "                                                                     " << endl;
    cout << " -p    Updates label that declares the species within the url        " << endl;
    cout << "       Default: &species=                                            " << endl;
    cout << "                                                                     " << endl;
    cout << "---------------------------------------------------------------------" << endl;
    cout << "Written by Brandon Kirk Harris                                       " << endl;
    cout << "---------------------------------------------------------------------" << endl;
}
