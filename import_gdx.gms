$STITLE Import GDX Result Files
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

$if not setglobal resultdir $set resultdir results/

********************************************************************************
*    ------------------------- INITIALIZE -----------------------------
********************************************************************************
*$label reporting

SET
         merged_DA       /dayahead_t0001*dayahead_t9000/
         merged_ID       /intraday_t0001*intraday_t9000/
         merged_CM       /congestionmanagement_t0001*congestionmanagement_t9000/
         merged_preCM    /precongestionmanagement_t0001*precongestionmanagement_t9000/
;

* Define import parameter
PARAMETER
* DAYAHEAD
*                Generation, curtailment and reserve
                 up_fr_da_gen(*,plj,tau)
                 up_fr_da_w(*,plj,tau)
                 up_fr_da_v(*,plj,tau)
                 up_fr_da_l(*,plj,tau)
                 up_fr_da_ren(*,r,tau)
                 up_fr_da_curt(*,r,tau)
                 up_fr_da_res_s(*,res,plj,tau)
                 up_fr_da_res_ns(*,plj,tau)
                 up_fr_da_res_h(*,res,plj,tau)

*                Prices
                 up_fr_da_price_gen(*,tau)
                 up_fr_da_price_res(*,res,tau)

*                Infeasibility and cost
                 up_fr_da_infes(*,tau)
                 up_fr_da_cost(*,tau)
                 up_fr_da_cs(*,plj,tau)
                 up_fr_da_cd(*,plj,tau)
                 up_fr_da_status(*,plj,tau)
                 up_fr_da_frc(*,c,r,tau)

*                Country level reports
                 up_fr_da_price_country(*,c,tau)
                 up_fr_da_transfer(*,c,cc,tau)
                 up_fr_da_price_ntc(*,c,cc,tau)

*                Node level reports
                 up_fr_da_infes_node(*,n,tau)
*                 up_fr_da_price_node(*,n,tau)
*                 up_fr_da_netin_node(*,n,tau)
*                 up_fr_da_lineflow(*,l,tau)
                 up_fr_da_curt_node(*,r,n,tau)
                 up_fr_da_ren_node(*,r,n,tau)
                 up_fr_da_ren_fc_node(*,r,n,tau)
*                 up_fr_da_price_line_pos(*,l,tau)
*                 up_fr_da_price_line_neg(*,l,tau)

* INTRADAY
*                Generation
                  up_fr_id_gen_to(*,plj,tau)
                  up_fr_id_ren_to(*,r,tau)
                  up_fr_id_w_to(*,plj,tau)
                  up_fr_id_v_to(*,plj,tau)
                  up_fr_id_l(*,plj,tau)

*                Intraday corrections
                  up_fr_id_gen_id(*,plj,tau)
                  up_fr_id_ren_id(*,r,tau)
                  up_fr_id_w_id(*,plj,tau)
                  up_fr_id_v_id(*,plj,tau)

*                status, infeasibilities, cost, price
                  up_fr_id_status(*,plj,tau)
                  up_fr_id_cs(*,plj,tau)
                  up_fr_id_cd(*,plj,tau)
                  up_fr_id_cost(*,tau)
                  up_fr_id_infes(*,tau)
                  up_fr_id_price(*,tau)
                  up_fr_id_frc(*,r,tau)

*                country level report
                  up_fr_id_price_country(*,c,tau)
                  up_fr_id_transfer(*,c,cc,tau)
                  up_fr_id_price_ntc(*,c,cc,tau)

*                node level report
                  up_fr_id_infes_node(*,n,tau)
*                  up_fr_id_price_node(*,n,tau)
*                  up_fr_id_netin_node(*,n,tau)
*                  up_fr_id_lineflow(*,l,tau)
                  up_fr_id_curt_node(*,r,n,tau)
                  up_fr_id_ren_node(*,r,n,tau)
                  up_fr_id_ren_fc_node(*,r,n,tau)
*                  up_fr_id_price_line_pos(*,l,tau)
*                  up_fr_id_price_line_neg(*,l,tau)

* CONGESTION MANAGEMENT
*                Redispatch
                  up_fr_cm_delta_gen(*,plj,tau)
                  up_fr_cm_ren_curt(*,r,tau)
                  up_fr_cm_l(*,plj,tau)
                  up_fr_cm_w_cm(*,plj,tau)
                  up_fr_cm_v_cm(*,plj,tau)

*                status, infeasibilities, cost, price
                  up_fr_cm_status(*,plj,tau)
                  up_fr_cm_cs(*,plj,tau)
                  up_fr_cm_cd(*,plj,tau)
                  up_fr_cm_cost(*,tau)
                  up_fr_cm_infes(*,tau)
                  up_fr_cm_infes2(*,tau)
                  up_fr_cm_price(*,tau)
                  up_fr_cm_delta_transfer(*,c,cc,tau)

*                node level report
                  up_fr_cm_infes_node(*,n,tau)
                  up_fr_cm_price_node(*,n,tau)
                  up_fr_cm_netin_node(*,n,tau)
                  up_fr_cm_lineflow(*,l,tau)
                  up_fr_cm_prelineflow(*,l,tau)
                  up_fr_cm_curt_node(*,r,n,tau)
                  up_fr_cm_price_line_pos(*,l,tau)
                  up_fr_cm_price_line_neg(*,l,tau)
                  up_fr_cm_infes2_node(*,n,tau)
                  up_fr_cm_hvdcflow(*,n,nn,tau)
                  up_fr_cm_price_hvdc(*,n,nn,tau)
                  up_fr_cm_alpha(*,l,tau)
;
********************************************************************************
*    ------------------------- MERGE GDX -----------------------------
********************************************************************************
EXECUTE "gdxmerge %resultdir%dayahead*.gdx output=%resultdir%merged_DA";
EXECUTE "gdxmerge %resultdir%intraday*.gdx output=%resultdir%merged_ID";
EXECUTE "gdxmerge %resultdir%precongestionmanagement*.gdx output=%resultdir%merged_preCM";
EXECUTE "gdxmerge %resultdir%congestionmanagement*.gdx output=%resultdir%merged_CM";
*$stop
********************************************************************************
*    ------------------------- IMPORT GDX -----------------------------
********************************************************************************

* Load dayahead
                 EXECUTE_LOAD "%resultdir%merged_DA.gdx"
                              merged_DA = Merged_set_1
                              up_fr_da_gen = fr_da_gen
                              up_fr_da_w = fr_da_w
                              up_fr_da_v = fr_da_v
                              up_fr_da_l = fr_da_l
                              up_fr_da_ren = fr_da_ren
                              up_fr_da_curt = fr_da_curt
                              up_fr_da_res_s = fr_da_res_s
                              up_fr_da_res_ns = fr_da_res_ns
                              up_fr_da_res_h = fr_da_res_h

*                             Prices
                              up_fr_da_price_gen = fr_da_price_gen
                              up_fr_da_price_res = fr_da_price_res

*                             Infeasibility and cost
                              up_fr_da_infes = fr_da_infes
                              up_fr_da_cost = fr_da_cost
                              up_fr_da_cs = fr_da_cs
                              up_fr_da_cd = fr_da_cd
                              up_fr_da_status = fr_da_status
                              up_fr_da_frc = fr_da_frc

*                             Country level reports
                              up_fr_da_price_country = fr_da_price_country
                              up_fr_da_transfer = fr_da_transfer
                              up_fr_da_price_ntc = fr_da_price_ntc

*                             Node level reports
                              up_fr_da_infes_node = fr_da_infes_node
*                             up_fr_da_price_node = fr_da_price_node
*                             up_fr_da_netin_node = fr_da_netin_node
*                             up_fr_da_lineflow =  fr_da_lineflow
                              up_fr_da_curt_node = fr_da_curt_node
                              up_fr_da_ren_node = fr_da_ren_node
                              up_fr_da_ren_fc_node = fr_da_ren_fc_node
*                             up_fr_da_price_line_pos = fr_da_price_line_pos
*                             up_fr_da_price_line_neg = fr_da_price_line_neg
                    ;

*                Generation, curtailment and reserve
                 fr_da_gen(pl,tau) = sum(merged_DA, up_fr_da_gen(merged_DA,pl,tau));
                 fr_da_w(j,tau) = sum(merged_DA, up_fr_da_w(merged_DA,j,tau));
                 fr_da_v(j,tau) = sum(merged_DA, up_fr_da_v(merged_DA,j,tau));
                 fr_da_l(j,tau) = sum(merged_DA, up_fr_da_l(merged_DA,j,tau));
                 fr_da_ren(r,tau) = sum(merged_DA, up_fr_da_ren(merged_DA,r,tau));
                 fr_da_curt(r,tau) = sum(merged_DA, up_fr_da_curt(merged_DA,r,tau));
                 fr_da_res_s(res,pl,tau) = sum(merged_DA, up_fr_da_res_s(merged_DA,res,pl,tau));
                 fr_da_res_ns(pl,tau) = sum(merged_DA, up_fr_da_res_ns(merged_DA,pl,tau));
                 fr_da_res_h(res,j,tau) = sum(merged_DA, up_fr_da_res_h(merged_DA,res,j,tau));

*                Prices
                 fr_da_price_gen(tau)= sum(merged_DA, up_fr_da_price_gen(merged_DA,tau));
                 fr_da_price_res(res,tau)= sum(merged_DA, up_fr_da_price_res(merged_DA,res,tau));

*                Infeasibility and cost
                 fr_da_infes(tau)  = sum(merged_DA, up_fr_da_infes(merged_DA,tau));
                 fr_da_cost(tau) = sum(merged_DA, up_fr_da_cost(merged_DA,tau));
                 fr_da_cs(pl,tau) = sum(merged_DA, up_fr_da_cs(merged_DA,pl,tau));
                 fr_da_cd(pl,tau) = sum(merged_DA, up_fr_da_cd(merged_DA,pl,tau));
                 fr_da_status(pl,tau)  = sum(merged_DA, up_fr_da_status(merged_DA,pl,tau));
                 fr_da_frc(c,r,tau) = sum(merged_DA, up_fr_da_frc(merged_DA,c,r,tau));

*                Country level reports
                 fr_da_price_country(c,tau) = sum(merged_DA, up_fr_da_price_country(merged_DA,c,tau));
                 fr_da_transfer(c,cc,tau) = sum(merged_DA, up_fr_da_transfer(merged_DA,c,cc,tau));
                 fr_da_price_ntc(c,cc,tau) = sum(merged_DA, up_fr_da_price_ntc(merged_DA,c,cc,tau));

*                Node level reports
                 fr_da_infes_node(n,tau) = sum(merged_DA, up_fr_da_infes_node(merged_DA,n,tau));
*                 fr_da_price_node(n,tau) = sum(merged_DA, up_fr_da_price_node(merged_DA,n,tau));
*                 fr_da_netin_node(n,tau) = sum(merged_DA, up_fr_da_netin_node(merged_DA,n,tau));
*                 fr_da_lineflow(l,tau) = sum(merged_DA, up_fr_da_lineflow(merged_DA,l,tau));
                 fr_da_curt_node(r,n,tau) = sum(merged_DA, up_fr_da_curt_node(merged_DA,r,n,tau));
                 fr_da_ren_node(r,n,tau) = sum(merged_DA, up_fr_da_ren_node(merged_DA,r,n,tau));
                 fr_da_ren_fc_node(r,n,tau) = sum(merged_DA, up_fr_da_ren_fc_node(merged_DA,r,n,tau));
*                 fr_da_price_line_pos(l,tau) = sum(merged_DA, up_fr_da_price_line_pos(merged_DA,l,tau));
*                 fr_da_price_line_neg(l,tau) = sum(merged_DA, up_fr_da_price_line_neg(merged_DA,l,tau));

                  OPTION kill=up_fr_da_gen, kill=up_fr_da_w, kill=up_fr_da_v, kill=up_fr_da_l, kill=up_fr_da_ren, kill=up_fr_da_curt, kill=up_fr_da_res_s, kill=up_fr_da_res_s, kill=up_fr_da_res_ns, kill=up_fr_da_res_h,
                         kill=up_fr_da_price_gen, kill=up_fr_da_price_res,
                         kill=up_fr_da_infes, kill=up_fr_da_cs, kill=up_fr_da_cd, kill=up_fr_da_status, kill=up_fr_da_frc,
                         kill=up_fr_da_price_country, kill=up_fr_da_transfer, kill=up_fr_da_price_ntc,
                         kill=up_fr_da_infes_node, kill=up_fr_da_curt_node, kill=up_fr_da_ren_node, kill=up_fr_da_ren_fc_node,
*                         kill=up_fr_da_price_node, kill=up_fr_da_netin_node, kill=up_fr_da_lineflow, kill=up_fr_da_price_line_pos, kill=up_fr_da_price_line_neg,
                         kill=up_fr_da_cost;

* Load intraday
$IFTHEN %solve_id%==YES
         EXECUTE_LOAD "%resultdir%merged_ID.gdx"
                      merged_ID = Merged_set_1
                      up_fr_id_gen_to = fr_id_gen_to
                      up_fr_id_ren_to = fr_id_ren_to
                      up_fr_id_w_to = fr_id_w_to
                      up_fr_id_v_to = fr_id_v_to
                      up_fr_id_l = fr_id_l

*                     Intraday corrections
                      up_fr_id_gen_id = fr_id_gen_id
                      up_fr_id_ren_id = fr_id_ren_id
                      up_fr_id_w_id = fr_id_w_id
                      up_fr_id_v_id = fr_id_v_id

*                     Infeasibility and cost
                      up_fr_id_status = fr_id_status
                      up_fr_id_cs = fr_id_cs
                      up_fr_id_cd = fr_id_cd
                      up_fr_id_cost = fr_id_cost
                      up_fr_id_infes = fr_id_infes
                      up_fr_id_price = fr_id_price
                      up_fr_id_frc = fr_id_frc

*                     Country level reports
                      up_fr_id_price_country = fr_id_price_country
                      up_fr_id_transfer = fr_id_transfer
                      up_fr_id_price_ntc = fr_id_price_ntc

*                     Node level reports
                      up_fr_id_infes_node = fr_id_infes_node
*                     up_fr_id_price_node = fr_id_price_node
*                     up_fr_id_netin_node = fr_id_netin_node
*                     up_fr_id_lineflow =  fr_id_lineflow
                      up_fr_id_curt_node = fr_id_curt_node
                      up_fr_id_ren_node = fr_id_ren_node
                      up_fr_id_ren_fc_node = fr_id_ren_fc_node
*                     up_fr_id_price_line_pos = fr_id_price_line_pos
*                     up_fr_id_price_line_neg = fr_id_price_line_neg
;
*                Generation
                 fr_id_gen_to(pl,tau) = sum(merged_ID, up_fr_id_gen_to(merged_ID,pl,tau));
                 fr_id_ren_to(r,tau) = sum(merged_ID, up_fr_id_ren_to(merged_ID,r,tau));
                 fr_id_w_to(j,tau) = sum(merged_ID, up_fr_id_w_to(merged_ID,j,tau));
                 fr_id_v_to(j,tau) = sum(merged_ID, up_fr_id_v_to(merged_ID,j,tau));
                 fr_id_l(j,tau) = sum(merged_ID, up_fr_id_l(merged_ID,j,tau));

*                Intraday corrections
                 fr_id_gen_id(pl,tau) = sum(merged_ID, up_fr_id_gen_id(merged_ID,pl,tau));
                 fr_id_ren_id(r,tau) = sum(merged_ID, up_fr_id_ren_id(merged_ID,r,tau));
                 fr_id_w_id(j,tau) = sum(merged_ID, up_fr_id_w_id(merged_ID,j,tau));
                 fr_id_v_id(j,tau) = sum(merged_ID, up_fr_id_v_id(merged_ID,j,tau));


*                Infeasibility and cost
                 fr_id_status(pl,tau)  = sum(merged_ID, up_fr_id_status(merged_ID,pl,tau));
                 fr_id_cs(pl,tau) = sum(merged_ID, up_fr_id_cs(merged_ID,pl,tau));
                 fr_id_cd(pl,tau) = sum(merged_ID, up_fr_id_cd(merged_ID,pl,tau));
                 fr_id_cost(tau) = sum(merged_ID, up_fr_id_cost(merged_ID,tau));
                 fr_id_infes(tau)  = sum(merged_ID, up_fr_id_infes(merged_ID,tau));
                 fr_id_price(tau) = sum(merged_ID, up_fr_id_price(merged_ID,tau));
                 fr_id_frc(r,tau) = sum(merged_ID, up_fr_id_frc(merged_ID,r,tau));

*                Country level reports
                 fr_id_price_country(c,tau) = sum(merged_ID, up_fr_id_price_country(merged_ID,c,tau));
                 fr_id_transfer(c,cc,tau) = sum(merged_ID, up_fr_id_transfer(merged_ID,c,cc,tau));
                 fr_id_price_ntc(c,cc,tau) = sum(merged_ID, up_fr_id_price_ntc(merged_ID,c,cc,tau));

*                Node level reports
                 fr_id_infes_node(n,tau) = sum(merged_ID, up_fr_id_infes_node(merged_ID,n,tau));
*                 fr_id_price_node(n,tau) = sum(merged_ID, up_fr_id_price_node(merged_ID,n,tau));
*                 fr_id_netin_node(n,tau) = sum(merged_ID, up_fr_id_netin_node(merged_ID,n,tau));
*                 fr_id_lineflow(l,tau) = sum(merged_ID, up_fr_id_lineflow(merged_ID,l,tau));
                 fr_id_curt_node(r,n,tau) = sum(merged_ID, up_fr_id_curt_node(merged_ID,r,n,tau));
                 fr_id_ren_node(r,n,tau) = sum(merged_ID, up_fr_id_ren_node(merged_ID,r,n,tau));
                 fr_id_ren_fc_node(r,n,tau) = sum(merged_ID, up_fr_id_ren_fc_node(merged_ID,r,n,tau));
*                 fr_id_price_line_pos(l,tau) = sum(merged_ID, up_fr_id_price_line_pos(merged_ID,l,tau));
*                 fr_id_price_line_neg(l,tau) = sum(merged_ID, up_fr_id_price_line_neg(merged_ID,l,tau));

         OPTION kill=up_fr_id_gen_to, kill=up_fr_id_ren_to, kill=up_fr_id_w_to, kill=up_fr_id_v_to, kill=up_fr_id_l,
                kill=up_fr_id_gen_id, kill=up_fr_id_ren_id, kill=up_fr_id_w_id, kill=up_fr_id_v_id,
                kill=up_fr_id_status, kill=up_fr_id_cs, kill=up_fr_id_cd, kill=up_fr_id_cost, kill=up_fr_id_infes, kill=up_fr_id_price, kill=up_fr_id_frc,
                kill=up_fr_id_price_country, kill=up_fr_id_transfer, kill=up_fr_id_price_ntc,
                kill=up_fr_id_infes_node, kill=up_fr_id_curt_node, kill=up_fr_id_ren_node, kill=up_fr_id_ren_fc_node
*               , kill=up_fr_id_price_node, kill=up_fr_id_netin_node, kill=up_fr_id_lineflow, kill=up_fr_id_price_line_pos, kill=up_fr_id_price_line_neg
                ;

$ENDIF

* Load congestion management
$IFTHEN %solve_cm%==YES
* PRE CONGESTION MANAGEMENT
             Execute_load "%resultdir%merged_preCM.gdx"
                          merged_preCM = Merged_set_1
                          up_fr_cm_prelineflow = fr_cm_prelineflow
;
                 fr_cm_prelineflow(l,ttau) = SUM(merged_preCM,up_fr_cm_prelineflow(merged_preCM,l,ttau));

* CONGESTION MANAGEMENT
         EXECUTE_LOAD "%resultdir%merged_CM.gdx"
                      merged_CM = Merged_set_1
                      up_fr_cm_delta_gen = fr_cm_delta_gen
                      up_fr_cm_ren_curt = fr_cm_ren_curt
                      up_fr_cm_l = fr_cm_l
                      up_fr_cm_w_cm = fr_cm_w_cm
                      up_fr_cm_v_cm = fr_cm_v_cm

*                     Infeasibility and cost
                      up_fr_cm_status = fr_cm_status
                      up_fr_cm_cs = fr_cm_cs
                      up_fr_cm_cd = fr_cm_cd
                      up_fr_cm_cost = fr_cm_cost
                      up_fr_cm_infes = fr_cm_infes
                      up_fr_cm_infes2 = fr_cm_infes2
                      up_fr_cm_price = fr_cm_price
                      up_fr_cm_delta_transfer = fr_cm_delta_transfer

*                     Node level reports
                      up_fr_cm_infes_node = fr_cm_infes_node
                      up_fr_cm_infes2_node = fr_cm_infes2_node
                      up_fr_cm_price_node = fr_cm_price_node
                      up_fr_cm_netin_node = fr_cm_netin_node
                      up_fr_cm_lineflow =  fr_cm_lineflow
                      up_fr_cm_curt_node = fr_cm_curt_node
                      up_fr_cm_price_line_pos = fr_cm_price_line_pos
                      up_fr_cm_price_line_neg = fr_cm_price_line_neg
                      up_fr_cm_hvdcflow = fr_cm_hvdcflow
                      up_fr_cm_price_hvdc = fr_cm_price_hvdc
                      up_fr_cm_alpha = fr_cm_alpha
;
*                Redispatch
                 fr_cm_delta_gen(pl,tau) = sum(merged_CM, up_fr_cm_delta_gen(merged_CM,pl,tau));
                 fr_cm_ren_curt(r,tau) = sum(merged_CM, up_fr_cm_ren_curt(merged_CM,r,tau));
                 fr_cm_l(j,tau) = sum(merged_CM, up_fr_cm_l(merged_CM,j,tau));
                 fr_cm_w_cm(j,tau) = sum(merged_CM, up_fr_cm_w_cm(merged_CM,j,tau));
                 fr_cm_v_cm(j,tau) = sum(merged_CM, up_fr_cm_v_cm(merged_CM,j,tau));

*                Infeasibility and cost
                 fr_cm_status(pl,tau)  = sum(merged_CM, up_fr_cm_status(merged_CM,pl,tau));
                 fr_cm_cs(pl,tau) = sum(merged_CM, up_fr_cm_cs(merged_CM,pl,tau));
                 fr_cm_cd(pl,tau) = sum(merged_CM, up_fr_cm_cd(merged_CM,pl,tau));
                 fr_cm_cost(tau) = sum(merged_CM, up_fr_cm_cost(merged_CM,tau));
                 fr_cm_infes(tau)  = sum(merged_CM, up_fr_cm_infes(merged_CM,tau));
                 fr_cm_infes2(tau)  = sum(merged_CM, up_fr_cm_infes2(merged_CM,tau));
                 fr_cm_price(tau) = sum(merged_CM, up_fr_cm_price(merged_CM,tau));
                 fr_cm_delta_transfer(c,cc,tau) = sum(merged_CM, up_fr_cm_delta_transfer(merged_CM,c,cc,tau));

*                Node level reports
                 fr_cm_infes_node(n,tau) = sum(merged_CM, up_fr_cm_infes_node(merged_CM,n,tau));
                 fr_cm_infes2_node(n,tau) = sum(merged_CM, up_fr_cm_infes2_node(merged_CM,n,tau));
                 fr_cm_price_node(n,tau) = sum(merged_CM, up_fr_cm_price_node(merged_CM,n,tau));
                 fr_cm_netin_node(n,tau) = sum(merged_CM, up_fr_cm_netin_node(merged_CM,n,tau));
                 fr_cm_lineflow(l,tau) = sum(merged_CM, up_fr_cm_lineflow(merged_CM,l,tau));
                 fr_cm_curt_node(r,n,tau) = sum(merged_CM, up_fr_cm_curt_node(merged_CM,r,n,tau));
                 fr_cm_price_line_pos(l,tau) = sum(merged_CM, up_fr_cm_price_line_pos(merged_CM,l,tau));
                 fr_cm_price_line_neg(l,tau) = sum(merged_CM, up_fr_cm_price_line_neg(merged_CM,l,tau));
                 fr_cm_hvdcflow(hvdc(n,nn),tau) = sum(merged_CM, up_fr_cm_hvdcflow(merged_CM,n,nn,tau));
                 fr_cm_price_hvdc(hvdc(n,nn),tau) = sum(merged_CM, up_fr_cm_price_hvdc(merged_CM,n,nn,tau));
                 fr_cm_alpha(l,tau) = sum(merged_CM, up_fr_cm_alpha(merged_CM,l,tau));

         OPTION kill=up_fr_cm_delta_gen, kill=up_fr_cm_ren_curt, kill=up_fr_cm_l, kill=up_fr_cm_w_cm, kill=up_fr_cm_v_cm,
                kill=up_fr_cm_status, kill=up_fr_cm_cs, kill=up_fr_cm_cd, kill=up_fr_cm_cost, kill=up_fr_cm_infes, kill=up_fr_cm_infes2, kill=up_fr_cm_price, kill=up_fr_cm_delta_transfer,
                kill=up_fr_cm_infes_node, kill=up_fr_cm_infes2_node, kill=up_fr_cm_price_node, kill=up_fr_cm_netin_node, kill=up_fr_cm_lineflow, kill=up_fr_cm_curt_node,
                kill=up_fr_cm_price_line_pos, kill=up_fr_cm_price_line_neg, kill=up_fr_cm_hvdcflow, kill=up_fr_cm_price_hvdc,
                kill=up_fr_cm_prelineflow,kill=up_fr_cm_alpha;

$ENDIF
