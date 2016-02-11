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

********************************************************************;
***Get the number of 200 m square plots each year;
***and get the number of trees per hectare and per acre;
********************************************************************;
%macro skipme;
libname in 'F:\TI-REGEN\1997data\sas\data';

data stems;
  set in.saptree;

proc print data=stems;
  where type='tree' and year=1992;
/*
data stems;
  set in.sap;
  block=substr(quadrat,1,3);
proc sort data=stems;
  by year;
proc freq data=stems;
  by year;
  tables blockuse*block / out=trtcnt;
proc sort data=trtcnt;
  by year;
proc freq noprint data=trtcnt;
  by year;
  tables blockuse*block / out=last;
proc sort data=last;
  by year blockuse;
proc means sum data=last;
  by year blockuse;
  var count;
run;
*/

run;

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
    stems_ha=stems/samparea;
  end;
  if type='tree' then do;
    if blockuse='HARVEST' then stems_ha=stems/10;
    if blockuse='CONTROL' then stems_ha=stems/30;
  end;
  *sample area in acres;
  stems_ac=stems_ha/2.471;
  treat=put(year,yearharv.);

proc print data=in.&dsn.2; *(obs=100);
  title "stem sum for &dsn";

%mend bylist;
*%bylist(list=year type dbhclin,dsn=dbh_in);
*%bylist(list=year type dbhclcm,dsn=dbh_cm);
*%bylist(list=year type htclft,dsn=ht_ft);
*%bylist(list=year type htclcm,dsn=ht_m);
%bylist(list=year type blockuse spgrp,dsn=tdbh_in);

proc print data=tdbh_in;
  title 'tdbh_in';

run;

%mend skipme;
*%macro skipbot;
**************************************************************************
***Stems per acre/hectare by species group for pre-harvest, harvest,
***  and post-harvest, for harvested and control blocks;
**************************************************************************;
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

**************************************************************************
***Stems per acre;
**************************************************************************;
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
filename grafout "F:\TI-REGEN\1997data\sas\images\control.cgm";

***Assign axis definitions FOR STEMS PER AC;

axis1 order=(0 to 225 by 25)
      LABEL=(ANGLE=90 J=C 'STEMS PER ACRE' )
      origin=(17,25) pct LEngth=40 pct;
axis2 ORDER=('WHITE PINE' 'RED SPRUCE' 'HEMLOCK' 'OTHER SWDS' 'RED OAK'
             'RED MAPLE' 'YELLOW BIRCH' 'OTHER HWDS')
      VALUE=(TICK=1 J=C 'WHITE' J=C 'PINE'
             TICK=2 J=C 'RED' J=C 'SPRUCE'
             TICK=3 J=C 'HEM-' J=C 'LOCK'
             TICK=4 J=C 'OTHER' J=C 'SWDS'
             TICK=5 J=C 'RED' J=C 'OAK'
             TICK=6 J=C 'RED' J=C 'MAPLE'
             TICK=7 J=C 'YELLOW' J=C 'BIRCH'
             TICK=8 J=C 'OTHER' J=C 'HWDS')
      label=none origin=(17,25)pct length=75 pct;
axis3 label=none value=none;

***Assign LEGEND definitions;

LEGEND NOFRAME LABEL=NONE;

***Assign pattern characteristics;

pattern1 value=empty C=black;
pattern2 value=X1 C=black;
pattern3 value=R1 C=black;

***Produce the Vertical Bar Chart FOR STEMS PER AC;
PROC SORT DATA=in.tdbh_in2;
  BY BLOCKUSE;
proc print;
data tdbh_inc;
  set in.tdbh_in2;
  if blockuse='CONTROL';

proc sort data=tdbh_inc;
  by blockuse;

proc gchart data=tdbh_inc gout=work.gseg;
  BY BLOCKUSE;
  format year yearharv.;
  vbar year /  discrete
     Raxis=axis1 gaxis=axis2 maxis=axis3 legend=legend
     GROUP=SPGRP
     sumvar=stems_ac
     subgroup=year;
  title;

run;
quit;

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
filename grafout "F:\TI-REGEN\1997data\sas\images\harvest.cgm";

***Assign axis definitions FOR STEMS PER AC;

axis1 order=(0 to 225 by 25)
      LABEL=(ANGLE=90 J=C 'STEMS PER ACRE' )
      origin=(17,25) pct LEngth=40 pct;
axis2 ORDER=('WHITE PINE' 'RED SPRUCE' 'HEMLOCK' 'OTHER SWDS' 'RED OAK'
             'RED MAPLE' 'YELLOW BIRCH' 'OTHER HWDS')
      VALUE=(TICK=1 J=C 'WHITE' J=C 'PINE'
             TICK=2 J=C 'RED' J=C 'SPRUCE'
             TICK=3 J=C 'HEM-' J=C 'LOCK'
             TICK=4 J=C 'OTHER' J=C 'SWDS'
             TICK=5 J=C 'RED' J=C 'OAK'
             TICK=6 J=C 'RED' J=C 'MAPLE'
             TICK=7 J=C 'YELLOW' J=C 'BIRCH'
             TICK=8 J=C 'OTHER' J=C 'HWDS')
      label=none origin=(17,25)pct length=75 pct;
axis3 label=none value=none;

***Assign LEGEND definitions;

LEGEND NOFRAME LABEL=NONE;

***Assign pattern characteristics;

pattern1 value=empty C=black;
pattern2 value=X1 C=black;
pattern3 value=R1 C=black;

data tdbh_inh;
  set in.tdbh_in2;
  if blockuse='HARVEST';

proc sort data=tdbh_inh;
  by blockuse;

proc gchart data=tdbh_inh gout=work.gseg;
  BY BLOCKUSE;
  format year yearharv.;
  vbar year /  discrete
     Raxis=axis1 gaxis=axis2 maxis=axis3 legend=legend
     GROUP=SPGRP
     sumvar=stems_ac
     subgroup=year;
  title;

run;
quit;
*%mend skipbot;
run;
