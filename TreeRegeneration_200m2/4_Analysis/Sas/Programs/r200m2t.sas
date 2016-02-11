**************************************************************************
**************************************************************************
***PROGRAM: E:\Holtsas\r200m2t.sas
***PURPOSE: Read in 200m square plot data, generate height with height
***           equations (see F:\Tiregen\1997data\rawsapht.sas),
***           extrapolate to study area, compare harvest vs. control
***INPUT:   F:\TI-REGEN\twohunM2\REG200.84D
***         F:\TI-REGEN\twohunM2\reg200.92D
***         F:\TI-REGEN\twohunM2\REG200m2.97D
***         F:\TI-REGEN\QCENTSC.LST
***OUTPUT:
***DATE CREATED: 19JUN1997/11MAR1999
***PROGRAMMER: JWW/SPE
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
  LENGTH SPECIES $ 4;
  species=put(spec,fiafmt.);
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
  LENGTH SPECIES $ 4;
  species=put(spec,fiafmt.);
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

proc sort data=freq92;
  by quadrat;

proc sort data=freq97;
  by quadrat;

data compare(drop=count percent);
  merge freq92(in=in92)
        freq97(in=in97);
  by quadrat;
  if in92 then in1992='yes'; else in1992='no '; *if in1992='no ' then output;
  if in97 then in1997='yes'; else in1997='no '; *if in1997='no ' then output;

proc print data=compare;
  title 'compare 92 and 97';

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
/*
PROC SORT DATA=R84D;
  BY YEAR QUADRAT SPEC ;

PROC FREQ DATA=R84D;
  BY SIZE;
  TABLES QUADRAT*SPEC / NOROW NOCOL NOPERCENT;
  WEIGHT NUMBER;

PROC SORT DATA=R84D; BY YEAR QUADRAT SPEC COND;

PROC SORT DATA=R92D; BY YEAR QUADRAT SPEC COND;

PROC MEANS DATA=R84D SUM NOPRINT; BY YEAR QUADRAT SPEC COND ; VAR NUMBER;
OUTPUT OUT=QSUM84 SUM=NSTEMS;

PROC MEANS DATA=R92D SUM NOPRINT; BY YEAR QUADRAT SPEC COND ; VAR NUMBER;
OUTPUT OUT=QSUM92 SUM=NSTEMS;

PROC SORT DATA=QSUM84; BY YEAR SPEC COND;

PROC SORT DATA=QSUM92; BY YEAR SPEC COND;

PROC MEANS DATA=QSUM84 MEAN STD N; BY YEAR SPEC COND ; VAR NSTEMS;

PROC MEANS DATA=QSUM92 MEAN STD N; BY YEAR SPEC COND ; VAR NSTEMS;
*/
/*
PROC SORT DATA=R84D; BY YEAR QUADRAT SPEC ;

PROC SORT DATA=R92D; BY YEAR QUADRAT SPEC ;

PROC MEANS DATA=R84D SUM NOPRINT; BY YEAR QUADRAT SPEC ; VAR NUMBER; ID SPECIES;
OUTPUT OUT=QSUM84 SUM=NSTEMS;

PROC MEANS DATA=R92D SUM NOPRINT; BY YEAR QUADRAT SPEC ; VAR NUMBER; ID SPECIES;
OUTPUT OUT=QSUM92 SUM=NSTEMS;

PROC SORT DATA=QSUM84; BY QUADRAT;

PROC SORT DATA=QSUM92; BY QUADRAT;

PROC TRANSPOSE DATA=QSUM84 PREFIX=N84 OUT=TOUT84; BY QUADRAT;
ID SPECIES; VAR NSTEMS;

DATA SET84; SET TOUT84;
DROP _NAME_;
IF N84WP=. THEN N84WP=0; IF N84RS=. THEN N84RS=0; IF N84BF=. THEN N84BF=0;
IF N84HM=. THEN N84HM=0; IF N84RO=. THEN N84RO=0; IF N84WO=. THEN N84WO=0;
IF N84RM=. THEN N84RM=0;
IF N84YB=. THEN N84YB=0; IF N84PB=. THEN N84PB=0; IF N84GB=. THEN N84GB=0;
IF N84WA=. THEN N84WA=0; IF N84BE=. THEN N84BE=0; IF N84SM=. THEN N84SM=0;
IF N84POPG=. THEN N84POPG=0; IF N84POPT=. THEN N84POPT=0;
IF N84BC=. THEN N84BC=0; IF N84APL=. THEN N84APL=0;
IF N84HH=. THEN N84HH=0; IF N84RP=. THEN N84RP=0; IF N84PP=. THEN N84PP=0;
IF N84WH=. THEN N84WH=0; IF N84ALD =. THEN N84ALD=0;   IF N84OTH =. THEN N84OTH=0;

PROC TRANSPOSE DATA=QSUM92 PREFIX=N92 OUT=TOUT92; BY QUADRAT;
ID SPECIES; VAR NSTEMS;

DATA SET92; SET TOUT92;
DROP _NAME_;
IF N92WP=. THEN N92WP=0; IF N92RS=. THEN N92RS=0; IF N92BF=. THEN N92BF=0;
IF N92HM=. THEN N92HM=0; IF N92RO=. THEN N92RO=0; IF N92WO=. THEN N92WO=0;
IF N92RM=. THEN N92RM=0;
IF N92YB=. THEN N92YB=0; IF N92PB=. THEN N92PB=0; IF N92GB=. THEN N92GB=0;
IF N92WA=. THEN N92WA=0; IF N92BE=. THEN N92BE=0; IF N92SM=. THEN N92SM=0;
IF N92POPG=. THEN N92POPG=0; IF N92POPT=. THEN N92POPT=0;
IF N92BC=. THEN N92BC=0; IF N92APL=. THEN N92APL=0;
IF N92HH=. THEN N92HH=0; IF N92RP=. THEN N92RP=0; IF N92PP=. THEN N92PP=0;
IF N92WH=. THEN N92WH=0; IF N92ALD =. THEN N92ALD=0;   IF N92OTH =. THEN N92OTH=0;

PROC PRINT DATA=SET92

RUN;
*/

********************************************************************;
***READ SAPLING HEIGHT DATA;
********************************************************************;

filename sapht 'f:\ti-regen\1997data\saphgt2.inft.txt';

data rsapht;
  infile sapht firstobs=2 missover;
  input Species DBHcm Dist Top Bot Subquad $ Gap $ Htm DBHIN Htft;
  spec=int(species);
  IF 9<=SPEC<=10 THEN DELETE;
  FIA_spp=put(spec,fiafmt.);
  if .5<dbhin<1.49 then dbhclin=1;
  if 1.5<dbhin<2.49 then dbhclin=2;
  if 2.5<dbhin<4 then dbhclin=3;
  if dbhin>4 then dbhclin=4;
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

********************************************************************;
***Get equation parameters for softwoods vs. hardwoods;
********************************************************************;

proc sort data=rsapht;
  *by  FIA_SPP;
  by wood;
  *by gap;

proc reg noprint data=rsapht outest=est;
  by wood;
  model htft=transdbh;

proc print data=est;
  title 'est';

run;

proc sort data=onetree;
  by wood;

proc sort data=est;
  by wood;

data heights(drop=i);
  merge onetree(in=wanted)
        est(keep=wood intercep transdbh rename=(transdbh=beta));
  by wood;
  if wanted;
  htin=round(intercep+(beta*dbhin),1);
  htft=htin/12;

proc print data=heights(obs=100);
  title 'heights';

run;

