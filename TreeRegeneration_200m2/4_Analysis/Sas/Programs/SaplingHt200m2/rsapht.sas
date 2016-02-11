**************************************************************************
**************************************************************************
***PROGRAM: F:\Ti-regen\1997data\Sas\Programs\rsapht.sas
***PURPOSE: Read in 1997 sapling height (in feet) data
***         Use proc GLM to get an equation and predicted heights
***         Get the means of predicted and actual heights and plot
***            height versus dbh by gap, also plot equations.
***INPUT:   f:\ti-regen\1997data\RawData\saphgt2.inft.txt
***OUTPUT:  none
***DATE CREATED: 16MAR1999
***PROGRAMMER: SPE
***MODIFIED:
***NOTE:    The graph of the equations implies an interaction:
***           slow initial growth for trees not in gaps followed
***           by faster growth than trees in gaps.
**************************************************************************
**************************************************************************;

options nocenter;
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
  19=PP    /*Pinus resinosa (red pine)               */
  20=RP    /*Pinus rigida (pitch pine)               */
  25=witch /*Hamamelis virginiana (witch hazel)      */
  26=alder /*Alnus sp. (alder sp.)                   */
  OTHER='unknown';
 VALUE $ WOODFMT
   'softwood'='softwood species'
   'hardwood'='hardwood species';


********************************************************************;
***READ SAPLING HEIGHT DATA;
********************************************************************;

filename sapht 'f:\ti-regen\1997data\RawData\saphgt2.inft.txt';

data rsapht;
  infile sapht firstobs=2 missover;
  input Species DBHcm Dist Top Bot Subquad $ Gap $ Htm DBHIN Htft;
  spec=int(species);
  IF 9<=SPEC<=10 THEN DELETE;
  FIA_spp=put(spec,fiafmt.);
  if .5<dbhin<1.49 then dbhclass=1;
  if 1.5<dbhin<2.49 then dbhclass=2;
  if 2.5<dbhin<3.49 then dbhclass=3;
  if dbhin>3.5 then dbhclass=4;
  transdbh=-1*(1/dbhin);
  if FIA_spp in('WP','RS','BF','HE','PP','RP') then wood='softwood';
    else wood='hardwood';
  if dbhclass=. then put species dbhcm dist subquad htm;
  if spec=. then put spec species dbhcm dist subquad htm;

run;
/*
proc freq data=rsapht;
  tables spec*dbhclass / nopercent nocol norow;
run;

PROC PRINT DATA=SLRRM;

proc sort data=rsapht;
  by gap;

proc freq data=rsapht;
  by gap;
  tables spec*dbhclass / nopercent nocol norow;

proc gplot data=rsapht;
  plot htft*dbhin=spec;

run;
*/
********************************************************************;
***Get equations;
********************************************************************;

proc sort data=rsapht;
  *by  FIA_SPP;
  *by wood;
  by gap;

proc glm data=rsapht;
  *by  FIA_SPP;
  *by wood;
  by gap;
  model htft=transdbh;
  output out=slrrm p=htpred;

*goptions reset=global  noborder
           dev=CGMMPPA GSFNAME=SAPHT GSFMODE=REPLACE NOPROMPT ;
*filename sapht 'e:\tiwork\graphics\sapht1.cgm';
goptions reset=global gunit=pct border ftext=swissb htitle=6 htext=4;

proc sort data=SLRRM;
  *by  FIA_SPP DBHIN;
  *by wood dbhin;
  by gap dbhin;

***Get means by (species) wood type and dbhclass for predicted heights;

PROC MEANS MEAN NOPRINT DATA=SLRRM;
  *BY FIA_SPP DBHIN;
  *by wood dbhin;
  by gap dbhin;
  VAR htft HTPRED;
  OUTPUT OUT=MEANHT MEAN=;

SYMBOL1 I=J VALUE=DOT WIDTH=2 COLOR=BLACK;
SYMBOL2 I=J VALUE=DOT WIDTH=2 COLOR=GREEN;
SYMBOL3 I=J VALUE=DOT WIDTH=2 COLOR=RED;
SYMBOL4 I=J VALUE=DOT WIDTH=2 COLOR=GOLD;
SYMBOL5 I=J VALUE=DOT WIDTH=2 COLOR=BROWN;
SYMBOL6 I=J VALUE=DOT WIDTH=2 COLOR=LIME;
SYMBOL7 I=J VALUE=DOT WIDTH=2 COLOR=BLUE;

proc gplot data=MEANHT;
  *plot htPRED*dbhin=FIA_SPP;
  *plot htpred*dbhin=wood;
  plot htpred*dbhin=gap;

run;

proc gplot data=MEANHT;
  *plot htft*dbhin=FIA_SPP;
  *plot htft*dbhin=wood;
  plot htft*dbhin=gap;

run;

title1 height=4 justify=center 'Plot of Actual Values and Regression. Model: wood type=a-b*1/dbh';
footnote j=r "Run Date: &SYSDATE"
         j=l 'Holt Research Forest 1997 Sapling Data';
symbol1 i=r color=green width=2 value=triangle height=2;
symbol2 i=r color=blue  width=2 value=circle height=2;
*symbol3 i=r color=red width=2 value=square height=2;
axis1 minor=none
      label=none;
axis2 minor=none
      label=none;
legend1 label=none;
proc gplot data=rsapht;
  plot htft*transdbh=gap/haxis=axis1
                          vaxis=axis2
                          legend=legend1;
format wood $woodfmt.;

run;

quit;
