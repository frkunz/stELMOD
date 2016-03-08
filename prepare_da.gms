$STITLE Prepare Input Data for Dayahead Model within Rolling Planning

*-------------------------------------- Delete and unfix old setting -----------------------
$include unfix

wind_fc(c,r,t) = 0;
dem(t,c) = 0;
dem_res_up_2(t,c)=0;
dem_res_down_2(t,c)=0;
dem_res_up_3(t,c) = 0;
dem_res_down_3(t,c) = 0;

exchange(n,t) = 0;
ntc(c,cc,t) = 0;
*------------------------------------- DATA ----------------------------------------------
$ife '%case%=1' $set wind_param_da wind_rel
$ife NOT '%case%=1' $set wind_param_da wind_fc_da


* First loop determines simulation periods depending on time lag for market clearing (normaly 12 hours)
loop(ttau$(ord(ttau) ge ord(tau) + 24 - clr_da + 1 and ord(ttau) le ord(tau) + 24 - clr_da + tda),
*        Second loop maps the simulation periods to model periods
         loop(t$(ord(t) eq ord(ttau) - ord(tau) - clr_da),
*                DEMAND
                 dem(t,c) = SUM(n$mapnc(n,c), splitdem(n)) * d(ttau,c);

*                AVAILABILITY
                 avail(pl,t) = avail_tau(ttau,pl);

*                WIND
                 wind_fc(c,ren,t) = %wind_param_da%(ttau,c,ren);

*                RESERVE
                 dem_res(res,t,c)        = d_res(res,ttau,c);

*                CHP MUSTRUN
                 mrCHP(pl,t)             = mrCHP_tau(ttau,pl);

*                EXCHANGE
                 exchange(n,t)           = exchangeup(ttau,n);

*                NTC
                 ntc(c,cc,t)             = ntcup(ttau,c,cc);

         );
);

* INITAL VALUES ARE TAKE FROM LAST INTRADAY SOLVE, I.E. ARE EXPECTED VALUES
on_hist(pl) = sum(t$(ord(t) eq clr_da), round(ir_status_id(pl,t),0));
gen_hist(pl) = sum(t$(ord(t) eq clr_da), ir_gen_id(pl,t));
l_0(j) = sum(t$(ord(t) eq clr_da), ir_level_id(j,t));
up_hist_clust(plclust(pl),t) = sum(tt$(ord(tt) eq ord(t) + clr_da), ir_time_on_clust(pl,tt));
dn_hist_clust(plclust(pl),t) = sum(tt$(ord(tt) eq ord(t) + clr_da), ir_time_off_clust(pl,tt));

*display l_0, ir_level_id, ir_level_da;
*display l_0, ir_level_id;

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




