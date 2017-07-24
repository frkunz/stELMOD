$STITLE Stochastic Congestion Management Model
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

Free Variable
         CM_COST            total cost
         CM_NETINPUT        netinput in MW

         CM_GEN_CM          change of generation
         CM_V_CM            change in release
         CM_W_CM            change in pumping
         CM_REN_CURT_CM     curtailment congestion management

         CM_TRANSFER_CM     commercial transfer change

         CM_ALPHA           PST angle

;

Positive Variable
         CM_CS              startup cost
         CM_CD              shut down cost

         CM_GEN             generation
         CM_L               reservoir level
         CM_V               reservoir release
         CM_W               reservoir pupmping

         CM_GEN_MAX         possible maximum generation
         CM_GEN_MIN         possible minimum generation

         CM_HVDCFLOW        flow on hvdc lines

         CM_REN_BID         renewbale energy bid
         CM_INFES_MKT       slack in market clearing equation (increase of generation)
         CM_INFES_MKT2      slack in market clearing equation (decrease of generation)
;

Integer Variable
         CM_ON              status of plants
         CM_UP              startup of plants
         CM_DN              shutdown of plants

Equations
         CM_obj             objective definition
         CM_def_CS          startup cost definition
         CM_def_CD          shutdown cost definition

*        Market clearing equations
         CM_mkt             market clearing or energy balance electricity
         CM_mkt_country     market clearing at country level
         CM_mkt_node        market clearing at node level

*        Minimum/maximum generation restrictions
         CM_res_gmax        maximum generation constraint
         CM_res_gmin        minimum generation constraint
         CM_res_rup         upward ramping constraint
         CM_res_rdown       downward ramping constraint
         CM_res_on          online time restriction
         CM_res_off         offline time restriction
         CM_def_gen_max     maximum generation definition
         CM_def_gen_min     minimum generation definition
         CM_def_onupdn      plant status balance

*        Storage
         CM_res_v           upper release bound
         CM_res_w           upper storage bound
         CM_res_l           pump storage level constraints
         CM_res_lmin        lower pump storage constraint
         CM_lom_l           law of motion storage level

*        Defintions
         CM_def_gen         total generation definition
         CM_def_V           total reservoir release
         CM_def_W           total reservoir pumping

*        Renewables
         CM_def_REN_BID     definition of renewable bidding in intraday market
         CM_res_REN_BID     upper bound on renewable bidding

*        Must run constraint
         CM_res_mustr       must run constraint
         CM_res_mrCHP       must run CHP plants

*        Network
         CM_res_pmax_pos   thermal line limit
         CM_res_pmax_neg   thermal line limit
         CM_res_hvdcmax    thermal hvdc limit
         CM_res_grid       balance for synchronized ac grid
         CM_res_ntc        ntc limit
         CM_res_transfer   transfer change limit
         CM_res_alpha_pos  PST angle limit
         CM_res_alpha_neg  PST angle limit
;

*------------------------------------------ OBJECTIVE -----------------------------------------------
CM_obj..
         CM_COST         =E=     (
                                 sum((mapkt(k,t_cm(t)),pl)$cap_max(pl), prob(t,k)*(mc(pl)*CM_GEN_CM(pl,t,k) + CM_CS(pl,t,k) + CM_CD(pl,t,k)))
                                 + sum((mapkt(k,t_cm(t)),n), prob(t,k)*pen_infes*(CM_INFES_MKT(n,t,k)+CM_INFES_MKT2(n,t,k)))
                                 + sum((mapkt(k,t_cm(t)),r,n), prob(t,k)*c_curt(r)*CM_REN_CURT_CM(r,n,t,k))
                                 )
                                 /scaler
;

CM_def_CS(pl,mapkt(k,t_cm(t)))$(cap_max(pl) and sc(pl))..
         CM_CS(pl,t,k)   =G=     sc(pl)/noplants(pl)*(CM_ON(pl,t,k) - CM_ON(pl,t-1,k) - status_da_id_bar(pl,t,k) - on_hist(pl)$(not taufirst and tfirst(t)))
;

CM_def_CD(pl,mapkt(k,t_cm(t)))$(cap_max(pl) and su(pl))..
         CM_CD(pl,t,k)   =G=     su(pl)/noplants(pl)*(status_da_id_bar(pl,t,k) + CM_ON(pl,t-1,k) - CM_ON(pl,t,k) + on_hist(pl)$(not taufirst and tfirst(t)))
;

*------------------------------------- MARKET CLEARING EQUATIONS -----------------------------------
CM_mkt(mapkt(k,t_cm(t)))..
         sum(pl$cap_max(pl), CM_GEN_CM(pl,t,k))
         + sum(j$v_max(j), CM_V_CM(j,t,k) - CM_W_CM(j,t,k))
         + sum((r,n), CM_REN_CURT_CM(r,n,t,k))
         + sum(n, CM_INFES_MKT(n,t,k)) - sum(n, CM_INFES_MKT2(n,t,k))
                         =E=
                                 0
;

CM_mkt_country(c,mapkt(k,t_cm(t)))..
         sum(n$mapnc(n,c), sum(pl$(mappln(pl,n) and cap_max(pl)), CM_GEN_CM(pl,t,k)))
         + sum(n$mapnc(n,c), sum(j$(mappln(j,n) and v_max(j)), CM_V_CM(j,t,k) - CM_W_CM(j,t,k)))
         - sum((n)$mapnc(n,c), sum(r, CM_REN_CURT_CM(r,n,t,k)))
         + sum(n$mapnc(n,c), CM_INFES_MKT(n,t,k)) - sum(n$mapnc(n,c), CM_INFES_MKT2(n,t,k))
                         =E=
                                 + sum(cc$ntc(c,cc,t), CM_TRANSFER_CM(c,cc,t,k))
                                 - sum(cc$ntc(cc,c,t), CM_TRANSFER_CM(cc,c,t,k))
;

CM_mkt_node(n,mapkt(k,t_cm(t)))..
          sum(pl$(mappln(pl,n) and cap_max(pl)), CM_GEN(pl,t,k))
          + sum(j$(mappln(j,n) and v_max(j)), CM_V(j,t,k) - CM_W(j,t,k))
          + sum((r), CM_REN_BID(r,n,t,k))
          + infes_da_id_bar(n,t,k) + CM_INFES_MKT(n,t,k) - CM_INFES_MKT2(n,t,k)
                         =E=
                                 sum(c$mapnc(n,c), splitdem(n)*dem(t,c))
                                 + exchange(n,t)
                                 + CM_NETINPUT(n,t,k)
                                 + sum(nn$hvdc(n,nn), CM_HVDCFLOW(n,nn,t,k) - CM_HVDCFLOW(nn,n,t,k))
;

*------------------------------------ TECHNICAL CONSTRAINTS ----------------------------------------
CM_res_gmax(pl,mapkt(k,t_cm(t)))$cap_max(pl)..
         CM_ON(pl,t,k)*cap_max(pl)/noplants(pl)*avail(pl,t) - res_s_up_bar(pl,t)
                         =G=     CM_GEN(pl,t,k)
;

CM_res_gmin(pl,mapkt(k,t_cm(t)))$cap_max(pl)..
         CM_GEN(pl,t,k)
                         =G=     CM_ON(pl,t,k)*cap_min(pl)/noplants(pl) + res_s_down_bar(pl,t)
;

CM_res_rup(pl,mapkt(k,t_cm(t)))$(a_up(pl) and cap_max(pl))..
         CM_GEN_MAX(pl,t,k)
                         =G=     CM_GEN(pl,t,k) + res_s_up_bar(pl,t)
;

CM_res_rdown(pl,mapkt(k,t_cm(t)))$(a_down(pl) and cap_max(pl))..
         CM_GEN(pl,t,k) - res_s_down_bar(pl,t)
                         =G=     CM_GEN_MIN(pl,t,k)
;

CM_def_gen_max(pl,mapkt(k,t_cm(t)))$(a_up(pl) and cap_max(pl))..
          sum(kk$pred(kk,k), CM_GEN(pl,t-1,kk))
          + a_up(pl)* sum(kk$pred(kk,k), CM_ON(pl,t-1,kk)) + cap_min(pl)/noplants(pl)*(CM_UP(pl,t,k))
          + a_up(pl)$gen_hist(pl)$tfirst(t) + cap_min(pl)/noplants(pl)*(NOT gen_hist(pl))$tfirst(t)
          + gen_hist(pl)$tfirst(t)
                         =E=     CM_GEN_MAX(pl,t,k)
;

CM_def_GEN_MIN(pl,mapkt(k,t_cm(t)))$(a_down(pl) and cap_max(pl))..
         CM_GEN_MIN(pl,t,k)
                         =G=     sum(kk$pred(kk,k), CM_GEN(pl,t-1,kk))
                                 - a_down(pl)*(CM_ON(pl,t,k)) - cap_min(pl)/noplants(pl)*(CM_DN(pl,t,k))
                                 - a_down(pl)$(gen_hist(pl))$tfirst(t) - cap_min(pl)/noplants(pl)$(NOT gen_hist(pl))$tfirst(t)
                                 + gen_hist(pl)$tfirst(t)
;

CM_def_onupdn(pl,mapkt(k,t_cm(t)))$cap_max(pl)..
         CM_ON(pl,t,k) - sum(kk$pred(kk,k), CM_ON(pl,t-1,kk)) - on_hist(pl)$(not taufirst and tfirst(t))
                         =E=     CM_UP(pl,t,k) - CM_DN(pl,t,k)
;
*------------------------------------------ ONLINE/ OFFLINE TIME RESTRICTIONS ------------------------------------
*CM_res_on(pl,mapkt(k,t),mmapkt(kk,tt))$(ord(tt) ge ord(t) + 1
*                                        and ord(tt) le ord(t) + ontime(pl)
*                                        and cap_max(pl)
*                                        and ances_full(k,kk)
*                                        and t_cm(t)
*                                        and t_cm(tt))..
*         CM_ON(pl,tt,kk) =G=     CM_ON(pl,t,k) - sum(kkk$pred(kkk,k), CM_ON(pl,t-1,kkk)) - on_hist(pl)$tfirst(t)
*;

*CM_res_off(pl,mapkt(k,t),mmapkt(kk,tt))$(ord(tt) ge ord(t) + 1
*                                         and ord(tt) le ord(t) + offtime(pl)
*                                         and cap_max(pl)
*                                          and ances_full(k,kk)
*                                         and t_cm(t)
*                                         and t_cm(tt))..
*         1 - CM_ON(pl,tt,kk)
*                         =G=     sum(kkk$pred(kkk,k), CM_ON(pl,t-1,kkk)) - CM_ON(pl,t,k) + on_hist(pl)$tfirst(t)
*;

CM_res_on(pl,mapkt(k,t_cm(t)))$(cap_max(pl) and ontime(pl))..
         CM_DN(pl,t,k)$plclust(pl) + SUM((kk,tt)$(mmapkt(kk,tt) and t_id(tt) and ances_full(kk,k) and ord(tt) ge (ord(t) - ontime(pl) + 1) and ord(tt) lt ord(t)), CM_UP(pl,tt,kk))
                         =L=     sum(kk$pred(kk,k), CM_ON(pl,t-1,kk)) + on_hist(pl)$(not taufirst and tfirst(t)) - up_hist_clust(pl,t)$plclust(pl)
;

CM_res_off(pl,mapkt(k,t_cm(t)))$(cap_max(pl) and offtime(pl))..
         CM_UP(pl,t,k)$plclust(pl) + SUM((kk,tt)$(mmapkt(kk,tt) and t_id(tt) and ances_full(kk,k) and ord(tt) ge (ord(t) - offtime(pl) + 1) and ord(tt) lt ord(t)), CM_DN(pl,tt,kk))
                         =L=     noplants(pl) - sum(kk$pred(kk,k), CM_ON(pl,t-1,kk)) - on_hist(pl)$(not taufirst and tfirst(t)) - dn_hist_clust(pl,t)$plclust(pl)
;

*-------------------------------------------- STORAGE ----------------------------------------------------------
CM_res_v(j,mapkt(k,t_cm(t)))$l_max(j)..
         v_max(j)        =G=     CM_V(j,t,k) + res_h_up_bar(j,t)
;

CM_res_w(j,mapkt(k,t_cm(t)))$l_max(j)..
         w_max(j)        =G=     CM_W(j,t,k) + res_h_down_bar(j,t)
;

CM_res_l(j,mapkt(k,t_cm(t)))$l_max(j)..
         l_max(j)        =G=     CM_L(j,t,k) + res_h_down_bar(j,t)
;

CM_res_lmin(j,mapkt(k,t_cm(t)))$l_max(j)..
         CM_L(j,t,k) - res_h_up_bar(j,t)
                         =G=     l_min(j)
;

CM_lom_l(j,mapkt(k,t_cm(t)))$l_max(j)..
         CM_L(j,t,k)     =E=     sum(kk$pred(kk,k), CM_L(j,t-1,kk)) + l_0(j)$tfirst(t)
                                 + eta(j)*CM_W(j,t,k) - CM_V(j,t,k)
;
*--------------------------------------------- DEFINITIONS ------------------------------------------------------
CM_def_GEN(pl,mapkt(k,t_cm(t)))$cap_max(pl)..
         CM_GEN(pl,t,k)  =E=     gen_da_id_bar(pl,t,k) + CM_GEN_CM(pl,t,k)
;

CM_def_V(j,mapkt(k,t_cm(t)))$l_max(j)..
         CM_V(j,t,k)     =E=     v_da_id_bar(j,t,k) + CM_V_CM(j,t,k)
;

CM_def_W(j,mapkt(k,t_cm(t)))$l_max(j)..
         CM_W(j,t,k)     =E=     w_da_id_bar(j,t,k) + CM_W_CM(j,t,k)
;

*--------------------------------------------- MUST RUN ------------------------------------------------------
* Cummulative conventional capacity
CM_res_mustr(mapkt(k,t_cm(t)))$mustrun(t)..
         sum(pl$plmr(pl), CM_GEN(pl,t,k))
                         =G=     mustrun(t)$(mustrun(t) gt 1)
                                 + mustrun(t)*sum(c, dem(t,c))$(mustrun(t) ge 0 and mustrun(t) le 1)
;

* CHP plants
CM_res_mrCHP(pl,mapkt(k,t_cm(t)))$mrCHP(pl,t)..
         CM_GEN(pl,t,k)
                         =G=     mrCHP(pl,t)*cap_max(pl)
;

*--------------------------------------------- RENEWABLES ----------------------------------------------------
CM_def_REN_BID(r,n,mapkt(k,t_cm(t)))..
         CM_REN_BID(r,n,t,k)
                         =E=     SUM(c$mapnc(n,c), SUM(ren, splitren(n,ren)*ren_sto_tmp(c,ren,t,k))) - ren_curt_da_id_bar(r,n,t,k) - CM_REN_CURT_CM(r,n,t,k)
;


CM_res_REN_BID(r,n,mapkt(k,t_cm(t)))..
         SUM(c$mapnc(n,c), SUM(ren, splitren(n,ren)*ren_sto_tmp(c,ren,t,k)))
                         =G=     CM_REN_BID(r,n,t,k)
;
*--------------------------------------------- NETWORK ----------------------------------------------------
CM_res_pmax_pos(l,mapkt(k,t_cm(t)))$cap_l(l)..
        cap_l(l)*cap_factor
                         =G=     sum(n, ptdf(l,n)*CM_NETINPUT(n,t,k))
                                 + sum(ll, psdf(l,ll)*CM_ALPHA(ll,t,k))*BaseMVA
;

CM_res_pmax_neg(l,mapkt(k,t_cm(t)))$cap_l(l)..
        sum(n, ptdf(l,n)*CM_NETINPUT(n,t,k))
        + sum(ll, psdf(l,ll)*CM_ALPHA(ll,t,k))*BaseMVA
                         =G=     - cap_l(l)*cap_factor
;

CM_res_hvdcmax(hvdc(n,nn),mapkt(k,t_cm(t)))$cap_hvdc(n,nn)..
        cap_hvdc(n,nn)
                         =G=     CM_HVDCFLOW(n,nn,t,k)
;

CM_res_grid(grid,mapkt(k,t_cm(t)))..
         SUM(n$mapngrid(n,grid), CM_NETINPUT(n,t,k))
                         =E=     0
;

CM_res_ntc(c,cc,mapkt(k,t_cm(t)))$ntc(c,cc,t)..
        ntc(c,cc,t)     =G=     transfer_da_id_bar(c,cc,t,k) + CM_TRANSFER_CM(c,cc,t,k)
;

CM_res_transfer(c,cc,mapkt(k,t_cm(t)))..
        transfer_da_id_bar(c,cc,t,k) + CM_TRANSFER_CM(c,cc,t,k)
                         =G=     0
;

CM_res_alpha_pos(l,mapkt(k,t_cm(t)))..
         CM_ALPHA(l,t,k) =L=     (30/(180/Pi))$sum(ll, psdf(ll,l))
;

CM_res_alpha_neg(l,mapkt(k,t_cm(t)))..
         CM_ALPHA(l,t,k) =G=     -(30/(180/Pi))$sum(ll, psdf(ll,l))
;

model congestionmanagement /
*                Objective
                  CM_obj
                  CM_def_CS
                  CM_def_CD

*                Market Clearings
                  CM_mkt
                  CM_mkt_country
                  CM_mkt_node

*                Technical
                  CM_res_gmax
                  CM_res_gmin
                  CM_res_rup
                  CM_res_rdown
                  CM_res_on
                  CM_res_off
                  CM_def_gen_max
                  CM_def_gen_min
                  CM_def_onupdn

*                Storage
                  CM_res_v
                  CM_res_w
                  CM_res_l
                  CM_res_lmin
                  CM_lom_l

*                Defintions
                  CM_def_gen
                  CM_def_V
                  CM_def_W

*                Renewables
                  CM_def_REN_BID
                  CM_res_REN_BID

*                Must Run
                  CM_res_mustr
                  CM_res_mrCHP

*                Network constraints
                  CM_res_pmax_pos
                  CM_res_pmax_neg
                  CM_res_hvdcmax
                  CM_res_grid
                  CM_res_ntc
                  CM_res_transfer
                  CM_res_alpha_pos
                  CM_res_alpha_neg

/;
