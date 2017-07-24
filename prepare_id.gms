$STITLE Prepare Input Data for Intraday Model
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
ren_fc(c,r,t) = 0;
dem(t,c) = 0;

on_hist(pl) = 0;
gen_hist(pl) = 0;
gen_bar(pl,t) = 0;
v_bar(j,t) = 0;
w_bar(j,t) = 0;
res_s_up_bar(pl,t) = 0;
res_s_down_bar(pl,t) = 0;
res_h_up_bar(j,t) = 0;
res_h_down_bar(j,t) = 0;
shed_ren_bar(r,t) = 0;
ren_curt_bar(r,n,t) = 0;
ren_tmp(c,r,t) = 0;
exchange(n,t) = 0;
ntc(c,cc,t) = 0;

$IFTHEN NOT %case%==1

ren_sto_tmp(c,r,t,k) = 0;
ren_mean_tmp(c,r,t,k) = 0;
prob(t,k) = 0;
mapkt(k,t) = NO;
mmapkt(k,t) = NO;
pred(k,kk) = NO;
ances(k,kk) = NO;

$ENDIF

*---------------------------------- FIX PREDERTEMINED VARIABLES ---------------------------
*######### Inital conditions
*Distiguish first and other simulation periods
* In the first period inital values are zero
if(taufirst = 1,

        on_hist(pl) = sum(tfirst, ir_status_da(pl,tfirst));
        gen_hist(pl) = sum(tfirst, ir_gen_da(pl,tfirst));
        l_0(j)   = sum(tfirst, ir_level_da(j,tfirst));

        ir_gen_da(pl,t) = ir_gen_da(pl,t+lag_id);
        ir_status_da(pl,t) = ir_status_da(pl,t+lag_id);
        ir_level_da(j,t) = ir_level_da(j,t+lag_id);

* Otherwise valriables are determined by previous intraday model run
else
*        set history variables
        on_hist(pl) = sum(tfirst, ir_status_cm(pl,tfirst));
        gen_hist(pl) = sum(tfirst, ir_gen_id(pl,tfirst)+ir_delta_gen_cm(pl,tfirst));
        l_0(j) = sum(tfirst, ir_level_cm(j,tfirst));
        up_hist_clust(plclust(pl),t) = ir_time_on_clust(pl,t);
        dn_hist_clust(plclust(pl),t) = ir_time_off_clust(pl,t);


*######### END Initial conditions
);

*display l_0;
*######### Set exogenous parameters
* First loop determines relevant simulation horizon
loop(ttau$(ord(ttau) ge ord(tau) + lag_id and ord(ttau) le ord(tau) + lag_id + tid),
*        Second loop maps simulation to time horizon
         loop(t$(ord(t) eq ord(ttau) - ord(tau) - lag_id + 1),
*                Demand
                 dem(t,c) = SUM(n$mapnc(n,c), splitdem(n)) * d(ttau,c);
*                Plant availability
                 avail(pl,t) = avail_tau(ttau,pl);
*                CHP mustrun
                 mrCHP(pl,t) = mrCHP_tau(ttau,pl);
*                Exchange
                 exchange(n,t) = exchangeup(ttau,n);
*                RES
                 ren_tmp(c,ren,t) = ren_rel(ttau,c,ren)+0;
*                NTC
                 ntc(c,cc,t) = ntcup(ttau,c,cc);
         );
);

$IFTHEN NOT %case%==1
* Define scenario tree characteristics of the reduced scenario tree
loop(ttau$(ord(ttau) eq ord(tau) + lag_id),
         ances(k,kk) = ances_red(ttau,k,kk);
);
pred(k,kk)$ances(k,kk) = yes;
mapkt(root,t)$(ord(t) eq 1) = yes;
mapkt(k,t)$(sum(h$(ord(h) eq ord(t)), stage(k,h)) and sum(kk$ances(kk,k), 1) ge 1) = YES;
mmapkt(k,t)$mapkt(k,t) = yes;

*display mapkt, ances;

* Assign renewable forecast to scenario tree of the model horizon
loop(ttau$(ord(ttau) eq ord(tau) + lag_id),
         loop(mapkt(k,t),
*                Renewables
                 prob(t,k) = sum((h), ren_frc_prob(ttau,h,k));
                 ren_sto_tmp(c,ren,t,k) = sum((h), ren_frc(c,ren,ttau,h,k))+0;
                 ren_sto_tmp(c,ren,t,root)$mapkt(root,t) = ren_rel(ttau,c,ren)+0;
         );
);

$ife '%case%=1' $goto det_sto
$ife '%case%=2' $goto cf_mean
$ife '%case%=3' $goto cf_mostlikely
$ife '%case%=4' $goto det_sto

$label cf_mean
*changingforecase_mean
ren_mean_tmp(c,r,t,k)$mapkt(k,t) = sum(kk$mapkt(kk,t), prob(t,kk)*ren_sto_tmp(c,r,t,kk));
loop(mapkt(k,t),
         prob(t,k) = 1$(prob(t,k) = smax(kk, prob(t,kk)));
);
ren_sto_tmp(c,r,t,k)$mapkt(k,t) = ren_mean_tmp(c,r,t,k);
$goto det_sto


$label cf_mostlikely
*changingforecase_mostlikely
loop(mapkt(k,t),
         prob(t,k) = 1$(prob(t,k) = smax(kk, prob(t,kk)));
);
ren_sto_tmp(c,r,t,k)$mapkt(k,t) = ren_sto_tmp(c,r,t,k)$prob(t,k);
$goto det_sto


$label det_sto
*redefine mapping of scenario tree
mapkt(k,t) = NO;
mmapkt(k,t) = NO;
mapkt(k,t) = YES$prob(t,k);
mmapkt(k,t)$mapkt(k,t) = yes;

*######### END Set exogenous parameters

*########## Fix predetermined status variables

loop(pl$(ir_time_on(pl) gt 0 or ir_time_off(pl) gt 0),
         ID_ON.FX(pl,t,k)$(ord(t) le ir_time_on(pl) and mapkt(k,t)) = 1;
         ID_ON.FX(pl,t,k)$(ord(t) le ir_time_off(pl) and mapkt(k,t)) = 0;
);

ID_ON.FX(pl,t,k)$(mapkt(k,t) and ir_res_ns(pl,t)) = 0;

*display ID_GEN_ID.up;
*########## End fixing status variables

$ELSE

*########## Fix predetermined status variables

loop(pl$(ir_time_on(pl) gt 0 or ir_time_off(pl) gt 0),
         ID_ON.FX(pl,t)$(ord(t) le ir_time_on(pl)) = 1;
         ID_ON.FX(pl,t)$(ord(t) le ir_time_off(pl)) = 0;
);

ID_ON.FX(pl,t)$(ir_res_ns(pl,t)) = 0;

*display ID_GEN_ID.up;
*########## End fixing status variables


$ENDIF

gen_bar(pl,t) = ir_gen_da(pl,t);
v_bar(j,t) =  ir_v_da(j,t);
w_bar(j,t) =  ir_w_da(j,t);
res_h_up_bar(j,t) = sum(res$mapresDir(res,"up"), ir_res_h(res,j,t));
res_h_down_bar(j,t) =  sum(res$mapresDir(res,"down"), ir_res_h(res,j,t));
res_s_up_bar(pl,t) = sum(res$mapresDir(res,"up"), ir_res_s(res,pl,t));
res_s_down_bar(pl,t) = sum(res$mapresDir(res,"down"), ir_res_s(res,pl,t));
ren_curt_bar(r,n,t) = ir_curt_da(r,n,t);


*--------------------------------- Initialize variables -----------------------------
$IFTHEN %case%==1

ID_GEN.l(pl,t) = gen_bar(pl,t);
ID_V.l(j,t) = v_bar(j,t);
ID_W.l(j,t) = w_bar(j,t);
ID_ON.l(pl,t) = ir_status_da(pl,t);
ID_L.l(j,t) = ir_level_da(j,t);
ID_GEN_ID.l(pl,t) = 0;
ID_V_ID.l(j,t) = 0;
ID_W_ID.l(j,t) = 0;
ID_REN_CURT_ID.l(r,n,t) = 0;
ID_INFES_MKT.l(n,t) = 0;
ID_REN_BID.l(r,n,t) = SUM(c$mapnc(n,c), SUM(ren, ren_tmp(c,ren,t)*splitren(n,ren))) - ren_curt_bar(r,n,t);

ID_COST.L = 0;
ID_mkt.M(t) = 0;
ID_mkt_country.M(c,t) = 0;
ID_TRANSFER.L(c,cc,t) = ir_transfer_da(c,cc,t);
ID_res_ntc.M(c,cc,t) = 0;

ID_ON.up(pl,t) = noplants(pl);
ID_UP.up(pl,t) = noplants(pl);
ID_DN.up(pl,t) = noplants(pl);

$ELSE

ID_GEN.l(pl,t,k)$mapkt(k,t) = gen_bar(pl,t);
ID_V.l(j,t,k)$mapkt(k,t) = v_bar(j,t);
ID_W.l(j,t,k)$mapkt(k,t) = w_bar(j,t);
ID_ON.l(pl,t,k)$(mapkt(k,t)) = ir_status_da(pl,t);
ID_L.l(j,t,k)$mapkt(k,t) = ir_level_da(j,t);
*ID_L.l(j,t,k)$mapkt(k,t) = sum(kk$pred(kk,k), ID_L.l(j,t-1,kk)) + l_0(j)$tfirst(t) + eta(j)*ID_W.l(j,t,k) - ID_V.l(j,t,k);
ID_GEN_ID.l(pl,t,k)$(mapkt(k,t)) = 0;
ID_V_ID.l(j,t,k)$(mapkt(k,t)) = 0;
ID_W_ID.l(j,t,k)$(mapkt(k,t)) = 0;
ID_REN_CURT_ID.l(r,n,t,k)$(mapkt(k,t)) = 0;
ID_INFES_MKT.l(n,t,k)$(mapkt(k,t)) = 0;
ID_REN_BID.l(r,n,t,k)$(mapkt(k,t)) = SUM(c$mapnc(n,c), SUM(ren, ren_sto_tmp(c,ren,t,k)*splitren(n,ren))) - ren_curt_bar(r,n,t);

ID_COST.L = 0;
ID_mkt.M(k,t)$(mapkt(k,t)) = 0;
ID_mkt_country.M(c,k,t)$(mapkt(k,t)) = 0;
ID_TRANSFER.L(c,cc,t,k)$(mapkt(k,t)) = ir_transfer_da(c,cc,t);
ID_res_ntc.M(c,cc,k,t)$(mapkt(k,t)) = 0;

ID_ON.up(pl,t,k)$(mapkt(k,t)) = noplants(pl);
ID_UP.up(pl,t,k)$(mapkt(k,t)) = noplants(pl);
ID_DN.up(pl,t,k)$(mapkt(k,t)) = noplants(pl);

$ENDIF
