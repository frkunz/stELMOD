$STITLE Dayahead Model

Free Variable
         DA_COST            total cost
         DA_NETINPUT        netinput in MW
;

Positive Variable
         DA_GEN             generation
         DA_L               reservoir level
         DA_V               reservoir release
         DA_W               reservoir pupmping
         DA_CS              startup cost
         DA_CD              shut down cost

         DA_RES_S           spinning reserve
         DA_RES_NS          non-spinning reserve
         DA_RES_H           hydro reserve

         DA_GEN_MIN         possible minimum generation
         DA_GEN_MAX         possible maximum generation

         DA_TRANSFER        transactional transfer between countries

         DA_WIND_BID        renewbale energy bid
         DA_WIND_CURT       renewable energy curtailment
         DA_INFES_MKT       slack in market clearing equation
;

Integer Variable
         DA_ON              status of plants
         DA_UP              startup of plants
         DA_DN              shutdown of plants
;

Equations
         DA_obj             objective definition

*        Market clearing equations
         DA_mkt             market clearing or energy balance electricity
         DA_mkt_country     market clearing at country level
         DA_mkt_node        market clearing at node level
         DA_mkt_sres_up_2   market clearing upward secondary reserve
         DA_mkt_sres_down_2 market clearing downward secondary reserve
         DA_mkt_sres_up_3   market clearing upward spinning reserve
         DA_mkt_sres_down_3 market clearing upward spinning reserve
         DA_def_CS          startup cost definition
         DA_def_CD          shut down cost definition

         DA_mkt_res         reserve market clearing conditions

*        Minimum/maximum generation restrictions
         DA_res_gmax        maximum generation constraint
         DA_res_gmax_dec    maximum decentral generation constraint
         DA_res_gmin        minimum generation constraint
         DA_res_rup         upward ramping constraint
         DA_res_rdown       downward ramping constraint
         DA_res_nres_up     upper bound on non-spinning reserve
         DA_def_gen_max     possible maximum generation definition
         DA_def_gen_min     possible minimum generation definition
         DA_def_onupdn      plant status balance

*        Minimum online/offline time restrictions
         DA_res_on          online restrition
         DA_res_off         offline restriction

*        Storage related restrictions
         DA_res_v           upper release bound
         DA_res_w           upper pump bound
         DA_res_l           upper resevoir level bound
         DA_res_lmin        lower bound on storage
         DA_lom_l           law of motion reservoir level

*        Must run constraint
         DA_res_mustr       must run constraint
         DA_res_mrCHP       must run CHP plants

*        Renewables
         DA_def_WIND_BID    definition of renewable bidding

*        Network
         DA_res_ntc         transactional transfer limit
         DA_res_pmax_pos    thermal line limit
         DA_res_pmax_neg    thermal line limit
;

*------------------------------------------ OBJECTIVE -----------------------------------------------
DA_obj..
         DA_COST         =E=     (sum((t_da(t),pl)$cap_max(pl), mc(pl)*DA_GEN(pl,t) + DA_CS(pl,t) + DA_CD(pl,t))
                                 + sum((t_da(t),pl)$cap_max(pl), cr(pl)*sum(res, DA_RES_S(res,pl,t) + DA_RES_NS(pl,t)$plns(res,pl)))
                                 + sum((t_da(t),j)$v_max(j), cr(j)*sum(res, DA_RES_H(res,j,t)))
                                 + sum((t_da(t),n), pen_infes*DA_INFES_MKT(n,t))
                                 + sum((t_da(t),r,n), c_curt(r)*DA_WIND_CURT(r,n,t))
                                 )/scaler
;

DA_def_CS(pl,t_da(t))$(cap_max(pl) and sc(pl))..
         DA_CS(pl,t)     =G=     sc(pl)/noplants(pl)*DA_UP(pl,t)
;

DA_def_CD(pl,t_da(t))$(cap_max(pl) and su(pl))..
         DA_CD(pl,t)     =G=     su(pl)/noplants(pl)*DA_DN(pl,t)
;

*------------------------------------- MARKET CLEARING EQUATIONS -----------------------------------
DA_mkt(t_da(t))..
         sum(pl$cap_max(pl), DA_GEN(pl,t)) + sum(j$v_max(j), DA_V(j,t) - DA_W(j,t)) + sum((r,n), DA_WIND_BID(r,n,t)) + sum(n, DA_INFES_MKT(n,t))
                         =E=
                                 sum(c, dem(t,c)) + sum(n, exchange(n,t))
;

DA_mkt_country(c,t_da(t))$dem(t,c)..
          sum(n$mapnc(n,c), sum(pl$(mappln(pl,n) and cap_max(pl)), DA_GEN(pl,t)))
          + sum(n$mapnc(n,c), sum(j$(mappln(j,n) and v_max(j)), DA_V(j,t) - DA_W(j,t)))
          + sum(n$mapnc(n,c), sum(r, DA_WIND_BID(r,n,t))) + sum(n$mapnc(n,c), DA_INFES_MKT(n,t))
                         =E=
                                 dem(t,c) + sum(n, exchange(n,t))
                                 + sum(cc$ntc(c,cc,t), DA_TRANSFER(c,cc,t))
                                 - sum(cc$ntc(cc,c,t), DA_TRANSFER(cc,c,t))
;

DA_mkt_node(n,t_da(t))..
          sum(pl$(mappln(pl,n) and cap_max(pl)), DA_GEN(pl,t)) + sum(j$(mappln(j,n) and v_max(j)), DA_V(j,t) - DA_W(j,t))
          + sum(r, DA_WIND_BID(r,n,t)) + DA_INFES_MKT(n,t)
                         =E=
                                 sum(c$mapnc(n,c), splitdem(n)*dem(t,c))
                                 + exchange(n,t)
                                 + DA_NETINPUT(n,t)
;

DA_mkt_res(res,t_da(t),c)$dem_res(res,t,c)..
         sum(n$mapnc(n,c), sum(pl$(plr(res,pl) and mappln(pl,n) and cap_max(pl)), DA_RES_S(res,pl,t)))
         + sum(n$mapnc(n,c), sum(j$(plr(res,j) and mappln(j,n) and v_max(j)), DA_RES_H(res,j,t)))
         + sum(n$mapnc(n,c), sum(pl$(plns(res,pl) and mappln(pl,n) and cap_max(pl)), DA_RES_NS(pl,t)))
                         =E=     dem_res(res,t,c)
;

*------------------------------------ TECHNICAL CONSTRAINTS ----------------------------------------
DA_res_gmax(pl,t_da(t))$cap_max(pl)..
         DA_ON(pl,t)*cap_max(pl)/noplants(pl)*avail(pl,t)
                         =G=     DA_GEN(pl,t) + sum(res$mapresDir(res,"up"), DA_RES_S(res,pl,t))
;

DA_res_gmin(pl,t_da(t))$cap_max(pl)..
         DA_GEN(pl,t) - sum(res$mapresDir(res,"down"), DA_RES_S(res,pl,t))
                         =G=     DA_ON(pl,t)*cap_min(pl)/noplants(pl)
;

DA_res_rup(pl,t_da(t))$(a_up(pl) and cap_max(pl))..
         DA_GEN_MAX(pl,t)
                         =G=     DA_GEN(pl,t) + sum(res$mapresDir(res,"up"), DA_RES_S(res,pl,t))
;

DA_res_rdown(pl,t_da(t))$(a_down(pl) and cap_max(pl))..
         DA_GEN(pl,t) - sum(res$mapresDir(res,"down"), DA_RES_S(res,pl,t))
                         =G=     DA_GEN_MIN(pl,t)
;

DA_def_gen_max(pl,t_da(t))$(a_up(pl) and cap_max(pl))..
          DA_GEN(pl,t-1)
          + a_up(pl)*(DA_ON(pl,t-1)) + cap_min(pl)/noplants(pl)*(DA_UP(pl,t))
          + a_up(pl)$gen_hist(pl)$tfirst(t) + cap_min(pl)/noplants(pl)$(NOT gen_hist(pl))$tfirst(t)
          + gen_hist(pl)$tfirst(t)
                         =E=     DA_GEN_MAX(pl,t)
;

DA_def_GEN_MIN(pl,t_da(t))$(a_down(pl) and cap_max(pl))..
         DA_GEN_MIN(pl,t)
                         =G=     DA_GEN(pl,t-1)
                                 - a_down(pl)*(DA_ON(pl,t)) - cap_min(pl)/noplants(pl)*(DA_DN(pl,t))
                                 - a_down(pl)$gen_hist(pl)$tfirst(t) - cap_min(pl)/noplants(pl)$(NOT gen_hist(pl))$tfirst(t)
                                 + gen_hist(pl)$tfirst(t)
;

DA_res_nres_up(pl,t_da(t))$(sum(res, plns(res,pl)) and cap_max(pl))..
         a_up(pl)*(noplants(pl)-DA_ON(pl,t))
         + avail(pl,t)*cap_max(pl)/noplants(pl)*(noplants(pl)-DA_ON(pl,t))$(not a_up(pl))
                         =G=     DA_RES_NS(pl,t)
;

DA_def_onupdn(pl,t_da(t))$cap_max(pl)..
         DA_ON(pl,t) - DA_ON(pl,t-1) - on_hist(pl)$(not taufirst and tfirst(t))
                         =E=     DA_UP(pl,t) - DA_DN(pl,t)
;
*------------------------------------------ ONLINE/ OFFLINE TIME RESTRICTIONS ------------------------------------
DA_res_on(pl,t_da(t))$(cap_max(pl) and ontime(pl))..
         DA_DN(pl,t)$plclust(pl) + SUM(tt$(ord(tt) ge (ord(t) - ontime(pl) + 1) and ord(tt) lt ord(t)), DA_UP(pl,tt))
                         =L=     DA_ON(pl,t-1) + on_hist(pl)$(not taufirst and tfirst(t)) - up_hist_clust(pl,t)$plclust(pl)
;

DA_res_off(pl,t_da(t))$(cap_max(pl) and offtime(pl))..
         DA_UP(pl,t)$plclust(pl) + SUM(tt$(ord(tt) ge (ord(t) - offtime(pl) + 1) and ord(tt) lt ord(t)), DA_DN(pl,tt))
                         =L=     noplants(pl) - DA_ON(pl,t-1) - on_hist(pl)$(not taufirst and tfirst(t)) - dn_hist_clust(pl,t)$plclust(pl)
;

*-------------------------------------------- STORAGE ----------------------------------------------------------
DA_res_v(j,t_da(t))$l_max(j)..
         v_max(j)        =G=     DA_V(j,t) + sum(res$mapresDir(res,"up"), DA_RES_H(res,j,t))
;

DA_res_w(j,t_da(t))$l_max(j)..
         w_max(j)        =G=     DA_W(j,t) + sum(res$mapresDir(res,"down"), DA_RES_H(res,j,t))
;

DA_res_l(j,t_da(t))$l_max(j)..
         l_max(j)        =G=     DA_L(j,t) + sum(res$mapresDir(res,"down"), DA_RES_H(res,j,t))
;

DA_res_lmin(j,t_da(t))$l_max(j)..
         DA_L(j,t) - sum(res$mapresDir(res,"up"), DA_RES_H(res,j,t))
                         =G=     l_min(j)
;

DA_lom_l(j,t_da(t))$l_max(j)..
         DA_L(j,t)       =E=     DA_L(j,t-1) + l_0(j)$tfirst(t)
                                 + eta(j)*DA_W(j,t) - DA_V(j,t)
;

*--------------------------------------------- MUST RUN ------------------------------------------------------
* Cummulative conventional capacity
DA_res_mustr(t_da(t))$mustrun(t)..
         sum(pl$plmr(pl), DA_GEN(pl,t))
                         =G=     mustrun(t)$(mustrun(t) gt 1)
                                 + mustrun(t)*sum(c, dem(t,c))$(mustrun(t) ge 0 and mustrun(t) le 1)
;

* CHP plants
DA_res_mrCHP(pl,t_da(t))$mrCHP(pl,t)..
         DA_GEN(pl,t)    =G=     mrCHP(pl,t)*cap_max(pl)
;

*--------------------------------------------- RENEWABLES ----------------------------------------------------

DA_def_WIND_BID(r,n,t_da(t))..
         DA_WIND_BID(r,n,t)
                         =E=     SUM(c$mapnc(n,c), SUM(ren, wind_fc(c,ren,t)*splitren(n,ren))) - DA_WIND_CURT(r,n,t)
;

*--------------------------------------------- NETWORK ----------------------------------------------------
DA_res_ntc(c,cc,t_da(t))$ntc(c,cc,t)..
        ntc(c,cc,t)      =G=     DA_TRANSFER(c,cc,t)
;

DA_res_pmax_pos(l,t_da(t))$cap_l(l)..
        cap_l(l)         =G=     sum(n, ptdf(l,n)*DA_NETINPUT(n,t))
;

DA_res_pmax_neg(l,t_da(t))$cap_l(l)..
        sum(n, ptdf(l,n)*DA_NETINPUT(n,t))
                         =G=     - cap_l(l)
;


model dayahead /
*                Objective
                  DA_obj
                  DA_def_CS
                  DA_def_CD

*                Market Clearings
                  DA_mkt
                  DA_mkt_country
*                  DA_mkt_node
                  DA_mkt_res

*                Technical
                  DA_res_gmax
                  DA_res_gmin
                  DA_res_on
                  DA_res_off
                  DA_res_nres_up
                  DA_res_rup
                  DA_res_rdown
                  DA_def_gen_max
                  DA_def_gen_min
                  DA_def_onupdn

*                Storage
                  DA_res_v
                  DA_res_w
                  DA_res_l
                  DA_res_lmin
                  DA_lom_l

*                Must Run
                  DA_res_mustr
                  DA_res_mrCHP

*                Renewables
                  DA_def_WIND_BID

*                Network constraints
                  DA_res_ntc
*                  DA_res_pmax_pos
*                  DA_res_pmax_neg
/;
