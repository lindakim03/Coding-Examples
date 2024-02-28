*****************************************;
*  Calculating BMI for Children in CO   *; 
*    *** See step 2 for SQL code ***    *;
*****************************************;

*1. Import data in SAS using infile;

Data Raw1;
	Infile '/home/u57923289/sasuser.v94/raw1.csv' 
		dlm="," firstobs=2;
	Input patno: 6. birth: MMDDYY10. 
		height:4.2 weight: 4.2 state: $2. visit:MMDDYY10.;
	Format birth MMDDYY10.
		   visit MMDDYY10.;
	Informat birth MMDDYY10.
		     visit MMDDYY10.;
run;

Data Raw2;
	Infile '/home/u57923289/sasuser.v94/raw2.csv' 
		dlm="," firstobs=2;
	Input patno: 6. sex: $1. birth;
	Format birth MMDDYY10.;
	Informat birth MMDDYY10.;
run;

*2. Merge using Proc SQL;

Proc Sql;
	Create Table EHR as 
	Select a.patno as patno, b.patno as ID, a.birth as 
		birth, height, weight, state, visit, sex 
	From Raw1 as a full join Raw2 on b
	on a.patno = b.patno;
quit;

proc means data=EHR;
	var height weight;
run;

*3. Cleaning and Selecting Data;
**Select CO and create AGE, AGEMOS, SEX ;

Data EHR1;
	set EHR (drop=ID);
	where state="CO";
	agemos=Round(Yrdif(birth, visit, 'AGE')*12, .01);
	age=Int(Yrdif(birth, visit, 'AGE'));
	if sex="M" then
		sex=1;
	else if sex="F" then
		sex=2;
   new = input(sex, 1.);
   drop sex;
   rename new=sex;
	
run;

**Select ages 2-19 & Dataset with non-missing sex, height, and weight;

Data EHR2;
	set EHR1;
	where age between 2 and 19;
	where sex >0;
	where height>0;
	where  weight>0;
run;

proc contents data=ehr3;
run;

*Check numeric values for extreme values;

proc means data=ehr3 n nmiss min max maxdec=3;
	var height weight;
run;


*Save as mydata per CDC instructions;

data mydata;
	set EHR3;
run;

*step 4 and 5: %include;
%include '/home/u57923289/sasuser.v94/cdc-source-code.sas';
run;
*step 6;

proc means data=_cdcdata;
run;

*Dataset _cdcdata has BMI calculations;

proc contents data=_cdcdata;
run;


