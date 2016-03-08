$STITLE Prepare Input Data for Initial Dayahead Model

*-------------------------------------- Delete and unfix old setting -----------------------
$include unfix

wind_fc(c,r,t) = 0;
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
$ife '%case%=1' $set wind_param_da wind_rel
$ife NOT '%case%=1' $set wind_param_da wind_fc_da

wind_fc(c,ren,t) = sum(tau$(ord(tau) eq ord(t) and ord(t) le card(t_da)),%wind_param_da%(tau,c,ren));

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
DA_WIND_CURT.l(r,n,t) = 0;
DA_INFES_MKT.l(n,t) = 0;
DA_WIND_BID.l(r,n,t) = 0;
DA_TRANSFER.L(c,cc,t) = 0;

DA_ON.up(pl,t) = noplants(pl);
DA_UP.up(pl,t) = noplants(pl);
DA_DN.up(pl,t) = noplants(pl);






