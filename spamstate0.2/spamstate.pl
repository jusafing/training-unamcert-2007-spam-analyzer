#!/usr/bin/perl 

use Net::Nslookup;
use Mail::MboxParser;
use perlchartdir;


### 	DEPARTAMENTO DE SEGURIDAD EN COMPUTO / UNAM CERT
###  	PLAN DE BECARIOS DE SEGURIDAD EN COMPUTO
###	PROGRAMACION EN PERL
### 	PROYECTO FINAL

###	JAVIER ULISES SANTILLAN ARENAS
###	bec_jsantillan@seguridad.unam.mx

###	ANALIZADOR Y GENERADOR DE ESTADISTICAS DE SPAM EN BUZONES DE CORREO MBOX
###	spamstate V1.0

##############################################################
#######          OBTENCION  DE  ARGUMENTOS           #########
##############################################################
$num=@ARGV;
for($i=0;$i<$num;$i++)
{
	if ($ARGV[$i] eq "-p"){
		if ($ARGV[$i+1] eq "-o" || $ARGV[$i+1] eq "-r" || $ARGV[$i+1] eq "-c" || $ARGV[$i+1] eq "-fi" || $ARGV[$i+1] eq "-ff" || $i==$num-1) { $argumentos{$ARGV[$i]}="null" }
		else {$argumentos{$ARGV[$i]}=$ARGV[$i+1]; $i++}
	}
	elsif($ARGV[$i] eq "-o"){
		if ($ARGV[$i+1] eq "-r" || $ARGV[$i+1] eq "-p" || $ARGV[$i+1] eq "-c" || $ARGV[$i+1] eq "-fi" || $ARGV[$i+1] eq "-ff" || $i==$num-1) { $argumentos{$ARGV[$i]}="null" }
		else {$argumentos{$ARGV[$i]}=$ARGV[$i+1]; $i++;}
	}
	elsif($ARGV[$i] eq "-r"){
		if ($ARGV[$i+1] eq "-o" || $ARGV[$i+1] eq "-p" || $ARGV[$i+1] eq "-c" || $ARGV[$i+1] eq "-fi" || $ARGV[$i+1] eq "-ff" || $i==$num-1) { $argumentos{$ARGV[$i]}="null" }
		else {$argumentos{$ARGV[$i]}=$ARGV[$i+1]; $i++;}
	}
        elsif($ARGV[$i] eq "-c"){
                if ($ARGV[$i+1] eq "-o" || $ARGV[$i+1] eq "-p" || $ARGV[$i+1] eq "-r" || $ARGV[$i+1] eq "-fi" || $ARGV[$i+1] eq "-ff" || $i==$num-1) { $argumentos{$ARGV[$i]}="null" }
		else {$argumentos{$ARGV[$i]}=$ARGV[$i+1]; $i++;}
	}
        elsif($ARGV[$i] eq "-fi"){
                if ($ARGV[$i+1] eq "-o" || $ARGV[$i+1] eq "-p" || $ARGV[$i+1] eq "-r" || $ARGV[$i+1] eq "-c" || $ARGV[$i+1] eq "-ff" || $i==$num-1) { $argumentos{$ARGV[$i]}="null" }
                else {$argumentos{$ARGV[$i]}=$ARGV[$i+1]; $i++;}
        }
	elsif($ARGV[$i] eq "-ff"){
                if ($ARGV[$i+1] eq "-o" || $ARGV[$i+1] eq "-p" || $ARGV[$i+1] eq "-r" || $ARGV[$i+1] eq "-c" || $ARGV[$i+1] eq "-fi" || $i==$num-1) { $argumentos{$ARGV[$i]}="null" }
                else {$argumentos{$ARGV[$i]}=$ARGV[$i+1]; $i++;}
        }
	else { die "\n ERROR, argumento $ARGV[$i] no valido\n\n" }
}
$cf_flag=0;
foreach $opcion (keys%argumentos)
{
	if ($opcion eq "-c"){
		die "ERROR, opcion [-c]: No existe el archivo $argumentos{$opcion}\n" unless (-e $argumentos{$opcion});
		$config_file=$argumentos{$opcion};
		$cf_flag=1;
	}
}
if($cf_flag==0){
	$config_default=`pwd`;
	chomp($config_default);
	$config_default.="/spamstate.conf";
	open(CONFIG_FILE,"<$config_default") || die "ERROR, No se pudo abrir el archivo $config_default\n";
	$config=$config_default;
}
else{
	open(CONFIG_FILE,"<$config_file") || die "ERROR, No se pudo abrir el archivo $config_file\n";
	$config=$config_file;
}
while(<CONFIG_FILE>)
{
	chomp;
	@linea=split("=",$_);
	if ($linea[0] eq "PASSWD"){
		$argumentos_exe{"-p"}=$linea[1];	
		$argumentos_exe{'-p'}="not" if ($argumentos_exe{"-p"} eq "" );
	}
	if ($linea[0] eq "OMITIR"){
		$argumentos_exe{"-o"}=$linea[1];
	}
	if ($linea[0] eq "SALIDA"){
		$argumentos_exe{"-r"}=$linea[1];
		$argumentos_exe{'-r'}="not" if ($argumentos_exe{"-r"} eq "" );
	}
	if ($linea[0] eq "SPAM"){
		$argumentos_exe{"SPAM"}=$linea[1];
		$argumentos_exe{'SPAM'}="null" if ($argumentos_exe{"SPAM"}  eq "");
	}
}
close(CONFIG_FILE);
foreach $x (keys%argumentos)
{
	die "\n\nERROR, Falta argumento [$x]\n\n" if ($argumentos{$x} eq "null");
	$argumentos_exe{$x}=$argumentos{$x};
}
print "\n##############################################################\n";
print "\n	ARGUMENTOS DE EJECUCION DEL PROGRAMA\n\n\t";
foreach $x (keys%argumentos_exe)
{
		die "\n\tERROR en argumento $x\n\n" if($argumentos_exe{$x} eq "null");
		print "[ $x ] - $argumentos_exe{$x}\n\t";
}

delete $argumentos_exe{'-r'} if ($argumentos_exe{'-r'} eq "not");
delete $argumentos_exe{'-p'} if ($argumentos_exe{'-p'} eq "not");
die "\n\tERROR, solo un modo de ejecucion [-p] o [-r]\n\n" if (exists $argumentos_exe{'-r'} && exists $argumentos_exe{'-p'});
die "\n\tERROR, no se especifico el modo de ejecucion [-p] [-r]\n" if (! exists $argumentos_exe{'-r'} && ! exists $argumentos_exe{'-p'});

print "\n###############################################################\n";
if (defined $argumentos_exe{"-r"}){
	if (exists $argumentos_exe{'-fi'}){
		@fi=split("-",$argumentos_exe{'-fi'});
		die "\n\nERROR, Fecha Inicial erronea\n\n" if ($fi[0]<=0 || $fi[0]>12 || $fi[1]<=0 || $fi[1]>31 || ($fi[0]==2 && $fi[1]>29) );
	}
	if (defined $argumentos_exe{'-ff'}){
                @ff=split("-",$argumentos_exe{'-ff'});
                die "\n\nERROR, Fecha Final erronea\n\n" if ($ff[0]<=0 || $ff[0]>12 || $ff[1]<=0 || $ff[1]>31 || ($ff[0]==2 && $ff[1]>29) );
        }
	if (defined $argumentos_exe{"-fi"} && defined $argumentos_exe{"-ff"}){
		die "\n\nERROR, La fecha final debe ser despues a la fecha inicial\n\n" if ($ff[0] < $fi[0]);
		die "\n\nERROR, La fecha final debe ser despues a la fecha inicial\n\n" if ($ff[0] == $fi[0] && $ff[1] < $fi[1]);
	}
}
@usr_omitir=split(",",$argumentos_exe{'-o'});

if(exists $argumentos_exe{'-p'})
{
	die "\n\nERROR [-p] : No es posible accesar al archivo $argumentos_exe{'-p'}\n\n" if (! -r $argumentos_exe{'-p'});
	open(PASSWD,"<$argumentos_exe{'-p'}");
	while (<PASSWD>)
	{
		@linea=split(":",$_);
		$ok=0;
		foreach $usuario (@usr_omitir)
		{
			if($linea[0] eq $usuario) { $ok=1; last;}
		}
		$usr_home{$linea[0]}=$linea[5] if ($ok==0);
	}
	close(PASSWD);
}
###################################################################
#########         LECTURA DE LOS BUZONES DE CORREO         ########
###################################################################
$datex=`date`;
@datexa=split(" ",$datex);
$date_exe="$datexa[0]-$datexa[1]-$datexa[2]";
$hour_exe=$datexa[3];

if (exists $argumentos_exe{'-p'})
{
	`touch  datos.txt`;
	open (DATOS,">>datos.txt");
	foreach $usuario (keys%usr_home)
	{
		$user=$usuario;
		$maildir=$usr_home{$usuario}."/$argumentos_exe{'SPAM'}";
		print "***************************************************************";
	        print "\nPROCESANDO USUARIO: $usuario  BUZON: $maildir\n";
		next unless (-e $maildir);
		lee_buzon();
		print "\n";
	}
	close(DATOS);
}

if (defined $argumentos_exe{"-r"}){
	if (exists $argumentos_exe{'-fi'} && ! exists $argumentos_exe{'-ff'}){
		$argumentos_exe{'-ff'}="12-31";
	}
	if (exists $argumentos_exe{'-ff'} && ! exists $argumentos_exe{'-fi'}){
	        $argumentos_exe{'-fi'}="1-1";
        }
	if (! exists $argumentos_exe{"-fi"} && ! exists $argumentos_exe{"-ff"}){
		$argumentos_exe{'-fi'}="1-1";
		$argumentos_exe{'-ff'}="12-31";
	}
	print "\n Fechas de reporte:  INICIO: $argumentos_exe{'-fi'}\tFINAL $argumentos_exe{'-ff'}\n";
	crea_archivo_reporte();
	crea_reporte_final();
}

sub lee_buzon
{
	my $parseropts = {
	enable_cache    => 0,
        enable_grep     => 1,
        cache_file_name => 'mail/cache-file',
    	};
    	my $mb = Mail::MboxParser->new($maildir, decode => 'ALL', parseropts => $parseropts);
	$contmsj=1;
	for my $msg ($mb->get_messages) {
		print "\n\tProcesando Mensaje [ $contmsj ] en el Buzon ..... ";
		$subject=$msg->header->{subject};
        	$from=$msg->header->{from};
		$date_hrs=$msg->header->{date};
		#my $body = $msg->body(0);
		@correo = $msg->body($msg->find_body);
		@date_hrs=split(" ",$date_hrs);
		$date=$date_hrs[0].$date_hrs[1].$date_hrs[2];
		pop(@date_hrs);			
		$hour=pop(@date_hrs);
		$subject="NO SUBJECT" if ($subject eq "");
		crea_salida();
		$contmsj++;
		print "OK";
    	}
}

sub crea_salida
{	
	$ic=0;
	print DATOS "$date_exe|$hour_exe|$user|$date|$hour|$from|$subject|";
#	print "$date_exe|$hour_exe|$user|$date|$hour|$from|$subject|";

	while($ic <= @correo){
		$a='[0-9]{1,3}';
		$b='^0[0-9]{1,2}';
		while ($correo[$ic]=~(/(($a)\.($a)\.($a)\.($a))/g) && ($2<256) && ($3<256) && ($4<256) && ($5<256) && ($2 !~ /$b/) && ($3 != /$b/) && ($4 != /$b/) && ($5 != /$b/)){
			@asnout=`whois -h whois.cymru.com "-v $1"`;
        	        @linea=split(/\|/,$asnout[2]);
			$asn=$linea[0]/1;
		        print DATOS "XXX,XXX,$1,$asn*";
#			print "XXX,XXX,$1,$asn*";
		}
		while( $correo[$ic]=~/(((ftp|http|https):\/\/|www\.)([\w*\-?\w*\.]+)*)/g ){
			$urlx=$1;
			$url="$urlx/";
			if ($url=~/^http./ || $url=~/^ftp/)
			{
				@dom=split(/:\/\//,$url);
				@dom=split(/\//,$dom[1]);
			}
			else{@dom=split(/\//,$url);}
			$dir = nslookup $dom[0];
			next if ($dir eq "");
			@asnout=`whois -h whois.cymru.com "-v $dir"`;
			@linea=split(/\|/,$asnout[2]);
			$asn=$linea[0]/1;
			print DATOS "$urlx,$dom[0],$dir,$asn*";
#			print "$urlx,$dom[0],$dir,$asn*";
		 }
		 $ic++;
	}
	print DATOS "\n";
}

sub crea_archivo_reporte
{
	$outtmp=$argumentos_exe{'-r'}."/url_spam_".$date_exe."_".$hour_exe.".dat";
	`touch $outtmp`;
	open(SALIDA,">$outtmp");
	open(DATOS,"<datos.txt");
	@mesdiai=split("-",$argumentos_exe{'-fi'});
	@mesdiaf=split("-",$argumentos_exe{'-ff'});
	while(<DATOS>)
	{
		@linea=split(/\|/,$_);
#		print "\nLINEA: $linea[0]\n";
		@fecharep=split("-",$linea[0]);
#		print "FECHA:$linea[0]-MES:$fecharep[1]-DIA:$fecharep[2]\n";
		mes($fecharep[1]);
#		print "MES:$mes -INI:$mesdiai[0]-FIN:$mesdiaf[0]\n";
		if ($mes >= $mesdiai[0] && $mes <= $mesdiaf[0])
		{
			if($mesdiai[0] == $mesdiaf[0]){
				print SALIDA "$_" if ($fecharep[2] >= $mesdiai[1] && $fecharep[2] <= $mesdiaf[1]);
#                               print "$_" if ($fecharep[2] >= $mesdiai[1] && $fecharep[2] <= $mesdiaf[1]);
			}
			elsif($mes == $mesdiai[0]){
				print SALIDA "$_" if ($fecharep[2] >= $mesdiai[1]);
#				print "$_" if ($fecharep[2] >= $mesdiai[1]);
			}
			elsif($mes == $mesdiaf[0]){
				print SALIDA "$_" if ($fecharep[2] <= $mesdiaf[1]);
#				print "$_" if ($fecharep[2] <= $mesdiaf[1]);
			}
			else{
				print SALIDA "$_";
#				print "$_";
			}
		}
	}
	close(SALIDA);
	close(DATOS);
	print "\n > ARCHIVO DE DATOS GENERADO     -> $outtmp" if (-e $outtmp);
}
sub mes
{
	$m=shift;
	if($m eq "jan" || $m eq "ene"){$mes=1;}
	elsif($m eq "feb" || $m eq "feb"){$mes=2;}
	elsif($m eq "mar"){$mes=3;}
	elsif($m eq "apr" || $m eq "abr"){$mes=4;}
	elsif($m eq "may"){$mes=5;}
	elsif($m eq "jun"){$mes=6;}
	elsif($m eq "jul"){$mes=7;}
	elsif($m eq "aug" || $m eq "ago"){$mes=8;}
	elsif($m eq "sep"){$mes=9;}
	elsif($m eq "cct"){$mes=10;}
	elsif($m eq "nov"){$mes=11;}
	elsif($m eq "dec" || $m eq "dic"){$mes=12;}
}
sub crea_reporte_final
{
	open (DATOS,"<$outtmp");
	$rep=$argumentos_exe{'-r'}."/url_spam_".$date_exe."_".$hour_exe.".txt";
	`touch $rep`;
	open (REPORTE,">$rep");
	while (<DATOS>)
	{
		chomp;
		@campo=split(/\|/,$_);
#		print "CAMPO5: $campo[5]\t CAMPO6 $campo[6]\tCAMPO[7] $campo[7]\n";
		$froms{$campo[5]}++;
		$subjects{$campo[6]}++;
		@urls=split(/\*/,$campo[7]);
		foreach $url (@urls){
			@var=split(",",$url);
			$asns{$var[3]}++;
		}
	}
	close(DATOS);
	print REPORTE "\n\n**************************************************************\n";
	print REPORTE "***    R E P O R T E     D E    E S T A D I S T I C A S    ***\n";
	print REPORTE "**************************************************************\n\n";
	print REPORTE "--------------------------------------------------------------\n";
	print REPORTE ">  Fecha de creacion:\t$date_exe\n";
	print REPORTE ">  Hora de creacion :\t$hour_exe\n\n";
	print REPORTE "Intervalo de reporte: INICIO  (mm/dd): $argumentos_exe{'-fi'}\n";
	print REPORTE "                      TERMINO (mm/dd): $argumentos_exe{'-ff'}\n";
	print REPORTE "--------------------------------------------------------------\n\n\n";
	print REPORTE "#######################\n";
	print REPORTE "###    TOP 10 ASN   ###\n";
	print REPORTE "#######################\n";
	$cntop=1;
	foreach $top (sort byasn keys%asns)
	{
		print REPORTE "\t$cntop ) [ $top ]\t:\t$asns{$top}\n" if ($cntop <=10);
		push(@asngraph_val,$asns{$top});
		push(@asngraph_nom,$top);
		$cntop++;
	}
	grafica("ASN");
	$cntop=1;
	print REPORTE "\n###############################\n";
	print REPORTE "###    TOP 50 REMITENTES    ###\n";
	print REPORTE "###############################\n";
        foreach $top (sort byfrom  keys%froms)
        {
                print REPORTE "\t$cntop ) [ $top ]\t:\t$froms{$top}\n" if ($cntop <=50);
		$cntop++;
        }
	$cntop=1;
	print REPORTE "\n#############################\n";
        print REPORTE "###    TOP 50 SUBJECTS    ###\n";
	print REPORTE "#############################\n";
        foreach $top (sort bysubject keys%subjects)
        {
                print REPORTE "\t$cntop ) [ $top ]\t:\t$subjects{$top}\n" if ($cntop <=50);
		$cntop++;
        }
	close(DATOS);
	close(REPORTE);
	print "\n > ARCHIVO DE REPORTES GENERADO  -> $rep" if (-e $rep);
	print "\n > ARCHIVO DE GRAFICAS PARA ASN  -> $grap" if (-e $grap);
}
sub byasn
{
	$asns{$b} <=> $asns{$a} || $a cmp $b 
}
sub byfrom
{
	$froms{$b} <=> $froms{$a} || $a cmp $b 
}
sub bysubject
{
	$subjects{$b} <=> $subjects{$a} || $a cmp $b 
}

sub grafica
{
	$tipo=shift;
	$grap=$argumentos_exe{'-r'}."/url_spam_".$date_exe."_".$hour_exe."_".$tipo.".png";
	# The data for the bar chart
	my $data = [@asngraph_val];
	# The labels for the bar chart
	my $labels = [@asngraph_nom];
	# Create a XYChart object of size 400 x 240 pixels.
	my $c = new XYChart(1000, 300);
	# Add a title to the chart using 14 pts Times Bold Italic font
	$c->addTitle("ASN");
	# Set the plotarea at (45, 40) and of 300 x 160 pixels in size. Use alternating light
	# grey (f8f8f8) / white (ffffff) background.
	$c->setPlotArea(20, 20, 970, 175, 0xf8f8f8, 0xffffff);
	# Add a multi-color bar chart layer
	my $layer = $c->addBarLayer3($data);
	# Set layer to 3D with 10 pixels 3D depth
	$layer->set3D(20);
	# Set bar shape to circular (cylinder)
	$layer->setBarShape($perlchartdir::CircleShape);
	# Set the labels on the x axis.
	$c->xAxis()->setLabels($labels);
	# Add a title to the y axis
	$c->yAxis()->setTitle("CANTIDAD DE INCIDENCIAS");
	# Add a title to the x axis
	$c->xAxis()->setTitle("ASN");
	# output the chart
	$c->makeChart($grap);

}

print "\n\n\n";
