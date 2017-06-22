$STITLE Upload and Process Input Data
$set debugdata no
$ifi not %debugdata%=="yes" $goto notdebugdata
$setglobal Techdata technologies
$setglobal DemData demand
$setglobal datadir data\
$setglobal renewable renewable
$setglobal renewable_det renewable_det

$if not set t_id $set t_id 36
$if not set t_da $set t_da 36
$if not set t_cm $set t_cm 1
$if not setglobal lag_id $setglobal lag_id 1
$if not setglobal clr_da $setglobal clr_da 12
$if not setglobal start_h $setglobal start_h 1
$label notdebugdata

* Compute maximum model horizon
$eval modelperiods max(%t_da%,%t_id%,%t_cm%)

*###############################################################################
*                        DEFIN SETS AND PARAMETER
*###############################################################################
set
*        Technology and plant sets
         i               set of technologies
         is(i)           set of storage technologies
         plj             set of power plants and pumpstorage
         pl(plj)         set of plants
         chp(plj)        subset of CHP plants
         j(plj)          set of pump storage facilities
         plbin           subset of power plants with unit commitment
         plclust         subset of power plants with clustered unit commitment
         ren             set of renewables
         r               set of renewables (aggregated)
         /RES/
         f               set of fuels
         plns            set of technologies qualifying for non-spinning reserve
         plr             set of technologies qualifying for reserve market
         plmr            set of plants contributing to must run requirement
         res             set of reserve markets
         /up2, up3, down2, down3/
         dir             set of reserve directions
         /up,down/
         grid            /UCTE,Nordel,"National Grid",Eirgrid,Baltic/

*        network data
         n               set of nodes
         l               set of lines
         c               set of countries
         hvdc            set of hvdc connections
*        uc(c)           set of countries with unit commiment (assigned after dataupload)

*        Mappings
         mapipl          mapping from technology to plants
         mappli          mapping from plants to technology
         mapij           mapping from technology to pump storage
         mapfi           mapping fuel to technology
         mapif           mapping technology to fuel
         mday            mapping from simulation horizon to days
         mh              mapping from simulation horizon to hours
         mapresDir       mapping from reserve market to directions
         /up2.up, up3.up, down2.down, down3.down/
         mappln          mapping plants to nodes
         mapnc           mapping nodes to country
         mapncgrid       mapping nodes to country and grid
         mapngrid        mapping nodes to grid
         maplfromto      mapping lines to 'from' and 'to' nodes

*        Time sets
         tau             set of time periods
         t               set of model horizon
         /t1*t%modelperiods%/
         tfirst(t)       first model period
         /t1/
         tlast(t)        last model period
         t_id(t)         set of intraday periods
         /t1*t%t_id%/
         tlast_id(t)     last period in intraday model
         /t%t_id%/
         t_da(t)         set of dayahead periods
         /t1*t%t_da%/
         tlast_da(t)     last period in dayahead model
         /t%t_da%/
         t_cm(t)         set of congestion management periods
         /t1*t%t_cm%/
         tlast_cm(t)     last period in congestion management model
         /t%t_cm%/
         day             set of days
         /day000*day370/
         hour            set of hours (ending hour)
         /hour01*hour24/
;
alias(tau,ttau,tttau),(t,tt,ttt), (t_id, tt_id, ttt_id), (t_da, tt_da, ttt_da), (n,nn), (c,cc), (l,ll);

parameter
*        Plants
         mc              marginal cost
         cr              reserve contribution cost
         sc              startup cost
         su              shut down cost
         offtime         required offline time (incl. shut down period)
         ontime          required online time (incl. startup period)
         plantime        required planning time
         cap_max         maximum generation
         cap_min         maximum generation
         a_up            upward ramping restrition when online (% of max generation)
         a_down          downward ramping restrition when online (% of max generation)
         carb_coef       carbon coefficient
         pf              fuel price
         avail           availability of plant on model horizon (% of max generation)
         avail_tau       availability of plant on simulation horizon (% of max generation)
         mrCHP           mustrun for CHP plants at model horizon (% of max generation)
         mrCHP_tau       mustrun for CHP plants at simulation horizon (% of max generation)
         noplants        number of plants (relevant for linearized unit commitment)

*        Storage
         l_max           maximum pump storage level
         l_min           minimum storage level
         v_max           maximum pump storage release per period
         w_max           maximum pumping per period
         l_0             initial storage level
         l_T             terminal storage level
         eta             pump efficiency

*        Network
         ptdf            PTDF matrix
         psdf            PSDF matrix
         cap_l           thermal limit of lines
         cap_hvdc        thermal limit of hvdc lines
         ntc             transactional net transfer capacity

*        Demands
         d               demand per simulation period
         dem             demand per model period
         dem_node        demand per model period and node
         d_res           reserve demand per simulation period
         dem_res         reserve demand per model period
         sres_up_2       upward secondary spinning reserve (absolute value)
         sres_down_2     downward secondary spinning reserve (absolute value)
         sres_up_3       upward tertiary spinning reserve (absolute value)
         sres_down_3     downward tertiary spinning reserve (absolute value)

         dem_res_up_2    upward secondary spinning reserve (absolute value) used in model
         dem_res_down_2  downward secondary spinning reserve (absolute value) used in model
         dem_res_up_3    upward tertiary spinning reserve (absolute value) used in model
         dem_res_down_3  downward tertiary spinning reserve (absolute value) used in model
         mustrun         must run amount of conventionals
         splitdem        distribution of demand to nodes

         exchange        exchange per model period

*        Renewables
         wind_fc         wind forecast in model
         splitren        distribution from renewables to nodes
         wind_fc_node    wind forecast on node basis
         wind_sto        stochastic wind forecast
         wind_tmp        temporary deterministic wind forecast
         wind_sto_tmp    temporary stochastic wind forecast
         wind_mean_tmp   temporary mean stochastic wind forecast
         c_curt          curtailment penalty
         wind_fc_da      wind forecast dayahead aggregated
         wind_rel        wind realization
*        +++ Following are defined in construct_tree_1.gms
*        ren_frc         renewable forecast on simulation horizon
*        ren_frc_prob    renewable forecast probability on simulation horizon


*        Initial conditions
         on_hist         historical plant status
         gen_hist        historical plant generation
         up_hist_clust   historical startup for linearized unit commitment
         dn_hist_clust   historical shutdown for linearized unit commitment
         taufirst        one for first period in simulation horizon

*        Values fixed in intraday
         gen_bar         pre contracted dayahead generation
         v_bar           pre contracted pump storage release
         w_bar           pre contracted pump storage pumping
         res_s_up_bar    pre contracted upward spinning reserve
         res_s_down_bar  pre contracted downward spinning reserve
         res_h_up_bar    pre contracted pump storage upward reserve
         res_h_down_bar  pre contracted pump storage downward reserve
         shed_wind_bar   pre contracted wind bid
         wind_frc_bar    dayahead wind forecast
         wind_curt_bar   pre contracted wind curtailment

*        Values fixed in congestion management
         gen_da_id_bar   pre contracted dayahead and intraday generation
         status_da_id_bar        dayahead and intraday generation status
         v_da_id_bar     pre contracted dayahead and intraday pump storage release
         w_da_id_bar     pre contracted dayahead and intraday pump storage pumping
         wind_curt_da_id_bar     pre contracted dayahead and intraday wind curtailment
         infes_da_id_bar dayahead and intraday infeasibility
         transfer_da_id_bar dayahead and intraday transfer

*        report parameter in rolling planning
         solved_id       solve status intraday models
         solved_da       solve status dayahead models
         solved_cm       solve status congestion management models
         bid_wind_da_bar wind bidding in dayahead market

*        For data upload
         demandup        demand upload
         techup          technology upload
         pumpup          pump storage data
         plantup         plant data
         fuelup          fuel data upload
         reserveup       reserve data upload
         taxesup         carbon tax upload
         renup           renewable upload
         mustrun_up      mustrun upload
         speedup         wind speed upload
         availup         availability upload
         lineup          upload of line data
         exchangeup      upload of exchange data
         ptdfup          upload of ptdf matrix
         CHPup           upload of CHP data
         nodeup          upload of node data
         hvdcup          upload of hvdc data
         countryup       upload of country data
         ntcup           hourly final ntc
         ntcup1          upload of yearly ntc
         ntcup2          upload of hourly ntc

*        Intermediate reports
         ir_status_id    intermediate report status intraday (expected value)
         ir_gen_id       intermediate report generation intraday (expected value)
         ir_status_sto_id        intermediate report status intraday (stochastic value)
         ir_gen_sto_id   intermediate report generation intraday (stochastic value)
         ir_v_sto_id     intermediate report storage release intraday (stochastic value)
         ir_w_sto_id     intermedaite report storage pumpimg intraday (stochastic value)
         ir_curt_sto_id  intermediate report curtailment intraday (stochastic value)
         ir_infes_sto_id intermediate report infeasibility (stochastic value)
         ir_v_id         intermediate report storage release intraday
         ir_w_id         intermedaite report storage pumpimg intraday
         ir_curt_id      intermediate report curtailment intraday
         ir_infes_id     intermediate report infeasibility
         ir_level_id     intermediate report storage level intraday (expected value)
         ir_time_off     intermediate report time to be offline
         ir_time_on      intermediate report time to be online
         ir_res_h        intermedaite report hydro storage
         ir_res_s        intermediate report spinning reserve
         ir_res_ns       intermediate report non-spinning
         ir_status_da    intermediate report status dayahead
         ir_gen_da       intermediate report generation dayahead
         ir_v_da         intermediate report storage release dayahead
         ir_w_da         intermedaite report storage pumpimg dayahead
         ir_level_da     intermediate report storage level dayahead
         ir_curt_da      intermediate report curtailment dayahead
         ir_price_da     intermediate report market price dayahead
         ir_transfer_da  intermediate report transfer dayahead
         ir_status_cm    intermediate report status congestion management
         ir_curt_cm      intermediate report curtailment congestion management
         ir_delta_gen_cm intermediate report redispatch congestion management
         ir_v_sto_cm     intermediate report storage release congestion management (stochastic value)
         ir_w_sto_cm     intermedaite report storage pumpimg congestion management (stochastic value)
         ir_v_cm         intermediate report storage release congestion management
         ir_w_cm         intermedaite report storage pumpimg congestion management
         ir_level_cm     intermediate report storage level congestion management (expected value)
         ir_time_off_clust       intermediate report offline time for linearized unit commitment
         ir_time_on_clust        intermediate report online time for linearized unit commitment

*        Final reports (aggregated level)
         fr_id_gen_to    final report intraday generation total
         fr_id_ren_to    final report intraday renewable supply
         fr_id_w_to      final report intraday pumping
         fr_id_v_to      final report intraday release
         fr_id_l         final report intraday storage level
         fr_id_gen_id    final report intraday generation correction
         fr_id_ren_id    final report intraday renewable curtailment
         fr_id_w_id      final report intraday pumping correction
         fr_id_v_id      final report intraday release correction
         fr_id_status    final report intraday status
         fr_id_cs        final report intraday startup cost
         fr_id_cd        final report intraday shutdown cost
         fr_id_cost      final report intraday total cost
         fr_id_infes     final report intraday infeasibility market clearing
         fr_id_price     final report intraday price
         fr_id_frc       final report intraday renewable forecast

         fr_da_gen       final report dayahead generation
         fr_da_w         final report dayahead pumping
         fr_da_v         final report dayahead release
         fr_da_l         final report dayahead level
         fr_da_ren       final report dayahead renewable supply
         fr_da_curt      final report dayahead renewable curtailment
         fr_da_res_s     final report dayahead spinning reserve
         fr_da_res_ns    final report dayahead non-spinning reserve
         fr_da_res_h     final report dayahead storage reserve
         fr_da_price_gen final report dayahead generation price
         fr_da_price_res final report dayahead reserve price
         fr_da_infes     final report dayahead infeasibilit market clearing
         fr_da_cs        final report dayahead startup cost
         fr_da_cd        final report dayahead shut down cost
         fr_da_cost      final report dayahead total cost
         fr_da_status    final report dayahead status
         fr_da_frc       final report dayahead renewable forecast

         fr_cm_delta_gen final report congestion management redispatch
         fr_cm_ren_curt  final report congestion management renewable curtailment
         fr_cm_cost      final report congestion management total cost
         fr_cm_status    final report congestion management status
         fr_cm_cs        final report congestion management startup cost
         fr_cm_cd        final report congestion management shutdown cost
         fr_cm_infes     final report congestion management infeasibility market clearing
         fr_cm_infes2    final report congestion management infeasibility market clearing
         fr_cm_price     final report congestion management price
         fr_cm_l         final report congestion management storage level
         fr_cm_w_cm      final report congestion management pumping correction
         fr_cm_v_cm      final report congestion management release correction

*        Final reports(country level)
         fr_id_price_country     final report intraday price
         fr_id_transfer          final report intraday transfer
         fr_id_price_ntc         final report intraday ntc congestion price

         fr_da_price_country     final report dayahead price
         fr_da_transfer          final report dayahead transfer
         fr_da_price_ntc         final report dayahead ntc congestion price

         fr_cm_delta_transfer    final report congestion maangement transfer (change to DA+ID)

*        Final reports(node level)
         fr_id_infes_node        final report intraday infeasibility at node
         fr_id_price_node        final report intraday nodal price
         fr_id_netin_node        final report intraday net input at node
         fr_id_lineflow          final report intraday lineflow
         fr_id_curt_node         final report intraday curtailment node
         fr_id_ren_node          final report intraday renewable bid node
         fr_id_ren_fc_node       final report intraday renewable forcast node
         fr_id_price_line_pos    final report intraday line congestion price positive
         fr_id_price_line_neg    final report intraday line congestion price negative

         fr_da_infes_node        final report dayahead infeasibility at node
         fr_da_price_node        final report dayahead nodal price
         fr_da_netin_node        final report dayahead net input at node
         fr_da_lineflow          final report dayahead lineflow
         fr_da_curt_node         final report dayahead curtailment node
         fr_da_ren_node          final report dayahead renewable bid node
         fr_da_ren_fc_node       final report dayahead renewable forcast node
         fr_da_price_line_pos    final report dayahead line congestion price positive
         fr_da_price_line_neg    final report dayahead line congestion price negative

         fr_cm_infes_node        final report congestion management infeasibility at node
         fr_cm_infes2_node       final report congestion management infeasibility at node
         fr_cm_price_node        final report congestion management nodal price
         fr_cm_netin_node        final report congestion management net input at node
         fr_cm_lineflow          final report congestion management lineflow
         fr_cm_prelineflow       final report pre congestion management lineflow
         fr_cm_curt_node         final report congestion management curtailment node
         fr_cm_price_line_pos    final report congestion management line congestion price positive
         fr_cm_price_line_neg    final report congestion management line congestion price negative
         fr_cm_hvdcflow          final report congestion management hvdcflow
         fr_cm_price_hvdc        final report congestion management hvdc line congestion price
         fr_cm_alpha             final report congestion management PST angle

*        exports
         status, generation, reserve, price, stats, renewables, emissions, fuel, costs, partload, infeasibility,
         generation_node, price_node, infeasibility_node, renewable_node, lineflow, hvdcflow, overload, nodeinput,
         price_line, price_node_diff, generation_node_tech, generation_country_tech
         price_country, price_country_diff, transfer, price_ntc
;


* Sclars related to mode horizons and timing
scalar
         tid             number of periods for the intraday model                /%t_id%/
         tda             number of periods in dayahead model                     /%t_da%/
         lag_id          time lag for intraday market clearing                   /%lag_id%/
         clr_da          hour in which dayahead market clears (ending point)     /%clr_da%/
         start_h         starting hour (ending point)                            /%start_h%/
         tautemp         gap for report writing
         pen_infes       infeasibility penalty                                   /%penalty%/
         scaler          scaling of objective                                    /%scaler%/
         trm             transmission realiability margin                        /%trm%/
         BaseMVA         Base MVA for p.u. calculations                          /500/
         cap_factor      Factor for congestionmanagement-presolve                /1/
         cluster_size    size of cluster for clustered unit commiment            /%cluster_size%/
;

*###############################################################################
*                        UPLOAD AND ASSIGN DATA
*###############################################################################

$onecho >temp.tmp
set=l            rng=AClines!A2          rdim=1 cdim=0
set=n            rng=nodes!A2            rdim=1 cdim=0
set=plj          rng=plants!A2           rdim=1 cdim=0
set=f            rng=fuels!A2            rdim=1 cdim=0
set=i            rng=technologies!A2     rdim=1 cdim=0
set=c            rng=country!A3          rdim=1 cdim=0
set=tau          rng=Demand!A4           rdim=1 cdim=0
set=hvdc         rng=DClines!B2          rdim=2 cdim=0
dset=ren         rng=Renewables!B3       rdim=0 cdim=1
set=mappln       rng=plants!D2           rdim=2 cdim=0
set=mappli       rng=plants!A2           rdim=2 cdim=0
set=mapif        rng=technologies!A2     rdim=2 cdim=0
set=mapnc        rng=nodes!E2            rdim=2 cdim=0
set=mapncgrid    rng=nodes!E2            rdim=3 cdim=0
set=maplfromto   rng=AClines!A2          rdim=3 cdim=0

par=lineup       rng=AClines!A1          rdim=1 cdim=1
par=hvdcup       rng=DClines!B2          rdim=2 cdim=0
par=ntcup1       rng=NTC!A2              rdim=1 cdim=1
par=nodeup       rng=nodes!A1            rdim=1 cdim=1
par=fuelup       rng=fuels!A1            rdim=1 cdim=1
par=techup       rng=technologies!A1     rdim=1 cdim=1
par=plantup      rng=plants!A1           rdim=1 cdim=1
par=countryup    rng=country!A1          rdim=1 cdim=2
par=demandup     rng=Demand!A2           rdim=1 cdim=2
par=renup        rng=Renewables!A2       rdim=1 cdim=3
par=CHPup        rng=CHP!A2              rdim=1 cdim=1
par=availup      rng=Availability!A2     rdim=1 cdim=2
par=taxesup      rng=Other!A1
par=exchangeup   rng=NetExport!A2        rdim=1 cdim=1
$offecho

$onUNDF
$ifi %xls_upload%=="YES" $call "gdxxrw %datadir%%data%.xls cmerge=1 @temp.tmp"
$gdxin %data%
$load l n plj f i c ren tau hvdc mappln mappli mapif mapnc mapncgrid maplfromto
$load nodeup lineup hvdcup fuelup techup taxesup countryup plantup demandup renup ntcup1 CHPup availup exchangeup
$offUNDF

*display l, n, p, f, i, co, map_pn, map_pi, map_if, lineup, nodeup, fuelup, techup, otherup, countryup, genup;

*------------------------------- NETWORK DATA ----------------------------------
cap_l(l) = trm*lineup(l,"ThermalLimit")*lineup(l,"Circuits");
hvdc(n,nn)$hvdc(nn,n) = hvdc(nn,n);
cap_hvdc(n,nn) = hvdcup(n,nn);
cap_hvdc(n,nn)$cap_hvdc(nn,n) = cap_hvdc(nn,n);
*display n,l, cap_l;

* set ntc between identical countries to infinity
ntcup(tau,c,cc) = ntcup1(c,cc);
*ntcup(tau,c,cc)$SUM(ttau, ntcup2(ttau,c,cc)) = ntcup2(tau,c,cc);
ntcup(tau,c,c) = 0;
*display ntc;

* Include the ptdf matrix
$gdxin %datadir%%ptdf%.gdx
$load ptdfup=%ptdf_par%
;

ptdf(l,n)$(cap_l(l)) = round(ptdfup(l,n),8);
psdf(l,ll) = 0;

mapngrid(n,grid) = YES$SUM(c$mapnc(n,c), mapncgrid(n,c,grid));

*option kill=ptdfup;
*display cap_l, n, l;
*------------------------------ DEMAND DATA ------------------------------------

splitdem(n) = nodeup(n,'Demand share');
splitren(n,ren) = nodeup(n,ren);

d(tau,c) = demandup(tau,c,"demand")*countryup(c,"Demand","Demand");
* if Net export is specified
*d(tau,c) = demandup(tau,c,"demand")+demandup(tau,c,"net export");

*exchangeup(tau,n) = 0;

sres_up_2(tau,c)   = demandup(tau,c,"secondary up");
sres_down_2(tau,c) = demandup(tau,c,"secondary down");
sres_up_3(tau,c)   = demandup(tau,c,"tertiary up");
sres_down_3(tau,c) = demandup(tau,c,"tertiary down");

d_res("up2",tau,c) = demandup(tau,c,"secondary up");
d_res("up3",tau,c) = demandup(tau,c,"tertiary up");
d_res("down2",tau,c) = demandup(tau,c,"secondary down");
d_res("down3",tau,c) = demandup(tau,c,"tertiary down");

*mustrun(t) = mustrun_up;
mustrun(t) = 0;

*display tau,d, ren_frc, ren_frc_init, sres_up_2, sres_down_2, sres_up_3, sres_down_3, mustrun;

*------------------------------- RENEWABLES ------------------------------------
*r('RES') = YES;

* Dayahead forecast
wind_fc_da(tau,c,ren) = renup(tau,c,ren,"Forecast")*countryup(c,"Capacity",ren);

* realization
wind_rel(tau,c,ren) = renup(tau,c,ren,"Realization")*countryup(c,"Capacity",ren);
*$stop
*---------------------------- TECHNOLOGY DATA ----------------------------------
* Construct power plant and storage sets
j(plj)$mappli(plj,"PSP") = YES;
pl(plj)$(NOT mappli(plj,"PSP")) = YES;
mapipl(i,pl) = mappli(pl,i);
mapij(i,j) = mappli(j,i);
mapfi(f,i) = mapif(i,f);

* Construct CHP set
chp(pl)$(plantup(pl,"chp") eq 1) = yes;
mrCHP_tau(tau,pl)$chp(pl) = sum(n$mappln(pl,n), sum(c$mapnc(n,c), CHPup(tau,c)));
*display chp, mrCHP_tau;

* Marginal and reserve cost
mc(i) = sum(f$mapfi(f,i), fuelup(f,"Price")/techup(i,"Average Efficiency")
        + taxesup("carbon","tax") * fuelup(f, "carbon")/techup(i,"Average Efficiency"))
        - techup(i,"subsidy");

c_curt(r) = taxesup("Curtailment","tax");
pf(f) = fuelup(f,"Price");
mc(pl) = sum(mapipl(i,pl), mc(i));

mc(pl)$plantup(pl,'Efficiency')
         = sum(i$mapipl(i,pl), sum(f$mapfi(f,i),
           sum(n$mappln(pl,n), sum(c$mapnc(n,c), countryup(c,'Fuel price',f)))*fuelup(f,"Price")/plantup(pl,"Efficiency")
           + taxesup("carbon","tax") * fuelup(f, "carbon")/plantup(pl,"Efficiency"))
           - techup(i,"subsidy"));

mc(j) =  sum(mapij(i,j), mc(i));
carb_coef(i) = sum(f$mapfi(f,i), fuelup(f, "carbon")/techup(i,"Average Efficiency"));
carb_coef(pl) = sum(mapipl(i,pl), carb_coef(i));
carb_coef(pl)$plantup(pl,'Efficiency') = sum(i$mapipl(i,pl), sum(f$mapfi(f,i), fuelup(f, "carbon")/plantup(pl,"Efficiency")));
cr(pl) = sum(mapipl(i,pl), techup(i,"reserve Cost"));
cr(j) = sum(mapij(i,j), techup(i,"reserve Cost"));

* Online offline time
offtime(pl) = sum(mapipl(i,pl),techup(i,"offtime"));
ontime(pl) = sum(mapipl(i,pl), techup(i,"ontime"));
plantime(pl) = offtime(pl);

* Capacities
cap_max(pl) = plantup(pl,"Generation capacity");
cap_min(pl) = cap_max(pl)*sum(mapipl(i,pl), techup(i,"min generation"));

* Startup cost
sc(pl) = sum(mapipl(i,pl), techup(i,"Startup Cost"))*cap_max(pl);
su(pl) = sum(mapipl(i,pl), techup(i,"Shutdown Cost"))*cap_max(pl);

* Ramping parameter
a_up(pl) = cap_max(pl)*(60*sum(mapipl(i,pl), techup(i,"ramping up")))/2;
a_down(pl) = cap_max(pl)*(60*sum(mapipl(i,pl), techup(i,"ramping down")))/2;
a_up(pl)$(a_up(pl) ge cap_max(pl) or a_up(pl) eq 0) = 0;
a_down(pl)$(a_down(pl) ge cap_max(pl) or a_down(pl) eq 0) = 0;

* Assign pump storage data
eta(j) = sum(mapij(i,j), techup(i,"Average Efficiency"));
l_max(j) = plantup(j,"Storage Capacity");
l_min(j) = 0;
v_max(j) = plantup(j,"Generation capacity");
w_max(j) = plantup(j,"Pump capacity");
l_0(j) = 0;

* construct set for binary and clustered unit commitment
$IFTHEN %uc_region%==""
set uc(c)        subset of countries with unit commitment;
uc(c) = NO;
$ELSE
set uc(c)        subset of countries with unit commitment        /%uc_region%/;
$ENDIF

plbin(pl) = YES$(SUM(uc(c), SUM(n$mappln(pl,n), mapnc(n,c))));
plclust(pl) = YES$(NOT plbin(pl));
noplants(plbin(pl)) = 1;
noplants(plclust(pl)) = round(cap_max(pl)/cluster_size,0) + 1;

* introduce a storage set
is(i)$sum(j$mapij(i,j), plantup(j,"Storage Capacity")) = yes;

* Set for reserve and mustrun contribution
plns("up3",pl)$(sum(mapipl(i,pl), techup(i,"non-spinning reserve")) and cap_max(pl)) = yes;
plns("up3",chp)$(not techup("CHP","non-spinning reserve") and cap_max(chp)) = no;

plr("up2",pl)$(sum(mapipl(i,pl), techup(i,"secondary reserve")) and cap_max(pl)) = yes;
plr("down2",pl)$(sum(mapipl(i,pl), techup(i,"secondary reserve")) and cap_max(pl)) = yes;
plr("up2",chp)$(not techup("CHP","secondary reserve") and cap_max(chp)) = no;
plr("down2",chp)$(not techup("CHP","secondary reserve") and cap_max(chp)) = no;

plr("up3",pl)$(sum(mapipl(i,pl), techup(i,"tertiary reserve")) and cap_max(pl)) = yes;
plr("down3",pl)$(sum(mapipl(i,pl), techup(i,"tertiary reserve")) and cap_max(pl)) = yes;
plr("up3",chp)$(not techup("CHP","tertiary reserve") and cap_max(chp)) = no;
plr("down3",chp)$(not techup("CHP","tertiary reserve") and cap_max(chp)) = no;

plr("up2",j)$(sum(mapij(i,j), techup(i,"secondary reserve")) and l_max(j)) = yes;
plr("down2",j)$(sum(mapij(i,j), techup(i,"secondary reserve")) and l_max(j)) = yes;

plr("up3",j)$(sum(mapij(i,j), techup(i,"tertiary reserve")) and l_max(j)) = yes;
plr("down3",j)$(sum(mapij(i,j), techup(i,"tertiary reserve")) and l_max(j)) = yes;

plmr(pl)$(sum(mapipl(i,pl), techup(i,"mustrun")) and cap_max(pl)) = yes;

* Assign availabilities (Assigment is done in prepare_files)
**avail_tau(pl,tau) = 1;
avail_tau(tau,pl)$cap_max(pl) = sum(mapipl(i,pl), techup(i,'availability'));
avail_tau(tau,pl)$(cap_max(pl) and sum(n$mappln(pl,n), sum(c$mapnc(n,c), sum(mapipl(i,pl), availup(tau,c,i))))) = sum(n$mappln(pl,n), sum(c$mapnc(n,c), sum(mapipl(i,pl), availup(tau,c,i))));
avail_tau(tau,chp(pl))$cap_max(pl) = max(mrCHP_tau(tau,pl), avail_tau(tau,pl));

*display t, availup, avail_tau;
*display cr;
*display plns, plr2, plr3, techup, plmr;
*display mc, sc, su, cr, offtime, ontime, cap_max, cap_min, a_up, a_down,  plns;

*display eta, l_max, w_max, v_max, pumpup;
*display avail_tau;
*----------------- INITIALIZE INITIAL AND REPORT VARIABLES ---------------------
* Initial parameters
on_hist(pl) = 0;
gen_hist(pl) = 0;
gen_bar(pl,t) = 0;
v_bar(j,t) = 0;
w_bar(j,t) = 0;
res_s_up_bar(pl,t) = 0;
res_s_down_bar(pl,t) = 0;
res_h_up_bar(j,t) = 0;
res_h_down_bar(j,t) = 0;
shed_wind_bar(r,t) = 0;
wind_frc_bar(c,t) = 0;
wind_fc(c,r,t) = 0;
dem(t,c) = 0;
bid_wind_da_bar(r,t) = 0;
wind_curt_bar(r,n,t) = 0;
avail(pl,t) = 0;

* Intemediate report variables
ir_status_id(pl,t) = 0;
ir_gen_id(pl,t) = 0;
ir_level_id(j,t) = 0;
ir_time_off(pl) = 0;
ir_time_on(pl) = 0;
ir_status_cm(pl,t) = 0;
ir_delta_gen_cm(pl,t) = 0;
ir_level_cm(j,t) = 0;
up_hist_clust(pl,t) = 0;
dn_hist_clust(pl,t) = 0;
ir_time_on_clust(pl,t) = 0;
ir_time_off_clust(pl,t) = 0;

* Initialize import parameter
* DAYAHEAD
*                Generation, curtailment and reserve
                 fr_da_gen(pl,tau) = 0;
                 fr_da_w(j,tau) = 0;
                 fr_da_v(j,tau) = 0;
                 fr_da_l(j,tau) = 0;
                 fr_da_ren(r,tau) = 0;
                 fr_da_curt(r,tau) = 0;
                 fr_da_res_s(res,pl,tau) = 0;
                 fr_da_res_ns(pl,tau) = 0;
                 fr_da_res_h(res,j,tau) = 0;

*                Prices
                 fr_da_price_gen(tau) = 0;
                 fr_da_price_res(res,tau) = 0;

*                Infeasibility and cost
                 fr_da_infes(tau) = 0;
                 fr_da_cs(pl,tau) = 0;
                 fr_da_cd(pl,tau) = 0;
                 fr_da_status(pl,tau) =  0;
                 fr_da_frc(c,r,tau) = 0;

*                Country level reports
                 fr_da_price_country(c,tau) = 0;
                 fr_da_transfer(c,cc,tau) = 0;
                 fr_da_price_ntc(c,cc,tau) = 0;

*                Node level reports
                 fr_da_infes_node(n,tau) = 0;
*                 fr_da_price_node(n,tau) = 0;
*                 fr_da_netin_node(n,tau) = 0;
*                 fr_da_lineflow(l,tau)   = 0;
                 fr_da_curt_node(r,n,tau)  = 0;
                 fr_da_ren_node(r,n,tau)   = 0;
                 fr_da_ren_fc_node(r,n,tau) = 0;
*                 fr_da_price_line_pos(l,tau) = 0;
*                 fr_da_price_line_neg(l,tau) = 0;

* INTRADAY
*                Generation
                  fr_id_gen_to(pl,tau) = 0;
                  fr_id_ren_to(r,tau) = 0;
                  fr_id_w_to(j,tau) = 0;
                  fr_id_v_to(j,tau) = 0;
                  fr_id_l(j,tau) = 0;

*                Intraday corrections
                  fr_id_gen_id(pl,tau) = 0;
                  fr_id_ren_id(r,tau) = 0;
                  fr_id_w_id(j,tau) = 0;
                  fr_id_v_id(j,tau) = 0;

*                status, infeasibilities, cost, price
                  fr_id_status(pl,tau) = 0;
                  fr_id_cs(pl,tau) = 0;
                  fr_id_cd(pl,tau) = 0;
                  fr_id_cost(tau) = 0;
                  fr_id_infes(tau) = 0;
                  fr_id_price(tau) = 0;
                  fr_id_frc(r,tau) = 0;

*                country level report
                  fr_id_price_country(c,tau) = 0;
                  fr_id_transfer(c,cc,tau) = 0;
                  fr_id_price_ntc(c,cc,tau) = 0;

*                node level report
                  fr_id_infes_node(n,tau) = 0;
*                  fr_id_price_node(n,tau) = 0;
*                  fr_id_netin_node(n,tau) = 0;
*                  fr_id_lineflow(l,tau) = 0;
                  fr_id_curt_node(r,n,tau) = 0;
                  fr_id_ren_node(r,n,tau) = 0;
                  fr_id_ren_fc_node(r,n,tau) = 0;
*                  fr_id_price_line_pos(l,tau) =  0;
*                  fr_id_price_line_neg(l,tau) =  0;

* CONGESTION MANAGEMENT
*                Redispatch
                  fr_cm_delta_gen(pl,tau) = 0;
                  fr_cm_ren_curt(r,tau) = 0;
                  fr_cm_l(j,tau) = 0;
                  fr_cm_w_cm(j,tau) = 0;
                  fr_cm_v_cm(j,tau) = 0;

*                status, infeasibilities, cost, price
                  fr_cm_status(pl,tau) = 0;
                  fr_cm_cs(pl,tau) = 0;
                  fr_cm_cd(pl,tau) = 0;
                  fr_cm_cost(tau) = 0;
                  fr_cm_infes(tau) = 0;
                  fr_cm_infes2(tau) = 0;
                  fr_cm_price(tau) = 0;

*                node level report
                  fr_cm_infes_node(n,tau) = 0;
                  fr_cm_price_node(n,tau) = 0;
                  fr_cm_netin_node(n,tau) = 0;
                  fr_cm_lineflow(l,tau) = 0;
                  fr_cm_prelineflow(l,tau) = 0;
                  fr_cm_curt_node(r,n,tau) = 0;
                  fr_cm_price_line_pos(l,tau) =  0;
                  fr_cm_price_line_neg(l,tau) =  0;
                  fr_cm_infes2_node(n,tau) = 0;
                  fr_cm_hvdcflow(hvdc(n,nn),tau) = 0;
                  fr_cm_price_hvdc(hvdc(n,nn),tau) = 0;
                  fr_cm_alpha(l,tau) = 0;

*-------------------- MAPPING SIMULATION TIME TO HOURS AND DAYS --------------------
* Mapping from simulation periods to days and hours
* Establish mapping from model period to hours and days
mday(tau,day)$(ord(tau) - 1 gt (ord(day)-1)*24 - start_h and ord(tau) + start_h - 1 le ord(day)*24) = yes;
loop(day,
         loop(tau$mday(tau,day),
                 mh(tau,hour)$(ord(tau) + start_h - 1 - 24*(ord(day)-1) eq ord(hour)) = yes;
         );
);
*display mday, mh;

