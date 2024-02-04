FILENAME Happy19 '/folders/myfolders/ProjetSAS/2019.csv';

FILENAME Happy18 '/folders/myfolders/ProjetSAS/2018.csv';

FILENAME Happy17 '/folders/myfolders/ProjetSAS/2017.csv';

FILENAME Happy16 '/folders/myfolders/ProjetSAS/2016.csv';

FILENAME Happy15 '/folders/myfolders/ProjetSAS/2015.csv';

LIBNAME projet '/folders/myfolders';


PROC IMPORT DATAFILE=Happy19
    DBMS=CSV
    OUT=projet.happy2019;
    GETNAMES=YES;
RUN;

PROC IMPORT DATAFILE=Happy18
    DBMS=CSV
    OUT=projet.happy2018;
    GETNAMES=YES;
RUN;

PROC IMPORT DATAFILE=Happy17
    DBMS=CSV
    OUT=projet.happy2017;
    GETNAMES=YES;
RUN;

PROC IMPORT DATAFILE=Happy16
    DBMS=CSV
    OUT=projet.happy2016;
    GETNAMES=YES;
RUN;

PROC IMPORT DATAFILE=Happy15
    DBMS=CSV
    OUT=projet.happy2015;
    GETNAMES=YES;
RUN;

/* exploration des données */ 

/* statistiques descriptives */

ods noproctitle;
ods graphics / imagemap=on;

proc means data=PROJET.HAPPY2019 chartype mean std min max n vardef=df;
	var Overall_rank Score GDP_per_capita Social_support Healthy_life_expectancy 
		Freedom_to_make_life_choices Generosity Perceptions_of_corruption;
run;



/* Corrélation entre les données */

options validvarname=any;
ods noproctitle;
ods graphics / imagemap=on;

/* Macro de matrice du nuage de points */
%macro scatterPlotMatrix(xVars=, title=, groupVar=);
	proc sgscatter data=PROJET.HAPPY2019;
		matrix &xVars / %if(&groupVar ne %str()) %then
			%do;
				group=&groupVar legend=(sortorder=ascending) %end;
		;
		title &title;
	run;

	title;
%mend scatterPlotMatrix;

%scatterPlotMatrix(xVars=GDP_per_capita Social_support Healthy_life_expectancy 
	Freedom_to_make_life_choices Generosity Perceptions_of_corruption, 
	title="Matrice du nuage de points groupés par Country_or_region", 
	groupVar=Country_or_region);
	
/* Nous constatons que Le PIB et l'espérance de vie et le support social sont fortement corrélés */


/*Realisation de l'ACP*/

ods noproctitle;
ods graphics / imagemap=on;

proc princomp data=PROJET.HAPPY2019 OUT= B outstat=C  plots(only)=(scree);
	var Overall_rank GDP_per_capita Social_support Healthy_life_expectancy 
		Freedom_to_make_life_choices Generosity Perceptions_of_corruption;
run;

/* En se basant sur la matrice de corrélation , les variables qui influent le plus le score sont :
Le PIB , l'espérence de vie , le support social et la liberté */ 


/* Top 10 des pays  avec une forte générosité */

proc sql number outobs=10;
create table bestCountry as
select * from projet.happy2019 order by generosity descending;
quit;

/* Top 10 des pays avec une faible générosité */
proc sql number outobs=10;
create table WorstCountry as
select * from projet.happy2019 order by generosity ascending;
quit;

/* On remarque que les pays avec une générosrité élevée n'ont pas forcément un bon niveau de bohneur donc 
le taux de générosité n'a pas une influence significative pour sur le niveau de bonheur  */


/* Top 10 des pays avec une forte économie  */
proc sql number outobs=10;
create table bestCountry as
select * from projet.happy2019 order by gdp_per_capita descending;
quit;

/* Top 10 des pays avec une faible  économie  */
proc sql number outobs=10;
create table WorstCountry as
select * from projet.happy2019 order by gdp_per_capita ascending;
quit;

/*On remarque que la majeure partie des pays du classement par PIB sont des pays avec un bon niveau de bonheur .
Donc l'économie fait partie des facteurs déterminant le niveau de bonheur d'un pays donné*/



/* Top 10 des pays avec plus de liberté */

proc sql number outobs=10;
create table bestCountry as
select * from projet.happy2019 order by freedom_to_make_life_choices descending;
quit;
/* Top 10 des pays avec moins de liberté */
proc sql number outobs=10;
create table WorstCountry as
select * from projet.happy2019 order by freedom_to_make_life_choices ascending;
quit;

/*La liberté des personnes dans un pays a également une influence très signifiactive sur le niveau de bonheur.
Nous constatons que la majorité des pays avec une grande liberté sont des pays avec un bon niveau de bonheur */

/* Top 10 des pays avec un fort support social*/

proc sql number outobs=10;
create table bestCountry as
select * from projet.happy2019 order by social_support  descending;
quit;
/* Top 10 des pays avec un faible support social */
proc sql number outobs=10;
create table WorstCountry as
select * from projet.happy2019 order by social_support  ascending;
quit;

/*La support social dans un pays a également une influence très signifiactive sur le niveau de bonheur.
Nous constatons que la majorité des pays avec un fort support social sont des pays avec un bon niveau de bonheur */


/* évolution du score de bonheur au cours des années (2015 à 2019)*/
/*_______________________________________________________________*/


proc sql;
create table Score_2015_a_2019 as
select H2015.country ,H2015.happiness_Score as score2015 , H2016.happiness_Score as score2016,H2017.happiness_Score as score2017,
H2018.Score as score2018,H2019.Score as score2019,
 (H2016.happiness_Score - H2015.happiness_Score) as Score2016_2015,
 (H2017.happiness_Score - H2016.happiness_Score) as Score2017_2016,
 (H2018.Score - H2017.happiness_Score) as Score2018_2017,
 (H2019.Score - H2018.Score) as Score2019_2018
from projet.happy2015 H2015
left join
     projet.happy2016 H2016
on H2015.country = H2016.country
left join
     projet.happy2017 H2017
on H2016.country = H2017.country
left join
     projet.happy2018 H2018
on H2017.country = H2018.country_or_region
left join
     projet.happy2019 H2019
on H2018.country_or_region = H2019.country_or_region;
quit;

proc sql;
create table Evolution_Score_2015_a_2019 as
select S.country /*, S.Score2016_2015,S.Score2017_2016,S.Score2018_2017,S.Score2019_2018,*/,
(case when  S.Score2016_2015 >0 then "Augmentation" else "Baisse" end)as Evolution2015_2016,
(case when  S.Score2017_2016 >0 then "Augmentation" else "Baisse" end)as Evolution2016_2017,
(case when  S.Score2018_2017 >0 then "Augmentation" else "Baisse" end)as Evolution2017_2018,
(case when  S.Score2019_2018 >0 then "Augmentation" else "Baisse" end)as Evolution2018_2019
from Score_2015_a_2019 S;
quit;



/*_______________________________________________________________*/

/* évolution du score de bonheur au cours des années en observant le comportement des variables significatives*/

/*2015-2016*/
proc sql;
create table Score_2015_a_2019 as
select H2015.country, H2015.happiness_Score as score2015 , H2015.Economy__GDP_per_Capita_ as PIB2015, H2015.Family as Family15, H2015.Health__life_Expectancy_ as health15,
 H2016.happiness_Score as score2016, H2016.Economy__GDP_per_Capita_ as PIB2016, H2016.Family as Family16, H2016.Health__life_Expectancy_ as health16,
 H2017.happiness_Score as score2017,H2017.Economy__GDP_per_Capita_ as PIB2017, H2017.Family as Family17, H2017.Health__life_Expectancy_ as health17,
 H2018.Score as score2018, H2018.gdp_per_capita as PIB2018, H2018.social_support as Family18, H2018.Healthy_life_Expectancy as health18, H2018.Freedom_to_make_life_choices as Freedom18,
 H2019.Score as score2019, H2019.gdp_per_capita as PIB2019, H2019.social_support as Family19, H2019.Healthy_life_Expectancy as health19,H2019.Freedom_to_make_life_choices as Freedom19,

 (H2016.happiness_Score - H2015.happiness_Score) as Score2016_2015, (PIB2016 - PIB2015) as PIB2016_2015,
 (Family16 - Family15) as Family2016_2015,(health16 - health15) as health2016_2015,
 
 (H2017.happiness_Score - H2016.happiness_Score) as Score2017_2016,(PIB2017 - PIB2016) as PIB2017_2016,
 (Family17 - Family16) as Family2017_2016,(health17 - health17) as health2017_2016,
 
 (H2018.Score - H2017.happiness_Score) as Score2018_2017,(PIB2018 - PIB2017) as PIB2018_2017,
 (Family18 - Family17) as Family2018_2017,(health18 - health17) as health2018_2017,
 
 (H2019.Score - H2018.Score) as Score2019_2018,(PIB2019 - PIB2018) as PIB2019_2018,
 (Family19 - Family18) as Family2019_2018,(health19 - health18) as health2019_2018, (Freedom19 - Freedom18) as Freedom2019_2018
 
 
from projet.happy2015 H2015
left join
     projet.happy2016 H2016
on H2015.country = H2016.country
left join
     projet.happy2017 H2017
on H2016.country = H2017.country
left join
     projet.happy2018 H2018
on H2017.country = H2018.country_or_region
left join
     projet.happy2019 H2019
on H2018.country_or_region = H2019.country_or_region;
quit;

proc sql;
create table Evolution_Score_2015_a_2019 as
select S.country /*, S.Score2016_2015,S.Score2017_2016,S.Score2018_2017,S.Score2019_2018,*/,
(case when  S.Score2016_2015 >0 then "Augmentation" else "Baisse" end)as Evolution2015_2016,
(case when  S.PIB2016_2015 >0 then "Augmentation" else "Baisse" end)as PIB2015_2016,
(case when  S.Family2016_2015 >0 then "Augmentation" else "Baisse" end)as Family2015_2016,
(case when  S.Health2016_2015 >0 then "Augmentation" else "Baisse" end)as Health2015_2016,


(case when  S.Score2017_2016 >0 then "Augmentation" else "Baisse" end)as Evolution2016_2017,
(case when  S.PIB2017_2016 >0 then "Augmentation" else "Baisse" end)as PIB2016_2017,
(case when  S.Family2017_2016 >0 then "Augmentation" else "Baisse" end)as Family2016_2017,
(case when  S.Health2017_2016 >0 then "Augmentation" else "Baisse" end)as Health2016_2017,

(case when  S.Score2018_2017 >0 then "Augmentation" else "Baisse" end)as Evolution2017_2018,
(case when  S.PIB2018_2017 >0 then "Augmentation" else "Baisse" end)as PIB2017_2018,
(case when  S.Family2018_2017 >0 then "Augmentation" else "Baisse" end)as Family2017_2018,
(case when  S.Health2018_2017 >0 then "Augmentation" else "Baisse" end)as Health2017_2018,

(case when  S.Score2019_2018 >0 then "Augmentation" else "Baisse" end)as Evolution2018_2019,
(case when  S.PIB2019_2018 >0 then "Augmentation" else "Baisse" end)as PIB2018_2019,
(case when  S.Family2019_2018 >0 then "Augmentation" else "Baisse" end)as Family2018_2019,
(case when  S.Health2019_2018 >0 then "Augmentation" else "Baisse" end)as Health2018_2019,
(case when  S.Freedom2019_2018 >0 then "Augmentation" else "Baisse" end)as Freedom2018_2019
from Score_2015_a_2019 S;
quit;


/* regression multiple */

ods noproctitle;
ods graphics / imagemap=on;

proc reg data=projet.HAPPY2019 alpha=0.05 plots(only)=(diagnostics residuals 
        observedbypredicted);
    model Score=GDP_per_capita Social_support Healthy_life_expectancy 
        Freedom_to_make_life_choices Generosity Perceptions_of_corruption /;
    run;
quit;

/*Suppression des variables Generosity Perceptions_of_corruption pour ajuster notre modèle  */

ods noproctitle;
ods graphics / imagemap=on;

proc reg data=projet.HAPPY2019 alpha=0.05 plots(only)=(diagnostics residuals 
        observedbypredicted);
    model Score=GDP_per_capita Social_support Healthy_life_expectancy 
        Freedom_to_make_life_choices /;
    run;
quit;


/*régression avec croisement des variables */

ods noproctitle;
ods graphics / imagemap=on;

proc glmselect data=PROJET.HAPPY2019 outdesign(addinputvars)=Work.reg_design;
	model Score=GDP_per_capita Social_support Healthy_life_expectancy 
		Freedom_to_make_life_choices GDP_per_capita*Social_support 
		GDP_per_capita*Healthy_life_expectancy 
		GDP_per_capita*Freedom_to_make_life_choices 
		Social_support*Healthy_life_expectancy 
		Social_support*Freedom_to_make_life_choices 
		Healthy_life_expectancy*Freedom_to_make_life_choices / showpvalues 
		selection=none;
run;

proc reg data=Work.reg_design alpha=0.05 plots(only)=(diagnostics residuals 
		observedbypredicted);
	ods select DiagnosticsPanel ResidualPlot ObservedByPredicted;
	model Score=&_GLSMOD /;
	run;
quit;

proc delete data=Work.reg_design;
run;

/*seul le croisement entre social_support et healthy_life_expentancy a un impact significatif sur le niveau de bonheur*/
