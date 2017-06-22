$title A Stochastic Multi-Market Electricity Model for the European Electricity Market (stELMOD)
$ontext
+ DESCRIPTION +
stELMOD is a stochastic optimization model to analyze the impact of uncertain wind generation
on the dayahead and intraday electricity markets as well as network congestion management.
The consecutive clearing of the electricity markets is incorporated by
a rolling planning procedure resembling the market process of most European markets.

The model is documented in:
Abrell, J. and Kunz, F. (2015):
Integrating Intermittent Renewable Wind Generation - A Stochastic Multi-Market
Electricity Model for the European Electricity Market
Networks and Spatial Economics 15(1), pp. 117-147.
http://link.springer.com/article/10.1007/s11067-014-9272-4


+ VERSION +
Version 1.0.0, March 2016


+ LICENSE +
This work is licensed under the MIT License (MIT).

The MIT License (MIT)
Copyright (c) 2016 Friedrich Kunz (DIW Berlin) and Jan Abrell (ETH Zurich)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software
and associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute,
sublicense, and/or sell copies of the Software, and to permit persons to whom the Software
is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE
AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


+ CITATION +
Whenever you use this code, please refer to
Abrell, J. and Kunz, F. (2015):
Integrating Intermittent Renewable Wind Generation - A Stochastic Multi-Market
Electricity Model for the European Electricity Market
Networks and Spatial Economics 15(1), pp. 117-147.
http://link.springer.com/article/10.1007/s11067-014-9272-4


+ CONTACT +
Friedrich Kunz, DIW Berlin, fkunz@diw.de, phone: +49(0)30 89789 495

$offtext

$eolcom //

*###############################################################################
*                        SET OPTIONS AND DATA FILES
*###############################################################################

*##### DEFINE INPUT ############################################################
* datadir        input data folder
* data           input data file (type: xls)
* ptdf           input ptdf file (type: gdx)
* ptdf_par       naming of ptdf parameter in %ptdf%.gdx
* renewable      DISABLED - stoachstic renewable input file (type: gdx)
* xls_upload     activate xls upload, if no a gdx-file is requried (options: YES, NO)

$setglobal datadir data/
$setglobal data data_DE
$setglobal ptdf ptdf
$setglobal ptdf_par PTDF
*$setglobal renewable renewable //DISABLED
$setglobal xls_upload YES

*##### DEFINE OUTPUT ###########################################################
* resultdir      output data folder
* result         output result file (type: gdx)

$setglobal resultdir results\
$setglobal result results

*##### DEFINE MODEL STRUCTURE ##################################################
* case           type of optimization (options: 1,2,3,4)
*                        1 - deterministic
*                        2 - changingforecast_mean
*                        3 - changingforecast_mostlikely
*                        4 - stochastic
* solve_id       solve intraday during rolling planning (options: YES, NO)
* solve_cm       solve congestion management during rolling planning (options: YES, NO)
* only_reporting do only reporting, no model solve (options: YES, NO)

$setglobal case 1
$setglobal solve_id YES
$setglobal solve_cm YES
$setglobal only_reporting NO

*##### DEFINE MODEL TIMING #####################################################
* start_h        DISABLED - begin of rolling planning horizon (type: integer)
* end_h          end of rolling planning (type: integer)
* t_da           dayahead model horizon (type: integer, default 36)
* t_id           intraday model horizon (type: integer, default 36)
* t_cm           congestion management model horizon (type: integer, default 1)
* lag_id         DISABLED - time lag of intraday (type: integer, default 1)
* clr_da         DISABLED - daily hour of dayahead market clearing (type: integer, default 12)

*$setglobal start_h 1 //DISABLED
$setglobal end_h 9000
$setglobal t_da 36
$setglobal t_id 36
$setglobal t_cm 1
*$setglobal lag_id 1 //DISABLED
*$setglobal clr_da 12 //DISABLED

*##### DEFINE MODEL INPUT PARAMETER ############################################
* threads        define number of threads for solver (options: -1,0,1,2,3,4)
* scaler         scaling parameter for objective value (type: integer)
* penalty        penalty or VoLL for load shedding (type: integer)
* uc_region      region with unit commitment, other regions with clustered unit commitment
*                (options: set of countries delimited by comma, e.g. DE, AT)
*                NOTE: countries listed here should comply with country set "c"
* cluster_size   size of unit commitment cluster in MW
* trm            transmission reliability margin for congestion management (options: [0,1))
* PST            DISABLED - consider phase-shifting transformers in congestion management
*                (options: YES, NO)
*                NOTE: reguires the definition of a psdf matrix in %ptdf%.gdx

$setglobal threads 1
$setglobal scaler 1
$setglobal penalty 1000000
$setglobal uc_region DE,AT,LU
$setglobal cluster_size 100
$setglobal trm 0.8
*$setglobal PST NO //DISABLED

*###############################################################################
*                        SET DEFAULT OPTIONS
*###############################################################################
* Include the option file written by batch if exist
$if exist envvariables.txt $include envvariables.txt

* Set default data options
$if not setglobal datadir $setglobal datadir data\
$if not setglobal data $setglobal data Data
$if not setglobal renewable $setglobal renewable renewable
$if not setglobal ptdf $setglobal ptdf ptdf
$if not setglobal ptdf_par $setglobal ptdf_par ptdf
$if not setglobal xls_upload $setglobal xls_upload YES
$if not setglobal resultdir $set resultdir results\
$if not setglobal result $set result call

* Set other options
$if not setglobal start_h $setglobal start_h 1
$if not setglobal end_h $setglobal end_h 9000
$if not setglobal t_id $setglobal t_id 36
$if not setglobal t_da $setglobal t_da 36
$if not setglobal t_cm $setglobal t_cm 1
$if not setglobal lag_id $setglobal lag_id 1
$if not setglobal clr_da $setglobal clr_da 12
$if not setglobal penalty $setglobal penalty 1000000
$if not setglobal threads $setglobal threads 1
$if not setglobal case $setglobal case 1
$if not setglobal scaler $setglobal scaler 1000000
$if not setglobal trm $setglobal trm 0.8
$if not setglobal PST $setglobal PST NO

* define some options in particular for stochastic setting
$ife '%case%=1' $setglobal renewable renewable_det
$ife NOT '%case%=1' $setglobal renewable renewable

$setglobal set_sto_root
$setglobal set_sto_root2
$setglobal set_sto

$ife NOT '%case%=1' $setglobal set_sto_root ,root
$ife NOT '%case%=1' $setglobal set_sto_root2 root,
$ife NOT '%case%=1' $setglobal set_sto ,k

$maxgoto 100000
$setenv GDXCOMPRESS 1

* Check validity of data options
$if not exist %datadir%%data%.xls $abort "####### CAN NOT FIND DATA FILE #######"
*option profile = 3;
*$stop
*###############################################################################
*                                UPLOAD DATA
*###############################################################################
$onUNDF
$include dataload
$offUNDF

*##### Definition of input data adjustments for rolling planning

* disable unit commitment for small plants
sc(pl)$(cap_max(pl) lt 10) = 0;
su(pl)$(cap_max(pl) lt 10) = 0;
cap_min(pl)$(cap_max(pl) lt 10) = 0;
ontime(pl)$(cap_max(pl) lt 10) = 0;
offtime(pl)$(cap_max(pl) lt 10) = 0;

* disable network
*cap_l(l) = 0;
*cap_l(l) = 1.5*cap_l(l);
*cap_hvdc(n,nn) = 0;
*ntc(c,cc) = 0;


*##### Some model specifics are disabled in this model version due to various reasons
*(e.g. solution speed, no input data, or other issues)

* disable ramping
a_up(pl) = 0;
a_down(pl) = 0;

*disable offtime for unit commitment
offtime(pl) = 0;

* disable reserve procurement in dayahead
d_res(res,tau,c) = 0;

* disable chp
mrCHP_tau(tau,pl) = 0;

*$stop
*--------------------------------------------------------------------------------
*                        include stochastic
*--------------------------------------------------------------------------------
$IFTHEN NOT %case%==1
$include construct_tree
$ENDIF
*$stop

*file myput;
*put myput;

$IF %only_reporting%==YES $goto reporting
*###############################################################################
*                 DECLARE MODELS AND MODEL OPTIONS
*###############################################################################
FILE rename /"rename.bat"/;

*$include models
$include model_dayahead
$IFTHEN %case%==1
$include model_intraday_det
$include model_congestionmanagement_det
$ELSE
$include model_intraday_sto
$include model_congestionmanagement_sto
$ENDIF

* Write CLPEX option file
$onecho >cplex.opt
epint=0
threads=%threads%
parallelmode -1
$offecho

$ontext
lpmethod 4
startalg 4
subalg 4
$offtext

dayahead.solvelink = %Solvelink.LoadLibrary%;
dayahead.optfile = 1 ;
dayahead.iterlim  = 100000000;
dayahead.reslim  = 100000000;
dayahead.optcr = 0.01 ;
dayahead.holdfixed = 1 ;

intraday.solvelink = %Solvelink.LoadLibrary%;
intraday.optfile = 1 ;
intraday.iterlim  = 100000000;
intraday.reslim  = 100000000;
intraday.optcr = 0.01 ;
intraday.holdfixed = 1 ;

congestionmanagement.solvelink = %Solvelink.LoadLibrary%;
congestionmanagement.optfile = 1 ;
congestionmanagement.iterlim  = 100000000;
congestionmanagement.reslim  = 100000000;
congestionmanagement.optcr = 0.01 ;
congestionmanagement.holdfixed = 1 ;

option solprint=silent;
option limrow = 0, limcol=0;
option MIP=CPLEX;
option LP=CPLEX;

*###############################################################################
*                                ROLLING PLANNING
*###############################################################################
*$offlisting

********************************************************************************
*    ------------------------- INITALIZATION -----------------------------
********************************************************************************
* Set flag for first simulation period
taufirst = 1;

* prepare parameter and fix variables
$include prepare_da_init

* Run dayahead model
solve dayahead using MIP minimizing DA_COST;

* Write intermediate report for pre-determined variables
*ir_gen_da(pl,t)$(ord(t) le 24-lag_id) = DA_GEN.L(pl,t+lag_id);
ir_res_s(res,pl,t)$(ord(t) le 24-lag_id) = DA_RES_S.L(res,pl,t+lag_id);
ir_res_ns(pl,t)$(ord(t) le 24-lag_id) = DA_RES_NS.L(pl,t+lag_id);
ir_res_h(res,j,t)$(ord(t) le 24-lag_id) = DA_RES_H.L(res,j,t+lag_id);
ir_v_da(j,t)$(ord(t) le 24-lag_id) = DA_V.L(j,t+lag_id);
ir_w_da(j,t)$(ord(t) le 24-lag_id) = DA_W.L(j,t+lag_id);
*ir_level_da(j,t)$(ord(t) le 24-lag_id) = DA_L.L(j,t+lag_id);
ir_curt_da(r,n,t)$(ord(t) le 24-lag_id) = DA_WIND_CURT.L(r,n,t+lag_id);
ir_price_da(c,t)$(ord(t) le 24-lag_id) = DA_mkt.M(t+lag_id)*scaler + DA_mkt_country.M(c,t+lag_id)*scaler;
ir_transfer_da(c,cc,t)$(ord(t) le 24-lag_id) = DA_TRANSFER.L(c,cc,t+lag_id);

ir_gen_da(pl,t)$(ord(t) le 24-lag_id+1) = DA_GEN.L(pl,t);
ir_status_da(pl,t)$(ord(t) le 24-lag_id+1) = DA_ON.L(pl,t);
ir_level_da(j,t)$(ord(t) le 24-lag_id+1) = DA_L.L(j,t);

* Write final report
loop(tau$(ord(tau) le 24),
         loop(tt$(ord(tt) eq ord(tau)),
*                Generation, curtailment and reserve
                 fr_da_gen(pl,tau) = DA_GEN.L(pl,tt);
                 fr_da_w(j,tau) = DA_W.L(j,tt);
                 fr_da_v(j,tau) = DA_V.L(j,tt);
                 fr_da_l(j,tau) = DA_L.L(j,tt);
                 fr_da_ren(r,tau) = sum(n, DA_WIND_BID.L(r,n,tt));
                 fr_da_curt(r,tau) = sum(n, DA_WIND_CURT.L(r,n,tt));
                 fr_da_res_s(res,pl,tau) = DA_RES_S.L(res,pl,tt);
                 fr_da_res_ns(pl,tau) = DA_RES_NS.L(pl,tt);
                 fr_da_res_h(res,j,tau) = DA_RES_H.L(res,j,tt);

*                Prices
                 fr_da_price_gen(tau) = DA_mkt.M(tt)*scaler;
                 fr_da_price_res(res,tau) = (sum(c, DA_mkt_res.M(res,tt,c)*scaler*dem_res(res,tt,c))/sum(c, dem_res(res,tt,c)))$sum(c, dem_res(res,tt,c));

*                Infeasibility and cost
                 fr_da_infes(tau) = sum(n, DA_INFES_MKT.L(n,tt));
                 fr_da_cs(pl,tau) = DA_CS.L(pl,tt);
                 fr_da_cd(pl,tau) = DA_CD.L(pl,tt);
                 fr_da_status(pl,tau) =  DA_ON.L(pl,tt);
                 fr_da_frc(c,r,tau) = wind_fc(c,r,tt);

*                Country level reports
                 fr_da_price_country(c,tau) = DA_mkt_country.M(c,tt)*scaler;
                 fr_da_transfer(c,cc,tau) = DA_TRANSFER.L(c,cc,tt);
                 fr_da_price_ntc(c,cc,tau) = DA_res_ntc.M(c,cc,tt)*scaler;

*                Node level reports
                 fr_da_infes_node(n,tau) = DA_INFES_MKT.L(n,tt);
*                 fr_da_price_node(n,tau) = DA_mkt_node.M(n,tt)*scaler;
*                 fr_da_netin_node(n,tau) = DA_NETINPUT.L(n,tt);
*                 fr_da_lineflow(l,tau)   = sum(n, ptdf(l,n)*DA_NETINPUT.L(n,tt));
                 fr_da_curt_node(r,n,tau)  = DA_WIND_CURT.L(r,n,tt);
                 fr_da_ren_node(r,n,tau)   = DA_WIND_BID.L(r,n,tt);
                 fr_da_ren_fc_node(r,n,tau) = SUM(c$mapnc(n,c), SUM(ren, wind_fc(c,ren,tt)*splitren(n,ren)));
*                 fr_da_price_line_pos(l,tau) = DA_res_pmax_pos.M(l,tt)*scaler;
*                 fr_da_price_line_neg(l,tau) = DA_res_pmax_neg.M(l,tt)*scaler;
         );
);
fr_da_cost(tau)$(ord(tau) eq 1) = DA_COST.L*scaler;

EXECUTE_UNLOAD "%resultdir%dayahead.gdx" fr_da_gen, fr_da_w, fr_da_v, fr_da_l, fr_da_ren, fr_da_curt, fr_da_res_s, fr_da_res_s, fr_da_res_ns, fr_da_res_h,
                                         fr_da_price_gen, fr_da_price_res,
                                         fr_da_infes, fr_da_cs, fr_da_cd, fr_da_status, fr_da_frc,
                                         fr_da_price_country, fr_da_transfer, fr_da_price_ntc,
                                         fr_da_infes_node, fr_da_curt_node, fr_da_ren_node, fr_da_ren_fc_node,
*                                         fr_da_price_node, fr_da_netin_node, fr_da_lineflow, fr_da_price_line_pos, fr_da_price_line_neg,
                                         fr_da_cost;
PUTCLOSE rename, "move %resultdir%dayahead.gdx %resultdir%dayahead_t0001.gdx";
EXECUTE "rename.bat";

OPTION kill=fr_da_gen, kill=fr_da_w, kill=fr_da_v, kill=fr_da_l, kill=fr_da_ren, kill=fr_da_curt, kill=fr_da_res_s, kill=fr_da_res_s, kill=fr_da_res_ns, kill=fr_da_res_h,
       kill=fr_da_price_gen, kill=fr_da_price_res,
       kill=fr_da_infes, kill=fr_da_cs, kill=fr_da_cd, kill=fr_da_status, kill=fr_da_frc,
       kill=fr_da_price_country, kill=fr_da_transfer, kill=fr_da_price_ntc,
       kill=fr_da_infes_node, kill=fr_da_curt_node, kill=fr_da_ren_node, kill=fr_da_ren_fc_node,
*       kill=fr_da_price_node, kill=fr_da_netin_node, kill=fr_da_lineflow, kill=fr_da_price_line_pos, kill=fr_da_price_line_neg,
       kill=fr_da_cost;

*$stop
********************************************************************************
* ------------------------- ROLLING PLANNING LOOP -----------------------------
********************************************************************************
loop(tau$(ord(tau) lt (card(tau) - card(t)) and ord(tau) ge 1 and ord(tau) le
                 card(tau) and ord(tau) le %end_h%),

********************************************************************************
*    ------------------------- INTRADAY MODEL -----------------------------
********************************************************************************
*        Prepare data
$        include prepare_id

         solved_id("modelstats",tau) = 0;
         solved_id("solvestats",tau) = 0;
         solved_id("absolute gap",tau) = 0;
         solved_id("relative gap",tau) = 0;

$IF %solve_id%==NO $GOTO end_solve_id
*        Solve model
         solve intraday using MIP minimizing ID_COST;

*         ABORT$(intraday.modelstat > 2 and intraday.modelstat <> 8) "*** INTRADAY INFEASIBLE ***";

         solved_id("modelstats",tau) = intraday.modelstat;
         solved_id("solvestats",tau) = intraday.solvestat;
         solved_id("absolute gap",tau) = abs(intraday.objest - intraday.objval);
         solved_id("relative gap",tau) = solved_id("absolute gap",tau)/(1e-10+abs(intraday.objval));

$LABEL end_solve_id

*        Write intermediate reports for history variables
$IFTHEN %case%==1
         ir_status_id(pl,t)      = ID_ON.L(pl,t);
         ir_gen_id(pl,t)         = ID_GEN.L(pl,t);
         ir_level_id(j,t)        = ID_L.L(j,t);
         ir_v_id(j,t)            = ID_V.l(j,t);
         ir_w_id(j,t)            = ID_W.l(j,t);
         ir_curt_id(r,n,t)       = ID_WIND_CURT_ID.l(r,n,t);
         ir_infes_id(n,t)        = ID_INFES_MKT.l(n,t);
*         display  ir_level_id;
$ELSE
*        Expected values
         ir_status_id(pl,t)      = sum(mapkt(k,t), prob(t,k)*ID_ON.L(pl,t,k));
         ir_gen_id(pl,t)         = sum(mapkt(k,t), prob(t,k)*ID_GEN.L(pl,t,k));
         ir_level_id(j,t)        = sum(mapkt(k,t), prob(t,k)*ID_L.L(j,t,k));
*        Stochastic values
         ir_status_sto_id(pl,t,k)        = ID_ON.L(pl,t,k);
         ir_gen_sto_id(pl,t,k)           = ID_GEN.L(pl,t,k);
         ir_v_sto_id(j,t,k)              = ID_V.l(j,t,k);
         ir_w_sto_id(j,t,k)              = ID_W.l(j,t,k);
         ir_curt_sto_id(r,n,t,k)         = ID_WIND_CURT_ID.l(r,n,t,k);
         ir_infes_sto_id(n,t,k)          = ID_INFES_MKT.l(n,t,k);
*         display  ir_level_id;
$ENDIF

$IF %solve_id%==NO $GOTO end_id
*        Write final report variables to periods they belong to
         loop((tfirst%set_sto_root%),
*                Generation
                  fr_id_gen_to(pl,tau+lag_id) = ID_GEN.L(pl,tfirst%set_sto_root%);
                  fr_id_ren_to(r,tau+lag_id) = sum(n, ID_WIND_BID.L(r,n,tfirst%set_sto_root%));
                  fr_id_w_to(j,tau+lag_id) = ID_W.L(j,tfirst%set_sto_root%);
                  fr_id_v_to(j,tau+lag_id) = ID_V.L(j,tfirst%set_sto_root%);
                  fr_id_l(j,tau+lag_id) = ID_L.L(j,tfirst%set_sto_root%);

*                Intraday corrections
                  fr_id_gen_id(pl,tau+lag_id) = ID_GEN_ID.L(pl,tfirst%set_sto_root%);
                  fr_id_ren_id(r,tau+lag_id) = sum(n, ID_WIND_CURT_ID.L(r,n,tfirst%set_sto_root%));
                  fr_id_w_id(j,tau+lag_id) = ID_W_ID.L(j,tfirst%set_sto_root%);
                  fr_id_v_id(j,tau+lag_id) = ID_V_ID.L(j,tfirst%set_sto_root%);

*                status, infeasibilities, cost, price
                  fr_id_status(pl,tau+lag_id) = ID_ON.L(pl,tfirst%set_sto_root%);
                  fr_id_cs(pl,tau+lag_id) = ID_CS.L(pl,tfirst%set_sto_root%);
                  fr_id_cd(pl,tau+lag_id) = ID_CD.L(pl,tfirst%set_sto_root%);
                  fr_id_cost(tau+lag_id) = ID_COST.L*scaler;
                  fr_id_infes(tau+lag_id) = sum(n, ID_INFES_MKT.L(n,tfirst%set_sto_root%));
                  fr_id_price(tau+lag_id) = ID_mkt.M(%set_sto_root2%tfirst)*scaler;
$IFTHEN %case%==1
                  fr_id_frc(r,tau+lag_id) = sum((ren,c), wind_tmp(c,ren,tfirst));
$ELSE
                  fr_id_frc(r,tau+lag_id) = sum((ren,c), wind_sto_tmp(c,ren,tfirst%set_sto_root%));
$ENDIF
*                country level report
                  fr_id_price_country(c,tau+lag_id) = ID_mkt_country.M(c%set_sto_root%,tfirst)*scaler;
                  fr_id_transfer(c,cc,tau+lag_id) = ID_TRANSFER.L(c,cc,tfirst%set_sto_root%);
                  fr_id_price_ntc(c,cc,tau+lag_id) = ID_res_ntc.M(c,cc%set_sto_root%,tfirst)*scaler;

*                node level report
                  fr_id_infes_node(n,tau+lag_id) = ID_INFES_MKT.L(n,tfirst%set_sto_root%);
*                  fr_id_price_node(n,tau+lag_id) = ID_MKT_NODE.M(n%set_sto_root%,tfirst)*scaler;
*                  fr_id_netin_node(n,tau+lag_id) = ID_NETINPUT.L(n,tfirst%set_sto_root%);
*                  fr_id_lineflow(l,tau+lag_id) = sum(n, ptdf(l,n)*ID_NETINPUT.L(n,tfirst%set_sto_root%));
                  fr_id_curt_node(r,n,tau+lag_id) = ID_WIND_CURT_ID.L(r,n,tfirst%set_sto_root%);
                  fr_id_ren_node(r,n,tau+lag_id) = ID_WIND_BID.L(r,n,tfirst%set_sto_root%);
$IFTHEN %case%==1
                  fr_id_ren_fc_node(r,n,tau+lag_id) = SUM(c$mapnc(n,c), SUM(ren, splitren(n,ren)*wind_tmp(c,ren,tfirst)));
$ELSE
                  fr_id_ren_fc_node(r,n,tau+lag_id) = SUM(c$mapnc(n,c), SUM(ren, splitren(n,ren)*wind_sto_tmp(c,ren,tfirst%set_sto_root%)));
$ENDIF
*                  fr_id_price_line_pos(l,tau+lag_id) =  ID_res_pmax_pos.M(l%set_sto_root%,tfirst)*scaler;
*                  fr_id_price_line_neg(l,tau+lag_id) =  ID_res_pmax_neg.M(l%set_sto_root%,tfirst)*scaler;
         );
         EXECUTE_UNLOAD "%resultdir%intraday.gdx" fr_id_gen_to, fr_id_ren_to, fr_id_w_to, fr_id_v_to, fr_id_l,
                                                  fr_id_gen_id, fr_id_ren_id, fr_id_w_id, fr_id_v_id,
                                                  fr_id_status, fr_id_cs, fr_id_cd, fr_id_cost, fr_id_infes, fr_id_price, fr_id_frc,
                                                  fr_id_price_country, fr_id_transfer, fr_id_price_ntc,
                                                  fr_id_infes_node, fr_id_curt_node, fr_id_ren_node, fr_id_ren_fc_node
*                                                 , fr_id_price_node, fr_id_netin_node, fr_id_lineflow, fr_id_price_line_pos, fr_id_price_line_neg
                                                  ;
         PUTCLOSE rename, "move %resultdir%intraday.gdx %resultdir%intraday_"tau.tl:0".gdx";
         EXECUTE "rename.bat";
         OPTION kill=fr_id_gen_to, kill=fr_id_ren_to, kill=fr_id_w_to, kill=fr_id_v_to, kill=fr_id_l,
                kill=fr_id_gen_id, kill=fr_id_ren_id, kill=fr_id_w_id, kill=fr_id_v_id,
                kill=fr_id_status, kill=fr_id_cs, kill=fr_id_cd, kill=fr_id_cost, kill=fr_id_infes, kill=fr_id_price, kill=fr_id_frc,
                kill=fr_id_price_country, kill=fr_id_transfer, kill=fr_id_price_ntc,
                kill=fr_id_infes_node, kill=fr_id_curt_node, kill=fr_id_ren_node, kill=fr_id_ren_fc_node
*               , kill=fr_id_price_node, kill=fr_id_netin_node, kill=fr_id_lineflow, kill=fr_id_price_line_pos, kill=fr_id_price_line_neg
                ;

$LABEL end_id

********************************************************************************
*    ------------------------- CONGESTION MANAGEMENT MODEL ----------------
********************************************************************************
*        Prepare data
$        include prepare_cm

         solved_cm("modelstats",tau) = 0;
         solved_cm("solvestats",tau) = 0;
         solved_cm("absolute gap",tau) = 0;
         solved_cm("relative gap",tau) = 0;

$IF %solve_cm%==NO $GOTO end_solve_cm

$IFTHEN %case%==1
         CM_GEN_CM.fx(pl,t)$(cap_max(pl)) = 0;
         CM_W_CM.fx(j,t)$(l_max(j)) = 0;
         CM_V_CM.fx(j,t)$(l_max(j)) = 0;
         CM_WIND_CURT_CM.fx(r,n,t) = 0;
         CM_ALPHA.fx(l,t) = 0;

$ELSE
         CM_GEN_CM.fx(pl,t,k)$(mapkt(k,t) and cap_max(pl)) = 0;
         CM_W_CM.fx(j,t,k)$(mapkt(k,t) and l_max(j)) = 0;
         CM_V_CM.fx(j,t,k)$(mapkt(k,t) and l_max(j)) = 0;
         CM_WIND_CURT_CM.fx(r,n,t,k)$(mapkt(k,t)) = 0;
         CM_ALPHA.fx(l,t,k)$(mapkt(k,t)) = 0;

$ENDIF
*        Solve pre-solve congestion management model
         cap_factor = 10000;
         solve congestionmanagement using MIP minimizing CM_COST;

*        Write final report variables to periods they belong to
         loop((tfirst%set_sto_root%),
                 loop(ttau$(ord(ttau) eq ord(tau)+lag_id),
                         fr_cm_prelineflow(l,tau+lag_id) = CM_res_pmax_neg.l(l%set_sto_root%,tfirst);
                 );
         );
         EXECUTE_UNLOAD "%resultdir%precongestionmanagement.gdx" fr_cm_prelineflow;
         PUTCLOSE rename, "move %resultdir%precongestionmanagement.gdx %resultdir%precongestionmanagement_"tau.tl:0".gdx";
         EXECUTE "rename.bat";
         OPTION kill=fr_cm_prelineflow;

         if(smax(l, abs(SUM((tfirst%set_sto_root%), CM_res_pmax_neg.l(l%set_sto_root%,tfirst))) - cap_l(l)) > 0,
*                Prepare data
$                include prepare_cm
                 cap_factor = 1;

*                Solve congestion management model
                 solve congestionmanagement using MIP minimizing CM_COST;

         );

         solved_cm("modelstats",tau) = congestionmanagement.modelstat;
         solved_cm("solvestats",tau) = congestionmanagement.solvestat;
         solved_cm("absolute gap",tau) = abs(congestionmanagement.objest - congestionmanagement.objval);
         solved_cm("relative gap",tau) = solved_cm("absolute gap",tau)/(1e-10+abs(congestionmanagement.objval));

$LABEL end_solve_cm

*         display t_cm,CM_GEN_CM.l;

*        Set online/offline time
         loop(pl$((offtime(pl) or ontime(pl)) and taufirst = 0),
*                for plants with binary unit commitment
                 If(plbin(pl),
*                        Offline times
                          If(sum((tfirst%set_sto_root%), CM_ON.L(pl,tfirst%set_sto_root%) - ir_status_cm(pl,tfirst)) eq - 1,
                                   ir_time_off(pl) = offtime(pl) - 1;
*                        Online times
                          ElseIf sum((tfirst%set_sto_root%), CM_ON.L(pl,tfirst%set_sto_root%) - ir_status_cm(pl,tfirst)) eq 1,
                                   ir_time_on(pl) = ontime(pl) - 1;
*                        Adjust online/offline times if no status change
                          Else
                                  ir_time_off(pl)$ir_time_off(pl) = ir_time_off(pl) -1;
                                  ir_time_on(pl)$ir_time_on(pl) = ir_time_on(pl) - 1;
                          );
                 Else
*                for plants with integer (clustered) unit commitment
                          ir_time_off_clust(pl,t) = ir_time_off_clust(pl,t+1);
                          ir_time_on_clust(pl,t) = ir_time_on_clust(pl,t+1);
*                        Offline times
                          If(sum((tfirst%set_sto_root%), CM_ON.L(pl,tfirst%set_sto_root%) - ir_status_cm(pl,tfirst)) lt 0,
                                   ir_time_off_clust(pl,t)$(ord(t) le offtime(pl) - 1) = ir_time_off_clust(pl,t) + sum((tfirst%set_sto_root%), - CM_ON.L(pl,tfirst%set_sto_root%) + ir_status_cm(pl,tfirst));
*                        Online times
                          ElseIf sum((tfirst%set_sto_root%), CM_ON.L(pl,tfirst%set_sto_root%) - ir_status_cm(pl,tfirst)) gt 0,
                                   ir_time_on_clust(pl,t)$(ord(t) le ontime(pl) - 1) = ir_time_on_clust(pl,t) + sum((tfirst%set_sto_root%), CM_ON.L(pl,tfirst%set_sto_root%) - ir_status_cm(pl,tfirst));
                          );
                 );

         );


*        Write intermediate reports for history variables
$IFTHEN %case%==1

         ir_status_cm(pl,t)      = CM_ON.L(pl,t);
         ir_delta_gen_cm(pl,t)   = CM_GEN_CM.L(pl,t);
         ir_curt_cm(r,n,t)       = CM_WIND_CURT_CM.L(r,n,t);
         ir_level_cm(j,t)        = CM_L.L(j,t);
         ir_v_cm(j,t)            = CM_V.l(j,t);
         ir_w_cm(j,t)            = CM_W.l(j,t);

$ELSE

*        Expected values
         ir_status_cm(pl,t)      = sum(mapkt(k,t), prob(t,k)*CM_ON.L(pl,t,k));
         ir_delta_gen_cm(pl,t)   = sum(mapkt(k,t), prob(t,k)*CM_GEN_CM.L(pl,t,k));
         ir_curt_cm(r,n,t)       = sum(mapkt(k,t), prob(t,k)*CM_WIND_CURT_CM.L(r,n,t,k));
         ir_level_cm(j,t)        = sum(mapkt(k,t), prob(t,k)*CM_L.L(j,t,k));
*        Stochastic values
         ir_v_sto_cm(j,t,k)      = CM_V.l(j,t,k);
         ir_w_sto_cm(j,t,k)      = CM_W.l(j,t,k);
$ENDIF
*        Shift intermediate report for history variables one period forward
         ir_gen_da(pl,t)         = ir_gen_da(pl,t+1);
         ir_status_da(pl,t)      = ir_status_da(pl,t+1);
         ir_res_s(res,pl,t)      = ir_res_s(res,pl,t+1);
         ir_res_ns(pl,t)         = ir_res_ns(pl,t+1);
         ir_res_h(res,j,t)       = ir_res_h(res,j,t+1);
         ir_v_da(j,t)            = ir_v_da(j,t+1);
         ir_w_da(j,t)            = ir_w_da(j,t+1);
         ir_level_da(j,t)        = ir_level_da(j,t+1);
         ir_curt_da(r,n,t)       = ir_curt_da(r,n,t+1);
         ir_price_da(c,t)        = ir_price_da(c,t+1);
         ir_transfer_da(c,cc,t)  = ir_transfer_da(c,cc,t+1);

$IF %solve_cm%==NO $GOTO end_cm
*        Write final report variables to periods they belong to
         loop((tfirst%set_sto_root%),
*                Redispatch
                  fr_cm_delta_gen(pl,tau+lag_id) = CM_GEN_CM.L(pl,tfirst%set_sto_root%);
                  fr_cm_ren_curt(r,tau+lag_id) = sum(n, CM_WIND_CURT_CM.L(r,n,tfirst%set_sto_root%));
                  fr_cm_l(j,tau+lag_id) = CM_L.L(j,tfirst%set_sto_root%);
                  fr_cm_w_cm(j,tau+lag_id) = CM_W_CM.L(j,tfirst%set_sto_root%);
                  fr_cm_v_cm(j,tau+lag_id) = CM_V_CM.L(j,tfirst%set_sto_root%);

*                status, infeasibilities, cost, price
                  fr_cm_status(pl,tau+lag_id) = CM_ON.L(pl,tfirst%set_sto_root%);
                  fr_cm_cs(pl,tau+lag_id) = CM_CS.L(pl,tfirst%set_sto_root%);
                  fr_cm_cd(pl,tau+lag_id) = CM_CD.L(pl,tfirst%set_sto_root%);
                  fr_cm_cost(tau+lag_id) = CM_COST.L*scaler;
                  fr_cm_infes(tau+lag_id) = sum(n, CM_INFES_MKT.L(n,tfirst%set_sto_root%));
                  fr_cm_infes2(tau+lag_id) = sum(n, CM_INFES_MKT2.L(n,tfirst%set_sto_root%));
                  fr_cm_price(tau+lag_id) = CM_mkt.M(%set_sto_root2%tfirst)*scaler;
                  fr_cm_delta_transfer(c,cc,tau+lag_id) = CM_TRANSFER_CM.L(c,cc,tfirst%set_sto_root%);

*                node level report
                  fr_cm_infes_node(n,tau+lag_id) = CM_INFES_MKT.L(n,tfirst%set_sto_root%);
                  fr_cm_infes2_node(n,tau+lag_id) = CM_INFES_MKT2.L(n,tfirst%set_sto_root%);
                  fr_cm_price_node(n,tau+lag_id) = CM_MKT_NODE.M(n%set_sto_root%,tfirst)*scaler;
                  fr_cm_netin_node(n,tau+lag_id) = CM_NETINPUT.L(n,tfirst%set_sto_root%);
                  fr_cm_lineflow(l,tau+lag_id) = CM_res_pmax_neg.l(l%set_sto_root%,tfirst);
                  fr_cm_curt_node(r,n,tau+lag_id) = CM_WIND_CURT_CM.L(r,n,tfirst%set_sto_root%);
                  fr_cm_price_line_pos(l,tau+lag_id) =  CM_res_pmax_pos.M(l%set_sto_root%,tfirst)*scaler;
                  fr_cm_price_line_neg(l,tau+lag_id) =  CM_res_pmax_neg.M(l%set_sto_root%,tfirst)*scaler;
                  fr_cm_hvdcflow(hvdc(n,nn),tau+lag_id) = CM_HVDCFLOW.L(n,nn,tfirst%set_sto_root%);
                  fr_cm_price_hvdc(hvdc(n,nn),tau+lag_id) =  CM_res_hvdcmax.M(n,nn%set_sto_root%,tfirst)*scaler;
                  fr_cm_alpha(l,tau+lag_id) =  CM_ALPHA.L(l,tfirst%set_sto_root%)*scaler;

         );

         EXECUTE_UNLOAD "%resultdir%congestionmanagement.gdx" fr_cm_delta_gen, fr_cm_ren_curt, fr_cm_l, fr_cm_w_cm, fr_cm_v_cm,
                                                              fr_cm_status, fr_cm_cs, fr_cm_cd, fr_cm_cost, fr_cm_infes, fr_cm_infes2, fr_cm_price, fr_cm_delta_transfer,
                                                              fr_cm_infes_node, fr_cm_infes2_node, fr_cm_price_node, fr_cm_netin_node, fr_cm_lineflow, fr_cm_curt_node,
                                                              fr_cm_price_line_pos, fr_cm_price_line_neg, fr_cm_hvdcflow, fr_cm_price_hvdc, fr_cm_alpha;
         PUTCLOSE rename, "move %resultdir%congestionmanagement.gdx %resultdir%congestionmanagement_"tau.tl:0".gdx";
         EXECUTE "rename.bat";
         OPTION kill=fr_cm_delta_gen, kill=fr_cm_ren_curt, kill=fr_cm_l, kill=fr_cm_w_cm, kill=fr_cm_v_cm,
                kill=fr_cm_status, kill=fr_cm_cs, kill=fr_cm_cd, kill=fr_cm_cost, kill=fr_cm_infes, kill=fr_cm_infes2, kill=fr_cm_price, kill=fr_cm_delta_transfer,
                kill=fr_cm_infes_node, kill=fr_cm_infes2_node, kill=fr_cm_price_node, kill=fr_cm_netin_node, kill=fr_cm_lineflow, kill=fr_cm_curt_node,
                kill=fr_cm_price_line_pos, kill=fr_cm_price_line_neg, kill=fr_cm_hvdcflow, kill=fr_cm_price_hvdc, kill=fr_cm_alpha;

$LABEL end_cm
*        Remove flag for first period
         taufirst = 0;

********************************************************************************
*    ------------------------- DAYAHEAD MODEL -----------------------------
********************************************************************************
* Day ahead model run in specified dayhaead hours
* It is assumed that the intraday model always runs before the dayahead model in
* order to providfe some initial values
* E.g. In hour 12 (11:00 - 12:00) dayahead market clears for the next day. Before the
* dayahead market clears (at 12:00) the intraday market for hour 13 (13:00-14:00) clears
* and provides initial values for hour 24 (23:00 to 24:00) at that day
         loop(mh(tau,hour)$(ord(hour) eq clr_da),
*                Prepare dayahead data
$                include prepare_da

*                Solve dayahead model
                 solve dayahead using MIP minimizing DA_COST;

                 ABORT$(dayahead.modelstat > 2 and dayahead.modelstat <> 8) "*** DAYAHEAD INFEASIBLE ***";

                 solved_da("modelstats",tau) = dayahead.modelstat;
                 solved_da("solvestats",tau) = dayahead.solvestat;
                 solved_da("absolute gap",tau) = abs(dayahead.objest - dayahead.objval);
                 solved_da("relative gap",tau) = solved_da("absolute gap",tau)/(1e-10+abs(dayahead.objval));


*                only the first 24 periods are used for reporting
*                values are appended to existing vector
                 loop(t$(ord(t) le 24),
*                         display ir_level_da,ir_v_da,ir_w_da;
*                        Intermediate report for pre-determined variables
                         loop(tt$(ord(tt) eq ord(t) + 24 - clr_da - lag_id),
                                   ir_gen_da(pl,tt) = DA_GEN.L(pl,t);
                                   ir_status_da(pl,tt) = DA_ON.L(pl,t);
                                   ir_res_s(res,pl,tt) = DA_RES_S.L(res,pl,t);
                                   ir_res_ns(pl,tt) = DA_RES_NS.L(pl,t);
                                   ir_res_h(res,j,tt) = DA_RES_H.L(res,j,t);
                                   ir_v_da(j,tt) = DA_V.L(j,t);
                                   ir_w_da(j,tt) = DA_W.L(j,t);
                                   ir_level_da(j,tt) = DA_L.L(j,t);
                                   ir_curt_da(r,n,tt) = DA_WIND_CURT.L(r,n,t);
                                   ir_price_da(c,tt) = DA_mkt.M(t)*scaler + DA_mkt_country.M(c,t)*scaler;
                                   ir_transfer_da(c,cc,tt) = DA_TRANSFER.L(c,cc,t);
                         );
*                         display ir_level_da,ir_v_da,ir_w_da;

*                        Final reports
*                        Set reporting gap
                         tautemp = 24-clr_da+ord(t);
*                        Generation, curtailment and reserve
                         fr_da_gen(pl,tau+tautemp) = DA_GEN.L(pl,t);
                         fr_da_w(j,tau+tautemp) = DA_W.L(j,t);
                         fr_da_v(j,tau+tautemp) = DA_V.L(j,t);
                         fr_da_l(j,tau+tautemp) = DA_L.L(j,t);
                         fr_da_ren(r,tau+tautemp) = sum(n, DA_WIND_BID.L(r,n,t));
                         fr_da_curt(r,tau+tautemp) = sum(n, DA_WIND_CURT.L(r,n,t));
                         fr_da_res_s(res,pl,tau+tautemp) = DA_RES_S.L(res,pl,t);
                         fr_da_res_ns(pl,tau+tautemp) = DA_RES_NS.L(pl,t);
                         fr_da_res_h(res,j,tau+tautemp) = DA_RES_H.L(res,j,t);

*                        Prices
                         fr_da_price_gen(tau+tautemp) = DA_mkt.M(t)*scaler;
                         fr_da_price_res(res,tau+tautemp) = (sum(c, DA_mkt_res.M(res,t,c)*scaler*dem_res(res,t,c))/sum(c, dem_res(res,t,c)))$sum(c, dem_res(res,t,c));

*                        Infeasibility and cost
                         fr_da_infes(tau+tautemp) = sum(n, DA_INFES_MKT.L(n,t));
                         fr_da_cs(pl,tau+tautemp) = DA_CS.L(pl,t);
                         fr_da_cd(pl,tau+tautemp) = DA_CD.L(pl,t);
                         fr_da_cost(tau)          = DA_COST.L*scaler;
                         fr_da_status(pl,tau+tautemp) = DA_ON.L(pl,t);
                         fr_da_frc(c,r,tau+tautemp) = wind_fc(c,r,t);

*                        Country level reports
                         fr_da_price_country(c,tau+tautemp) = DA_mkt_country.M(c,t)*scaler;
                         fr_da_transfer(c,cc,tau+tautemp) = DA_TRANSFER.L(c,cc,t);
                         fr_da_price_ntc(c,cc,tau+tautemp) = DA_res_ntc.M(c,cc,t)*scaler;

*                        Node level reports
                         fr_da_infes_node(n,tau+tautemp) = DA_INFES_MKT.L(n,t);
*                         fr_da_price_node(n,tau+tautemp) = DA_mkt_node.M(n,t)*scaler;
*                         fr_da_netin_node(n,tau+tautemp) = DA_NETINPUT.L(n,t);
*                         fr_da_lineflow(l,tau+tautemp)   =  sum(n, ptdf(l,n)*DA_NETINPUT.L(n,t));
                         fr_da_curt_node(r,n,tau+tautemp)  = DA_WIND_CURT.L(r,n,t);
                         fr_da_ren_node(r,n,tau+tautemp)   = DA_WIND_BID.L(r,n,t);
                         fr_da_ren_fc_node(r,n,tau+tautemp) = SUM(c$mapnc(n,c), SUM(ren, wind_fc(c,ren,t)*splitren(n,ren)));
*                         fr_da_price_line_pos(l,tau+tautemp) = DA_res_pmax_pos.M(l,t)*scaler;
*                         fr_da_price_line_neg(l,tau+tautemp) = DA_res_pmax_neg.M(l,t)*scaler;
                 );
*                 display ir_level_da,ir_v_da,ir_w_da;
                  EXECUTE_UNLOAD "%resultdir%dayahead.gdx" fr_da_gen, fr_da_w, fr_da_v, fr_da_l, fr_da_ren, fr_da_curt, fr_da_res_s, fr_da_res_s, fr_da_res_ns, fr_da_res_h,
                                                           fr_da_price_gen, fr_da_price_res,
                                                           fr_da_infes, fr_da_cs, fr_da_cd, fr_da_status, fr_da_frc,
                                                           fr_da_price_country, fr_da_transfer, fr_da_price_ntc,
                                                           fr_da_infes_node, fr_da_curt_node, fr_da_ren_node, fr_da_ren_fc_node,
*                                                           fr_da_price_node, fr_da_netin_node, fr_da_lineflow, fr_da_price_line_pos, fr_da_price_line_neg,
                                                           fr_da_cost;
                  PUTCLOSE rename, "move %resultdir%dayahead.gdx %resultdir%dayahead_"tau.tl:0".gdx";
                  EXECUTE "rename.bat";

                  OPTION kill=fr_da_gen, kill=fr_da_w, kill=fr_da_v, kill=fr_da_l, kill=fr_da_ren, kill=fr_da_curt, kill=fr_da_res_s, kill=fr_da_res_s, kill=fr_da_res_ns, kill=fr_da_res_h,
                         kill=fr_da_price_gen, kill=fr_da_price_res,
                         kill=fr_da_infes, kill=fr_da_cs, kill=fr_da_cd, kill=fr_da_status, kill=fr_da_frc,
                         kill=fr_da_price_country, kill=fr_da_transfer, kill=fr_da_price_ntc,
                         kill=fr_da_infes_node, kill=fr_da_curt_node, kill=fr_da_ren_node, kill=fr_da_ren_fc_node,
*                         kill=fr_da_price_node, kill=fr_da_netin_node, kill=fr_da_lineflow, kill=fr_da_price_line_pos, kill=fr_da_price_line_neg,
                         kill=fr_da_cost;

         );
);
*$stop
*#######################################################################################
*                                 REPORTING
*#######################################################################################
$label reporting

$include import_gdx

$include report

execute_unload "%resultdir%%result%.gdx";
