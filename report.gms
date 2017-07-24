$STITLE Reporting of Model Results
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

set
         gen_tmp
         /Total, Dayahead, Intraday/
         price_tmp
         /Dayahead, Intraday, Reserve_Up_2, Reserve_U_3, Reserve_Down_2, Reserve_Down_3/
         status_tmp
         /online, Startup, shutdown/
         reserve_tmp
         /Spinning_Up_2, Spinning_Up_3, Non_Spinning, Spinning_Down_2, Spinning_Down_3/
         renew_tmp_I
         /dayahead, intraday, redispatch/
         renew_tmp_II
         /forecast,shedding,supply/
         stats_tmp
         /modelstats, solvestats, absolute_gap, relative_gap/
         costs_tmp
         /fuel, startup, shut_down, carbon, subsidy, total/
         infes_tmp
         /mkt/
         fuel_tmp
         /use, cost/
;

loop(tau$(ord(tau) le %end_h%+lag_id),
*        Lopp establishes mapping from periods to hours and days
         loop(day$mday(tau,day), loop(hour$mh(tau,hour),

*                STATUS
                  status("online",i,day,hour) = sum(pl$mapipl(i,pl), fr_cm_status(pl,tau));
                  status("startup",i,day,hour) = sum(pl$(mapipl(i,pl) and fr_cm_status(pl,tau)-fr_cm_status(pl,tau-1) eq 1), 1);
                  status("shutdown",i,day,hour) = sum(pl$(mapipl(i,pl) and fr_cm_status(pl,tau)-fr_cm_status(pl,tau-1) eq -1), 1);

*                GENERATION
*                 total
                  generation("total",i,day,hour) = sum(pl$mapipl(i,pl), fr_id_gen_to(pl,tau) + fr_cm_delta_gen(pl,tau));
*                        Looks a bit strange but does ensure that previous value on technology set i are not overwritten since no extra set for storage technologies was introduced
                  generation("total",is,day,hour) = sum(j$mapij(is,j), fr_id_v_to(j,tau) - fr_id_w_to(j,tau));
                  generation("total",r,day,hour) = fr_id_ren_to(r,tau) - fr_cm_ren_curt(r,tau);

*                 dayahead
                  generation("dayahead",i,day,hour) = sum(pl$mapipl(i,pl), fr_da_gen(pl,tau));
                  generation("dayahead",is,day,hour) = sum(j$mapij(is,j), fr_da_v(j,tau) - fr_da_w(j,tau));
                  generation("dayahead",r,day,hour) = fr_da_ren(r,tau);

*                 intraday correction
                  generation("intraday",i,day,hour) = sum(pl$mapipl(i,pl), fr_id_gen_id(pl,tau));
                  generation("intraday",is,day,hour) = sum(j$mapij(is,j), fr_id_v_id(j,tau) - fr_id_w_id(j,tau));
                  generation("intraday",r,day,hour) = -fr_id_ren_id(r,tau);
*                  Difference between dayahead and intraday bidding renewable quantities (curtailment is included in bidded quantity)
*                  generation("intraday",r,day,hour) = fr_id_ren_to(r,tau) - fr_da_ren(r,tau);

*                 redispatch correction
                  generation("redispatch",i,day,hour) = sum(pl$mapipl(i,pl), fr_cm_delta_gen(pl,tau));
                  generation("redispatch",is,day,hour) = sum(j$mapij(is,j), fr_cm_v_cm(j,tau) - fr_cm_w_cm(j,tau));
                  generation("redispatch",r,day,hour) = -fr_cm_ren_curt(r,tau);

*                RESERVE
                  reserve("Spinning_Up_2",i,day,hour) = sum(pl$mapipl(i,pl), fr_da_res_s("up2",pl,tau));
                  reserve("Spinning_Up_2",is,day,hour) = sum(j$mapij(is,j), fr_da_res_h("up2",j,tau));
                  reserve("Spinning_Up_3",i,day,hour) = sum(pl$mapipl(i,pl), fr_da_res_s("up3",pl,tau));
                  reserve("Spinning_Up_3",is,day,hour) =  sum(j$mapij(is,j), fr_da_res_h("up3",j,tau));
                  reserve("Spinning_Down_2",i,day,hour) = sum(pl$mapipl(i,pl), fr_da_res_s("down2",pl,tau));
                  reserve("Spinning_Down_2",is,day,hour) = sum(j$mapij(is,j), fr_da_res_h("down2",j,tau));
                  reserve("Spinning_Down_3",i,day,hour) = sum(pl$mapipl(i,pl), fr_da_res_s("down3",pl,tau));
                  reserve("Spinning_Down_3",is,day,hour) =  sum(j$mapij(is,j), fr_da_res_h("down3",j,tau));
                  reserve("Non_Spinning",i,day,hour) =  sum(pl$mapipl(i,pl), fr_da_res_ns(pl,tau));


*                PRICES
                  price("dayahead",day,hour) = fr_da_price_gen(tau);
                  price("Intraday",day,hour) = fr_id_price(tau);
                  price("Reserve_Up_2",day,hour) = fr_da_price_res("up2",tau);
                  price("Reserve_Down_2",day,hour) =  fr_da_price_res("down2",tau)+eps;
                  price("Reserve_Up_3",day,hour) = fr_da_price_res("up3",tau)+eps;
                  price("Reserve_Down_3",day,hour) = fr_da_price_res("down3",tau)+eps;

*                RENEWABLES
                  renewables("dayahead","forecast",r,day,hour) = SUM(c, fr_da_frc(c,r,tau));
                  renewables("dayahead","Shedding",r,day,hour) = fr_da_curt(r,tau);
                  renewables("dayahead","supply",r,day,hour) = fr_da_ren(r,tau);
                  renewables("intraday","forecast",r,day,hour) = fr_id_frc(r,tau);
                  renewables("intraday","Shedding",r,day,hour) = fr_id_ren_id(r,tau);
                  renewables("intraday","supply",r,day,hour) = fr_id_ren_to(r,tau);
                  renewables("redispatch","Shedding",r,day,hour) = fr_cm_ren_curt(r,tau);
                  renewables("redispatch","supply",r,day,hour) = fr_id_ren_to(r,tau)-fr_cm_ren_curt(r,tau);

*                PART LOAD
                 partload(pl,day,hour)$cap_max(pl) = (fr_id_gen_to(pl,tau) + fr_cm_delta_gen(pl,tau))/cap_max(pl);

*                EMISSIONS
                 emissions("total",c,f,i,day,hour)$mapfi(f,i) = sum(n$mapnc(n,c), sum(pl$(mapipl(i,pl) and mappln(pl,n)), carb_coef(pl)*(fr_id_gen_to(pl,tau) + fr_cm_delta_gen(pl,tau))));
                 emissions("dayahead",c,f,i,day,hour)$mapfi(f,i) = sum(n$mapnc(n,c), sum(pl$(mapipl(i,pl) and mappln(pl,n)), carb_coef(pl)*(fr_da_gen(pl,tau))));
                 emissions("intraday",c,f,i,day,hour)$mapfi(f,i) = sum(n$mapnc(n,c), sum(pl$(mapipl(i,pl) and mappln(pl,n)), carb_coef(pl)*(fr_id_gen_id(pl,tau))));
                 emissions("redispatch",c,f,i,day,hour)$mapfi(f,i) = sum(n$mapnc(n,c), sum(pl$(mapipl(i,pl) and mappln(pl,n)), carb_coef(pl)*(fr_cm_delta_gen(pl,tau))));
*                 emissions(f,i,day,hour)$mapfi(f,i) = sum(pl$mapipl(i,pl), carb_coef(pl)*(fr_id_gen_to(pl,tau) + fr_cm_delta_gen(pl,tau)));

*                COST
*                 costs("fuel",f,i,day,hour)$(mapfi(f,i)) = pf(f)*sum(pl$mapipl(i,pl), (fr_id_gen_to(pl,tau)+fr_cm_delta_gen(pl,tau))/(plantup(pl,'Efficiency')$plantup(pl,'Efficiency') + techup(i,"Average Efficiency")$(NOT plantup(pl,'Efficiency'))));
*                 costs("startup",f,i,day,hour)$mapfi(f,i) = sum(pl$mapipl(i,pl), fr_id_cs(pl,tau) + fr_cm_cs(pl,tau));
*                 costs("shut_down",f,i,day,hour)$mapfi(f,i) = sum(pl$mapipl(i,pl), fr_id_cd(pl,tau) + fr_cm_cd(pl,tau));
*                 costs("carbon",f,i,day,hour)$(mapfi(f,i)) = sum(pl$mapipl(i,pl), carb_coef(pl)*(fr_id_gen_to(pl,tau)+fr_cm_delta_gen(pl,tau)))*taxesup("carbon","tax");
*                 costs("subsidy",f,i,day,hour)$(mapfi(f,i) and techup(i,"subsidy")) = sum(pl$mapipl(i,pl), (fr_id_gen_to(pl,tau)+fr_cm_delta_gen(pl,tau)))*techup(i,"subsidy");
*                 costs("curtailment","xxx",r,day,hour) = (renewables("dayahead","Shedding",r,day,hour) + renewables("intraday","Shedding",r,day,hour))*c_curt(r);
*                 costs("total",f,i,day,hour)$mapfi(f,i) = costs("fuel",f,i,day,hour) + costs("startup",f,i,day,hour) + costs("carbon",f,i,day,hour) - costs("subsidy",f,i,day,hour);

                 costs("total","fuel",f,i,day,hour)$(mapfi(f,i)) = pf(f)*sum(pl$mapipl(i,pl), (fr_id_gen_to(pl,tau)+fr_cm_delta_gen(pl,tau))/(plantup(pl,'Efficiency')$plantup(pl,'Efficiency') + techup(i,"Average Efficiency")$(NOT plantup(pl,'Efficiency'))));
                 costs("total","startup",f,i,day,hour)$mapfi(f,i) = sum(pl$mapipl(i,pl), fr_id_cs(pl,tau) + fr_cm_cs(pl,tau));
                 costs("total","shut_down",f,i,day,hour)$mapfi(f,i) = sum(pl$mapipl(i,pl), fr_id_cd(pl,tau) + fr_cm_cd(pl,tau));
                 costs("total","carbon",f,i,day,hour)$(mapfi(f,i)) = sum(pl$mapipl(i,pl), carb_coef(pl)*(fr_id_gen_to(pl,tau)+fr_cm_delta_gen(pl,tau)))*taxesup("carbon","tax");
                 costs("total","subsidy",f,i,day,hour)$(mapfi(f,i) and techup(i,"subsidy")) = sum(pl$mapipl(i,pl), (fr_id_gen_to(pl,tau)+fr_cm_delta_gen(pl,tau)))*techup(i,"subsidy");
                 costs("total","curtailment","xxx",r,day,hour) = (renewables("dayahead","Shedding",r,day,hour) + renewables("intraday","Shedding",r,day,hour) + renewables("redispatch","Shedding",r,day,hour))*c_curt(r);
                 costs("total","infeasibility","xxx","xxx",day,hour) = (fr_id_infes(tau) + fr_cm_infes(tau) + fr_cm_infes2(tau))*pen_infes;
                 costs("total","total",f,i,day,hour)$mapfi(f,i) = costs("total","fuel",f,i,day,hour) + costs("total","startup",f,i,day,hour) + costs("total","carbon",f,i,day,hour) - costs("total","subsidy",f,i,day,hour);

                 costs("dayahead","fuel",f,i,day,hour)$(mapfi(f,i)) = pf(f)*sum(pl$mapipl(i,pl), (fr_da_gen(pl,tau))/(plantup(pl,'Efficiency')$plantup(pl,'Efficiency') + techup(i,"Average Efficiency")$(NOT plantup(pl,'Efficiency'))));
                 costs("dayahead","startup",f,i,day,hour)$mapfi(f,i) = sum(pl$mapipl(i,pl), fr_da_cs(pl,tau));
                 costs("dayahead","shut_down",f,i,day,hour)$mapfi(f,i) = sum(pl$mapipl(i,pl), fr_da_cd(pl,tau));
                 costs("dayahead","carbon",f,i,day,hour)$(mapfi(f,i)) = sum(pl$mapipl(i,pl), carb_coef(pl)*(fr_da_gen(pl,tau)))*taxesup("carbon","tax");
                 costs("dayahead","subsidy",f,i,day,hour)$(mapfi(f,i) and techup(i,"subsidy")) = sum(pl$mapipl(i,pl), (fr_da_gen(pl,tau)))*techup(i,"subsidy");
                 costs("dayahead","curtailment","xxx",r,day,hour) = (renewables("dayahead","Shedding",r,day,hour))*c_curt(r);
                 costs("dayahead","infeasibility","xxx","xxx",day,hour) = (fr_da_infes(tau))*pen_infes;
                 costs("dayahead","total",f,i,day,hour)$mapfi(f,i) = costs("dayahead","fuel",f,i,day,hour) + costs("dayahead","startup",f,i,day,hour) + costs("dayahead","carbon",f,i,day,hour) - costs("dayahead","subsidy",f,i,day,hour);

                 costs("intraday","fuel",f,i,day,hour)$(mapfi(f,i)) = pf(f)*sum(pl$mapipl(i,pl), (fr_id_gen_id(pl,tau))/(plantup(pl,'Efficiency')$plantup(pl,'Efficiency') + techup(i,"Average Efficiency")$(NOT plantup(pl,'Efficiency'))));
                 costs("intraday","startup",f,i,day,hour)$mapfi(f,i) = sum(pl$mapipl(i,pl), fr_id_cs(pl,tau) - fr_da_cs(pl,tau)); // difference between dayahead and intraday startup costs as intraday cost comrpise all startup cost
                 costs("intraday","shut_down",f,i,day,hour)$mapfi(f,i) = sum(pl$mapipl(i,pl), fr_id_cd(pl,tau) - fr_da_cd(pl,tau));
                 costs("intraday","carbon",f,i,day,hour)$(mapfi(f,i)) = sum(pl$mapipl(i,pl), carb_coef(pl)*(fr_id_gen_id(pl,tau)))*taxesup("carbon","tax");
                 costs("intraday","subsidy",f,i,day,hour)$(mapfi(f,i) and techup(i,"subsidy")) = sum(pl$mapipl(i,pl), (fr_id_gen_id(pl,tau)))*techup(i,"subsidy");
                 costs("intraday","curtailment","xxx",r,day,hour) = (renewables("intraday","Shedding",r,day,hour))*c_curt(r);
                 costs("intraday","infeasibility","xxx","xxx",day,hour) = (fr_id_infes(tau) - fr_da_infes(tau))*pen_infes;
                 costs("intraday","total",f,i,day,hour)$mapfi(f,i) = costs("intraday","fuel",f,i,day,hour) + costs("intraday","startup",f,i,day,hour) + costs("intraday","carbon",f,i,day,hour) - costs("intraday","subsidy",f,i,day,hour);

                 costs("redispatch","fuel",f,i,day,hour)$(mapfi(f,i)) = pf(f)*sum(pl$mapipl(i,pl), (fr_cm_delta_gen(pl,tau))/(plantup(pl,'Efficiency')$plantup(pl,'Efficiency') + techup(i,"Average Efficiency")$(NOT plantup(pl,'Efficiency'))));
                 costs("redispatch","startup",f,i,day,hour)$mapfi(f,i) = sum(pl$mapipl(i,pl), fr_cm_cs(pl,tau));
                 costs("redispatch","shut_down",f,i,day,hour)$mapfi(f,i) = sum(pl$mapipl(i,pl), fr_cm_cd(pl,tau));
                 costs("redispatch","carbon",f,i,day,hour)$(mapfi(f,i)) = sum(pl$mapipl(i,pl), carb_coef(pl)*(fr_cm_delta_gen(pl,tau)))*taxesup("carbon","tax");
                 costs("redispatch","subsidy",f,i,day,hour)$(mapfi(f,i) and techup(i,"subsidy")) = sum(pl$mapipl(i,pl), (fr_cm_delta_gen(pl,tau)))*techup(i,"subsidy");
                 costs("redispatch","curtailment","xxx",r,day,hour) = (renewables("redispatch","Shedding",r,day,hour))*c_curt(r);
                 costs("redispatch","infeasibility","xxx","xxx",day,hour) = (fr_cm_infes(tau)+fr_cm_infes2(tau))*pen_infes;
                 costs("redispatch","total",f,i,day,hour)$mapfi(f,i) = costs("redispatch","fuel",f,i,day,hour) + costs("redispatch","startup",f,i,day,hour) + costs("redispatch","carbon",f,i,day,hour) - costs("redispatch","subsidy",f,i,day,hour);

                 fuel("use",f,i,day,hour)$(pf(f) and mapfi(f,i)) = sum(pl$mapipl(i,pl), fr_id_gen_to(pl,tau)/(plantup(pl,'Efficiency')$plantup(pl,'Efficiency') + techup(i,"Average Efficiency")$(NOT plantup(pl,'Efficiency'))));
                 fuel("cost",f,i,day,hour) = fuel("use",f,i,day,hour)*pf(f);

$IF %only_reporting%==YES $ONTEXT
*                MODEL AND SOLVE STATS
                 stats("dayahead","modelstats",day,hour) = solved_da("modelstats",tau);
                 stats("dayahead","solvestats",day,hour) = solved_da("solvestats",tau);
                 stats("dayahead","absolute gap",day,hour) = solved_da("absolute gap",tau);
                 stats("dayahead","relative gap",day,hour) = solved_da("relative gap",tau);
                 stats("intraday","modelstats",day,hour) = solved_id("modelstats",tau);
                 stats("intraday","solvestats",day,hour) = solved_id("solvestats",tau);
                 stats("intraday","absolute gap",day,hour) = solved_id("absolute gap",tau);
                 stats("intraday","relative gap",day,hour) = solved_id("relative gap",tau);
                 stats("redispatch","modelstats",day,hour) = solved_cm("modelstats",tau);
                 stats("redispatch","solvestats",day,hour) = solved_cm("solvestats",tau);
                 stats("redispatch","absolute gap",day,hour) = solved_cm("absolute gap",tau);
                 stats("redispatch","relative gap",day,hour) = solved_cm("relative gap",tau);
$ONTEXT
$OFFTEXT
*                INFEASIBILITIES
                 infeasibility("dayahead","mkt",day,hour) =  fr_da_infes(tau);
                 infeasibility("intraday","mkt",day,hour) =  fr_id_infes(tau);
                 infeasibility("redispatch","mkt",day,hour) =  fr_cm_infes(tau);
                 infeasibility("redispatch2","mkt",day,hour) =  fr_cm_infes2(tau);

*                COUNTRY LEVEL GENERATION
                 generation_country_tech("total",i,c,day,hour) = sum(n$mapnc(n,c), sum(pl$(mapipl(i,pl) and mappln(pl,n)), fr_id_gen_to(pl,tau)+fr_cm_delta_gen(pl,tau)));
                 generation_country_tech("total",is,c,day,hour) = sum(n$mapnc(n,c), sum(j$(mapij(is,j) and mappln(j,n)), fr_id_v_to(j,tau) - fr_id_w_to(j,tau)));
                 generation_country_tech("total",r,c,day,hour) = sum(n$mapnc(n,c), fr_id_ren_node(r,n,tau)-fr_cm_curt_node(r,n,tau));

                 generation_country_tech("dayahead",i,c,day,hour) = sum(n$mapnc(n,c), sum(pl$(mapipl(i,pl) and mappln(pl,n)), fr_da_gen(pl,tau)));
                 generation_country_tech("dayahead",is,c,day,hour) = sum(n$mapnc(n,c), sum(j$(mapij(is,j) and mappln(j,n)), fr_da_v(j,tau) - fr_da_w(j,tau)));
                 generation_country_tech("dayahead",r,c,day,hour) = sum(n$mapnc(n,c), fr_da_ren_node(r,n,tau));

                 generation_country_tech("intraday",i,c,day,hour) = sum(n$mapnc(n,c), sum(pl$(mapipl(i,pl) and mappln(pl,n)), fr_id_gen_id(pl,tau)));
                 generation_country_tech("intraday",is,c,day,hour) = sum(n$mapnc(n,c), sum(j$(mapij(is,j) and mappln(j,n)), fr_id_v_id(j,tau) - fr_id_w_id(j,tau)));
                 generation_country_tech("intraday",r,c,day,hour) = sum(n$mapnc(n,c), -fr_id_curt_node(r,n,tau));

                 generation_country_tech("redispatch",i,c,day,hour) = sum(n$mapnc(n,c), sum(pl$(mapipl(i,pl) and mappln(pl,n)), fr_cm_delta_gen(pl,tau)));
                 generation_country_tech("redispatch",is,c,day,hour) = sum(n$mapnc(n,c), sum(j$(mapij(is,j) and mappln(j,n)), fr_cm_v_cm(j,tau) - fr_cm_w_cm(j,tau)));
                 generation_country_tech("redispatch",r,c,day,hour) = sum(n$mapnc(n,c), -fr_cm_curt_node(r,n,tau));

*                NODE LEVEL GENERATION
                 generation_node("total",n,day,hour) = sum(pl$mappln(pl,n), fr_id_gen_to(pl,tau)+fr_cm_delta_gen(pl,tau))
                                                           + sum(j$mappln(j,n), fr_id_v_to(j,tau) - fr_id_w_to(j,tau));
                 generation_node("dayahead",n,day,hour) = sum(pl$mappln(pl,n), fr_da_gen(pl,tau))
                                                           + sum(j$mappln(j,n), fr_da_v(j,tau) - fr_da_w(j,tau));
                 generation_node("intraday",n,day,hour) = sum(pl$mappln(pl,n), fr_id_gen_id(pl,tau))
                                                          + sum(j$mappln(j,n), fr_id_v_id(j,tau) - fr_id_w_id(j,tau));
                 generation_node("redispatch",n,day,hour) = sum(pl$mappln(pl,n), fr_cm_delta_gen(pl,tau))
                                                         + sum(j$mappln(j,n), fr_cm_v_cm(j,tau) - fr_cm_w_cm(j,tau));

*                NODE/TECHNOLOGY LEVEL GENERATION
                 generation_node_tech("total",i,n,day,hour) = sum(pl$(mapipl(i,pl) and mappln(pl,n)), fr_id_gen_to(pl,tau)+fr_cm_delta_gen(pl,tau));
                 generation_node_tech("total",is,n,day,hour) = sum(j$(mapij(is,j) and mappln(j,n)), fr_id_v_to(j,tau) - fr_id_w_to(j,tau));
                 generation_node_tech("total",r,n,day,hour) = fr_id_ren_node(r,n,tau)-fr_cm_curt_node(r,n,tau);
*                dayahead
                 generation_node_tech("dayahead",i,n,day,hour) = sum(pl$(mapipl(i,pl) and mappln(pl,n)), fr_da_gen(pl,tau));
                 generation_node_tech("dayahead",is,n,day,hour) = sum(j$(mapij(is,j) and mappln(j,n)), fr_da_v(j,tau) - fr_da_w(j,tau));
                 generation_node_tech("dayahead",r,n,day,hour) = fr_da_ren_node(r,n,tau);

*                intraday correction
                 generation_node_tech("intraday",i,n,day,hour) = sum(pl$(mapipl(i,pl) and mappln(pl,n)), fr_id_gen_id(pl,tau));
                 generation_node_tech("intraday",is,n,day,hour) = sum(j$(mapij(is,j) and mappln(j,n)), fr_id_v_id(j,tau) - fr_id_w_id(j,tau));
                 generation_node_tech("intraday",r,n,day,hour) = -fr_id_curt_node(r,n,tau);

*                redispatch correction
                 generation_node_tech("redispatch",i,n,day,hour) = sum(pl$(mapipl(i,pl) and mappln(pl,n)), fr_cm_delta_gen(pl,tau));
                 generation_node_tech("redispatch",is,n,day,hour) = sum(j$(mapij(is,j) and mappln(j,n)), fr_cm_v_cm(j,tau) - fr_cm_w_cm(j,tau));
                 generation_node_tech("redispatch",r,n,day,hour) = -fr_cm_curt_node(r,n,tau);

*                NODE LEVEL INFEASIBILITY
                 infeasibility_node("intraday","mkt",n,day, hour) = fr_id_infes_node(n,tau);
                 infeasibility_node("dayahead","mkt",n,day, hour) = fr_da_infes_node(n,tau);
                 infeasibility_node("redispatch","mkt",n,day, hour) = fr_cm_infes_node(n,tau);
                 infeasibility_node("redispatch2","mkt",n,day, hour) = fr_cm_infes2_node(n,tau);
*                COUNTRY LEVEL PRICE
                 price_country_diff("dayahead",c,day,hour) = fr_da_price_country(c,tau);
                 price_country_diff("intraday",c,day,hour) = fr_id_price_country(c,tau);

                 price_country("dayahead",c,day,hour) = price("dayahead",day,hour) + price_country_diff("dayahead",c,day,hour);
                 price_country("intraday",c,day,hour) = price("intraday",day,hour) + price_country_diff("intraday",c,day,hour);

                 renewable_node("dayahead","forecast",r,n,day,hour) = fr_da_ren_fc_node(r,n,tau);
                 renewable_node("dayahead","shedding",r,n,day,hour) = fr_da_curt_node(r,n,tau);
                 renewable_node("dayahead","supply",r,n,day,hour) = fr_da_ren_node(r,n,tau);
                 renewable_node("intraday","forecast",r,n,day,hour) = fr_id_ren_fc_node(r,n,tau);
                 renewable_node("intraday","shedding",r,n,day,hour) = fr_id_curt_node(r,n,tau);
                 renewable_node("intraday","supply",r,n,day,hour) = fr_id_ren_node(r,n,tau);
                 renewable_node("redispatch","shedding",r,n,day,hour) = fr_cm_curt_node(r,n,tau);
                 renewable_node("redispatch","supply",r,n,day,hour) = fr_id_ren_node(r,n,tau)-fr_cm_curt_node(r,n,tau);

                 transfer("dayahead",c,cc,day,hour) = fr_da_transfer(c,cc,tau);
                 transfer("intraday",c,cc,day,hour) = fr_id_transfer(c,cc,tau);
                 price_ntc("dayahead",c,cc,day,hour) = fr_da_price_ntc(c,cc,tau);
                 price_ntc("intraday",c,cc,day,hour) = fr_id_price_ntc(c,cc,tau);

                 lineflow("pre congestion management",l,day,hour) = fr_cm_prelineflow(l,tau);
                 lineflow("congestion management",l,day,hour) = fr_cm_lineflow(l,tau);
                 overload("pre congestion management",l,day,hour) = abs(fr_cm_prelineflow(l,tau))/cap_l(l);
                 overload("congestion management",l,day,hour) = abs(fr_cm_lineflow(l,tau))/cap_l(l);
                 hvdcflow("congestion management",n,nn,day,hour)$hvdc(n,nn) = fr_cm_hvdcflow(n,nn,tau);
                 nodeinput("congestion management",n,day,hour) = fr_cm_netin_node(n,tau);
                 price_line("congestion management",l,day,hour) = fr_cm_price_line_pos(l,tau) - fr_cm_price_line_neg(l,tau);
         ););
);

