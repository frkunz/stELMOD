$STITLE Deterministic Congestion Management Model

Free Variable
         CM_COST            total cost
         CM_NETINPUT        netinput in MW

         CM_GEN_CM          change of generation
         CM_V_CM            change in release
         CM_W_CM            change in pumping
         CM_WIND_CURT_CM    curtailment congestion management

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

         CM_WIND_BID        renewbale energy bid
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
         CM_def_WIND_BID    definition of renewable bidding in intraday market
         CM_res_WIND_BID    upper bound on wind bidding

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
                                 sum((t_cm(t),pl)$cap_max(pl), (mc(pl)*CM_GEN_CM(pl,t) + CM_CS(pl,t) + CM_CD(pl,t)))
                                 + sum((t_cm(t),n), pen_infes*(CM_INFES_MKT(n,t)+CM_INFES_MKT2(n,t)))
                                 + sum((t_cm(t),r,n), c_curt(r)*CM_WIND_CURT_CM(r,n,t))
                                 )
                                 /scaler
;

CM_def_CS(pl,t_cm(t))$(cap_max(pl) and sc(pl))..
         CM_CS(pl,t)     =G=     sc(pl)/noplants(pl)*(CM_ON(pl,t) - CM_ON(pl,t-1) - status_da_id_bar(pl,t) - on_hist(pl)$(not taufirst and tfirst(t)))
;

CM_def_CD(pl,t_cm(t))$(cap_max(pl) and su(pl))..
         CM_CD(pl,t)     =G=     su(pl)/noplants(pl)*(status_da_id_bar(pl,t) + CM_ON(pl,t-1) - CM_ON(pl,t) + on_hist(pl)$(not taufirst and tfirst(t)))
;

*------------------------------------- MARKET CLEARING EQUATIONS -----------------------------------
CM_mkt(t_cm(t))..
         sum(pl$cap_max(pl), CM_GEN_CM(pl,t))
         + sum(j$v_max(j), CM_V_CM(j,t) - CM_W_CM(j,t))
         - sum((r,n), CM_WIND_CURT_CM(r,n,t))
         + sum(n, CM_INFES_MKT(n,t)) - sum(n, CM_INFES_MKT2(n,t))
                         =E=
                                 0
;

CM_mkt_country(c,t_cm(t))..
         sum(n$mapnc(n,c), sum(pl$(mappln(pl,n) and cap_max(pl)), CM_GEN_CM(pl,t)))
         + sum(n$mapnc(n,c), sum(j$(mappln(j,n) and v_max(j)), CM_V_CM(j,t) - CM_W_CM(j,t)))
         - sum((n)$mapnc(n,c), sum(r, CM_WIND_CURT_CM(r,n,t)))
         + sum(n$mapnc(n,c), CM_INFES_MKT(n,t)) - sum(n$mapnc(n,c), CM_INFES_MKT2(n,t))
                         =E=
                                 + sum(cc$ntc(c,cc,t), CM_TRANSFER_CM(c,cc,t))
                                 - sum(cc$ntc(cc,c,t), CM_TRANSFER_CM(cc,c,t))
;

CM_mkt_node(n,t_cm(t))..
          sum(pl$(mappln(pl,n) and cap_max(pl)), CM_GEN(pl,t))
          + sum(j$(mappln(j,n) and v_max(j)), CM_V(j,t) - CM_W(j,t))
          + sum((r), CM_WIND_BID(r,n,t))
          + infes_da_id_bar(n,t) + CM_INFES_MKT(n,t) - CM_INFES_MKT2(n,t)
                         =E=
                                 sum(c$mapnc(n,c), splitdem(n)*dem(t,c))
                                 + exchange(n,t)
                                 + CM_NETINPUT(n,t)
                                 + sum(nn$hvdc(n,nn), CM_HVDCFLOW(n,nn,t) - CM_HVDCFLOW(nn,n,t))
;

*------------------------------------ TECHNICAL CONSTRAINTS ----------------------------------------
CM_res_gmax(pl,t_cm(t))$cap_max(pl)..
         CM_ON(pl,t)*cap_max(pl)/noplants(pl)*avail(pl,t) - res_s_up_bar(pl,t)
                         =G=     CM_GEN(pl,t)
;

CM_res_gmin(pl,t_cm(t))$cap_max(pl)..
         CM_GEN(pl,t)
                         =G=     CM_ON(pl,t)*cap_min(pl)/noplants(pl) + res_s_down_bar(pl,t)
;

CM_res_rup(pl,t_cm(t))$(a_up(pl) and cap_max(pl))..
         CM_GEN_MAX(pl,t)
                         =G=     CM_GEN(pl,t) + res_s_up_bar(pl,t)
;

CM_res_rdown(pl,t_cm(t))$(a_down(pl) and cap_max(pl))..
         CM_GEN(pl,t) - res_s_down_bar(pl,t)
                         =G=     CM_GEN_MIN(pl,t)
;

CM_def_gen_max(pl,t_cm(t))$(a_up(pl) and cap_max(pl))..
          CM_GEN(pl,t-1)
          + a_up(pl)* CM_ON(pl,t-1) + cap_min(pl)/noplants(pl)*(CM_UP(pl,t))
          + a_up(pl)$gen_hist(pl)$tfirst(t) + cap_min(pl)/noplants(pl)*(NOT gen_hist(pl))$tfirst(t)
          + gen_hist(pl)$tfirst(t)
                         =E=     CM_GEN_MAX(pl,t)
;

CM_def_GEN_MIN(pl,t_cm(t))$(a_down(pl) and cap_max(pl))..
         CM_GEN_MIN(pl,t)
                         =G=     CM_GEN(pl,t-1)
                                 - a_down(pl)*(CM_ON(pl,t)) - cap_min(pl)/noplants(pl)*(CM_DN(pl,t))
                                 - a_down(pl)$(gen_hist(pl))$tfirst(t) - cap_min(pl)/noplants(pl)$(NOT gen_hist(pl))$tfirst(t)
                                 + gen_hist(pl)$tfirst(t)
;

CM_def_onupdn(pl,t_cm(t))$cap_max(pl)..
         CM_ON(pl,t) - CM_ON(pl,t-1) - on_hist(pl)$(not taufirst and tfirst(t))
                         =E=     CM_UP(pl,t) - CM_DN(pl,t)
;
*------------------------------------------ ONLINE/ OFFLINE TIME RESTRICTIONS ------------------------------------
CM_res_on(pl,t_cm(t))$(cap_max(pl) and ontime(pl))..
         CM_DN(pl,t)$plclust(pl) + SUM(tt$(ord(tt) ge (ord(t) - ontime(pl) + 1) and ord(tt) lt ord(t)), CM_UP(pl,tt))
                         =L=     CM_ON(pl,t-1) + on_hist(pl)$(not taufirst and tfirst(t)) - up_hist_clust(pl,t)$plclust(pl)
;

CM_res_off(pl,t_cm(t))$(cap_max(pl) and offtime(pl))..
         CM_UP(pl,t)$plclust(pl) + SUM(tt$(ord(tt) ge (ord(t) - offtime(pl) + 1) and ord(tt) lt ord(t)), CM_DN(pl,tt))
                         =L=     noplants(pl) - CM_ON(pl,t-1) - on_hist(pl)$(not taufirst and tfirst(t)) - dn_hist_clust(pl,t)$plclust(pl)
;

*-------------------------------------------- STORAGE ----------------------------------------------------------
CM_res_v(j,t_cm(t))$l_max(j)..
         v_max(j)        =G=     CM_V(j,t) + res_h_up_bar(j,t)
;

CM_res_w(j,t_cm(t))$l_max(j)..
         w_max(j)        =G=     CM_W(j,t) + res_h_down_bar(j,t)
;

CM_res_l(j,t_cm(t))$l_max(j)..
         l_max(j)        =G=     CM_L(j,t) + res_h_down_bar(j,t)
;

CM_res_lmin(j,t_cm(t))$l_max(j)..
         CM_L(j,t) - res_h_up_bar(j,t)
                         =G=     l_min(j)
;

CM_lom_l(j,t_cm(t))$l_max(j)..
         CM_L(j,t)       =E=     CM_L(j,t-1) + l_0(j)$tfirst(t)
                                 + eta(j)*CM_W(j,t) - CM_V(j,t)
;
*--------------------------------------------- DEFINITIONS ------------------------------------------------------
CM_def_GEN(pl,t_cm(t))$cap_max(pl)..
         CM_GEN(pl,t)    =E=     gen_da_id_bar(pl,t) + CM_GEN_CM(pl,t)
;

CM_def_V(j,t_cm(t))$l_max(j)..
         CM_V(j,t)       =E=     v_da_id_bar(j,t) + CM_V_CM(j,t)
;

CM_def_W(j,t_cm(t))$l_max(j)..
         CM_W(j,t)       =E=     w_da_id_bar(j,t) + CM_W_CM(j,t)
;

*--------------------------------------------- MUST RUN ------------------------------------------------------
* Cummulative conventional capacity
CM_res_mustr(t_cm(t))$mustrun(t)..
         sum(pl$plmr(pl), CM_GEN(pl,t))
                         =G=     mustrun(t)$(mustrun(t) gt 1)
                                 + mustrun(t)*sum(c, dem(t,c))$(mustrun(t) ge 0 and mustrun(t) le 1)
;

* CHP plants
CM_res_mrCHP(pl,t_cm(t))$mrCHP(pl,t)..
         CM_GEN(pl,t)
                         =G=     mrCHP(pl,t)*cap_max(pl)
;

*--------------------------------------------- RENEWABLES ----------------------------------------------------
CM_def_WIND_BID(r,n,t_cm(t))..
         CM_WIND_BID(r,n,t)
                         =E=     SUM(c$mapnc(n,c), SUM(ren, splitren(n,ren)*wind_tmp(c,ren,t))) - wind_curt_da_id_bar(r,n,t) - CM_WIND_CURT_CM(r,n,t)
;


CM_res_WIND_BID(r,n,t_cm(t))..
         SUM(c$mapnc(n,c), SUM(ren, splitren(n,ren)*wind_tmp(c,ren,t)))
                         =G=     CM_WIND_BID(r,n,t)
;
*--------------------------------------------- NETWORK ----------------------------------------------------
CM_res_pmax_pos(l,t_cm(t))$cap_l(l)..
        cap_l(l)*cap_factor
                         =G=     sum(n, ptdf(l,n)*CM_NETINPUT(n,t))
                                 + sum(ll, psdf(l,ll)*CM_ALPHA(ll,t))*BaseMVA
;

CM_res_pmax_neg(l,t_cm(t))$cap_l(l)..
        sum(n, ptdf(l,n)*CM_NETINPUT(n,t))
        + sum(ll, psdf(l,ll)*CM_ALPHA(ll,t))*BaseMVA
                         =G=     - cap_l(l)*cap_factor
;

CM_res_hvdcmax(hvdc(n,nn),t_cm(t))$cap_hvdc(n,nn)..
        cap_hvdc(n,nn)
                         =G=     CM_HVDCFLOW(n,nn,t)
;

CM_res_grid(grid,t_cm(t))..
         SUM(n$mapngrid(n,grid), CM_NETINPUT(n,t))
                         =E=     0
;

CM_res_ntc(c,cc,t_cm(t))$ntc(c,cc,t)..
        ntc(c,cc,t)     =G=     transfer_da_id_bar(c,cc,t) + CM_TRANSFER_CM(c,cc,t)
;

CM_res_transfer(c,cc,t_cm(t))..
        transfer_da_id_bar(c,cc,t) + CM_TRANSFER_CM(c,cc,t)
                         =G=     0
;

CM_res_alpha_pos(l,t_cm(t))..
         CM_ALPHA(l,t)   =L=     (30/(180/Pi))$sum(ll, psdf(ll,l))
;

CM_res_alpha_neg(l,t_cm(t))..
         CM_ALPHA(l,t)   =G=     -(30/(180/Pi))$sum(ll, psdf(ll,l))
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
                  CM_def_WIND_BID
                  CM_res_WIND_BID

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
