**************************************************************************
**************************************************************************
***PROGRAM: E:\Holtsas\FlexSap.sas
***PURPOSE: Read in 1997 sapling data, output for Al
***           Read in 1984, 92, 97 sapling data, get number of trees by dbh class
***           by species, output for Al
***INPUT:   F:\TI-REGEN\twohunM2\REG200.84D
***         F:\TI-REGEN\twohunM2\reg200.92D
***         F:\TI-REGEN\1997data\REG200m2.97D
***         F:\TI-REGEN\QCENTSC.LST
***         f:\ti-regen\1997data\saphgt2.inft.txt
***OUTPUT:
***DATE CREATED: 11MAR1999
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

FILENAME TREE84 'F:\TI-REGEN\twohunM2\REG200.84D';
FILENAME TREE92 'F:\TI-REGEN\twohunM2\reg200.92D';
FILENAME TREE97 'F:\TI-REGEN\1997data\reg200m2.97D';
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

proc print data=r&year.d(obs=10);
  title "r&year.d";

%mend yearwant;
%yearwant(year=84);
%yearwant(year=92);

DATA R97d;
  INFILE TREE97 MISSOVER;
  INPUT QUADRAT $ SPEC nreg1 NREG2 NREG3 NREG4 NREG5 NREG6 NREG7 NREG8 ;
  YEAR=1997;
  LENGTH SPECIES $ 4;
  species=put(spec,fiafmt.);
IF SPEC=0 THEN DO;
  NUMBER=0;
  SIZE=0;
  COUNT=COUNT+1;
  RETAIN COUNT;
END;
%loop;

proc print data=r97d(obs=10);
  title "r97d";

run;

data all200(drop=COND NREG1 NREG2 NREG3 NREG4 NREG5 NREG6 NREG7 NREG8 count);
  set r84d
      r92d
      r97d;
  block=substr(quadrat,1,2);
  if block in('3E','4D','5E','4F','3G','4G','5G','4I','3J','5J')
    then blockuse='HARVEST';
      else blockuse='CONTROL';
  if species in('WP','RS','BF','HE','PP','RP') then wood='softwood';
    else wood='hardwood';
  dbhin=size/2.54;
  ***assign dbh classes in inches;
  if .5<dbhin<1.49 then dbhclin=1;
  if 1.5<dbhin<2.49 then dbhclin=2;
  if 2.5<dbhin<4 then dbhclin=3;
  if dbhin>4 then dbhclin=4;

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

proc print data=onetree(obs=100);
  title 'obs';

run;

********************************************************************;
***READ SAPLING HEIGHT DATA;
********************************************************************;
/*
filename sapht 'f:\ti-regen\1997data\saphgt2.inft.txt';

data rsapht;
  infile sapht firstobs=2 missover;
  input Species DBHcm Dist Top Bot Subquad $ Gap $ Htm DBHIN Htft;
  spec=int(species);
  IF 9<=SPEC<=10 THEN DELETE;
  FIA_spp=put(spec,fiafmt.);
  if .5<dbhin<1.49 then dbhclass=1;
  if 1.5<dbhin<2.49 then dbhclass=2;
  if 2.5<dbhin<4 then dbhclass=3;
  if dbhin>4 then dbhclass=4;
  transdbh=-1*(1/dbhin);
  block=substr(subquad,1,2);
  if block in('3E','4D','5E','4F','3G','4G','5G','4I','3J','5J')
    then blockuse='HARVEST';
      else blockuse='CONTROL';
  if FIA_spp in('WP','RS','BF','HE','PP','RP') then wood='softwood';
    else wood='hardwood';
  if dbhclass=. then put species dbhcm dist subquad htm;
  if spec=. then put spec species dbhcm dist subquad htm;

run;

************************************************************************;
***Output 1997 Height Data and 84, 92, 97 Sapling Data To Flat Files for Al;
************************************************************************;

filename tree "F:\TI-REGEN\1997data\FLXSAP97.TXT";

data _null_;
  set rsapht;
  file tree;
  if _N_=1 then do;
    PUT @1  'PLOT # .25 H'
        @20 'FIA_SPP'
        @28 'DBH'
        @32 'HT';
  end;
  PUT @1  FIA_SPP $15.
      @17 DBHIN 4.2
      @26 HTFT 5.2;

run;
*/
**************************************************************************;
**84, 92, 97 data, get freqs of dbh by species;
**************************************************************************;

proc sort data=onetree;
  by year quadrat FIA_spp dbhclin;

proc freq noprint data=onetree;
  by year quadrat FIA_spp;
  tables dbhclin /out=all;

proc sort data=all;
  by year quadrat FIA_spp dbhclin count;

proc print data=all(obs=50);
  var year quadrat FIA_spp dbhclin count;
  title 'all after freq and sort';

**************************************************************************;
***Read in the quadrat list and save each successively in macro variable q;
**************************************************************************;

filename quad 'f:\holtdocs\forms\quadlst.txt';
  data quadlist;
    infile quad;
    input quad $;
  run;

%macro quadrat;
%do i=1 %to 160;
  data _null_;
    set quadlist(firstobs=&i obs=&i);
    call symput('q',trim(left(quad)));
  run;

************************************************************************;
***Output Sapling Data, Dead, Live Trees to Flat Files;
************************************************************************;

%macro specs(year=);
filename treesout "F:\TI-REGEN\twohunM2\Flex\SI&YEAR._&Q..TXT";
data _null_;
  set all;
  by year quadrat;
  if year="&year" and quadrat="&q";
  file treesout;
  if first.quadrat then do;
    PUT @1  '!PLOT # 200 M'
        @15  'FIA_SPP'
        @25 'DBH'
        @30 'COUNT';
  end;
  PUT @15 FIA_SPP $15.
      @25 DBHCLIN 4.
      @30 COUNT;
  run;

%mend specs;
%specs(year=1984);
%specs(year=1992);
%specs(year=1997);
run;

%end;
%mend quadrat;
%quadrat;
RUN;
