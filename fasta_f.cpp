#include <iostream>
#include <string>
#include <map>
#include <set>
#include <fstream>
#include <cstdlib>

using namespace std;
//0. delim_cut
//string delim_cut (string delim1, string delim2, string line);
//1. read_fasta
//void read_fasta (string filename, map<string, string> &f);
//2. read_value
//void read_value (string filename, set<string> &f);
//3. read_faa
//void read_faa (string filename, map<string, string> &f);
//4. void out_loc ###DO NOT USE - BROKEN#####
//void out_loc(string line, ofstream os)

//delim_cut
//function to edit the header lines of a fasta file based on delimiters
string delim_cut (string delim1, string delim2, string line)
{
    string yield;
    int found = line.find(delim1);
    int found2 = line.find(delim2);
    if (found == string::npos || found2 == string::npos)
        return string();
    else
    {
        yield = line.substr(line.find(delim1) + delim1.length(), -1);
        yield = yield.substr(0, yield.find(delim2));
        return yield;
    }
}

//read_fasta
//function to read a gene (fasta/cds) file and place it into a map
void read_fasta (string filename, map<string, string> &f)
{
    ifstream is;    
    string key;             //stores the key during a loop
    string value;           //stores the value during a loop
    string line;            //takes input from getline
    
    is.open(filename.c_str());
    if (is.fail())
    {
        cout << "Error:" << filename << " does not exist." << endl;
        exit (-1);
    }
    while (getline(is, line))
    {
        if (line[0] == '>')
        {
            if (key != "" && value != "")       //if both key and value have something
            {
                f[key] = value;                 //assign both to map
                value.clear();                  //reduce value to nothing
                key = line;                     //reset the key to new line
            }
            else
                key = line;                     //reset the kye to new line
        }
        else
            value = value + line;               //build the sequence string
    }
    if (key != "" && value != "")
        f[key] = value;
    is.close();
}

//read_value
//function to upload a list of entries to a set
void read_value (string filename, set<string> &f)
{
    ifstream is;
    string line;
    is.open(filename.c_str());
    if (is.fail())
    {
        cout << "Error: " << filename << " does not exist." << endl;
        exit (-1);
    }
    while (getline(is, line))
    {
        f.insert(line);
    }
    is.close();
}

//read_faa
//function to read a protein file and place it into a map, converting the header
void read_faa (string filename, map<string, string> &f)
{
    ifstream is;    
    string key;             //stores the key during a loop
    string value;           //stores the value during a loop
    string line;            //takes input from getline
    string delim1 = ">";
    string delim2 = " ";
    is.open(filename.c_str());
    if (is.fail())
    {
        cout << "Error: " << filename << " does not exist.";
        exit (-1);
    }
    while (getline(is, line))
    {
        if (line[0] == '>')
        {
            if (key != "" && value != "")       //if both key and value have something
            {
                key = delim_cut(delim1, delim2, key);
                f[key] = value;                 //assign both to map
                value.clear();                    //reduce value to nothing
                key = line;                     //reset the key to new line
            }
            else
                key = line;                     //reset the kye to new line
        }
        else
            value = value + line;               //build the sequence string
    }
    if (key != "" && value != "")
        key = delim_cut(">", " ", key);
        f[key] = value;
    is.close();
}
//void out_loc ###DO NOT USE - BROKEN#####
//outputs either to stdout or to a file object
void out_loc(string line, ofstream &os)
{
    if (os.fail())
        cout << line << endl;
    else
        os << line << endl;
}