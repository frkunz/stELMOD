$STITLE Prepare Input Data for Congestion Management Model
$ontext
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

*-------------------------------------- Delete and unfix old setting -----------------------
$include unfix

$IFTHEN %case%==1

gen_da_id_bar(pl,t) = 0;
v_da_id_bar(j,t) = 0;
w_da_id_bar(j,t) = 0;
ren_curt_da_id_bar(r,n,t) = 0;
status_da_id_bar(pl,t) = 0;
infes_da_id_bar(n,t) = 0;
transfer_da_id_bar(c,cc,t) = 0;

CM_ON.up(pl,t) = noplants(pl);
CM_UP.up(pl,t) = noplants(pl);
CM_DN.up(pl,t) = noplants(pl);

$ELSE

gen_da_id_bar(pl,t,k) = 0;
v_da_id_bar(j,t,k) = 0;
w_da_id_bar(j,t,k) = 0;
ren_curt_da_id_bar(r,n,t,k) = 0;
status_da_id_bar(pl,t,k) = 0;
infes_da_id_bar(n,t,k) = 0;
transfer_da_id_bar(c,cc,t,k) = 0;

CM_ON.up(pl,t,k)$(mapkt(k,t)) = noplants(pl);
CM_UP.up(pl,t,k)$(mapkt(k,t)) = noplants(pl);
CM_DN.up(pl,t,k)$(mapkt(k,t)) = noplants(pl);

$ENDIF
*---------------------------------- FIX PREDERTEMINED VARIABLES ---------------------------
* other input is determined in the prepare_id.gms
* demand, wind etc

$IFTHEN %case%==1

* fix PST angle
$IF %PST%==YES $goto end_pst_det
CM_ALPHA.fx(l,t) = 0;
$LABEL end_pst_det

gen_da_id_bar(pl,t) = ir_gen_id(pl,t);
v_da_id_bar(j,t) = ir_v_id(j,t);
w_da_id_bar(j,t) = ir_w_id(j,t);
ren_curt_da_id_bar(r,n,t) = ir_curt_da(r,n,t) + ir_curt_id(r,n,t);
status_da_id_bar(pl,t) = ir_status_id(pl,t);
infes_da_id_bar(n,t) = ir_infes_id(n,t);
transfer_da_id_bar(c,cc,t) = ID_TRANSFER.l(c,cc,t);

* fix variables for storage
CM_V_CM.FX(j,t)$(l_max(j)) = 0;
CM_W_CM.FX(j,t)$(l_max(j)) = 0;

* Define lower limit for unit commitment variable in order to avoid shutdown of plants
CM_ON.lo(pl,t)$(cap_max(pl)) = round(status_da_id_bar(pl,t),0);

$IF %solve_id%==YES $GOTO end_fx_cm_det
CM_ON.fx(pl,t)$(cap_max(pl)) = round(status_da_id_bar(pl,t),0);
CM_ON.up(pl,t)$(cap_max(pl) and ontime(pl) le 1) = noplants(pl);
CM_ON.lo(pl,t)$(cap_max(pl) and ontime(pl) le 1) = round(status_da_id_bar(pl,t),0);
$LABEL end_fx_cm_det

*########## Fix predetermined status variables

loop(pl$(ir_time_on(pl) gt 0 or ir_time_off(pl) gt 0),
         CM_ON.FX(pl,t)$(ord(t) le ir_time_on(pl)) = 1;
         CM_ON.FX(pl,t)$(ord(t) le ir_time_off(pl)) = 0;
);

*CM_INFES_MKT2.fx(n,t)$(not exchange(n,t)) = 0;
*CM_INFES_MKT2.fx(n,t) = 0;
CM_INFES_MKT.up(n,t) = sum(c$mapnc(n,c), splitdem(n)*dem(t,c));


*########## End fixing status variables

$ELSE

* fix PST angle
$IF %PST%==YES $GOTO end_pst_sto
CM_ALPHA.fx(l,t,k) = 0;
$LABEL end_pst_sto

gen_da_id_bar(pl,t,k)$mapkt(k,t) = ir_gen_sto_id(pl,t,k);
v_da_id_bar(j,t,k)$mapkt(k,t) = ir_v_sto_id(j,t,k);
w_da_id_bar(j,t,k)$mapkt(k,t) = ir_w_sto_id(j,t,k);
ren_curt_da_id_bar(r,n,t,k)$mapkt(k,t) = ir_curt_da(r,n,t) + ir_curt_sto_id(r,n,t,k);
status_da_id_bar(pl,t,k)$mapkt(k,t) = ir_status_sto_id(pl,t,k);
infes_da_id_bar(n,t,k)$mapkt(k,t) = ir_infes_sto_id(n,t,k);
transfer_da_id_bar(c,cc,t,k)$mapkt(k,t) = ID_TRANSFER.l(c,cc,t,k);

* fix variables for storage
CM_V_CM.FX(j,t,k)$(mapkt(k,t) and l_max(j)) = 0;
CM_W_CM.FX(j,t,k)$(mapkt(k,t) and l_max(j)) = 0;

* Define lower limit for unit commitment variable in order to avoid shutdown of plants
CM_ON.lo(pl,t,k)$(mapkt(k,t) and cap_max(pl)) = round(status_da_id_bar(pl,t,k),0);

$IF %solve_id%==YES $GOTO end_fx_cm_sto
CM_ON.fx(pl,t,k)$(mapkt(k,t) and cap_max(pl)) = round(status_da_id_bar(pl,t,k),0);
CM_ON.up(pl,t,k)$(mapkt(k,t) and cap_max(pl) and ontime(pl) le 1) = noplants(pl);
CM_ON.lo(pl,t,k)$(mapkt(k,t) and cap_max(pl) and ontime(pl) le 1) = round(status_da_id_bar(pl,t,k),0);
$LABEL end_fx_cm_sto

*########## Fix predetermined status variables

loop(pl$(ir_time_on(pl) gt 0 or ir_time_off(pl) gt 0),
         CM_ON.FX(pl,t,k)$(ord(t) le ir_time_on(pl) and mapkt(k,t)) = 1;
         CM_ON.FX(pl,t,k)$(ord(t) le ir_time_off(pl) and mapkt(k,t)) = 0;
);

*CM_INFES_MKT2.fx(n,t,k)$(mapkt(k,t) and not exchange(n,t)) = 0;
*CM_INFES_MKT2.fx(n,t,k)$mapkt(k,t) = 0;

*########## End fixing status variables

$ENDIF

*--------------------------------- Initialize variables -----------------------------
$IFTHEN %case%==1

CM_GEN_CM.l(pl,t) = 0;
CM_V_CM.l(j,t) = 0;
CM_W_CM.l(j,t) = 0;
CM_REN_CURT_CM.l(r,n,t) = 0;
CM_L.l(j,t) = ID_L.l(j,t);
CM_V.l(j,t) = ID_V.l(j,t);
CM_W.l(j,t) = ID_W.l(j,t);

CM_ON.l(pl,t) = round(ID_ON.l(pl,t),0);
CM_CS.l(pl,t) = 0;
CM_CD.l(pl,t) = 0;
CM_COST.l = 0;
CM_INFES_MKT.l(n,t) = 0;
CM_INFES_MKT2.l(n,t) = 0;
CM_mkt.m(t) = 0;
CM_mkt_node.m(n,t) = 0;
CM_NETINPUT.l(n,t) = 0;
CM_res_pmax_pos.l(l,t) = 0;
CM_res_pmax_neg.l(l,t) = 0;
CM_HVDCFLOW.L(n,nn,t) = 0;
CM_res_hvdcmax.M(n,nn,t) = 0;

$ELSE

CM_GEN_CM.l(pl,t,k)$(mapkt(k,t)) = 0;
CM_V_CM.l(j,t,k)$(mapkt(k,t)) = 0;
CM_W_CM.l(j,t,k)$(mapkt(k,t)) = 0;
CM_REN_CURT_CM.l(r,n,t,k)$(mapkt(k,t)) = 0;
CM_L.l(j,t,k)$(mapkt(k,t)) = ID_L.l(j,t,k);
CM_V.l(j,t,k)$(mapkt(k,t)) = ID_V.l(j,t,k);
CM_W.l(j,t,k)$(mapkt(k,t)) = ID_W.l(j,t,k);

CM_ON.l(pl,t,k)$(mapkt(k,t)) = ID_ON.l(pl,t,k);
CM_CS.l(pl,t,k)$(mapkt(k,t)) = 0;
CM_CD.l(pl,t,k)$(mapkt(k,t)) = 0;
CM_COST.l = 0;
CM_INFES_MKT.l(n,t,k)$(mapkt(k,t)) = 0;
CM_INFES_MKT2.l(n,t,k)$(mapkt(k,t)) = 0;
CM_mkt.m(t,k)$(mapkt(k,t)) = 0;
CM_mkt_node.m(n,t,k)$(mapkt(k,t)) = 0;
CM_NETINPUT.l(n,t,k)$(mapkt(k,t)) = 0;
CM_res_pmax_pos.l(l,t,k)$(mapkt(k,t)) = 0;
CM_res_pmax_neg.l(l,t,k)$(mapkt(k,t)) = 0;
CM_HVDCFLOW.L(n,nn,t,k)$(mapkt(k,t)) = 0;
CM_res_hvdcmax.M(n,nn,t,k)$(mapkt(k,t)) = 0;

$ENDIF
