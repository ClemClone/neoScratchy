**************************************************************************
**************************************************************************
***PROGRAM: F:\TreeRegeneration\4_Analyses\QuadCenter25m2vs200m2.sas
***PURPOSE: Examine the correlation between stem counts between 
***           the 1997 25m2 plots and 1997 200m2 plots that have
***           shared centers.  By species.
***INPUT:   F:\TreeRegeneration\3_Data\TwentyFive_m2\Qc25m2Lst.dat
***         F:\TreeRegeneration\3_Data\TwoHundred_m2\REG200m2.97D
***OUTPUT:
***DATE CREATED: 27JUN02
***PROGRAMMER: SPE
***MODIFIED:
***NOTE:    In this analysis the sampling unit is the 25m2 or 200m2 plot,
***           which is designated by quadrat name.
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

**************************************************************************;
***Get the 25m2 plots from quadrat centers;
**************************************************************************;

FILENAME reg25m2 'F:\TreeRegeneration\3_Data\TwentyFive_m2\Qc25m2Lst.dat';

DATA regQC25m2_97(drop=damage);
  length dataset $5.;
  INFILE reg25m2 MISSOVER;
  INPUT  quadrat $ spec damage dbh /*class*/ number;
  if dbh ge 2; *0 and 1 dhb classes are not in the 200m2 dataset;
  dataset=' 25m2';
  run;

proc sort data=regQC25m2_97;
  by quadrat spec;
  run;

proc print data=regqc25m2_97;
  where quadrat='5H3' and spec=8;
  run;

**************************************************************************;
***Get the 200m2 plots from quadrat centers;
**************************************************************************;

FILENAME TREE97 'F:\TreeRegeneration\3_Data\TwoHundred_m2\REG200m2.97D';

DATA reg200m2_97(drop=NREG1 NREG2 NREG3 NREG4 NREG5 NREG6 NREG7 NREG8 count);
  length dataset $5.;
  INFILE TREE97 MISSOVER;
  INPUT QUADRAT $ SPEC nreg1 NREG2 NREG3 NREG4 NREG5 NREG6 NREG7 NREG8 ;
  *YEAR=1997;
  IF SPEC=0 THEN DO;
  NUMBER=0;
  dbh=0;
  COUNT=COUNT+1;
  RETAIN COUNT;
END;
  dataset='200m2';
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

proc sort data=reg200m2_97;
  by quadrat spec;
  run;

proc print data=reg200m2_97;   
  where quadrat='5H3' and spec=8;
  title "r97d";
  run;

proc freq data=reg200m2_97; 
  tables spec;
  title "r97d";
  run;

**************************************************************************;
***Get the list of common quadrat centers;
**************************************************************************;

proc sort nodupkey data=regqc25m2_97 out=q25(keep=quadrat);
  by quadrat;
  run;

proc sort nodupkey data=reg200m2_97 out=q200(keep=quadrat);
  by quadrat;
  run;

data quadlist(keep=quadrat);
  merge q25(in=in25)
        q200(in=in200);
  by quadrat;
  if in25 and in200;
  run;

proc print data=quadlist;
  title 'quadlist';
  run;

**************************************************************************;
***Get the 25m2 plots;
**************************************************************************;

data r25m2;
  merge quadlist(in=wanted)
        regqc25m2_97;
  by quadrat;
  if wanted;
  dbh=round(dbh,1);
  if dbh gt 1.5;
  if spec=1 then species='WHITE PINE';
  if spec=2 then species='RED SPRUCE';
  if spec=4 then species='HEMLOCK';
  if spec=3 or spec=19 or spec=20 then species='OTHER SWDS';
  if spec=5  then species='RED OAK';
  if spec=7 then species='RED MAPLE';
  if spec=7.1 then species='RED MAPLE'; *should be checked in raw data;
  if spec=8 then species='YLW BIRCH';
  *if spec in(11,10,18,13,9,12,6,26,17,16,14,15,25) 
    then species='OTHER HWDS';
  if spec=6 or (9 le spec le 18) or (25 le spec le 26) 
    then species='OTHER HWDS';
  run;

proc print data=r25m2;
  where quadrat='5H3' and species='YLW BIRCH';
  title 'r25m2';
  run;

proc sort data=r25m2;
  by species quadrat;
  run;

proc means sum noprint data=r25m2;
  by species quadrat;
  var number;
  output out=mr25m2 sum=stemcount;
  run;

**************************************************************************;
***Get the 200m2 plots;
**************************************************************************;

data r200m2;
  merge quadlist(in=wanted)
        reg200m2_97;
  by quadrat;
  if wanted;
  dbh=round(dbh,1);
  if dbh gt 1.5;
  if spec=1 then species='WHITE PINE';
  if spec=2 then species='RED SPRUCE';
  if spec=4 then species='HEMLOCK';
  if spec=3 or spec=19 or spec=20 then species='OTHER SWDS';
  if spec=5  then species='RED OAK';
  if 7 le spec le 7.1 then species='RED MAPLE';
  if 8 le spec le 8.1 then species='YLW BIRCH';
  *if spec in(11,10,18,13,9,12,6,26,17,16,14,15,25) 
    then species='OTHER HWDS';
  if spec=6 or (9 le spec le 18) or (25 le spec le 26) 
    then species='OTHER HWDS';
  run;

proc print data=r200m2;
  title 'r200m2';
  run;

proc sort data=r200m2;
  by species quadrat;
  run;

proc means sum noprint data=r200m2;
  by species quadrat;
  var number;
  output out=mr200m2 sum=stemcount;
  run;

proc print data=mr200m2;
  run;

***account for zero stem counts;

proc freq data=mr200m2;
  tables species*quadrat/sparse out=f200m2;
  run;

proc print data=f200m2;
  run;

data fmr200m2;
  merge f200m2(drop=count percent)
        mr200m2;
  by species quadrat;
  run;

proc print data=fmr200m2;
  run;

**************************************************************************;
***Merge the 25m2 and 200m2 plots;
**************************************************************************;

data centers;
  length block $2. treatment $13.;
  merge mr25m2(drop=_type_ _freq_ rename=(stemcount=stemcount25))
        fmr200m2(in=wanted drop=_type_ _freq_ rename=(stemcount=stemcount200));
  by species quadrat;
  if wanted;
  if stemcount25=. then stemcount25=0;
  if stemcount200=. then stemcount200=0;
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
  run;

proc print data=centers;
  where stemcount25>stemcount200;
  title '25m2 stem count vs. 200m2 stem count';
  run;

***EXPORT***;
PROC EXPORT DATA=WORK.centers
  OUTFILE= "F:\TreeRegeneration\5_Findings\Stems25vs200m2.xls" 
            DBMS=EXCEL2000 REPLACE;
RUN;

proc freq data=centers;
  tables species;
  run;

**************************************************************************;
***Plot the 25m2 and 200m2 plots;
**************************************************************************;

proc sort data=centers;
  by treatment species;
  run;

goptions reset=all;

proc gchart data=centers;
  *symbol1 i=r v=star color=red;
  by species;
  vbar stemcount25 stemcount200/midpoints=0 to 50 by 1;
  title '25m2 stem count vs. 200m2 stem count';
  run;

proc gplot data=centers;
  symbol1 i=r v=star color=red;
  by treatment species;
  plot stemcount25*stemcount200;
  title '25m2 stem count vs. 200m2 stem count';
  run;

**************************************************************************;
***Correlation between the 25m2 and 200m2 plots;
**************************************************************************;

proc corr data=centers;
  by species;
  var stemcount25 stemcount200;
  run;

/*
**************************************************************************;
***Concatenate the 25m2 and 200m2 plots;
**************************************************************************;

data all;
  length block $2. FIA_spp species $10. treatment $13.;
  set r25m2
      r200m2;
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
  *if year ne 1997 then do;
  *  if cond=0 OR cond=2 OR cond=3 OR cond=4; *live trees only;
  *  if cond=0 or cond=3 or cond=4 then condition='live';
  *    else if cond=2 then condition='cull';
  *end;
  if number=1 then do;
    newnbr=1;
    output;
  end;
    else if number gt 1 then do i=1 to number;
       newnbr=1;
       output;
    end;
  run;

proc sort nodupkey data=all out=checkcount;
  by dataset quadrat;
  run;

proc freq data=checkcount;
  tables dataset;
  run;

proc print data=all; *(obs=100);
  *where block='3E' and year=1984 and spec=7; *and dbh=2; 
  title 'raw obs';
  run;

**************************************************************************;
***Run proc freq with sparse option to account for plots 
***  with zero stem counts;
**************************************************************************;

proc sort data=all;
  by dataset treatment;
  run;

proc freq noprint data=all;
  by dataset treatment;
  tables species*quadrat/sparse out=stems;
  run;

proc print data=stems;
  where species='WHITE PINE' and treatment='cut';
  run;

proc sort nodupkey data=all out=test;
  by dataset quadrat;
  run;

proc freq noprint data=test;
  tables dataset*quadrat/out=test;
  run;

proc freq data=test;
  tables dataset;
  title 'freq of dataset*quadrat';
  run;

**************************************************************************;
***Correlation;
**************************************************************************;

*********************************************************************;
***Get stems per hectare at quadrat level by dataset species;
***1 ha=10,000m2;
***25m2 stem count*400=stems/ha;
***200m2 stem count*50=stems/ha;
*********************************************************************;

data stemsperha;
  set stems;
  if dataset=' 25m2' then stemsperha=count*400;
  if dataset='200m2' then stemsperha=count*50;
  run;

proc print data=stemsperha;
  run;

*********************************************************************;
***Get mean stems per hectare;
*********************************************************************;

proc sort data=stemsperha;
  by species treatment dataset;
  run;

proc means n mean stderr data=stemsperha; 
  by species treatment dataset;
  var stemsperha;
  output out=stemdensity n=n mean= stderr=se;
  run;

proc print data=stemdensity;
  run;

proc sort data=stemdensity;
  by species treatment dataset;
  run;

proc print data=stemdensity;
  by species;
  var treatment dataset n stemsperha se;
  run;

***EXPORT***;
PROC EXPORT DATA=WORK.stemdensity
  OUTFILE= "F:\TreeRegeneration\5_Findings\StemsHa25vs200m2.xls" 
            DBMS=EXCEL2000 REPLACE;
RUN;
*/