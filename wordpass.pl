#!/usr/bin/perl -w

use strict;
use File::Util;
use File::Slurp;
use Scalar::Util::Numeric qw(isint);
use Data::Dumper qw(Dumper);
use Getopt::Std;

# Declaro Variables
my $file;
my $m;
my $M;
my $output;
my $write;
my $OUTFILE;
my %options=(); # declare the perl command line flags/options we want to allow
my @datos;

# Declaro opciones con letras
# Expect three flags, -h, -f, -m and -M.
# f/m/M can take an argument because the ":" after b.
getopts("hf:m:M:o:", \%options);

# Si ingreso opcion de ayuda (h) muestro menu y salgo
if ($options{h})
{
  &do_help();
  exit;
}

# test for the existence of the options on the command line.
if (!$options{f}){
	&do_help();
	print "\n[ERROR] - Falta parametro de archivo de diccionario (-f)\n\n";
	exit;
}
else{
	$file = $options{f};
}

# Verifico parametro minimo (-m) 
if ($options{m}){
	if(isint $options{m}){
        	$m = $options{m};
	}
	else{
		&do_help();
        	print "\n[ERROR] - Falta parametro entero para parametro (-m)\n\n";
        	exit;
	}
}
else {
        $m = 1;
}

# Verifico parametro maximo (-M)
if ($options{M}){
        if(isint $options{M}){
                $M = $options{M};
        }
        else{
                &do_help();
                print "\n[ERROR] - Falta parametro entero para parametro (-M)\n\n";
                exit;
        }
}
else {
	$M = 1;
}

# Verifico si existe el archivo de datos
if(-e $file){
	# Guardo el contedido del listado
	@datos = read_file("$file");         
}
else{
         &do_help();
         print "\n[ERROR] - No se encuentra el archivo ingresado: $options{f}\n\n";
         exit;
}

# Verifico si se puede escribir archivo de salida
if ($options{o}){
		$output = $options{o};	
		# Creacion del archivo para la generacion de log del satelite.
		# use a variable for the file handle
		open $OUTFILE, '>', $output or die "\n[ERROR] - No se encuentra el archivo ingresado: $output\n\n";
}

# Genero Diccionario
&do_magic;

close $OUTFILE or die "\n[ERROR] - No se encuentra el archivo ingresado: $output\n\n";

#############
# FUNCIONES #
#############

sub do_help {
  print "Available Parameters: \n";
  print " -h : Help \n";
  print " -f : Imput File \n";
  print " -m : Min combinations (Optional - default 1)\n";
  print " -M : Max combinations (Max 4 comb)\n";
  print " -o : Output file (optional)\n";
  print "\n";
  print "Example: ./wordpass.pl -f Passwd_parametros_BiggCrossfit.txt -m 2 -M 4 -o out.txt\n";
  print "\n";
  print "Imput file must be a list of words (one per line).\n";
}

# Generacion de diccionario
sub do_magic{
  chomp(@datos);
  foreach my $line1 (@datos){
    &do_output("$line1");
    foreach my $line2 (@datos){
      if (($line1 ne $line2)&&($M > 1)){
	&do_output("$line1$line2");
       	foreach my $line3 (@datos){
          if(($line2 ne $line3)&&($line1 ne $line3)&&($M > 2)){
	    &do_output("$line1$line2$line3");
	    foreach my $line4 (@datos){
	      if(($line2 ne $line3)&&($line1 ne $line3)&&($line1 ne $line4)&&($line2 ne $line4)&&($line3 ne $line4)&&($M > 3)){
		&do_output("$line1$line2$line3$line4");	
   	      }							
	    }						
          }
        }
      }
    }
  }
}

# Salida de datos
sub do_output{
	if ($output){
		#Imprimo salida dentro del archivo
		print $OUTFILE "$_[0]\n";
	}	
	else{
		#Imprimo por pantalla
		print $_[0]."\n";
	}
}
