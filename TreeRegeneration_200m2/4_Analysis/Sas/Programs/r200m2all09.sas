OPTIONS NOCENTER LINESIZE=73;
FILENAME TREE84 'F:\TreeRegeneration_200m2\3_Data\REG200.84D';
FILENAME TREE92 'F:\TreeRegeneration_200m2\3_Data\reg200.92D';
FILENAME TREE97 'F:\TreeRegeneration_200m2\3_Data\reg200m2.97D';
FILENAME TREE04 'F:\TreeRegeneration_200m2\3_Data\reg200m204.dat';
FILENAME TREE09 'F:\TreeRegeneration_200m2\3_Data\reg200m2.2009.dat';
FILENAME QUAD 'F:\TreeRegeneration_4m2\3_Data\REG4PLOTcovtypedrainclass.dat';
FILENAME OAK94 'F:\TreeRegeneration_4m2\3_Data\OAK4M2.94P';
DATA ROAK94;
INFILE OAK94 n=400;
LENGTH PLOT $ 8 TYPE $ 8 LOCATION $ 8 quadrat $ 3;
INPUT PLOT $ TYPE $ OAKCT94 LOCATION $;
if type='QUADCENT';
IF LOCATION='I' THEN locn=0; IF LOCATION='I' THEN LOCATION='INTERIOR';
IF LOCATION='E' THEN locn=1; IF LOCATION='E' THEN LOCATION='EDGE';
IF LOCATION='G' THEN locn=2; IF LOCATION='G' THEN LOCATION='GAP';
quadrat=substr(plot,1,3);
run;
proc sort data=roak94; by quadrat;
proc means sum data=roak94; by quadrat; VAR locn; *calculate number of 4m2 plots by location;
output out=quadgap sum=gapct;
run;
data gap200m2; set quadgap;    * Use sum to determine if 200m2 plot is located near or in a gap;
if gapct=0 then cut='interior';
if gapct>0 then cut='edge';
if gapct>5.9 then cut='gap';
run;
proc print data=roak94; *gap200m2;
run;
DATA QINFO; INFILE QUAD;
INPUT TYPE $ QUADRAT $ DRAIN $ FOREST $ SOIL $ COVTYPE $;
run;
DATA R84d; INFILE TREE84 MISSOVER;
INPUT QUADRAT $ SPEC cond nreg1 NREG2 NREG3 NREG4 NREG5 NREG6 NREG7 NREG8 ;
IF COND=0;
YEAR=1984;
LENGTH SPECIES $ 4;
     IF SPEC= 1 THEN SPECIES='WP';
     IF SPEC= 2 THEN SPECIES='RS';
     IF SPEC= 3 THEN SPECIES='BF';
     IF SPEC= 4 THEN SPECIES='HM';
     IF SPEC= 5 THEN SPECIES='RO';
     IF SPEC= 6 THEN SPECIES='WO';
     IF SPEC= 7 THEN SPECIES='RM';
     IF SPEC= 8 THEN SPECIES='YB';
     IF SPEC= 9 THEN SPECIES='PB';
     IF SPEC= 10 THEN SPECIES='GB';
     IF SPEC= 11 THEN SPECIES='BE';
     IF SPEC= 12 THEN SPECIES='WA';
     IF SPEC= 13 THEN SPECIES='SM';
     IF SPEC= 14 THEN SPECIES='POPG';
     IF SPEC= 15 THEN SPECIES='POPT';
     IF SPEC= 16 THEN SPECIES='BC';
     IF SPEC= 17 THEN SPECIES='APL';
     IF SPEC= 18 THEN SPECIES='HH';
     IF SPEC= 19 THEN SPECIES='RP';
     IF SPEC= 20 THEN SPECIES='PP';
     IF SPEC= 25 THEN SPECIES='WH';
     IF SPEC= 26 THEN SPECIES='ALD';
     IF SPECIES='   ' THEN SPECIES='OTH';
IF SPEC=0 THEN DO;
  NUMBER=0;
  SIZE=0;
  COUNT=COUNT+1;
  RETAIN COUNT;
END;
IF NREG1^=. THEN DO;
  NUMBER=INT(NREG1);
  SIZE=(NREG1-NUMBER)*10;
  OUTPUT;
END;
IF NREG2^=. THEN DO;
  NUMBER=INT(NREG2);
  SIZE=(NREG2-NUMBER)*10;
  OUTPUT;
END;
IF NREG3^=. THEN DO;
  NUMBER=INT(NREG3);
  SIZE=(NREG3-NUMBER)*10;
  OUTPUT;
END;
IF NREG4^=. THEN DO;
  NUMBER=INT(NREG4);
  SIZE=(NREG4-NUMBER)*10;
  OUTPUT;
END;
IF NREG5^=. THEN DO;
  NUMBER=INT(NREG5);
  SIZE=(NREG5-NUMBER)*10;
  OUTPUT;
END;
IF NREG6^=. THEN DO;
  NUMBER=INT(NREG6);
  SIZE=(NREG6-NUMBER)*10;
  OUTPUT;
END;
IF NREG7^=. THEN DO;
  NUMBER=INT(NREG7);
  SIZE=(NREG7-NUMBER)*10;
  OUTPUT;
END;
IF NREG8^=. THEN DO;
  NUMBER=INT(NREG8);
  SIZE=(NREG8-NUMBER)*10;
  OUTPUT;
END;
DATA R92d; INFILE TREE92 MISSOVER;
INPUT QUADRAT $ SPEC cond nreg1 NREG2 NREG3 NREG4 NREG5 NREG6 NREG7 NREG8 ;
IF COND=0;
YEAR=1992;
LENGTH SPECIES $ 4;
     IF SPEC= 1 THEN SPECIES='WP';
     IF SPEC= 2 THEN SPECIES='RS';
     IF SPEC= 3 THEN SPECIES='BF';
     IF SPEC= 4 THEN SPECIES='HM';
     IF SPEC= 5 THEN SPECIES='RO';
     IF SPEC= 6 THEN SPECIES='WO';
     IF SPEC= 7 THEN SPECIES='RM';
     IF SPEC= 8 THEN SPECIES='YB';
     IF SPEC= 9 THEN SPECIES='PB';
     IF SPEC= 10 THEN SPECIES='GB';
     IF SPEC= 11 THEN SPECIES='BE';
     IF SPEC= 12 THEN SPECIES='WA';
     IF SPEC= 13 THEN SPECIES='SM';
     IF SPEC= 14 THEN SPECIES='POPG';
     IF SPEC= 15 THEN SPECIES='POPT';
     IF SPEC= 16 THEN SPECIES='BC';
     IF SPEC= 17 THEN SPECIES='APL';
     IF SPEC= 18 THEN SPECIES='HH';
     IF SPEC= 19 THEN SPECIES='RP';
     IF SPEC= 20 THEN SPECIES='PP';
     IF SPEC= 25 THEN SPECIES='WH';
     IF SPEC= 26 THEN SPECIES='ALD';
     IF SPECIES='   ' THEN SPECIES='OTH';
IF SPEC=0 THEN DO;
  NUMBER=0;
  SIZE=0;
  COUNT=COUNT+1;
  RETAIN COUNT;
END;
IF NREG1^=. THEN DO;
  NUMBER=INT(NREG1);
  SIZE=(NREG1-NUMBER)*10;
  OUTPUT;
END;
IF NREG2^=. THEN DO;
  NUMBER=INT(NREG2);
  SIZE=(NREG2-NUMBER)*10;
  OUTPUT;
END;
IF NREG3^=. THEN DO;
  NUMBER=INT(NREG3);
  SIZE=(NREG3-NUMBER)*10;
  OUTPUT;
END;
IF NREG4^=. THEN DO;
  NUMBER=INT(NREG4);
  SIZE=(NREG4-NUMBER)*10;
  OUTPUT;
END;
IF NREG5^=. THEN DO;
  NUMBER=INT(NREG5);
  SIZE=(NREG5-NUMBER)*10;
  OUTPUT;
END;
IF NREG6^=. THEN DO;
  NUMBER=INT(NREG6);
  SIZE=(NREG6-NUMBER)*10;
  OUTPUT;
END;
IF NREG7^=. THEN DO;
  NUMBER=INT(NREG7);
  SIZE=(NREG7-NUMBER)*10;
  OUTPUT;
END;
IF NREG8^=. THEN DO;
  NUMBER=INT(NREG8);
  SIZE=(NREG8-NUMBER)*10;
  OUTPUT;
END;
DATA R97d; INFILE TREE97 MISSOVER;
INPUT QUADRAT $ SPEC nreg1 NREG2 NREG3 NREG4 NREG5 NREG6 NREG7 NREG8 ;
COND=0;
YEAR=1997;
LENGTH SPECIES $ 4;
     IF SPEC= 1 THEN SPECIES='WP';
     IF SPEC= 2 THEN SPECIES='RS';
     IF SPEC= 3 THEN SPECIES='BF';
     IF SPEC= 4 THEN SPECIES='HM';
     IF SPEC= 5 THEN SPECIES='RO';
     IF SPEC= 6 THEN SPECIES='WO';
     IF SPEC= 7 THEN SPECIES='RM';
     IF SPEC= 8 THEN SPECIES='YB';
     IF SPEC= 9 THEN SPECIES='PB';
     IF SPEC= 10 THEN SPECIES='GB';
     IF SPEC= 11 THEN SPECIES='BE';
     IF SPEC= 12 THEN SPECIES='WA';
     IF SPEC= 13 THEN SPECIES='SM';
     IF SPEC= 14 THEN SPECIES='POPG';
     IF SPEC= 15 THEN SPECIES='POPT';
     IF SPEC= 16 THEN SPECIES='BC';
     IF SPEC= 17 THEN SPECIES='APL';
     IF SPEC= 18 THEN SPECIES='HH';
     IF SPEC= 19 THEN SPECIES='RP';
     IF SPEC= 20 THEN SPECIES='PP';
     IF SPEC= 25 THEN SPECIES='WH';
     IF SPEC= 26 THEN SPECIES='ALD';
     IF SPECIES='   ' THEN SPECIES='OTH';
IF SPEC=0 THEN DO;
  NUMBER=0;
  SIZE=0;
  COUNT=COUNT+1;
  RETAIN COUNT;
END;
IF NREG1^=. THEN DO;
  NUMBER=INT(NREG1);
  SIZE=(NREG1-NUMBER)*10;
  OUTPUT;
END;
IF NREG2^=. THEN DO;
  NUMBER=INT(NREG2);
  SIZE=(NREG2-NUMBER)*10;
  OUTPUT;
END;
IF NREG3^=. THEN DO;
  NUMBER=INT(NREG3);
  SIZE=(NREG3-NUMBER)*10;
  OUTPUT;
END;
IF NREG4^=. THEN DO;
  NUMBER=INT(NREG4);
  SIZE=(NREG4-NUMBER)*10;
  OUTPUT;
END;
IF NREG5^=. THEN DO;
  NUMBER=INT(NREG5);
  SIZE=(NREG5-NUMBER)*10;
  OUTPUT;
END;
IF NREG6^=. THEN DO;
  NUMBER=INT(NREG6);
  SIZE=(NREG6-NUMBER)*10;
  OUTPUT;
END;
IF NREG7^=. THEN DO;
  NUMBER=INT(NREG7);
  SIZE=(NREG7-NUMBER)*10;
  OUTPUT;
END;
IF NREG8^=. THEN DO;
  NUMBER=INT(NREG8);
  SIZE=(NREG8-NUMBER)*10;
  OUTPUT;
END;
RUN;
DATA R04d; INFILE TREE04 MISSOVER;
INPUT QUADRAT $ SPEC cond nreg1 NREG2 NREG3 NREG4 NREG5 NREG6 NREG7 NREG8 ;
if COND=0;
YEAR=2004;
LENGTH SPECIES $ 4;
     IF SPEC= 1 THEN SPECIES='WP';
     IF SPEC= 2 THEN SPECIES='RS';
     IF SPEC= 3 THEN SPECIES='BF';
     IF SPEC= 4 THEN SPECIES='HM';
     IF SPEC= 5 THEN SPECIES='RO';
     IF SPEC= 6 THEN SPECIES='WO';
     IF SPEC= 7 THEN SPECIES='RM';
     IF SPEC= 8 THEN SPECIES='YB';
     IF SPEC= 9 THEN SPECIES='PB';
     IF SPEC= 10 THEN SPECIES='GB';
     IF SPEC= 11 THEN SPECIES='BE';
     IF SPEC= 12 THEN SPECIES='WA';
     IF SPEC= 13 THEN SPECIES='SM';
     IF SPEC= 14 THEN SPECIES='POPG';
     IF SPEC= 15 THEN SPECIES='POPT';
     IF SPEC= 16 THEN SPECIES='BC';
     IF SPEC= 17 THEN SPECIES='APL';
     IF SPEC= 18 THEN SPECIES='HH';
     IF SPEC= 19 THEN SPECIES='RP';
     IF SPEC= 20 THEN SPECIES='PP';
     IF SPEC= 25 THEN SPECIES='WH';
     IF SPEC= 26 THEN SPECIES='ALD';
     IF SPECIES='   ' THEN SPECIES='OTH';
IF SPEC=0 THEN DO;
  NUMBER=0;
  SIZE=0;
  COUNT=COUNT+1;
  RETAIN COUNT;
END;
IF NREG1^=. THEN DO;
  NUMBER=INT(NREG1);
  SIZE=(NREG1-NUMBER)*10;
  OUTPUT;
END;
IF NREG2^=. THEN DO;
  NUMBER=INT(NREG2);
  SIZE=(NREG2-NUMBER)*10;
  OUTPUT;
END;
IF NREG3^=. THEN DO;
  NUMBER=INT(NREG3);
  SIZE=(NREG3-NUMBER)*10;
  OUTPUT;
END;
IF NREG4^=. THEN DO;
  NUMBER=INT(NREG4);
  SIZE=(NREG4-NUMBER)*10;
  OUTPUT;
END;
IF NREG5^=. THEN DO;
  NUMBER=INT(NREG5);
  SIZE=(NREG5-NUMBER)*10;
  OUTPUT;
END;
IF NREG6^=. THEN DO;
  NUMBER=INT(NREG6);
  SIZE=(NREG6-NUMBER)*10;
  OUTPUT;
END;
IF NREG7^=. THEN DO;
  NUMBER=INT(NREG7);
  SIZE=(NREG7-NUMBER)*10;
  OUTPUT;
END;
IF NREG8^=. THEN DO;
  NUMBER=INT(NREG8);
  SIZE=(NREG8-NUMBER)*10;
  OUTPUT;
END;
RUN;
DATA R09d; INFILE TREE09 MISSOVER;
INPUT QUADRAT $ SPEC cond nreg1 NREG2 NREG3 NREG4 NREG5 NREG6 NREG7 NREG8 ;
if COND=0;
YEAR=2009;
LENGTH SPECIES $ 4;
     IF SPEC= 1 THEN SPECIES='WP';
     IF SPEC= 2 THEN SPECIES='RS';
     IF SPEC= 3 THEN SPECIES='BF';
     IF SPEC= 4 THEN SPECIES='HM';
     IF SPEC= 5 THEN SPECIES='RO';
     IF SPEC= 6 THEN SPECIES='WO';
     IF SPEC= 7 THEN SPECIES='RM';
     IF SPEC= 8 THEN SPECIES='YB';
     IF SPEC= 9 THEN SPECIES='PB';
     IF SPEC= 10 THEN SPECIES='GB';
     IF SPEC= 11 THEN SPECIES='BE';
     IF SPEC= 12 THEN SPECIES='WA';
     IF SPEC= 13 THEN SPECIES='SM';
     IF SPEC= 14 THEN SPECIES='POPG';
     IF SPEC= 15 THEN SPECIES='POPT';
     IF SPEC= 16 THEN SPECIES='BC';
     IF SPEC= 17 THEN SPECIES='APL';
     IF SPEC= 18 THEN SPECIES='HH';
     IF SPEC= 19 THEN SPECIES='RP';
     IF SPEC= 20 THEN SPECIES='PP';
     IF SPEC= 25 THEN SPECIES='WH';
     IF SPEC= 26 THEN SPECIES='ALD';
     IF SPECIES='   ' THEN SPECIES='OTH';
IF SPEC=0 THEN DO;
  NUMBER=0;
  SIZE=0;
  COUNT=COUNT+1;
  RETAIN COUNT;
END;
IF NREG1^=. THEN DO;
  NUMBER=INT(NREG1);
  SIZE=(NREG1-NUMBER)*10;
  OUTPUT;
END;
IF NREG2^=. THEN DO;
  NUMBER=INT(NREG2);
  SIZE=(NREG2-NUMBER)*10;
  OUTPUT;
END;
IF NREG3^=. THEN DO;
  NUMBER=INT(NREG3);
  SIZE=(NREG3-NUMBER)*10;
  OUTPUT;
END;
IF NREG4^=. THEN DO;
  NUMBER=INT(NREG4);
  SIZE=(NREG4-NUMBER)*10;
  OUTPUT;
END;
IF NREG5^=. THEN DO;
  NUMBER=INT(NREG5);
  SIZE=(NREG5-NUMBER)*10;
  OUTPUT;
END;
IF NREG6^=. THEN DO;
  NUMBER=INT(NREG6);
  SIZE=(NREG6-NUMBER)*10;
  OUTPUT;
END;
IF NREG7^=. THEN DO;
  NUMBER=INT(NREG7);
  SIZE=(NREG7-NUMBER)*10;
  OUTPUT;
END;
IF NREG8^=. THEN DO;
  NUMBER=INT(NREG8);
  SIZE=(NREG8-NUMBER)*10;
  OUTPUT;
END;
RUN;

data c1; set r84d r92d r97d r04d r09d;

proc sort data=c1; by year cond;
proc means sum data=c1; var number; by year cond;
run;

proc sort data=c1; by year quadrat;
proc means n data=c1; by year quadrat; var spec;
output out=qtally n=specn ;
run;
/*
proc sort data=qtally; by year;
proc means n sum data=qtally; by year; var quadn quadtot;
run;*/
proc sort data=qtally;  by quadrat ;
proc means n  data=qtally; by quadrat ; var year;
output out=qtally n=yearn ;
run;
quit;
