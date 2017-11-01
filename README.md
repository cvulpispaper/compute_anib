# compute_anib
This is a perl script for computing anib values among bacterial genomes. 
A greedy overlap removal strategy is applied.
The program implements tha algorithm described in 

The program depends on a working ncbi installation of ncbi blast+ 
You can install blast+ in your system by following instruction provided here:
https://blast.ncbi.nlm.nih.gov/Blast.cgi?PAGE_TYPE=BlastDocs&DOC_TYPE=Download

Since the program is written in the Perl programming language, you will also
need a Perl interpreter in order to run it. Perl is usually installed by default 
in unix alike systems. Anyway you can download and install the latest version of Perl 
from https://www.perl.org/get.html

This program computes anib values among a collection of bacterial genomes. 
The program requires 3 parameters of which 1 (the first) is mandatory

The first parameter is (the name of) a simple text file providing a list
of bacterial genomes that are to be compared. One genome per line.
All the genomes need to be in fasta format, and the list should must contain
the actual names of the files (not the species or anything else). The program 
will create a blast database out of every genome, perform all against all blastn
and derive anib values.
This parameter is mandatory. The file list.txt provides a valid example.
Sample genomes are also available on this github branch

The second parameter in the number of processors to be used by blastn. If no value 
is provided the default (1) will be used. You don't know about that, it can be left
to 1. My advice is to you as many processors as you can on your machine

The third parameter is a name for the output file. In no value is provided the 
default (anib_table.csv) will be used. The output file 

You can run this script by writing:
perl computeAnib.pl <list_file> <num_cpus> <output_file>
in the commandline.  The script can require up to several our to complete, so I would 
advise to run it as a background process with nohup.
Upon completion, the main output will be stored in the anib_table.csv file (or in the
output file specified at runtime), consisting in a tab delineated square matrix, 
where all anib values between all the pairs of genomes.  The file can be easily
visualized with MS-excel or equivalent programs.

No strong checking of file formats is perfomed, so in case of error please check that
all the files are in the correct format if you encounter any error.
Anyway feel free to contact Matteo Chiara (matteo.chiara@unimi.it) if you encounter
any problem or unexpected behaviour








