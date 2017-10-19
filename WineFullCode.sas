%let PATH 	= /home/taylorvender20180/my_courses/donald.wedding/c_8888/PRED411/UNIT03/HW;
%let NAME 	= P411;
%let LIB	= &NAME..;

libname &NAME. "&PATH.";

%let INFILE 	= &LIB.WINE;
%let TEMPFILE 	= TEMPFILE;
%let SCRUBFILE	= SCRUBFILE;
%let FIXFILE	= FIXFILE;
%let VARLIST	= VARLIST;
%let CAPFILE	= CAPFILE;
%let LOGFILE 	= LOGFILE;	


*need to do data exploration and document it. this is the assumption i made, (negative freesulfurdioxide? make sense?;

proc print data=&INFILE.(obs=10);
run;

proc contents data=&INFILE.;
run;

proc means data=&INFILE. n nmiss mean median;
run;

*target is how many cases of wine the person is buying;
proc univariate data=&INFILE. noprint;
histogram TARGET;
run;




data &TEMPFILE.;
set &INFILE.;
TARGET_FLAG = ( TARGET > 0 );
TARGET_AMT = TARGET - 1;
if TARGET_FLAG = 0 then TARGET_AMT = .;
run;

proc means data=&TEMPFILE. n nmiss mean median min max;
run;

proc means data=&TEMPFILE. n nmiss mean median min max;
class TARGET_FLAG;
run;

proc freq data=&TEMPFILE.;
table TARGET_FLAG /missing;
run;

*number of stars and missing stars is highly predictive;
proc freq data=&TEMPFILE.;
table STARS*TARGET_FLAG /missing;
run;


proc univariate data=&TEMPFILE. noprint;
histogram TARGET TARGET_AMT;
run;


proc corr data=&TEMPFILE.;
WITH STARS;
run;


proc corr data=&TEMPFILE.;
WITH TotalSulfurDioxide;
run;




data &SCRUBFILE.;
set &TEMPFILE.;
IMP_STARS				= STARS;
IMP_Density				= Density;
IMP_Sulphates			= Sulphates;
IMP_pH					= pH;
IMP_Alcohol				= Alcohol;
IMP_TotalSulfurDioxide	= TotalSulfurDioxide;
IMP_FreeSulfurDioxide	= FreeSulfurDioxide;
IMP_Chlorides			= Chlorides;
IMP_ResidualSugar		= ResidualSugar;


*Next try IMP_STARS=0 and not even have a flag;
if missing(STARS) 				then IMP_STARS				= 0;
if missing(Density)				then IMP_Density 			= 0.9944900;
if missing(Sulphates)			then IMP_Sulphates			= 0.5000000;
if missing(pH)					then IMP_pH					= 3.2000000;
if missing(Alcohol)				then IMP_Alcohol			= 10.4000000;
if missing(FreeSulfurDioxide)	then IMP_FreeSulfurDioxide	= 30.0000000;
if missing(Chlorides)			then IMP_Chlorides			= 0.0460000;
if missing(ResidualSugar)		then IMP_ResidualSugar		= 3.9000000;
/*
*at 25 mins on 2016 02 26 sync session. see missing stars as predictive. If oyu
dont have any stars, your wine won't sell;
*could treat stars as a categorical variable;
M_STARS					= 0;
if missing( STARS ) then do;
	IMP_STARS= 2;
	if LabelAppeal < -0.5 then IMP_STARS = 1;
	if 0.5 >LabelAppeal >= -0.5 AND AcidIndex >= 8.5 then IMP_STARS = 1;
	if 0.5 >LabelAppeal >= -0.5 AND AcidIndex < 8.5 AND IMP_Alcohol < 11 then IMP_STARS = 2;
	if 0.5 >LabelAppeal >= -0.5 AND AcidIndex < 8.5 AND IMP_Alcohol >= 11 then IMP_STARS = 2;
	if LabelAppeal >= 0.5 AND IMP_Alcohol < 10 then IMP_STARS = 2;
	if LabelAppeal >= 0.5 AND IMP_Alcohol >= 10 then IMP_STARS = 3;	
	M_STARS = 1;
end;
*/

if missing (TotalSulfurDioxide) then do;
	IMP_TotalSulfurDioxide = 122;
	if IMP_ResidualSugar < 5.8 then IMP_TotalSulfurDioxide = 109;
	if IMP_ResidualSugar >= 5.8 then IMP_TotalSulfurDioxide = 136;
end;

*some transforms to get rid of outliers;
*IMP_TotalSulfurDioxide = sign( IMP_TotalSulfurDioxide ) * sqrt( abs(IMP_TotalSulfurDioxide)+1 );
*IMP_TotalSulfurDioxide = sign( IMP_TotalSulfurDioxide ) * log( abs(IMP_TotalSulfurDioxide)+1 );



DROP	 STARS
		 Density
		 Sulphates
		 pH
		 Alcohol
		 TotalSulfurDioxide
		 FreeSulfurDioxide
		 Chlorides
		 ResidualSugar
		 ;

run;

data &CAPFILE.;
set &SCRUBFILE.;

CAP_FixedAcidity = FixedAcidity;
if FixedAcidity >= 2.590 then CAP_FixedAcidity = 2.590;
if FixedAcidity <= -1.865 then CAP_FixedAcidity = -1.865;

CAP_CitricAcid = CitricAcid;
if CitricAcid >= 2.66 then CAP_CitricAcid = 2.66;
if CitricAcid <= -2.18 then CAP_CitricAcid = -2.18;

CAP_IMP_Density = IMP_Density;
if IMP_Density >= 1.06981 then CAP_IMP_Density = 1.06981;
if IMP_Density <= 0.91680 then CAP_IMP_Density = 0.91680;

CAP_IMP_Sulphates = IMP_Sulphates;
if IMP_Sulphates >= 3.09 then CAP_IMP_Sulphates = 3.09;
if IMP_Sulphates <= -2.08 then CAP_IMP_Sulphates = -2.08;

CAP_IMP_pH = IMP_pH;
if IMP_pH >= 5.12 then CAP_IMP_pH = 5.12;
if IMP_pH <= 1.33 then CAP_IMP_pH = 1.33;

CAP_IMP_Alcohol = IMP_Alcohol;
if IMP_Alcohol >= 20.2 then CAP_IMP_Alcohol = 20.2;
if IMP_Alcohol <= 0.2 then CAP_IMP_Alcohol = 0.2;

CAP_IMP_TotalSulfurDioxide = IMP_TotalSulfurDioxide;
if IMP_TotalSulfurDioxide >= 746 then CAP_IMP_TotalSulfurDioxide = 746;
if IMP_TotalSulfurDioxide <= -516 then CAP_IMP_TotalSulfurDioxide = -516;

CAP_IMP_FreeSulfurDioxide = IMP_FreeSulfurDioxide;
if IMP_FreeSulfurDioxide >= 464 then CAP_IMP_FreeSulfurDioxide = 464;
if IMP_FreeSulfurDioxide <= -382 then CAP_IMP_FreeSulfurDioxide = -382;

CAP_IMP_Chlorides = IMP_Chlorides;
if IMP_Chlorides >= 0.952 then CAP_IMP_Chlorides = 0.952;
if IMP_Chlorides <= -0.848 then CAP_IMP_Chlorides = -0.848;

CAP_IMP_ResidualSugar = IMP_ResidualSugar;
if IMP_ResidualSugar >= 97.10 then CAP_IMP_ResidualSugar = 97.10;
if IMP_ResidualSugar <= -89.60 then CAP_IMP_ResidualSugar = -89.60;

DROP	 FixedAcidity
		 CitricAcid
		 IMP_Density
		 IMP_Sulphates
		 IMP_pH
		 IMP_Alcohol
		 IMP_TotalSulfurDioxide
		 IMP_FreeSulfurDioxide
		 IMP_Chlorides	
		 IMP_ResidualSugar
		 ;
run;

proc contents data=&CAPFILE.;
run;

libname scrlib "/home/taylorvender20180/my_courses/PRED411/UNIT03";

data scrlib.VENDERwinesales_CAPFILE;
set &CAPFILE.;
run;

proc export data=scrlib.VENDERwinesales_CAPFILE DBMS=csv outfile='/home/taylorvender20180/my_courses/PRED411/UNIT03/scrlib.VENDERwinesales_CAPFILE.csv' replace;
run;

proc means data=&TEMPFILE. MEAN VAR;
var TARGET;
run;

proc univariate data=&TEMPFILE. noprint;
histogram TARGET;
run;

proc print data=&SCRUBFILE. (obs=10);
run;

proc means data=&SCRUBFILE.  n nmiss mean median max min;
run; 

proc univariate data=&SCRUBFILE. plot;
run;

data &FIXFILE.;
set &CAPFILE.;

*ran proc reg with stepwise selection to choose variables;
proc reg data=&FIXFILE.;
model TARGET = 	
				AcidIndex
				CAP_CitricAcid
				CAP_FixedAcidity
				CAP_IMP_Alcohol
				CAP_IMP_Chlorides
				CAP_IMP_Density
				CAP_IMP_FreeSulfurDioxide
				CAP_IMP_ResidualSugar
				CAP_IMP_Sulphates
				CAP_IMP_TotalSulfurDioxide
				CAP_IMP_pH
				IMP_STARS
				LabelAppeal
				VolatileAcidity
				/selection = stepwise vif;
	output out=&FIXFILE. p=X_REGRESSION;
run;
quit;
run;

data &LOGFILE.;
set &CAPFILE.;

*Negative Binomial;
proc genmod data=&LOGFILE.;
model TARGET = 	
				AcidIndex
				CAP_IMP_Alcohol
				CAP_IMP_FreeSulfurDioxide
				CAP_IMP_Sulphates
				CAP_IMP_TotalSulfurDioxide
				CAP_IMP_pH
				IMP_STARS
				LabelAppeal
				VolatileAcidity
				/link=log dist=nb
				;
output out=&LOGFILE. p=X_GENMOD_NB;
run;

data &FIXFILE.;
set &CAPFILE.;
*poisson;
proc genmod data=&LOGFILE.;
model TARGET = 	
				AcidIndex
				CAP_IMP_Alcohol
				CAP_IMP_FreeSulfurDioxide
				CAP_IMP_Sulphates
				CAP_IMP_TotalSulfurDioxide
				CAP_IMP_pH
				IMP_STARS
				LabelAppeal
				VolatileAcidity
				/link=log dist=poi
				;
output out=&LOGFILE. p=X_GENMOD_POI;
run;

*hurdle model;


*probability the guy buys wine;
proc logistic data=&LOGFILE. plot(only)=(roc(ID=prob));
model TARGET_FLAG( ref="0" ) =
				AcidIndex
				CAP_CitricAcid
				CAP_FixedAcidity
				CAP_IMP_Alcohol
				CAP_IMP_Chlorides
				CAP_IMP_Density
				CAP_IMP_FreeSulfurDioxide
				CAP_IMP_ResidualSugar
				CAP_IMP_Sulphates
				CAP_IMP_TotalSulfurDioxide
				CAP_IMP_pH
				IMP_STARS
				LabelAppeal
				VolatileAcidity
				/selection=stepwise roceps=0.1;
output out = &LOGFILE. p=X_LOGIT_PROB;
run;


*if buys wine, how much does he buy?;
proc genmod data=&LOGFILE.;
model TARGET_AMT = 	
				AcidIndex
				CAP_IMP_Alcohol
				CAP_IMP_FreeSulfurDioxide
				CAP_IMP_Sulphates
				CAP_IMP_TotalSulfurDioxide
				CAP_IMP_pH
				IMP_STARS
				LabelAppeal
				VolatileAcidity
				/link=log dist=nb
				;
output out=&LOGFILE. p=X_GENMOD_HURDLE;
run;

proc means data=&LOGFILE. mean median;
class TARGET_FLAG;
var _numeric_;
run;

proc genmod data=&LOGFILE.;
model TARGET = 	
				AcidIndex
				CAP_IMP_Alcohol
				CAP_IMP_FreeSulfurDioxide
				CAP_IMP_Sulphates
				CAP_IMP_TotalSulfurDioxide
				CAP_IMP_pH
				IMP_STARS
				LabelAppeal
				VolatileAcidity
			/link=log dist=ZIP;
zeromodel 		AcidIndex
				CAP_IMP_Alcohol
				CAP_IMP_FreeSulfurDioxide
				CAP_IMP_Sulphates
				CAP_IMP_TotalSulfurDioxide
				CAP_IMP_pH
				IMP_STARS
				LabelAppeal
				VolatileAcidity / link=logit;
output out=&LOGFILE. pred=X_GENMOD_ZIP pzero=X_GENMOD_PZERO_ZIP;
run;

*ZINB MODEL;
*Sometimes, the NEGATIVE BINOMIAL distribution models will converge 
to the same solution as the POISSON models. In those cases, it might be useful to use 
different parameters in MODEL and/or ZEROMODEL because getting different answers will improve the chances of finding a good model;
proc genmod data=&LOGFILE.;
model TARGET = 	
				AcidIndex
				CAP_IMP_Alcohol
				CAP_IMP_Sulphates
				CAP_IMP_TotalSulfurDioxide
				CAP_IMP_pH
				IMP_STARS
				LabelAppeal
				VolatileAcidity
			/link=log dist=ZINB;
zeromodel 		AcidIndex
				CAP_IMP_Alcohol
				CAP_IMP_Sulphates
				CAP_IMP_TotalSulfurDioxide
				CAP_IMP_pH
				IMP_STARS
				LabelAppeal
				VolatileAcidity / link=logit;
output out=&LOGFILE. pred=X_GENMOD_ZINB pzero=X_GENMOD_PZERO_ZINB;
run;

data SCOREFILE;
set &LOGFILE.;

*Hurdle;
P_LOGIT_PROB = 	3.4196								    +
				AcidIndex					*(-0.3909)  +
				CAP_IMP_Alcohol				*(-0.0224)  +
				CAP_IMP_FreeSulfurDioxide	*(0.000646) +
				CAP_IMP_Sulphates			*(-0.1120)	+
				CAP_IMP_TotalSulfurDioxide	*(0.000893) +
				CAP_IMP_pH					*(-0.1984)	+
				IMP_STARS					*(2.0534)	+
				LabelAppeal					*(-0.4591)  +
				VolatileAcidity				*(-0.1852)	
				;
if P_LOGIT_PROB > 1000 then P_LOGIT_PROB = 1000;
if P_LOGIT_PROB < -1000 then P_LOGIT_PROB = -1000;
P_LOGIT_PROB = exp(P_LOGIT_PROB) / (1+exp(P_LOGIT_PROB));



P_GENMOD_HURDLE = 	0.8179									+
					AcidIndex					*(-0.0207)  +
					CAP_IMP_Alcohol				*(0.0095)   +
					CAP_IMP_FreeSulfurDioxide	*(0.0000)   +
					CAP_IMP_Sulphates			*(0.0005)	+
					CAP_IMP_TotalSulfurDioxide	*(-0.0000)  +
					CAP_IMP_pH					*(0.0093)	+
					IMP_STARS					*(0.1152)	+
					LabelAppeal					*(0.2959)   +
					VolatileAcidity				*(-0.0131)	
					;
					
P_GENMOD_HURDLE = exp(P_GENMOD_HURDLE);

P_HURDLE = P_LOGIT_PROB * (P_GENMOD_HURDLE+1);

P_GENMOD_PZERO_ZIP	=	-4.0264									+
						AcidIndex					*(0.4347)   +
						CAP_IMP_Alcohol				*(0.0296)   +
						CAP_IMP_FreeSulfurDioxide	*(-0.0008)  +
						CAP_IMP_Sulphates			*(0.1391)	+
						CAP_IMP_TotalSulfurDioxide	*(-0.0010)  +
						CAP_IMP_pH					*(0.2312)	+
						IMP_STARS					*(-2.3788)	+
						LabelAppeal					*(0.7235)   +
						VolatileAcidity				*(0.1935)	
						;

if P_GENMOD_PZERO_ZIP > 1000 then P_GENMOD_PZERO_ZIP = 1000;
if P_GENMOD_PZERO_ZIP < -1000 then P_GENMOD_PZERO_ZIP = -1000;
P_GENMOD_PZERO_ZIP = exp(P_GENMOD_PZERO_ZIP) / (1+exp(P_GENMOD_PZERO_ZIP));

P_GENMOD_ZIP	=	1.1601 									+
					AcidIndex					*(-0.0187)  +
					CAP_IMP_Alcohol				*(0.0073)   +
					CAP_IMP_FreeSulfurDioxide	*(0.0000)   +
					CAP_IMP_Sulphates			*(0.0004)	+
					CAP_IMP_TotalSulfurDioxide	*(-0.0000)  +
					CAP_IMP_pH					*(0.0055)	+
					IMP_STARS					*(0.1010)	+
					LabelAppeal					*(0.2328)   +
					VolatileAcidity				*(-0.0122)	
					;
					
P_GENMOD_ZIP = exp(P_GENMOD_ZIP);
P_GENMOD_ZIP = P_GENMOD_ZIP*(1-P_GENMOD_PZERO_ZIP);

P_GENMOD_PZERO_ZINB	=	-3.9034									+
						AcidIndex					*(0.4207)   +
						CAP_IMP_Alcohol				*(0.0288)   +
						CAP_IMP_Sulphates			*(0.1338)	+
						CAP_IMP_TotalSulfurDioxide	*(-0.0010)  +
						CAP_IMP_pH					*(0.2159)	+
						IMP_STARS					*(-2.2174)	+
						LabelAppeal					*(0.6868)   +
						VolatileAcidity				*(0.1862)	
						;
if P_GENMOD_PZERO_ZINB > 1000 then P_GENMOD_PZERO_ZINB = 1000;
if P_GENMOD_PZERO_ZINB < -1000 then P_GENMOD_PZERO_ZINB = -1000;
P_GENMOD_PZERO_ZINB = exp(P_GENMOD_PZERO_ZINB) / (1+exp(P_GENMOD_PZERO_ZINB));

P_GENMOD_ZINB	=	1.1630 									+
					AcidIndex					*(-0.0185)  +
					CAP_IMP_Alcohol				*(0.0072)   +
					CAP_IMP_Sulphates			*(0.0006)	+
					CAP_IMP_TotalSulfurDioxide	*(-0.0000)  +
					CAP_IMP_pH					*(0.0055)	+
					IMP_STARS					*(0.1002)	+
					LabelAppeal					*(0.2323)   +
					VolatileAcidity				*(-0.0121)	
					;
					
P_GENMOD_ZINB = exp(P_GENMOD_ZINB);
P_GENMOD_ZINB = P_GENMOD_ZINB*(1-P_GENMOD_PZERO_ZINB);

*negative binomial;
P_GENMOD_NB		=	1.2482 									+
					AcidIndex					*(-0.0874)  +
					CAP_IMP_Alcohol				*(0.0024)   +
					CAP_IMP_FreeSulfurDioxide	*(0.0001)   +
					CAP_IMP_Sulphates			*(-0.0133)	+
					CAP_IMP_TotalSulfurDioxide	*(0.0001)  +
					CAP_IMP_pH					*(-0.0170)	+
					IMP_STARS					*(0.3117)	+
					LabelAppeal					*(0.1330)   +
					VolatileAcidity				*(-0.0337)	
					;
P_GENMOD_NB = exp(P_GENMOD_NB);

*Poisson;
P_GENMOD_POI	=	1.2482 									+
					AcidIndex					*(-0.0874)  +
					CAP_IMP_Alcohol				*(0.0024)   +
					CAP_IMP_FreeSulfurDioxide	*(0.0001)   +
					CAP_IMP_Sulphates			*(-0.0133)	+
					CAP_IMP_TotalSulfurDioxide	*(0.0001)  +
					CAP_IMP_pH					*(-0.0170)	+
					IMP_STARS					*(0.3117)	+
					LabelAppeal					*(0.1330)   +
					VolatileAcidity				*(-0.0337)	
					;
P_GENMOD_POI = exp(P_GENMOD_POI);
run;

proc print data= SCOREFILE (obs=25);
run;


proc print data= SCOREFILE (obs=25);
var X_GENMOD_POI P_GENMOD_POI;
run;

proc print data= SCOREFILE (obs=25);
var X_GENMOD_NB P_GENMOD_NB;
run;

proc print data= SCOREFILE (obs=25);
var X_GENMOD_ZINB P_GENMOD_ZINB;
run;

proc print data= SCOREFILE (obs=25);
var X_GENMOD_ZIP P_GENMOD_ZIP;
run;
proc print data= SCOREFILE (obs=25);
var TARGET P_HURDLE;
run;

proc print data= SCOREFILE (obs=25);
var X_LOGIT_PROB P_LOGIT_PROB;
run;

proc print data= SCOREFILE (obs=25);
var X_GENMOD_HURDLE P_GENMOD_HURDLE;
run;

data HURDLESCORE;
set &LIB.wine_test;

TARGET_FLAG = ( TARGET > 0 );
TARGET_AMT = TARGET - 1;
if TARGET_FLAG = 0 then TARGET_AMT = .;

IMP_STARS				= STARS;
IMP_Density				= Density;
IMP_Sulphates			= Sulphates;
IMP_pH					= pH;
IMP_Alcohol				= Alcohol;
IMP_TotalSulfurDioxide	= TotalSulfurDioxide;
IMP_FreeSulfurDioxide	= FreeSulfurDioxide;
IMP_Chlorides			= Chlorides;
IMP_ResidualSugar		= ResidualSugar;


*Next try IMP_STARS=0 and not even have a flag;
if missing(STARS) 				then IMP_STARS				= 0;
if missing(Density)				then IMP_Density 			= 0.9944900;
if missing(Sulphates)			then IMP_Sulphates			= 0.5000000;
if missing(pH)					then IMP_pH					= 3.2000000;
if missing(Alcohol)				then IMP_Alcohol			= 10.4000000;
if missing(FreeSulfurDioxide)	then IMP_FreeSulfurDioxide	= 30.0000000;
if missing(Chlorides)			then IMP_Chlorides			= 0.0460000;
if missing(ResidualSugar)		then IMP_ResidualSugar		= 3.9000000;

if missing (TotalSulfurDioxide) then do;
	IMP_TotalSulfurDioxide = 122;
	if IMP_ResidualSugar < 5.8 then IMP_TotalSulfurDioxide = 109;
	if IMP_ResidualSugar >= 5.8 then IMP_TotalSulfurDioxide = 136;
end;


DROP	 STARS
		 Density
		 Sulphates
		 pH
		 Alcohol
		 TotalSulfurDioxide
		 FreeSulfurDioxide
		 Chlorides
		 ResidualSugar
		 ;

CAP_FixedAcidity = FixedAcidity;
if FixedAcidity >= 2.590 then CAP_FixedAcidity = 2.590;
if FixedAcidity <= -1.865 then CAP_FixedAcidity = -1.865;

CAP_CitricAcid = CitricAcid;
if CitricAcid >= 2.66 then CAP_CitricAcid = 2.66;
if CitricAcid <= -2.18 then CAP_CitricAcid = -2.18;

CAP_IMP_Density = IMP_Density;
if IMP_Density >= 1.06981 then CAP_IMP_Density = 1.06981;
if IMP_Density <= 0.91680 then CAP_IMP_Density = 0.91680;

CAP_IMP_Sulphates = IMP_Sulphates;
if IMP_Sulphates >= 3.09 then CAP_IMP_Sulphates = 3.09;
if IMP_Sulphates <= -2.08 then CAP_IMP_Sulphates = -2.08;

CAP_IMP_pH = IMP_pH;
if IMP_pH >= 5.12 then CAP_IMP_pH = 5.12;
if IMP_pH <= 1.33 then CAP_IMP_pH = 1.33;

CAP_IMP_Alcohol = IMP_Alcohol;
if IMP_Alcohol >= 20.2 then CAP_IMP_Alcohol = 20.2;
if IMP_Alcohol <= 0.2 then CAP_IMP_Alcohol = 0.2;

CAP_IMP_TotalSulfurDioxide = IMP_TotalSulfurDioxide;
if IMP_TotalSulfurDioxide >= 746 then CAP_IMP_TotalSulfurDioxide = 746;
if IMP_TotalSulfurDioxide <= -516 then CAP_IMP_TotalSulfurDioxide = -516;

CAP_IMP_FreeSulfurDioxide = IMP_FreeSulfurDioxide;
if IMP_FreeSulfurDioxide >= 464 then CAP_IMP_FreeSulfurDioxide = 464;
if IMP_FreeSulfurDioxide <= -382 then CAP_IMP_FreeSulfurDioxide = -382;

CAP_IMP_Chlorides = IMP_Chlorides;
if IMP_Chlorides >= 0.952 then CAP_IMP_Chlorides = 0.952;
if IMP_Chlorides <= -0.848 then CAP_IMP_Chlorides = -0.848;

CAP_IMP_ResidualSugar = IMP_ResidualSugar;
if IMP_ResidualSugar >= 97.10 then CAP_IMP_ResidualSugar = 97.10;
if IMP_ResidualSugar <= -89.60 then CAP_IMP_ResidualSugar = -89.60;

DROP	 FixedAcidity
		 CitricAcid
		 IMP_Density
		 IMP_Sulphates
		 IMP_pH
		 IMP_Alcohol
		 IMP_TotalSulfurDioxide
		 IMP_FreeSulfurDioxide
		 IMP_Chlorides	
		 IMP_ResidualSugar
		 ;

P_LOGIT_PROB = 	3.4196								    +
				AcidIndex					*(-0.3909)  +
				CAP_IMP_Alcohol				*(-0.0224)  +
				CAP_IMP_FreeSulfurDioxide	*(0.000646) +
				CAP_IMP_Sulphates			*(-0.1120)	+
				CAP_IMP_TotalSulfurDioxide	*(0.000893) +
				CAP_IMP_pH					*(-0.1984)	+
				IMP_STARS					*(2.0534)	+
				LabelAppeal					*(-0.4591)  +
				VolatileAcidity				*(-0.1852)	
				;
if P_LOGIT_PROB > 1000 then P_LOGIT_PROB = 1000;
if P_LOGIT_PROB < -1000 then P_LOGIT_PROB = -1000;
P_LOGIT_PROB = exp(P_LOGIT_PROB) / (1+exp(P_LOGIT_PROB));



P_GENMOD_HURDLE = 	0.8179									+
					AcidIndex					*(-0.0207)  +
					CAP_IMP_Alcohol				*(0.0095)   +
					CAP_IMP_FreeSulfurDioxide	*(0.0000)   +
					CAP_IMP_Sulphates			*(0.0005)	+
					CAP_IMP_TotalSulfurDioxide	*(-0.0000)  +
					CAP_IMP_pH					*(0.0093)	+
					IMP_STARS					*(0.1152)	+
					LabelAppeal					*(0.2959)   +
					VolatileAcidity				*(-0.0131)	
					;
					
P_GENMOD_HURDLE = exp(P_GENMOD_HURDLE);

P_HURDLE = P_LOGIT_PROB * (P_GENMOD_HURDLE+1);

KEEP INDEX;
KEEP P_HURDLE;

run;

proc print data=HURDLESCORE(obs=5);
run;

proc means data=HURDLESCORE n nmiss;
run; quit;

libname scrlib "/home/taylorvender20180/my_courses/PRED411/UNIT03";

data scrlib.VENDERwinesales_HURDLESCORE;
set HURDLESCORE;
run;

proc export data=scrlib.VENDERwinesales_HURDLESCORE DBMS=csv outfile='/home/taylorvender20180/my_courses/PRED411/UNIT03/scrlib.VENDERwinesales_HURDLESCORE.csv' replace;
run;

*zip scorecode;
data ZIPSCORE;
set &LIB.wine_test;

TARGET_FLAG = ( TARGET > 0 );
TARGET_AMT = TARGET - 1;
if TARGET_FLAG = 0 then TARGET_AMT = .;

IMP_STARS				= STARS;
IMP_Density				= Density;
IMP_Sulphates			= Sulphates;
IMP_pH					= pH;
IMP_Alcohol				= Alcohol;
IMP_TotalSulfurDioxide	= TotalSulfurDioxide;
IMP_FreeSulfurDioxide	= FreeSulfurDioxide;
IMP_Chlorides			= Chlorides;
IMP_ResidualSugar		= ResidualSugar;


*Next try IMP_STARS=0 and not even have a flag;
if missing(STARS) 				then IMP_STARS				= 0;
if missing(Density)				then IMP_Density 			= 0.9944900;
if missing(Sulphates)			then IMP_Sulphates			= 0.5000000;
if missing(pH)					then IMP_pH					= 3.2000000;
if missing(Alcohol)				then IMP_Alcohol			= 10.4000000;
if missing(FreeSulfurDioxide)	then IMP_FreeSulfurDioxide	= 30.0000000;
if missing(Chlorides)			then IMP_Chlorides			= 0.0460000;
if missing(ResidualSugar)		then IMP_ResidualSugar		= 3.9000000;

if missing (TotalSulfurDioxide) then do;
	IMP_TotalSulfurDioxide = 122;
	if IMP_ResidualSugar < 5.8 then IMP_TotalSulfurDioxide = 109;
	if IMP_ResidualSugar >= 5.8 then IMP_TotalSulfurDioxide = 136;
end;


DROP	 STARS
		 Density
		 Sulphates
		 pH
		 Alcohol
		 TotalSulfurDioxide
		 FreeSulfurDioxide
		 Chlorides
		 ResidualSugar
		 ;

CAP_FixedAcidity = FixedAcidity;
if FixedAcidity >= 2.590 then CAP_FixedAcidity = 2.590;
if FixedAcidity <= -1.865 then CAP_FixedAcidity = -1.865;

CAP_CitricAcid = CitricAcid;
if CitricAcid >= 2.66 then CAP_CitricAcid = 2.66;
if CitricAcid <= -2.18 then CAP_CitricAcid = -2.18;

CAP_IMP_Density = IMP_Density;
if IMP_Density >= 1.06981 then CAP_IMP_Density = 1.06981;
if IMP_Density <= 0.91680 then CAP_IMP_Density = 0.91680;

CAP_IMP_Sulphates = IMP_Sulphates;
if IMP_Sulphates >= 3.09 then CAP_IMP_Sulphates = 3.09;
if IMP_Sulphates <= -2.08 then CAP_IMP_Sulphates = -2.08;

CAP_IMP_pH = IMP_pH;
if IMP_pH >= 5.12 then CAP_IMP_pH = 5.12;
if IMP_pH <= 1.33 then CAP_IMP_pH = 1.33;

CAP_IMP_Alcohol = IMP_Alcohol;
if IMP_Alcohol >= 20.2 then CAP_IMP_Alcohol = 20.2;
if IMP_Alcohol <= 0.2 then CAP_IMP_Alcohol = 0.2;

CAP_IMP_TotalSulfurDioxide = IMP_TotalSulfurDioxide;
if IMP_TotalSulfurDioxide >= 746 then CAP_IMP_TotalSulfurDioxide = 746;
if IMP_TotalSulfurDioxide <= -516 then CAP_IMP_TotalSulfurDioxide = -516;

CAP_IMP_FreeSulfurDioxide = IMP_FreeSulfurDioxide;
if IMP_FreeSulfurDioxide >= 464 then CAP_IMP_FreeSulfurDioxide = 464;
if IMP_FreeSulfurDioxide <= -382 then CAP_IMP_FreeSulfurDioxide = -382;

CAP_IMP_Chlorides = IMP_Chlorides;
if IMP_Chlorides >= 0.952 then CAP_IMP_Chlorides = 0.952;
if IMP_Chlorides <= -0.848 then CAP_IMP_Chlorides = -0.848;

CAP_IMP_ResidualSugar = IMP_ResidualSugar;
if IMP_ResidualSugar >= 97.10 then CAP_IMP_ResidualSugar = 97.10;
if IMP_ResidualSugar <= -89.60 then CAP_IMP_ResidualSugar = -89.60;

DROP	 FixedAcidity
		 CitricAcid
		 IMP_Density
		 IMP_Sulphates
		 IMP_pH
		 IMP_Alcohol
		 IMP_TotalSulfurDioxide
		 IMP_FreeSulfurDioxide
		 IMP_Chlorides	
		 IMP_ResidualSugar
		 ;
P_GENMOD_PZERO_ZIP	=	-4.0264									+
						AcidIndex					*(0.4347)   +
						CAP_IMP_Alcohol				*(0.0296)   +
						CAP_IMP_FreeSulfurDioxide	*(-0.0008)  +
						CAP_IMP_Sulphates			*(0.1391)	+
						CAP_IMP_TotalSulfurDioxide	*(-0.0010)  +
						CAP_IMP_pH					*(0.2312)	+
						IMP_STARS					*(-2.3788)	+
						LabelAppeal					*(0.7235)   +
						VolatileAcidity				*(0.1935)	
						;

if P_GENMOD_PZERO_ZIP > 1000 then P_GENMOD_PZERO_ZIP = 1000;
if P_GENMOD_PZERO_ZIP < -1000 then P_GENMOD_PZERO_ZIP = -1000;
P_GENMOD_PZERO_ZIP = exp(P_GENMOD_PZERO_ZIP) / (1+exp(P_GENMOD_PZERO_ZIP));

P_GENMOD_ZIP	=	1.1601 									+
					AcidIndex					*(-0.0187)  +
					CAP_IMP_Alcohol				*(0.0073)   +
					CAP_IMP_FreeSulfurDioxide	*(0.0000)   +
					CAP_IMP_Sulphates			*(0.0004)	+
					CAP_IMP_TotalSulfurDioxide	*(-0.0000)  +
					CAP_IMP_pH					*(0.0055)	+
					IMP_STARS					*(0.1010)	+
					LabelAppeal					*(0.2328)   +
					VolatileAcidity				*(-0.0122)	
					;
					
P_GENMOD_ZIP = exp(P_GENMOD_ZIP);
P_GENMOD_ZIP = P_GENMOD_ZIP*(1-P_GENMOD_PZERO_ZIP);

KEEP INDEX;
KEEP P_GENMOD_ZIP;

run;

proc print data=ZIPSCORE(obs=5);
run;

proc means data=ZIPSCORE n nmiss;
run; quit;

libname scrlib "/home/taylorvender20180/my_courses/PRED411/UNIT03";

data scrlib.VENDERwinesales_ZIPSCORE;
set ZIPSCORE;
run;

proc export data=scrlib.VENDERwinesales_ZIPSCORE DBMS=csv outfile='/home/taylorvender20180/my_courses/PRED411/UNIT03/scrlib.VENDERwinesales_ZIPSCORE.csv' replace;
run;

*zinb scorecode;
data ZINBSCORE;
set &LIB.wine_test;

TARGET_FLAG = ( TARGET > 0 );
TARGET_AMT = TARGET - 1;
if TARGET_FLAG = 0 then TARGET_AMT = .;

IMP_STARS				= STARS;
IMP_Density				= Density;
IMP_Sulphates			= Sulphates;
IMP_pH					= pH;
IMP_Alcohol				= Alcohol;
IMP_TotalSulfurDioxide	= TotalSulfurDioxide;
IMP_FreeSulfurDioxide	= FreeSulfurDioxide;
IMP_Chlorides			= Chlorides;
IMP_ResidualSugar		= ResidualSugar;


*Next try IMP_STARS=0 and not even have a flag;
if missing(STARS) 				then IMP_STARS				= 0;
if missing(Density)				then IMP_Density 			= 0.9944900;
if missing(Sulphates)			then IMP_Sulphates			= 0.5000000;
if missing(pH)					then IMP_pH					= 3.2000000;
if missing(Alcohol)				then IMP_Alcohol			= 10.4000000;
if missing(FreeSulfurDioxide)	then IMP_FreeSulfurDioxide	= 30.0000000;
if missing(Chlorides)			then IMP_Chlorides			= 0.0460000;
if missing(ResidualSugar)		then IMP_ResidualSugar		= 3.9000000;

if missing (TotalSulfurDioxide) then do;
	IMP_TotalSulfurDioxide = 122;
	if IMP_ResidualSugar < 5.8 then IMP_TotalSulfurDioxide = 109;
	if IMP_ResidualSugar >= 5.8 then IMP_TotalSulfurDioxide = 136;
end;


DROP	 STARS
		 Density
		 Sulphates
		 pH
		 Alcohol
		 TotalSulfurDioxide
		 FreeSulfurDioxide
		 Chlorides
		 ResidualSugar
		 ;

CAP_FixedAcidity = FixedAcidity;
if FixedAcidity >= 2.590 then CAP_FixedAcidity = 2.590;
if FixedAcidity <= -1.865 then CAP_FixedAcidity = -1.865;

CAP_CitricAcid = CitricAcid;
if CitricAcid >= 2.66 then CAP_CitricAcid = 2.66;
if CitricAcid <= -2.18 then CAP_CitricAcid = -2.18;

CAP_IMP_Density = IMP_Density;
if IMP_Density >= 1.06981 then CAP_IMP_Density = 1.06981;
if IMP_Density <= 0.91680 then CAP_IMP_Density = 0.91680;

CAP_IMP_Sulphates = IMP_Sulphates;
if IMP_Sulphates >= 3.09 then CAP_IMP_Sulphates = 3.09;
if IMP_Sulphates <= -2.08 then CAP_IMP_Sulphates = -2.08;

CAP_IMP_pH = IMP_pH;
if IMP_pH >= 5.12 then CAP_IMP_pH = 5.12;
if IMP_pH <= 1.33 then CAP_IMP_pH = 1.33;

CAP_IMP_Alcohol = IMP_Alcohol;
if IMP_Alcohol >= 20.2 then CAP_IMP_Alcohol = 20.2;
if IMP_Alcohol <= 0.2 then CAP_IMP_Alcohol = 0.2;

CAP_IMP_TotalSulfurDioxide = IMP_TotalSulfurDioxide;
if IMP_TotalSulfurDioxide >= 746 then CAP_IMP_TotalSulfurDioxide = 746;
if IMP_TotalSulfurDioxide <= -516 then CAP_IMP_TotalSulfurDioxide = -516;

CAP_IMP_FreeSulfurDioxide = IMP_FreeSulfurDioxide;
if IMP_FreeSulfurDioxide >= 464 then CAP_IMP_FreeSulfurDioxide = 464;
if IMP_FreeSulfurDioxide <= -382 then CAP_IMP_FreeSulfurDioxide = -382;

CAP_IMP_Chlorides = IMP_Chlorides;
if IMP_Chlorides >= 0.952 then CAP_IMP_Chlorides = 0.952;
if IMP_Chlorides <= -0.848 then CAP_IMP_Chlorides = -0.848;

CAP_IMP_ResidualSugar = IMP_ResidualSugar;
if IMP_ResidualSugar >= 97.10 then CAP_IMP_ResidualSugar = 97.10;
if IMP_ResidualSugar <= -89.60 then CAP_IMP_ResidualSugar = -89.60;

DROP	 FixedAcidity
		 CitricAcid
		 IMP_Density
		 IMP_Sulphates
		 IMP_pH
		 IMP_Alcohol
		 IMP_TotalSulfurDioxide
		 IMP_FreeSulfurDioxide
		 IMP_Chlorides	
		 IMP_ResidualSugar
		 ;
		 
P_GENMOD_PZERO_ZINB	=	-3.9034									+
						AcidIndex					*(0.4207)   +
						CAP_IMP_Alcohol				*(0.0288)   +
						CAP_IMP_Sulphates			*(0.1338)	+
						CAP_IMP_TotalSulfurDioxide	*(-0.0010)  +
						CAP_IMP_pH					*(0.2159)	+
						IMP_STARS					*(-2.2174)	+
						LabelAppeal					*(0.6868)   +
						VolatileAcidity				*(0.1862)	
						;
if P_GENMOD_PZERO_ZINB > 1000 then P_GENMOD_PZERO_ZINB = 1000;
if P_GENMOD_PZERO_ZINB < -1000 then P_GENMOD_PZERO_ZINB = -1000;
P_GENMOD_PZERO_ZINB = exp(P_GENMOD_PZERO_ZINB) / (1+exp(P_GENMOD_PZERO_ZINB));

P_GENMOD_ZINB	=	1.1630 									+
					AcidIndex					*(-0.0185)  +
					CAP_IMP_Alcohol				*(0.0072)   +
					CAP_IMP_Sulphates			*(0.0006)	+
					CAP_IMP_TotalSulfurDioxide	*(-0.0000)  +
					CAP_IMP_pH					*(0.0055)	+
					IMP_STARS					*(0.1002)	+
					LabelAppeal					*(0.2323)   +
					VolatileAcidity				*(-0.0121)	
					;
					
P_GENMOD_ZINB = exp(P_GENMOD_ZINB);
P_GENMOD_ZINB = P_GENMOD_ZINB*(1-P_GENMOD_PZERO_ZINB);

KEEP INDEX;
KEEP P_GENMOD_ZINB;

run;

proc print data=ZINBSCORE(obs=5);
run;

proc means data=ZINBSCORE n nmiss;
run; quit;

libname scrlib "/home/taylorvender20180/my_courses/PRED411/UNIT03";

data scrlib.VENDERwinesales_ZINBSCORE;
set ZINBSCORE;
run;

proc export data=scrlib.VENDERwinesales_ZINBSCORE DBMS=csv outfile='/home/taylorvender20180/my_courses/PRED411/UNIT03/scrlib.VENDERwinesales_ZINBSCORE.csv' replace;
run;
