**************************************************************************
**************************************************************************
***PROGRAM: F:\TreeRegeneration\4_Analyses\TwoHundred_m2\SAS\Programs
***           StemsbyTrtmntOverTime200m2.sas
***PURPOSE: Examine stem count trends over time (three sampling periods, 
***           1984, 92, 97) by treatment (control, managed unharvested,
***           managed harvested). By species.
***INPUT:   F:\TreeRegeneration\3_Data\TwoHundred_m2\REG200.84D
***         F:\TreeRegeneration\3_Data\TwoHundred_m2\reg200.92D
***         F:\TreeRegeneration\3_Data\TwoHundred_m2\REG200m2.97D
***OUTPUT:  F:\TreeRegeneration\4_Analyses\TwoHundred_m2\SAS\Data
***DATE CREATED: 06SEP01
***PROGRAMMER: SPE
***MODIFIED:   06JAN04 SPE Created SAS output dataset
***NOTE:       In this analysis the sampling unit is the 200m2 plot,
***              which is designated by quadrat name.
**************************************************************************
**************************************************************************;

options nocenter linesize=75 pagesize=60 symbolgen mlogic mprint;
*nosymbolgen nomlogic nomprint;

PROC FORMAT;
  VALUE FIAFMT
   1=WP    /*Pinus strobus (white pine)              */
   2=RS    /*Picea rubens (red spruce)               */
   3=BF    /*Abies balsamia (balsam fir)             */
   4=HE    /*Tsuga canadensis (hemlock)              */
   5=RO    /*Quercus rubra (red oak)                 */
   6=WO    /*Quercus alba (white oak)                */
   7=RM    /*Acer rubrum (red maple)                 */
   8=YB    /*Betula alleghaniensis (yellow birch)    */
   9=PB    /*Betula papyrifera (paper birch)         */
  10=GB    /*Betula populifolia (gray birch)         */
  11=BE    /*Fagus grandifolia (beech)               */
  12=WA    /*Fraxinus americana (white ash)          */
  13=MM    /*Acer pensylvanicum (striped maple)      ???*/
  14=btasp /*Populus grandidentata (bigtooth aspen)  */
  15=qa    /*Populus tremuloides (quaking aspen)     */
  16=bc    /*Prunus serotina (black cherry)          */
  17=apl   /*Pyrus malus (apple)                     */
  18=HH    /*Ostrya virginiana (hop hornbeam)        */
  19=RP    /*Pinus resinosa (red pine)               */
  20=PP    /*Pinus rigida (pitch pine)               */
  25=witch /*Hamamelis virginiana (witch hazel)      */
  26=alder /*Alnus sp. (alder sp.)                   */
  OTHER='unknown';
  value sppfmt
  1='WHITE_PINE'
  2='RED_SPRUCE'
  4='HEMLOCK'
  3='BALSAM_FIR' 
  19,20='OTHER_SWDS'
  5='RED_OAK'
  7='RED_MAPLE'
  8='YLW_BIRCH'
  6,9-18,25,26='OTHER_HWDS'
  .='DEAD_CANT_TELL'
  OTHER='unknown';
  run;

*FILENAME TREE84 'F:\TreeRegeneration\twohunM2\REG200.84D';
*FILENAME TREE92 'F:\TreeRegeneration\twohunM2\reg200.92D';
*FILENAME TREE97 'F:\TreeRegeneration\1997data\reg200m2.97D';
*FILENAME QUAD   'F:\TreeRegeneration\QCENTSC.LST';
FILENAME TREE84 'F:\TreeRegeneration\3_Data\TwoHundred_m2\1984\REG200.84D';
FILENAME TREE92 'F:\TreeRegeneration\3_Data\TwoHundred_m2\1992\reg200.92D';
FILENAME TREE97 'F:\TreeRegeneration\3_Data\TwoHundred_m2\1997\REG200m2.97D';

%macro yearwant(year=);
DATA R&year.d;
  INFILE TREE&year MISSOVER;
  INPUT QUADRAT $ SPEC cond nreg1 NREG2 NREG3 NREG4 NREG5 NREG6 NREG7 NREG8;
  *IF COND=0;
  YEAR=19&year;
  IF SPEC=0 THEN DO;
    NUMBER=0;
    dbh=0;
    COUNT=COUNT+1;
    RETAIN COUNT;
  END;
%macro loop;
  %do i=1 %to 8;
  if nreg&i ne . then do;
    number=int(nreg&i);
    dbh=(nreg&i-number)*10;
    output;
  end;
  %end;
%mend loop;
%loop;
run;
proc print data=r&year.d; *(obs=10);
  where quadrat in('3E1','3E2','3E3','3E4') and spec=7;
  title "r&year.d";
  run;
proc freq data=r&year.d; *(obs=10);
  tables quadrat/out=qc&year;
  title "freq quads r&year.d";
  run;
proc freq data=qc&year;
  tables quadrat;
  run;
%mend yearwant;
%yearwant(year=84);
%yearwant(year=92);
run;

DATA R97d;
  INFILE TREE97 MISSOVER;
  INPUT QUADRAT $ SPEC nreg1 NREG2 NREG3 NREG4 NREG5 NREG6 NREG7 NREG8 ;
  YEAR=1997;
  IF SPEC=0 THEN DO;
  NUMBER=0;
  dbh=0;
  COUNT=COUNT+1;
  RETAIN COUNT;
END;
%loop;
run;

proc print data=r97d; *(obs=10);
  where quadrat in('3E1','3E2','3E3','3E4') and spec=7;
  title "r97d";
  run;

data all200(drop=i cond condition number newnbr
                 NREG1 NREG2 NREG3 NREG4 NREG5 NREG6 NREG7 NREG8 count);
  length block $2. FIA_spp species $10. treatment $13.;
  set r84d
      r92d
      r97d;
  dbh=round(dbh,1);
  if dbh gt 1.5;
  spec=int(spec);
  FIA_spp=put(spec,fiafmt.);
  if FIA_spp ne 'unknown';
  block=substr(quadrat,1,2);
  if 3 le substr(quadrat,1,1) le 5 then side='managed';
    else if 6 le substr(quadrat,1,1) le 8 then side='control';
  if side='managed' then do;
    if block in('3E','4D','5E','4F','3G','4G','5G','4I','3J','5J') 
      then treatment='cut';
        else treatment='uncut';
    end;
	else if side='control' then do;
      treatment='control';
	  end;
  /*
  if spec=1 then species='WHITE PINE';
  if spec=2 then species='RED SPRUCE';
  if spec=4 then species='HEMLOCK';
  if spec=3 or spec=19 or spec=20 then species='OTHER SWDS';
  if spec=5  then species='RED OAK';
  if spec=7 then species='RED MAPLE';
  if spec=8 then species='YLW BIRCH';
  *if spec in(11,10,18,13,9,12,6,26,17,16,14,15,25) 
    then species='OTHER HWDS';
  if spec=6 or (9 le spec le 18) or (25 le spec le 26) 
    then species='OTHER HWDS';
  */
  species=put(spec,sppfmt.);
  if year ne 1997 then do;
    if cond=0 OR cond=2 OR cond=3 OR cond=4; *live trees only;
    if cond=0 or cond=3 or cond=4 then condition='live';
      else if cond=2 then condition='cull';
  end;
  if number=1 then do;
    newnbr=1;
    output;
  end;
    else if number gt 1 then do i=1 to number;
       newnbr=1;
       output;
    end;
  run;

proc print data=all200; *(obs=100);
  *where block='3E' and year=1984 and spec=7; *and dbh=2; 
  title 'raw obs';
  run;

proc freq data=all200;
  tables spec species FIA_spp;
  title 'freq of spec, species, and FIA_spp';
  run;

*********************************************************************;
***FIGURE OUT SAMPLING EFFORT;
***1984: 40 blocks and 159 quadrats sampled (the missing one is 6C1);
***1992: 36 blocks (no 6J,7I,7J,8I) and 100 quadrats sampled;
***      3G1 not done and 3G2 done, and 7G2 done (no 6C1)
***1997: 36 blocks (no 6J,7I,7J,8I) and  99 quadrats sampled 
***      3G2 not done, 3G1 done, 7G2 not done (no 6C1)
***NB: 3G is a cut block;
***NB2: only 8, not 10 cut blocks sampled on treatment side in 92, 97;
***NB3: If want even sampling effort, take 1984 quads ALSO censused later;
*********************************************************************;

data sample(keep=year quadrat block);
  set all200;

***dedupe so one record per quadrat; 
proc sort nodupkey data=sample;
  by year quadrat;
  run;

***count up the number of quadrats per year;
proc freq /*noprint*/ data=sample;
  tables year*quadrat/out=sample2;
  run;

***add block;
data sample2;
  set sample2;
  block=substr(quadrat,1,2);
  run;

***find the missing quadrat of 1984 census;
proc print data=sample2;
  where year=1984 and block='6C';
  *var year block quadrat;
  title 'blocks and quadrats sampled';
  run;
/*
***get the number of quadrats sampled in each block in each year;
proc freq noprint data=sample2;
  tables year*block/out=correction;
  run;

***now add the correction factor to be used later;
data correction;
  set correction(drop=percent);
  if count=4 then factor=12.5;  *4 200m2 plots;
  if count=3 then factor=16.67; *3 200m2 plots;
  if count=2 then factor=25;    *2 200m2 plots;
  if count=1 then factor=50;    *1 200m2 plot;
  run;

proc print data=correction;
  title 'block, # quads sampled, correction factor';
  run;

proc freq data=correction;
  tables year;
  title 'total # of blocks per year';
  run;
*/
***Now get the list of quadrats common to all years;
***  This produces a printed list of quadrats and when they were censused;
***  This also produces a list of quadrats sampled in all years;
***    to remove quadrats not done after 1984;

data s1984 s1992 s1997;
  set sample2(drop=percent);
  if year=1984 then output s1984;
  if year=1992 then output s1992;
  if year=1997 then output s1997;
  run;

proc sort data=s1984;
  by quadrat;
  run;

proc sort data=s1992;
  by quadrat;
  run;

proc sort data=s1997;
  by quadrat;
  run;

data selectquad(drop=year);
  length treatment $13.;
  merge s1984(in=in84 rename=(count=census84))
        s1992(in=in92 rename=(count=census92)) 
        s1997(in=in97 rename=(count=census97));
  by quadrat;
  if in92 /*or*/ and in97;
  *if in84 and in92 and in97;
  *block=substr(quadrat,1,2);
  if 3 le substr(quadrat,1,1) le 5 then side='managed';
    else if 6 le substr(quadrat,1,1) le 8 then side='control';
  if side='managed' then do;
    if block in('3E','4D','5E','4F','3G','4G','5G','4I','3J','5J') 
      then treatment='cut';
        else treatment='uncut';
    end;
	else if side='control' then do;
      treatment='control';
	  end;
  run;

proc print data=selectquad;
  where (census92=1 or census97=1); *and side='managed';
  *var block quadrat treatment census92 census97;
  title '# quadrats sampled in each year';
  run;

**************************************************************************
**************************************************************************;
***OUTPUT OUTPUT OUTPUT;
***now pick only those quadrats sampled across all years;
**************************************************************************
**************************************************************************;

libname out 'F:\TreeRegeneration\4_Analysis\TwoHundred_m2\SAS\Data';
  run;

proc sort data=all200;
  by quadrat year;
  run;

proc sort data=selectquad;
  by quadrat;
  run;

data out.all200_select;
  merge selectquad(in=wanted keep=quadrat)
        all200;
  by quadrat;
  if wanted;
  run;

proc sort data=out.all200_select;
  by treatment;
  run;

proc print data=out.all200_select;
  where block='3E'; *and year=1984 and spec=7; 
  title 'sample print of 200m2 data, where quads sampled across all years';
  run;

proc freq nooprint data=out.all200_select;
  by treatment;
  tables species*year*quadrat/sparse out=out.all200_stems;
  run;

proc sort data=out.all200_stems; *all200_select;
  by species treatment year quadrat;
  run;

proc print data=out.all200_stems;
  by species treatment;
  where species='RED MAPLE';
  title 'all200_stems';
  run;

**************************************************************************
**************************************************************************;
***Summaries Tests;
**************************************************************************
**************************************************************************;

***Sum up to quadrat level;
proc means sum noprint data=out.all200_stems; *all200_select;
  by species treatment year quadrat;
  var count; *number;
  output out=countup sum=stemcount;
  run;

proc print data=countup;
  where species='WHITE PINE' and year=1997;
  title 'countup';
  run;

***check sample sizes, okay;
proc freq data=countup;
  tables species*treatment*year;
  run;

***means by treatment and inventory;
proc means mean noprint data=countup;
  by species treatment year;
  var stemcount;
  output out=meanstemcount mean=meanstems;
  run;

proc print data=meanstemcount;
  where species='RED MAPLE';
  title 'mean steam count';
  run;

proc npar1way wilcoxon data=countup;
  by species treatment;
  class year;
  var stemcount;
  run;

proc glm data=countup;
  by species;
  class treatment year;
  model stemcount=treatment year treatment*year;
  lsmeans treatment year treatment*year / pdiff=all adjust=tukey;
  run;
  quit;
/*
proc genmod data=countup order=freq;
  by species;
  class treatment year quadrat; *year study staname;
  model  stemcount=treatment year treatment*year/dist=negbin; *poisson;
  repeated  subject=quadrat; *subject=staname/covb corrw;
  title 'repeated';
  run;
quit;
*/
proc sort data=countup;
  by species year treatment;
  run;

proc means noprint n mean stderr data=countup;
  by species year treatment;
  var stemcount;
  output out=chartstuff n=n mean= stderr=se;
  run;

proc print data=chartstuff;
  title 'chartstuff';
  run;

proc npar1way wilcoxon data=countup;
  by species year;
  class treatment;
  var stemcount;
  run;
/*
***EXPORT***;
PROC EXPORT DATA=WORK.chartstuff
  OUTFILE= "F:\TreeRegeneration\5_Findings\TwoHundred_m2\StmsTrtYr200m2.xls" 
            DBMS=EXCEL2000 REPLACE;
RUN;
*/