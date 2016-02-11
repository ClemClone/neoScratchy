**************************************************************************
**************************************************************************
***PROGRAM: E:\Holtsas\ChartStems.sas
***PURPOSE: Plot #stems by dbh class, by height class, for each of
***         3 harvest treatments.
***         Plot #stems/hectare,acre by control vs. harvest, for species
***         groups, for each of 3 harvest treatments.
***INPUT:
***OUTPUT:
***DATE CREATED: 18MAR1999
***PROGRAMMER: SPE
***MODIFIED:
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
  VALUE YEARHARV 1984 = 'PRE-HARVEST'
                 1988,1992 = 'HARVEST YEAR'
                 1996,1997 = '8 YRS POST';

run;

%macro skipme;

********************************************************************;
***Get the number of 200 m square plots each year;
***and get the number of trees per hectare and per acre;
********************************************************************;

libname in 'F:\TI-REGEN\1997data\sas\data';

data stems;
  set in.saptree;

*proc freq data=stems;
*  tables type*dbhclin type*dbhclcm type*htclft type*htclm;
*  title 'freqs of dbh and height classes to get ranges for graphs';

%macro bylist(list=,dsn=);

proc sort data=stems;
  by &list quadrat;

proc means noprint sum data=stems;
  by &list;
  var newnbr;
  output out=&dsn.1 sum=stems;
  title 'sum of stems';

data in.&dsn.2;
  set &dsn.1;
  by &list;
  if "&dsn"="dbh_in" then if type='tree' then if dbhclin le 3 then delete;
  if "&dsn"="dbh_cm" then if type='tree' then if dbhclcm le 9 then delete;
  if "&dsn"="ht_ft" then if type='sapling' then if htclft=28 then delete;
  if "&dsn"="ht_m" then if type='sapling' then if htclm=8 then delete;
  *sample area in hectares;
  if type='sapling' then do;
    if year=1984 then samparea=159*200/10000;
    if year=1992 then samparea=100*200/10000;
    if year=1997 then samparea=99*200/10000;
/*
    if blockuse='HARVEST' then do;
      if year=1984 then samparea=40*200/10000;
      if year=1992 then samparea=20*200/10000;
      if year=1997 then samparea=20*200/10000;
    end;
  if blockuse='CONTROL' then do;
      if year=1984 then samparea=119*200/10000;
      if year=1992 then samparea=80*200/10000;
      if year=1997 then samparea=79*200/10000;
    end;
*/
    stems_ha=stems/samparea;
  end;
  if type='tree' then do;
    stems_ha=stems/40;
/*
    if blockuse='HARVEST' then stems_ha=stems/10;
    if blockuse='CONTROL' then stems_ha=stems/30;
*/
  end;
  *sample area in acres;
  stems_ac=stems_ha/2.471;
  treat=put(year,yearharv.);

proc print data=in.&dsn.2; *(obs=100);
  title "stem sum for &dsn";

%mend bylist;
%bylist(list=year type dbhclin,dsn=dbh_in);
*%bylist(list=year type dbhclcm,dsn=dbh_cm);
%bylist(list=year type htclft,dsn=ht_ft);
*%bylist(list=year type htclcm,dsn=ht_m);

run;

%mend skipme;
********************************************************************;
***Plot Number of Stems/Hectare,Acre by DBH and Height Classes by year;
********************************************************************;
*%macro skipbot;
libname in 'F:\TI-REGEN\1997data\sas\data';
title;

***point goptions to the library with the desired device drivers;
libname GDEVICE0 'C:\SAS\SASUSER';

***reset all goptions;
goptions reset=all gunit=pct noborder  cby=black colors=
         htitle=8 htext=6 dev=win hsize=0 vsize=0 vpos=0 hpos=0;

***Clear all graphs from the WORK.GSEG catalog;

proc greplay igout=work.gseg nofs;
  delete _all_;

run;

********************************************************************;
***GCHART & PLOT OF DBH CLASSES IN INCHES
********************************************************************;

proc sort data=in.dbh_in2;
  by year;

data _null_;
  set in.dbh_in2 end=eof;
  by year;
  if first.year then do;
    count+1;
    call symput('yr_'||left(put(count,5.)),year);
  end;
  if eof then call symput('count',put(count,5.));

run;

%macro outfile;

  %do i=1 %to &count;
  ***for output to screen;
  *goptions reset=global gunit=pct noborder dev=win chartype=49 htitle=6 htext=3;
  ***for output to PowerPoint;
  goptions DEVICE=CGMMPPA GSFNAME=GRAFOUT GSFMODE=REPLACE CHARTYPE=5
       hsize=11 vsize=8.50 vpos=0 hpos=0 cby=black htext=1.4
       ctext=black ctitle=black cback=white colors=;
  ***for output to Harvard Graphics;
  *goptions DEVICE=CGMHG3L GSFNAME=GRAFOUT GSFMODE=REPLACE CHARTYPE=13
         hsize=11 vsize=8.50 vpos=0 hpos=0 cby=black htext=1.4
         ctext=black ctitle=black cback=white colors=;
  filename grafout "F:\TI-REGEN\1997data\sas\images\dbhin.&&yr_&i...cgm";

***GCHART;
*footnote j=r "Run Date: &SYSDATE"
          j=l 'Holt Research Forest';
axis1 order=(0 to 260 by 20)
      origin=(11,25) pct length=50 pct
      label=none;
axis2 order=(0 to 50 by 1)
      origin=(11,25) pct length=70 pct
      value=none
      label=none;

pattern1 color=green  value=solid;

proc gchart data=in.dbh_in2;
  by year;
  vbar dbhclin
       / discrete
         raxis=axis1 maxis=axis2
         sumvar=stems_ac;
  where year=&&yr_&i;
  *label dbhclin='dbhclass in inches';
  *title height=.5 justify=center 'Number of stems by dbh class (in)';
  *title height=.5 j=c "&&yr_&i";
  format year yearharv.;
run;
quit;

***GPLOT to overlay horizontal axis over bar chart;

axis1 order=(0 to 260 by 20)
      origin=(11,25) pct length=50 pct
      value=none label=none major=none minor=none ;
axis2 value=(angle=0 rotate=0)
      order=(0 to 50 by 5)
      minor=(n=4 height=.1)
      label=none
      origin=(11,25) pct length=70 pct;
symbol1  v=NONE;
symbol2  v=NONE ;

proc gplot gout=work.gseg data=in.dbh_in2;
  *by year;
  plot stems_ac*dbhclin  / vaxis=axis1 haxis=axis2;
  where year=&&yr_&i;
  *format year yearharv.;
run;
quit;
***Use PROC GREPLAY to overlay the chart and the plot FOR STEMS PER HA;

proc greplay igout=work.gseg nofs tc=sashelp.templt template=whole;
treplay 1:gchart
        1:gplot;
proc greplay igout=work.gseg nofs;
  delete _all_;
run;
%end;
%mend;
%outfile;

run;

********************************************************************;
***GCHART & PLOT OF HEIGHT CLASSES IN FEET;
********************************************************************;

proc sort data=in.ht_ft2;
  by year;

data _null_;
  set in.ht_ft2 end=eof;
  by year;
  if first.year then do;
    count+1;
    call symput('yr_'||left(put(count,5.)),year);
  end;
  if eof then call symput('count',put(count,5.));

run;

%macro outfile2;

  %do i=1 %to &count;
  ***for output to screen;
  *goptions reset=global gunit=pct noborder dev=win chartype=49 htitle=6 htext=3;
  ***for output to PowerPoint;
  goptions DEVICE=CGMMPPA GSFNAME=GRAFOUT GSFMODE=REPLACE CHARTYPE=5
       hsize=11 vsize=8.50 vpos=0 hpos=0 cby=black htext=1.4
       ctext=black ctitle=black cback=white colors=;
  ***for output to Harvard Graphics;
  *goptions DEVICE=CGMHG3L GSFNAME=GRAFOUT GSFMODE=REPLACE CHARTYPE=13
         hsize=11 vsize=8.50 vpos=0 hpos=0 cby=black htext=1.4
         ctext=black ctitle=black cback=white colors=;
  filename grafout "F:\TI-REGEN\1997data\sas\images\htft&&yr_&i...cgm";


*FILENAME HTFT 'F:\TI-REGEN\1997data\sas\images\htft.CGM';
***GCHART;
*footnote j=r "Run Date: &SYSDATE"
         j=l 'Holt Research Forest';
axis1 order=(0 to 100 by 20)
      origin=(10.7,25) pct length=50 pct
      label=none; *(angle=90 j=c 'stems per acre');
axis2 order=(0 to 70 by 1)
      origin=(10.7,25) pct length=70 pct
      value=none
      label=none;

pattern1 color=green  value=solid;

proc gchart data=in.ht_ft2;
  by year;
  vbar htclft
       / discrete
         raxis=axis1 maxis=axis2
         sumvar=stems_ac;
  where year=&&yr_&i;
  *title height=.5 j=c "&&yr_&i";
  format year yearharv.;
run;
quit;

***GPLOT to overlay horizontal axis over bar chart;

axis1 order=(0 to 100 by 20)
      origin=(10.7,25) pct length=50 pct
      value=none label=none major=none minor=none ;
axis2 value=(angle=0 rotate=0)
      order=(0 to 70 by 5)
      minor=(n=4 height=.1)
      label=none
      origin=(10.7,25) pct length=70 pct;
symbol1  v=NONE;
symbol2  v=NONE ;

proc gplot gout=work.gseg data=in.ht_ft2;
  *by year;
  plot stems_ac*htclft  / vaxis=axis1 haxis=axis2;
  where year=&&yr_&i;

run;
quit;

***Use PROC GREPLAY to overlay the chart and the plot FOR STEMS PER HA;

proc greplay igout=work.gseg nofs tc=sashelp.templt template=whole;
treplay 1:gchart
        1:gplot;
proc greplay igout=work.gseg nofs;
  delete _all_;
run;
%end;
%mend;
%outfile2;

run;
quit;
