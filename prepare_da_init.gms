$STITLE Prepare Input Data for Initial Dayahead Model
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
dem_res_up_2(t,c)=0;
dem_res_down_2(t,c)=0;
dem_res_up_3(t,c) = 0;
dem_res_down_3(t,c) = 0;

dem_res(res,t,c) = 0;

exchange(n,t) = 0;
*------------------------------------- DATA ----------------------------------------------
* Initially, storage is partly filled and all plant are offline
on_hist(pl) = 0;
gen_hist(pl) = 0;
l_0(j) = l_max(j)/2;

* Demand
dem(t,c) = SUM(n$mapnc(n,c), splitdem(n)) * sum(tau$(ord(tau) eq ord(t) and ord(t) le card(t_da)), d(tau,c));
exchange(n,t) = sum(tau$(ord(tau) eq ord(t) and ord(t) le card(t_da)), exchangeup(tau,n));

* Availability
avail(pl,t) = sum(tau$(ord(tau) eq ord(t) and ord(t) le card(t_da)), avail_tau(tau,pl));

* CHP mustrun
mrCHP(pl,t) = sum(tau$(ord(tau) eq ord(t) and ord(t) le card(t_da)), mrCHP_tau(tau,pl));

* Reserve demand
dem_res_up_2(t,c)       = sum(tau$(ord(tau) eq ord(t) and ord(t) le card(t_da)),sres_up_2(tau,c));
dem_res_down_2(t,c)     = sum(tau$(ord(tau) eq ord(t) and ord(t) le card(t_da)),sres_down_2(tau,c));
dem_res_up_3(t,c)       = sum(tau$(ord(tau) eq ord(t) and ord(t) le card(t_da)),sres_up_3(tau,c));
dem_res_down_3(t,c)     = sum(tau$(ord(tau) eq ord(t) and ord(t) le card(t_da)),sres_down_3(tau,c));

dem_res(res,t,c)        = sum(tau$(ord(tau) eq ord(t) and ord(t) le card(t_da)), d_res(res,tau,c));

* NTC
ntc(c,cc,t) = sum(tau$(ord(tau) eq ord(t) and ord(t) le card(t_da)), ntcup(tau,c,cc));

* disable reserve demand for first hours in order to allow for an initialization
dem_res(res,t,c)$(ord(t) lt 13)         = 0;

* Renewable forecast
$ife '%case%=1' $set ren_param_da ren_rel
$ife NOT '%case%=1' $set ren_param_da ren_fc_da

ren_fc(c,ren,t) = sum(tau$(ord(tau) eq ord(t) and ord(t) le card(t_da)),%ren_param_da%(tau,c,ren));

*--------------------------------- Initialize variables -----------------------------
DA_GEN.l(pl,t) = 0;
DA_V.l(j,t) = 0;
DA_W.l(j,t) = 0;
DA_ON.l(pl,t) = 0;
DA_L.l(j,t) = 0;
DA_CS.l(pl,t) = 0;
DA_CD.l(pl,t) = 0;
DA_RES_S.l(res,pl,t) = 0;
DA_RES_NS.l(pl,t) = 0;
DA_RES_H.l(res,j,t) = 0;
DA_GEN_MIN.l(pl,t) = 0;
DA_GEN_MAX.l(pl,t) = 0;
DA_REN_CURT.l(r,n,t) = 0;
DA_INFES_MKT.l(n,t) = 0;
DA_REN_BID.l(r,n,t) = 0;
DA_TRANSFER.L(c,cc,t) = 0;

DA_ON.up(pl,t) = noplants(pl);
DA_UP.up(pl,t) = noplants(pl);
DA_DN.up(pl,t) = noplants(pl);






