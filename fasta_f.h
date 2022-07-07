//header file for fasta functions

//=================================
//include guard
#ifndef __FASTA_FUNCTION_INCLUDED__
#define __FASTA_FUNCTION_INCLUDED__
//=================================
#include <iostream>
#include <string>
#include <map>
#include <set>
#include <fstream>
#include <cstdlib>

//0. delim_cut
std::string delim_cut (std::string delim1, std::string delim2, std::string line);
//1. read_fasta
void read_fasta (std::string filename, std::map<std::string, std::string> &f);
//2. read_value
void read_value (std::string filename, std::set<std::string> &f);
//3. read_faa
void read_faa (std::string filename, std::map<std::string, std::string> &f);
//4. void out_loc
void out_loc (std::string line, std::ofstream &os);

#endif