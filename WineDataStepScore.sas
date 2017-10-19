%let PATH 	= /home/taylorvender20180/my_courses/donald.wedding/c_8888/PRED411/UNIT03/HW;
%let NAME 	= P411;
%let LIB	= &NAME..;

libname &NAME. "&PATH.";

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
P_TARGET = P_GENMOD_ZIP*(1-P_GENMOD_PZERO_ZIP);

KEEP INDEX;
KEEP P_TARGET;

run;

proc print data=ZIPSCORE(obs=5);
run;

proc means data=ZIPSCORE n nmiss;
run; quit;

libname scrlib "/home/taylorvender20180/my_courses/PRED411/UNIT03";

data scrlib.VENDERwinesales_SCOREFILE;
set ZIPSCORE;
run;

proc export data=scrlib.VENDERwinesales_SCOREFILE DBMS=csv outfile='/home/taylorvender20180/my_courses/PRED411/UNIT03/scrlib.VENDERwinesales_SCOREFILE.csv' replace;
run;