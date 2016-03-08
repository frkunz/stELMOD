$STITLE Stochastic Intraday Model

Free Variable
         ID_COST         total cost

         ID_GEN_ID       biddings in intraday market
         ID_V_ID         intraday release
         ID_W_ID         intraday pumping
         ID_WIND_CURT_ID curtailment intraday

         ID_NETINPUT     netinput in MW
;


Positive Variable
         ID_GEN          generation
         ID_L            reservoir level
         ID_V            reservoir release
         ID_W            reservoir pupmping
         ID_CS           startup cost
         ID_CD           shut down cost

         ID_GEN_MAX      possible maximum generation
         ID_GEN_MIN      possible minimum generation

         ID_TRANSFER     transactional transfer between countries

         ID_WIND_BID     renewbale energy bid
         ID_INFES_MKT    feasibility slack on market clearing equation
;

Integer Variable
         ID_ON           status of plants
         ID_UP           startup of plants
         ID_DN           shutdown of plants

;

positive variable infe;
Equations
         ID_obj                  objective intraday market
         ID_def_CS               startup cost definition
         ID_def_CD               shutdown cost definition

*        Market clearings
         ID_mkt                  market clearing intraday model
         ID_mkt_country          market clearing at country level
         ID_mkt_node             market clearing at node level

*        Technical constraints
         ID_res_gmax             intraday maximum generation constraint
         ID_res_gmin             intraday minimum generation constraint
         ID_res_rup              intraday upward ramping constraint
         ID_res_rdown            intraday downward ramping constraint
         ID_res_on               intraday online time restriction
         ID_res_off              intraday offline time restriction
         ID_def_gen_max          intraday maximum generation definition
         ID_def_gen_min          intraday minimum generation definition
         ID_def_onupdn

*        Storage
         ID_res_v                intraday upper release bound
         ID_res_w                intraday upper storage bound
         ID_res_l                intraday pump storage level constraints
         ID_res_lmin             intraday lower pump storage constraint
         ID_lom_l                intraday law of motion storage level

*        Defintions
         ID_def_gen              intraday total generation definition
         ID_def_V                definition total reservoir release
         ID_def_W                definition total reservoir pumping

*        Renewables
         ID_def_WIND_BID         definition of renewable bidding in intraday market
         ID_res_WIND_BID         upper bound on wind bidding

*        Must run
         ID_res_mustr            intraday must run constraint
         ID_res_mrCHP            intraday mustrun CHP plants

*        Network
         ID_res_ntc              transactional transfer limit
         ID_res_pmax_pos         uppper thermal transmission limit
         ID_res_pmax_neg         lower thermal transmission limit
;


ID_obj..
         ID_COST         =E=     (
                                 sum((mapkt(k,t_id(t)),pl)$cap_max(pl), prob(t,k)*(mc(pl)*ID_GEN(pl,t,k) + ID_CS(pl,t,k) + ID_CD(pl,t,k)))
                                 + sum((mapkt(k,t_id(t)),n), prob(t,k)*pen_infes*ID_INFES_MKT(n,t,k))
                                 + sum((mapkt(k,t_id(t)),n,r), prob(t,k)*c_curt(r)*(wind_curt_bar(r,n,t) + ID_WIND_CURT_ID(r,n,t,k)))
                                 )
                                 /scaler
;

ID_def_CS(pl,mapkt(k,t_id(t)))$(cap_max(pl) and sc(pl))..
         ID_CS(pl,t,k)   =G=     sc(pl)/noplants(pl)*ID_UP(pl,t,k)
;

ID_def_CD(pl,mapkt(k,t_id(t)))$(cap_max(pl) and su(pl))..
         ID_CD(pl,t,k)   =G=     su(pl)/noplants(pl)*ID_DN(pl,t,k)
;

*---------------------------------------- MARKET CLEARING -----------------------------------------------
ID_mkt(mapkt(k,t_id(t)))..
         sum(pl$cap_max(pl), ID_GEN(pl,t,k)) + sum(j$v_max(j), ID_V(j,t,k) - ID_W(j,t,k)) + sum((n,r), ID_WIND_BID(r,n,t,k)) + sum(n,ID_INFES_MKT(n,t,k))
                         =E=
                                 sum(c, dem(t,c)) + sum(n, exchange(n,t))
;

ID_mkt_country(c,mapkt(k,t_id(t)))$dem(t,c)..
         sum(n$mapnc(n,c), sum(pl$(mappln(pl,n) and cap_max(pl)), ID_GEN(pl,t,k))) + sum(n$mapnc(n,c), sum(j$(mappln(j,n) and v_max(j)), ID_V(j,t,k) - ID_W(j,t,k))) +
          sum(n$mapnc(n,c), sum(r, ID_WIND_BID(r,n,t,k))) + sum(n$mapnc(n,c), ID_INFES_MKT(n,t,k))
                         =E=
                                 dem(t,c) + sum(n, exchange(n,t))
                                 + sum(cc$ntc(c,cc,t), ID_TRANSFER(c,cc,t,k))
                                 - sum(cc$ntc(cc,c,t), ID_TRANSFER(cc,c,t,k))
;

ID_mkt_node(n,mapkt(k,t_id(t)))..
         sum(pl$mappln(pl,n), ID_GEN(pl,t,k)) + sum(j$mappln(j,n), ID_V(j,t,k) - ID_W(j,t,k)) +
          sum(r, ID_WIND_BID(r,n,t,k)) + ID_INFES_MKT(n,t,k)
                         =E=
                                 sum(c$mapnc(n,c), splitdem(n)*dem(t,c))
                                 + exchange(n,t)
                                 + ID_NETINPUT(n,t,k)
;
*------------------------------------ MINIMUM/MAXIMUM GENERATION CONSTRAINTS ----------------------------
ID_res_gmax(pl,mapkt(k,t_id(t)))$cap_max(pl)..
         ID_ON(pl,t,k)*cap_max(pl)/noplants(pl)*avail(pl,t) - res_s_up_bar(pl,t)
                         =G=     ID_GEN(pl,t,k)
;

ID_res_gmin(pl,mapkt(k,t_id(t)))$cap_max(pl)..
         ID_GEN(pl,t,k)  =G=     ID_ON(pl,t,k)*cap_min(pl)/noplants(pl) + res_s_down_bar(pl,t)
;

ID_res_rup(pl,mapkt(k,t_id(t)))$(a_up(pl) and cap_max(pl))..
         ID_GEN_MAX(pl,t,k)
                         =G=     ID_GEN(pl,t,k) + res_s_up_bar(pl,t)
;

ID_res_rdown(pl,mapkt(k,t_id(t)))$(a_down(pl) and cap_max(pl))..
         ID_GEN(pl,t,k) - res_s_down_bar(pl,t)
                         =G=     ID_GEN_MIN(pl,t,k)
;


ID_def_gen_max(pl,mapkt(k,t_id(t)))$(a_up(pl) and cap_max(pl))..
          sum(kk$pred(kk,k), ID_GEN(pl,t-1,kk))
          + a_up(pl)* sum(kk$pred(kk,k), ID_ON(pl,t-1,kk)) + cap_min(pl)/noplants(pl)*(ID_UP(pl,t,k))
          + a_up(pl)$gen_hist(pl)$tfirst(t) + cap_min(pl)/noplants(pl)$(NOT gen_hist(pl))$tfirst(t)
          + gen_hist(pl)$tfirst(t)
                         =E=     ID_GEN_MAX(pl,t,k)
;

ID_def_GEN_MIN(pl,mapkt(k,t_id(t)))$(a_down(pl) and cap_max(pl))..
         ID_GEN_MIN(pl,t,k)
                         =G=     sum(kk$pred(kk,k), ID_GEN(pl,t-1,kk)) - a_down(pl)*(ID_ON(pl,t,k)) - cap_min(pl)/noplants(pl)*(ID_DN(pl,t,k))
                                 - a_down(pl)$gen_hist(pl)$tfirst(t) - cap_min(pl)/noplants(pl)$(NOT gen_hist(pl))$tfirst(t)
                                 + gen_hist(pl)$tfirst(t)
;

ID_def_onupdn(pl,mapkt(k,t_id(t)))$cap_max(pl)..
         ID_ON(pl,t,k) - sum(kk$pred(kk,k), ID_ON(pl,t-1,kk)) - on_hist(pl)$(not taufirst and tfirst(t))
                         =E=     ID_UP(pl,t,k) - ID_DN(pl,t,k)
;
*------------------------------------------ ONLINE/ OFFLINE TIME RESTRICTIONS ------------------------------------
*ID_res_on(pl,mapkt(k,t),mmapkt(kk,tt))$(ord(tt) ge ord(t) + 1
*                                        and ord(tt) le ord(t) + ontime(pl)
*                                        and cap_max(pl)
*                                        and ances_full(k,kk)
*                                        and t_id(t)
*                                        and t_id(tt))..
*         ID_ON(pl,tt,kk) =G=     ID_ON(pl,t,k) - sum(kkk$pred(kkk,k), ID_ON(pl,t-1,kkk)) - on_hist(pl)$tfirst(t)
*;

*ID_res_off(pl,mapkt(k,t),mmapkt(kk,tt))$(ord(tt) ge ord(t) + 1
*                                         and ord(tt) le ord(t) + offtime(pl)
*                                         and cap_max(pl)
*                                         and ances_full(k,kk)
*                                         and t_id(t)
*                                         and t_id(tt))..
*         1 - ID_ON(pl,tt,kk)
*                         =G=     sum(kkk$pred(kkk,k), ID_ON(pl,t-1,kkk)) - ID_ON(pl,t,k) + on_hist(pl)$tfirst(t)
*;

* formulation works only for deterministic cases
*ID_res_on(pl,mapkt(k,t_id(t)))$(cap_max(pl) and ontime(pl))..
*         SUM((kk,tt)$(mmapkt(kk,tt) and t_id(tt) and ances_full(kk,k) and ord(tt) ge (ord(t) - ontime(pl) + 1) and ord(tt) le ord(t)), ID_UP(pl,tt,kk))
*                         =L=     ID_ON(pl,t,k)
*;

*ID_res_off(pl,mapkt(k,t_id(t)))$(cap_max(pl) and offtime(pl))..
*         SUM((kk,tt)$(mmapkt(kk,tt) and t_id(tt) and ances_full(kk,k) and ord(tt) ge (ord(t) - offtime(pl) + 1) and ord(tt) le ord(t)), ID_DN(pl,tt,kk))
*                         =L=     1 - ID_ON(pl,t,k)
*;

ID_res_on(pl,mapkt(k,t_id(t)))$(cap_max(pl) and ontime(pl))..
         ID_DN(pl,t,k)$plclust(pl) + SUM((kk,tt)$(mmapkt(kk,tt) and t_id(tt) and ances_full(kk,k) and ord(tt) ge (ord(t) - ontime(pl) + 1) and ord(tt) lt ord(t)), ID_UP(pl,tt,kk))
                         =L=     sum(kk$pred(kk,k), ID_ON(pl,t-1,kk)) + on_hist(pl)$(not taufirst and tfirst(t)) - up_hist_clust(pl,t)$plclust(pl)
;

ID_res_off(pl,mapkt(k,t_id(t)))$(cap_max(pl) and offtime(pl))..
         ID_UP(pl,t,k)$plclust(pl) + SUM((kk,tt)$(mmapkt(kk,tt) and t_id(tt) and ances_full(kk,k) and ord(tt) ge (ord(t) - offtime(pl) + 1) and ord(tt) lt ord(t)), ID_DN(pl,tt,kk))
                         =L=     noplants(pl) - sum(kk$pred(kk,k), ID_ON(pl,t-1,kk)) - on_hist(pl)$(not taufirst and tfirst(t)) - dn_hist_clust(pl,t)$plclust(pl)
;

*-------------------------------------------- STORAGE ----------------------------------------------------------
ID_res_v(j,mapkt(k,t_id(t)))$l_max(j)..
         v_max(j)        =G=     ID_V(j,t,k) + res_h_up_bar(j,t)
;

ID_res_w(j,mapkt(k,t_id(t)))$l_max(j)..
         w_max(j)        =G=     ID_W(j,t,k) + res_h_down_bar(j,t)
;

ID_res_l(j,mapkt(k,t_id(t)))$l_max(j)..
         l_max(j)        =G=     ID_L(j,t,k) + res_h_down_bar(j,t)
;

ID_res_lmin(j,mapkt(k,t_id(t)))$l_max(j)..
         ID_L(j,t,k) - res_h_up_bar(j,t)
                         =G=     l_min(j)
;

ID_lom_l(j,mapkt(k,t_id(t)))$l_max(j)..
         ID_L(j,t,k)     =E=     sum(kk$pred(kk,k), ID_L(j,t-1,kk)) + l_0(j)$tfirst(t)
                                 + eta(j)*ID_W(j,t,k) - ID_V(j,t,k)
;

*--------------------------------------------- DEFINITIONS ------------------------------------------------------
ID_def_GEN(pl,mapkt(k,t_id(t)))$cap_max(pl)..
         ID_GEN(pl,t,k)  =E=     gen_bar(pl,t) + ID_GEN_ID(pl,t,k)
;

ID_def_V(j,mapkt(k,t_id(t)))$l_max(j)..
         ID_V(j,t,k)     =E=     v_bar(j,t) + ID_V_ID(j,t,k)
;

ID_def_W(j,mapkt(k,t_id(t)))$l_max(j)..
         ID_W(j,t,k)     =E=     w_bar(j,t) + ID_W_ID(j,t,k)
;

*--------------------------------------------- MUST RUN ------------------------------------------------------
ID_res_mustr(mapkt(k,t_id(t)))$mustrun(t)..
         sum(pl$plmr(pl), ID_GEN(pl,t,k))
                         =G=     mustrun(t)$(mustrun(t) gt 1)
                                 + mustrun(t)*sum(c,dem(t,c))$(mustrun(t) ge 0 and mustrun(t) le 1)
;

ID_res_mrCHP(pl,mapkt(k,t_id(t)))$mrCHP(pl,t)..
         ID_GEN(pl,t,k)  =G=     mrCHP(pl,t)*cap_max(pl)
;

*--------------------------------------------- RENEWABLES ----------------------------------------------------
ID_def_WIND_BID(r,n,mapkt(k,t_id(t)))..
         ID_WIND_BID(r,n,t,k)
                         =E=     SUM(c$mapnc(n,c), SUM(ren, splitren(n,ren)*wind_sto_tmp(c,ren,t,k))) - wind_curt_bar(r,n,t) - ID_WIND_CURT_ID(r,n,t,k)
;


ID_res_WIND_BID(r,n,mapkt(k,t_id(t)))..
         SUM(c$mapnc(n,c), SUM(ren, splitren(n,ren)*wind_sto_tmp(c,ren,t,k)))
                         =G=     ID_WIND_BID(r,n,t,k)
;

*--------------------------------------------- NETWORK ----------------------------------------------------
ID_res_ntc(c,cc,mapkt(k,t_id(t)))$ntc(c,cc,t)..
        ntc(c,cc,t)      =G=     ID_TRANSFER(c,cc,t,k)
;

ID_res_pmax_pos(l,mapkt(k,t_id(t)))$cap_l(l)..
        cap_l(l)         =G=     sum(n, ptdf(l,n)*ID_NETINPUT(n,t,k))
;

ID_res_pmax_neg(l,mapkt(k,t_id(t)))$cap_l(l)..
        sum(n, ptdf(l,n)*ID_NETINPUT(n,t,k))
                         =G=     - cap_l(l)
;

model intraday /
*                Objective
                  ID_obj
                  ID_def_CS
                  ID_def_CD

*                Market Clearing
                  ID_mkt
                  ID_MKT_country
*                  ID_MKT_node

*                Technical constraints
                  ID_res_gmax
                  ID_res_gmin
                  ID_res_rup
                  ID_res_rdown
                  ID_res_on
                  ID_res_off
                  ID_def_gen_max
                  ID_def_gen_min
                  ID_def_onupdn

*                Storage
                  ID_res_v
                  ID_res_w
                  ID_res_l
                  ID_res_lmin
                  ID_lom_l

*                Definitions
                  ID_def_GEN
                  ID_def_V
                  ID_def_W

*                Must run
                  ID_res_mustr
                  ID_res_mrCHP

*                Renewables
                  ID_def_WIND_BID
                  ID_res_WIND_BID

*                Network
                  ID_res_ntc
*                  ID_res_pmax_pos
*                  ID_res_pmax_neg
/;
