#!/usr/bin/perl -w
use strict;
my $genomefile=shift;
my $nt=shift;
my $outfile=shift;

die("\n
     #####################################################################################################
     #This program requires 3 input parameters: A file containing a list of fasta files with the genomes,# 
     #the number of processors to be used by blastn, and a name for the output file. The first parameter #
     #is mandatory, but you did not provide it. Please run the program again!                            #
     #####################################################################################################\n\n");


my @gen=();
if (open(IN,$genomefile))
{
	while(<IN>)
	{
		chomp;
		push(@gen,$_);
	}
}else{
	print "Can not read the genomes file\n";
	die();
}

$nt=1 unless $nt;
$outfile= "anib_table.csv" unless $outfile;


open(OUT,">$outfile");
foreach my $gen (@gen)
{
        my $on=$gen.".D";
	unless (-e "$on.nhr")
	{
        	system("makeblastdb -in $gen -dbtype nucl -out $on")==0||die("$!\n");
	}
}


my %scores=();
foreach my $fh_file (@gen)
{
	foreach my $c (@gen)
	{
		if ($c eq $fh_file)
		{
			$scores{$c}{$fh_file}=1;
		}
		if ($scores{$c}{$fh_file})
		{
			 $scores{$fh_file}{$c}= $scores{$c}{$fh_file};
		}else{
			unless (-e "$fh_file\_$c\_blast")
			{
				system("blastn -task blastn -query $fh_file -db $c.D -outfmt 7 -num_threads $nt -out $fh_file\_$c\_blast")==0 || die();
			}
			my ($score)=read_ff("$fh_file\_$c\_blast");
			$scores{$fh_file}{$c}=$score;
		}
	}
}
my @vl=sort (keys %scores);
print OUT " @vl\n";
foreach my $s (sort keys %scores)
{
	print OUT "$s ";
	foreach my $ss (sort keys %{$scores{$s}})
	{
		print OUT "$scores{$ss}{$s} ";
	}
	print OUT "\n";
}

sub read_ff
{
	my $file=shift;
	print "$file\n";
	open(IN,$file);
	my $hsp;
	my $score=0;
	my $normV=0;
	my $nw=0;
	my $totl=0;
	#gi|421931669|gb|ANFV01000016.1| JNODE_3 99.72   43457   80      10      188830  232246  783302  739848  0.0     8.482e+04
	while(<IN>)
	{
		next if $_=~/\#/;
		my ($node,$id,$ln,$start,$end)=(split())[0,2,3,8,9];
		if ($start>$end)
		{
			my $swp=$end;
			$end=$start;
			$start=$swp;
		}
		#print OUT "$node $start $end\n";
		next unless $ln>500;
		next unless $id>30;
		$totl+=$ln;
		$nw++;
		my $add=1;
		if ($hsp->{$node})
		{
			my @coords=sort{$a<=>$b}@{$hsp->{$node}};
			for (my $i=0;$i<=$#coords*-1;$i+=2)
			{
				my $j=$i+1;
				my $s=$coords[$i];
				my $e=$coords[$j];
				next if $start > $e;
				last if $end< $s;
				my $ovl=0;
				if ($start<$e && $start>$s)
				{
					$ovl=$e-$start+1;
					$ln-=$ovl;
				}elsif($end>$s && $end<$e){
					$ovl=$end-$s+1;
					$ln-=$ovl;
				}elsif($start>$s && $end<$e){
					$add=0;
					last;

				}
				if (($ovl/$ln)>=0.1)
				{
					$add=0;
					last;
				}
			}
			
		}
		push (@{$hsp->{$node}},($start,$end)) if $add==1;
		$normV+=$ln;
		$score+=$id*$ln if $add==1;
	}
	foreach my $n (sort keys %{$hsp})
	{
		my $prev=0;
		my @coords=sort{$a<=>$b}@{$hsp->{$n}};
		for (my $i=0;$i<=$#coords-1;$i+=2)
		{
			my $j=$i+1;
			my $s=$coords[$i];
			my $e=$coords[$j];
			if ($prev>0)
			{
				my $diff=$s-$prev; 
			}
			$prev=$e;
		}
		
	}
	$score=$score/$normV;
	return ($score);
}
