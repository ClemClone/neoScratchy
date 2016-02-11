**************************************************************************
**************************************************************************
***PROGRAM: E:\Holtsas\SaplingHeight.sas
***PURPOSE: Read in 1997 sapling measured heights data. Generate equations
***         of the form: height=a+b(dbh), by species, harvest/no harvest,
***         softwood/hardwood. Read in 200m square plot sapling data,
***         use height equations to generate heights for the saplings.
***         Repeat for trees.
***         Plot #stems by dbh class, by height class, for each of
***         3 harvest treatments.
***         Plot #stems/hectare,acre by control vs. harvest, for species
***         groups, for each of 3 harvest treatments.
***         Extrapolate to study area, compare harvest vs. control
***INPUT:   F:\TI-REGEN\twohunM2\REG200.84D
***         F:\TI-REGEN\twohunM2\reg200.92D
***         F:\TI-REGEN\twohunM2\REG200m2.97D
***         F:\TI-REGEN\QCENTSC.LST
***         f:\ti-regen\1997data\RawData\saphgt2.inft.txt
***         F:\TI84\MFF\MHTALL.84D
***         F:\TI84\MFF\X84MHT.DAT
***         F:\TI84\MFF\SUSAN2.2VOL84.DAT
***         F:\TI84\TI84ALL.DAT 
***         f:\ti96\error3\sas\m2.sd2 
***OUTPUT:  F:\TI-REGEN\1997data\sas\sap,tree,saptree.sd2
***DATE CREATED: 11MAR1999
***PROGRAMMER: SPE
***MODIFIED: 25MAR99 SPE Charts are in SpGrpTrt.sas, StemsDbhHt.sas
***  The first does the # of stems by species group, harvest vs. control,
***    the second program does the # of stems by dbhclass and height class;
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

********************************************************************;
***Read in sapling height data;
********************************************************************;

filename sapht 'f:\ti-regen\1997data\RawData\saphgt2.inft.txt';

data rsapht;
  infile sapht firstobs=2 missover;
  input species dbhcm dist top bot subquad $ gap $ htm dbhin htft;
  IF 9 le species le 10 THEN DELETE;
  FIA_spp=put(species,fiafmt.);
  transdbh=1/dbhin;
  block=substr(subquad,1,2);
  if block in('3E','4D','5E','4F','3G','4G','5G','4I','3J','5J')
    then blockuse='HARVEST';
      else blockuse='CONTROL';
  if FIA_spp in('WP','RS','BF','HE','PP','RP') then wood='softwood';
    else wood='hardwood';

proc print data=rsapht(obs=20);
  title 'rsapht';

********************************************************************;
***Saplings: Get equation parameters;
********************************************************************;

proc sort data=rsapht;
  *by  FIA_SPP;
  by wood;
  *by gap;
  *by blockuse;

proc reg noprint data=rsapht outest=sap_est;
  by wood;
  model htft=transdbh;

proc print data=sap_est;
  title 'sapling height parameter estimates';

run;

**************************************************************************;
***Read in 200m square plot data for the three years ("treatments");
***"number" is the count of trees in size class "size" (dbh in cm),
***   i.e., 2.6;
**************************************************************************;

FILENAME TREE84 'F:\TI-REGEN\twohunM2\REG200.84D';
FILENAME TREE92 'F:\TI-REGEN\twohunM2\reg200.92D';
FILENAME TREE97 'F:\TI-REGEN\twohunM2\reg200m2.97D';
FILENAME QUAD   'F:\TI-REGEN\QCENTSC.LST';

DATA QINFO; INFILE QUAD;
  INPUT TYPE $ QUADRAT $ DRAIN $ FOREST $ SOIL $;

%macro yearwant(year=);
DATA R&year.d;
  INFILE TREE&year MISSOVER;
  INPUT QUADRAT $ SPEC cond nreg1 NREG2 NREG3 NREG4 NREG5 NREG6 NREG7 NREG8;
  IF COND=0;
  YEAR=19&year;
  FIA_spp=put(spec,fiafmt.);
IF SPEC=0 THEN DO;
    NUMBER=0;
    SIZE=0;
    COUNT=COUNT+1;
    RETAIN COUNT;
  END;
%macro loop;
  %do i=1 %to 8;
  if nreg&i ne . then do;
    number=int(nreg&i);
    size=(nreg&i-number)*10;
    output;
  end;
  %end;
%mend loop;
%loop;

run;

*proc print data=r&year.d(obs=10);
*  title "r&year.d";

*proc freq data=r&year.d;
*  tables quadrat / out=freq&year;
*  title "r&year.d";

*proc freq data=freq&year;
*  tables quadrat;
*  title 'quadsum';

%mend yearwant;
%yearwant(year=84);
%yearwant(year=92);

DATA R97d;
  INFILE TREE97 MISSOVER;
  INPUT QUADRAT $ SPEC nreg1 NREG2 NREG3 NREG4 NREG5 NREG6 NREG7 NREG8 ;
  YEAR=1997;
  FIA_spp=put(spec,fiafmt.);
IF SPEC=0 THEN DO;
  NUMBER=0;
  SIZE=0;
  COUNT=COUNT+1;
  RETAIN COUNT;
END;
%loop;

*proc print data=r97d(obs=10);
*  title "r97d";

*proc freq data=r97d;
*  tables quadrat / out=freq97;
*  title "r97d";

*proc freq data=freq97;
*  tables quadrat;
*  title 'quadsum';

run;

**************************************************************************;
***Combine years, define harvest vs. control, get dbh in inches, define
***  dbh classes in inches and cm;
**************************************************************************;

data all200(drop=COND NREG1 NREG2 NREG3 NREG4 NREG5 NREG6 NREG7 NREG8 count);
  set r84d
      r92d
      r97d;
  block=substr(quadrat,1,2);
  if block in('3E','4D','5E','4F','3G','4G','5G','4I','3J','5J')
    then blockuse='HARVEST';
      else blockuse='CONTROL';
  if FIA_spp in('WP','RS','BF','HE','PP','RP') then wood='softwood';
    else wood='hardwood';
  dbhin=size/2.54;
  if size=0 then delete;
  ***inch dbh classes;
  if .5<dbhin<1.49 then dbhclin=1;
  if 1.5<dbhin<2.49 then dbhclin=2;
  if 2.5<dbhin<4 then dbhclin=3; *force class;
  if dbhin ge 4 then dbhclin=4;
  if dbhclin='' then put spec FIA_spp number size dbhin dbhclin;
  ***cm dbh classes;
  %macro cm;
  %do j=1 %to 9;
    if &j le size lt &j+1 then dbhclcm=&j;
      *midpt=((&j)+(&j+2.99))/2;
      *dbhclcm=left(trim(round(midpt,.1)));
    *end;
  %end;
  %mend cm;
  %cm;

proc print data=all200; *(obs=20);
  where size=. or dbhin=.;

*proc freq data=all200;
*  tables dbhin size;
  title 'all200';

run;
**************************************************************************;
***Rearrange data so have one observation per tree;
**************************************************************************;

data onetree;
  set all200;
  if number=1 then do;
    newnbr=1;
    output;
  end;
    else if number gt 1 then do i=1 to number;
       newnbr=1;
       output;
    end;

proc print data=onetree; *(obs=20);
  where size=. or dbhin=.;
  title 'sapling data after rearranging for one tree per obs';

run;

********************************************************************;
***Generate heights for 200m square sapling data;
********************************************************************;

proc sort data=onetree;
  by wood;

proc sort data=sap_est;
  by wood;

data sap_hts(drop=i);
  *length htclft htclm $3;
  merge onetree(in=wanted)
        sap_est(keep=wood intercep transdbh rename=(transdbh=beta));
  by wood;
  if wanted;
  transdbh=1/dbhin;
  htft=round(intercep+(beta*transdbh),.1);
  htin=htft*12;
  htcm=htin*2.54;
  htm=htcm/100;
  ***ft height classes;
  %macro ft;
  %do k=1 %to 100;
    if &k+.5 le htft le &k+1.49 then do;
      midpt=&k+1;
      htclft=midpt;
    end;
  %end;
  %mend ft;
  %ft;
  ***m height classes;
  %macro m;
  %do l=1 %to 100;
    if &l le htm lt &l+1 then htclm=&l;
      *midpt=((&i)+(&i+2.99))/2;
      *htclm=left(trim(round(midpt,.1)));
    *end;
  %end;
  %mend m;
  %m;
  ***assign species groups;
  IF SPEC=1  THEN SPGRP='WHITE PINE';
  IF SPEC=2  THEN SPGRP='RED SPRUCE';
  IF SPEC=4  THEN SPGRP='HEMLOCK';
  IF SPEC=8 THEN SPGRP='YLW. BIRCH';
  if SPEC=3 OR SPEC=19 OR SPEC=20 THEN SPGRP='OTHER SWDS';
  IF SPEC=5  THEN SPGRP='RED OAK';
  IF SPEC=7 THEN SPGRP='RED MAPLE';
  IF SPEC=6 OR SPEC>=9 AND SPEC<=30 THEN SPGRP='OTHER HWDS';
  ***assign treatments;
  yearharv=put(year,yearharv.);

proc print data=sap_hts(obs=20);
  title 'sapling heights';

data tallsap;
  set sap_hts;
  where htft ge 24;

proc print;
  title 'tallsap';

proc freq data=tallsap;
  tables htclft;

run;

proc freq data=sap_hts;
  tables dbhcm dbhin dbhclcm dbhclin htm htft htclm htclft;
  title 'freq of sap_hts';

libname out 'F:\TI-REGEN\1997data\sas\data';

data out.sap;
  set sap_hts;

********************************************************************;
***Read in the 1984 tree height data;
********************************************************************;

filename trees1 "F:\TI84\MFF\MHTALL.84D";
filename trees2 "F:\TI84\MFF\X84MHT.DAT";
filename trees3 "F:\TI84\MFF\SUSAN2.2VOL84.DAT"; *(Barr-Stroud);

data set1;
infile trees1;
  input quadrat $ spec dbhcm cond htm cratio site;

data set2;
infile trees2;
  input spec dbhcm htm site;

data set3;
infile trees3;
  input quadrat $ spec dbhcm htm tvol site type stumpdia;

data rtreeht;
  set set1 set2 set3;
  FIA_spp=put(spec,fiafmt.);
  dbhin=dbhcm/2.54; *convert dbh in cm to inches to get same param. est. as Flex;
  htft=htm/.3048; *convert meters to feet to get same parameter estimates as Flex;
  transdbh=1/dbhin;
  block=substr(quadrat,1,2);
  if block in('3E','4D','5E','4F','3G','4G','5G','4I','3J','5J')
    then blockuse='HARVEST';
      else blockuse='CONTROL';
  if FIA_spp in('WP','RS','BF','HE','PP','RP') then wood='softwood';
    else wood='hardwood';

proc print rtreeht; *(obs=100);
  title 'rtreeht';

********************************************************************;
***Trees: Get equation parameters;
********************************************************************;

proc sort data=rtreeht;
  *by  FIA_SPP;
  by wood;
  *by blockuse;

proc reg noprint data=rtreeht outest=tree_est;
  by wood;
  model htft=transdbh;

proc print data=tree_est;
  title 'tree height parameter estimates';

********************************************************************;
***Read in all 1984 Timber Inventory Data;
********************************************************************;

filename trees "F:\TI84\TI84ALL.DAT";
data trees84(keep=quadrat spec FIA_spp dbhcm year);
  infile trees missover;
  input quadrat $ spec dbhcm cond;
  FIA_spp=put(spec,fiafmt.);
  if cond in(0);
  year=1984;

********************************************************************;
***Read in all 1988 Timber Inventory Data;
********************************************************************;

libname in 'f:\ti96\error3\sas';

data m2;
  set in.m2;

data trees88(keep=quadrat spec FIA_spp dbhcm year);
  set m2(rename=(quad=quadrat sp88=spec dbh88=dbhcm cond88=cond));
  if data88='yes';
  FIA_spp=put(spec,fiafmt.);
  if cond in(0);
  year=1988;

********************************************************************
***Read in all 1996 Timber Inventory Data;
********************************************************************;

data m3;
  set in.m2;

data trees96(keep=quadrat spec FIA_spp dbhcm year);
  set m3(rename=(quad=quadrat sp96=spec dbh96=dbhcm cond96=cond));
  if data96='yes';
  FIA_spp=put(spec,fiafmt.);
  if cond in(0);
  quadrat=substr(subquad,1,3);
  year=1996;

**************************************************************************;
***Concatenate 84, 88, 96 data;
**************************************************************************;

data alltrees;
  set trees84 trees88 trees96;
  block=substr(quadrat,1,2);
  if block in('3E','4D','5E','4F','3G','4G','5G','4I','3J','5J')
    then blockuse='HARVEST';
      else blockuse='CONTROL';
  if FIA_spp in('WP','RS','BF','HE','PP','RP') then wood='softwood';
    else wood='hardwood';
  dbhin=dbhcm/2.54;
  ***inch dbh classes; *force the first 2 classes;
  if 3.5 le dbhin le 3.99 then do;
    dbhclin=3;
    midpt=3;
  end;
  if 4 le dbhin le 4.49 then do;
    dbhclin=4;
    midpt=4;
  end;
  %macro in;
  %do i=4 %to 47;
    if &i+.5 le dbhin le &i+1.49 then do;
      midpt=&i+1;
      dbhclin=midpt;
    end;
  %end;
  %mend in;
  %in;
  ***cm dbh classes;
  %macro cm;
  %do j=9 %to 119;
    if &j le dbhcm lt &j+1 then dbhclcm=&j;
      *midpt=((&i)+(&i+2.99))/2;
      *dbhclcm=left(trim(round(midpt,.1)));
    *end;
  %end;
  %mend cm;
  %cm;

proc print data=alltrees(obs=20);
  title 'sample print of alltrees';

proc freq data=alltrees;
  tables dbhcm dbhin;
  title 'ti, freqs of dbhcm and dbhin';

run;

********************************************************************;
***Generate heights for the tree data;
********************************************************************;

proc sort data=alltrees;
  by wood;

data tree_hts;
  *length htclft htclm $3;
  merge alltrees(in=wanted)
        tree_est(keep=wood intercep transdbh rename=(transdbh=beta));
  by wood;
  if wanted;
  transdbh=1/dbhin;
  htft=round(intercep+(beta*transdbh),.1);
  htin=htft*12;
  htcm=htin*2.54;
  htm=htcm/100;
  ***ft height classes;
  %macro ft;
  %do k=1 %to 100;
    if &k+.5 le htft le &k+1.49 then do;
      midpt=&k+1;
      htclft=midpt;
    end;
  %end;
  %mend ft;
  %ft;
  ***m height classes;
  %macro m;
  %do l=1 %to 100;
    if &l le htm lt &l+1 then htclm=&l;
      *midpt=((&i)+(&i+2.99))/2;
      *htclm=left(trim(round(midpt,.1)));
    *end;
  %end;
  %mend m;
  %m;
  ***assign species groups;
  IF SPEC=1  THEN SPGRP='WHITE PINE';
  IF SPEC=2  THEN SPGRP='RED SPRUCE';
  IF SPEC=4  THEN SPGRP='HEMLOCK';
  IF SPEC=8 THEN SPGRP='YLW. BIRCH';
  if SPEC=3 OR SPEC=19 OR SPEC=20 THEN SPGRP='OTHER SWDS';
  IF SPEC=5  THEN SPGRP='RED OAK';
  IF SPEC=7 THEN SPGRP='RED MAPLE';
  IF SPEC=6 OR SPEC>=9 AND SPEC<=30 THEN SPGRP='OTHER HWDS';
  ***assign treatments;
  *yearharv=put(year,yearharv.);
  newnbr=1;

proc print data=tree_hts; *(obs=20);
  where dbhin=. or dbhcm=. or htm=. htft=.;
  title 'sample print of tree heights';

proc freq data=tree_hts;
  tables dbhcm dbhin dbhclcm dbhclin htm htft htclm htclft;
  title 'freq of tree_hts';

data out.tree;
  set tree_hts;


run;

********************************************************************;
***Concatenate sapling and tree data;
********************************************************************;

libname in 'F:\TI-REGEN\1997data\sas\data';

data sap;
  set in.sap;

data tree;
  set in.tree;

data in.saptree;
  set sap(in=sapling)
      tree(in=tree);
  if sapling then type='sapling';
  if tree then type='tree';
  if year=1988 then year=1992;
  if year=1996 then year=1997;

run;
